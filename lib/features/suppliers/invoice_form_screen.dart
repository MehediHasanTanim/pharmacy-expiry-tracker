import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/invoice_rules.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// What the invoice form starts from when opened for a delivery.
class InvoiceFormArgs {
  const InvoiceFormArgs({this.batchIds = const [], this.suggestedTotal});

  /// Batches this invoice pays for.
  final List<String> batchIds;

  /// Total worked out from the batches' cost prices, if known.
  final Money? suggestedTotal;
}

/// Add ([invoiceId] null) or edit an invoice (SUP-4). The due date follows the
/// supplier's payment terms until the user sets or clears it.
class InvoiceFormScreen extends ConsumerStatefulWidget {
  const InvoiceFormScreen({
    required this.supplierId,
    this.invoiceId,
    this.args = const InvoiceFormArgs(),
    super.key,
  });

  final String supplierId;
  final String? invoiceId;
  final InvoiceFormArgs args;

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _total = TextEditingController();
  final _notes = TextEditingController();
  late DateTime _invoiceDate;
  DateTime? _dueDate;
  // While true the due date is derived from the payment terms.
  bool _autoDue = false;
  int? _terms;
  bool _loading = true;
  bool _saving = false;

  bool get _isEdit => widget.invoiceId != null;

  @override
  void initState() {
    super.initState();
    _invoiceDate = ref.read(todayDateProvider);
    unawaited(_load());
  }

  Future<void> _load() async {
    final supplier = await ref
        .read(supplierRepositoryProvider)
        .getById(widget.supplierId);
    _terms = supplier?.paymentTermsDays;
    if (_isEdit) {
      final b = await ref
          .read(ledgerRepositoryProvider)
          .getInvoiceBalance(
            widget.invoiceId!,
            today: ref.read(todayDateProvider),
          );
      if (b != null) {
        _number.text = b.invoice.invoiceNumber ?? '';
        _total.text = _plain(b.invoice.total);
        _notes.text = b.invoice.notes ?? '';
        _invoiceDate = b.invoice.invoiceDate;
        _dueDate = b.invoice.dueDate;
      }
    } else {
      final suggested = widget.args.suggestedTotal;
      if (suggested != null) _total.text = _plain(suggested);
      _dueDate = defaultDueDate(_invoiceDate, _terms);
      _autoDue = _terms != null;
    }
    if (mounted) setState(() => _loading = false);
  }

  static String _plain(Money m) =>
      '${m.minor ~/ 100}.${(m.minor % 100).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _number.dispose();
    _total.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime initial, DateTime first, DateTime last) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
  }

  Future<void> _pickInvoiceDate() async {
    final today = ref.read(todayDateProvider);
    final picked = await _pick(
      _invoiceDate,
      DateTime(2000),
      DateTime(today.year + 1),
    );
    if (picked == null) return;
    setState(() {
      _invoiceDate = picked;
      if (_autoDue) _dueDate = defaultDueDate(picked, _terms);
    });
  }

  Future<void> _pickDueDate() async {
    final picked = await _pick(
      _dueDate ?? _invoiceDate,
      DateTime(2000),
      DateTime(_invoiceDate.year + 5),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _autoDue = false;
      });
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate() || _saving) return;
    if (_dueDate != null && _dueDate!.isBefore(_invoiceDate)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.errDueBeforeInvoice)));
      return;
    }
    final total = Money.tryParse(_total.text)!;
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await ref
            .read(editInvoiceProvider)
            .call(
              widget.invoiceId!,
              invoiceDate: _invoiceDate,
              total: total,
              dueDate: _dueDate,
              invoiceNumber: _number.text,
              notes: _notes.text,
            );
        if (mounted) context.pop(widget.invoiceId);
      } else {
        final inv = await ref
            .read(addInvoiceProvider)
            .call(
              InvoiceInput(
                supplierId: widget.supplierId,
                invoiceNumber: _number.text,
                invoiceDate: _invoiceDate,
                dueDate: _dueDate,
                total: total,
                notes: _notes.text,
                batchIds: widget.args.batchIds,
              ),
              // The form already applied (or deliberately dropped) the terms.
              defaultDueFromTerms: false,
            );
        if (mounted) context.pop(inv.id);
      }
    } on ValidationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? l10n.invoiceEdit : l10n.invoiceNew)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (widget.args.batchIds.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            l10n.invoiceBatchesLinked(
                              widget.args.batchIds.length,
                            ),
                            key: const Key('invoice-linked'),
                          ),
                        ],
                      ),
                    ),
                  TextFormField(
                    key: const Key('field-invoice-number'),
                    controller: _number,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.fieldInvoiceNumber,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('field-invoice-total'),
                    controller: _total,
                    autofocus: !_isEdit,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.fieldInvoiceTotal,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final m = Money.tryParse(v ?? '');
                      return m == null || m.minor <= 0
                          ? l10n.errAmountInvalid
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    key: const Key('field-invoice-date'),
                    onTap: _pickInvoiceDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.fieldInvoiceDate,
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(formatDate(context, _invoiceDate)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    key: const Key('field-due-date'),
                    onTap: _pickDueDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.fieldDueDate,
                        helperText: _autoDue ? l10n.invoiceDueFromTerms : null,
                        border: const OutlineInputBorder(),
                        suffixIcon: _dueDate == null
                            ? const Icon(Icons.calendar_today_outlined)
                            : IconButton(
                                key: const Key('clear-due'),
                                tooltip: l10n.clearDueDate,
                                icon: const Icon(Icons.close),
                                onPressed: () => setState(() {
                                  _dueDate = null;
                                  _autoDue = false;
                                }),
                              ),
                      ),
                      child: Text(
                        _dueDate == null
                            ? l10n.noDueDate
                            : formatDate(context, _dueDate!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('field-invoice-notes'),
                    controller: _notes,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l10n.fieldInvoiceNotes,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('invoice-save'),
                    onPressed: _saving ? null : _save,
                    child: Text(l10n.actionSave),
                  ),
                ],
              ),
            ),
    );
  }
}
