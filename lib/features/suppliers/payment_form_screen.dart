import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/suppliers_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Record a payment to a supplier (SUP-5). Without an invoice it is spread
/// over what is owed, oldest due first; paying more than is owed offers to
/// keep the extra as a credit.
class PaymentFormScreen extends ConsumerStatefulWidget {
  const PaymentFormScreen({
    required this.supplierId,
    this.invoiceId,
    super.key,
  });

  final String supplierId;

  /// Pre-selects one invoice and fills in what it still owes.
  final String? invoiceId;

  @override
  ConsumerState<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  late DateTime _paidOn;
  PaymentMethod _method = PaymentMethod.cash;
  // Null = oldest due first.
  String? _invoiceId;
  bool _saving = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _paidOn = ref.read(todayDateProvider);
    _invoiceId = widget.invoiceId;
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  static String _plain(Money m) =>
      '${m.minor ~/ 100}.${(m.minor % 100).toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final today = ref.read(todayDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: _paidOn,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (picked != null) setState(() => _paidOn = picked);
  }

  Future<void> _save({bool creditExcess = false}) async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate() || _saving) return;
    final amount = Money.tryParse(_amount.text)!;
    setState(() => _saving = true);
    try {
      final made = await ref
          .read(recordPaymentProvider)
          .call(
            supplierId: widget.supplierId,
            amount: amount,
            paidOn: _paidOn,
            invoiceId: _invoiceId,
            method: _method,
            reference: _reference.text,
            creditExcess: creditExcess,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            made.length > 1
                ? '${l10n.paymentSaved}. ${l10n.paymentSpread(made.length)}'
                : l10n.paymentSaved,
          ),
        ),
      );
      context.pop(true);
    } on OverpaymentException catch (e) {
      // Free the form first: agreeing re-submits it with the excess as credit.
      if (mounted) setState(() => _saving = false);
      if (mounted) await _askAboutExcess(amount, e);
    } on ValidationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _askAboutExcess(Money entered, OverpaymentException e) async {
    final l10n = AppLocalizations.of(context);
    final currency = ref.read(currencySymbolProvider);
    final record = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.paymentOverTitle),
        content: Text(
          l10n.paymentOverBody(
            entered.format(symbol: currency),
            e.owed.format(symbol: currency),
            e.excess.format(symbol: currency),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const Key('pay-with-credit'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.paymentOverCredit),
          ),
        ],
      ),
    );
    if (record ?? false) await _save(creditExcess: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = ref.watch(currencySymbolProvider);
    final invoices =
        ref.watch(supplierInvoicesProvider(widget.supplierId)).value ??
        const [];
    final open = [
      for (final b in invoices)
        if (!b.isSettled) b,
    ];
    final selected = open.where((b) => b.invoice.id == _invoiceId).firstOrNull;

    // Suggest the full balance of a pre-selected invoice, once.
    if (!_prefilled && selected != null && widget.invoiceId != null) {
      _prefilled = true;
      _amount.text = _plain(selected.balance);
    }

    String invoiceLabel(InvoiceBalance b) {
      final inv = b.invoice;
      final name = inv.invoiceNumber == null
          ? l10n.invoiceNoNumber(formatDate(context, inv.invoiceDate))
          : l10n.invoiceNumberLabel(inv.invoiceNumber!);
      return '$name · ${b.balance.format(symbol: currency)}';
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('field-payment-amount'),
              controller: _amount,
              autofocus: widget.invoiceId == null,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.fieldPaymentAmount,
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                final m = Money.tryParse(v ?? '');
                return m == null || m.minor <= 0 ? l10n.errAmountInvalid : null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              // Rebuilt when the open invoices load or change; an invoice that
              // is no longer open cannot stay selected.
              key: ValueKey('apply-${selected?.invoice.id}-${open.length}'),
              initialValue: selected?.invoice.id,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.fieldPaymentApplyTo,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem<String?>(child: Text(l10n.paymentOldestFirst)),
                for (final b in open)
                  DropdownMenuItem<String?>(
                    value: b.invoice.id,
                    child: Text(
                      invoiceLabel(b),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _invoiceId = v),
            ),
            const SizedBox(height: 12),
            InkWell(
              key: const Key('field-payment-date'),
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.fieldPaymentDate,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                child: Text(formatDate(context, _paidOn)),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final m in PaymentMethod.values)
                  ChoiceChip(
                    key: Key('method-${m.name}'),
                    label: Text(paymentMethodLabel(l10n, m)),
                    selected: _method == m,
                    onSelected: (_) => setState(() => _method = m),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('field-payment-reference'),
              controller: _reference,
              decoration: InputDecoration(
                labelText: l10n.fieldPaymentReference,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('payment-save'),
              onPressed: _saving ? null : _save,
              child: Text(l10n.actionSave),
            ),
          ],
        ),
      ),
    );
  }
}
