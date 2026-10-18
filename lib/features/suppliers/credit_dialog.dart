import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Records a credit note, on an invoice or on the account in general.
/// Completes with true if one was recorded.
Future<bool?> showCreditDialog(
  BuildContext context, {
  required String supplierId,
  String? invoiceId,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _CreditDialog(supplierId: supplierId, invoiceId: invoiceId),
  );
}

class _CreditDialog extends ConsumerStatefulWidget {
  const _CreditDialog({required this.supplierId, this.invoiceId});

  final String supplierId;
  final String? invoiceId;

  @override
  ConsumerState<_CreditDialog> createState() => _CreditDialogState();
}

class _CreditDialogState extends ConsumerState<_CreditDialog> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final currency = ref.read(currencySymbolProvider);
    final amount = Money.tryParse(_amount.text);
    if (amount == null || amount.minor <= 0) {
      setState(() => _error = l10n.errAmountInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(recordCreditProvider)
          .call(
            supplierId: widget.supplierId,
            amount: amount,
            issuedOn: ref.read(todayDateProvider),
            invoiceId: widget.invoiceId,
            note: _note.text,
          );
      if (mounted) Navigator.pop(context, true);
    } on OverpaymentException catch (e) {
      setState(
        () => _error = l10n.creditTooMuch(e.owed.format(symbol: currency)),
      );
    } on ValidationException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.creditTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('credit-amount'),
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.fieldCreditAmount,
              errorText: _error,
              errorMaxLines: 3,
            ),
          ),
          TextField(
            key: const Key('credit-note'),
            controller: _note,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.fieldCreditNote),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const Key('credit-save'),
          onPressed: _busy ? null : _save,
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}
