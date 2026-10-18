import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/invoice_status_chip.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// One row in a supplier's invoice list.
class InvoiceTile extends ConsumerWidget {
  const InvoiceTile({required this.balance, super.key});

  final InvoiceBalance balance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currency = ref.watch(currencySymbolProvider);
    final inv = balance.invoice;
    return ListTile(
      key: Key('invoice-${inv.id}'),
      title: Text(
        inv.invoiceNumber == null
            ? l10n.invoiceNoNumber(formatDate(context, inv.invoiceDate))
            : l10n.invoiceNumberLabel(inv.invoiceNumber!),
      ),
      subtitle: Text(
        [
          if (inv.dueDate != null)
            l10n.invoiceDueIn(formatDate(context, inv.dueDate!)),
          '${l10n.invoiceTotalLabel} ${inv.total.format(symbol: currency)}',
        ].join(' · '),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InvoiceStatusChip(status: balance.status),
          if (!balance.isSettled)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                balance.balance.format(symbol: currency),
                key: Key('invoice-balance-${inv.id}'),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
        ],
      ),
      onTap: () => context.push(
        '${Routes.suppliers}/${inv.supplierId}/invoice/${inv.id}',
      ),
    );
  }
}

class PaymentTile extends ConsumerWidget {
  const PaymentTile({required this.payment, required this.onDelete, super.key});

  final Payment payment;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currency = ref.watch(currencySymbolProvider);
    final detail = [
      if (payment.method != null) paymentMethodLabel(l10n, payment.method!),
      if (payment.reference != null) payment.reference!,
    ].join(' · ');
    return ListTile(
      key: Key('payment-${payment.id}'),
      leading: const Icon(Icons.payments_outlined),
      title: Text(
        l10n.paymentLine(
          payment.amount.format(symbol: currency),
          formatDate(context, payment.paidOn),
        ),
      ),
      subtitle: detail.isEmpty ? null : Text(detail),
      trailing: IconButton(
        key: Key('delete-payment-${payment.id}'),
        tooltip: l10n.actionDelete,
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}

class CreditTile extends ConsumerWidget {
  const CreditTile({required this.credit, required this.onDelete, super.key});

  final Credit credit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currency = ref.watch(currencySymbolProvider);
    return ListTile(
      key: Key('credit-${credit.id}'),
      leading: const Icon(Icons.receipt_long_outlined),
      title: Text(
        l10n.paymentLine(
          credit.amount.format(symbol: currency),
          formatDate(context, credit.issuedOn),
        ),
      ),
      subtitle: Text(
        [
          if (credit.invoiceId == null) l10n.creditGeneral,
          if (credit.note != null) credit.note!,
        ].join(' · '),
      ),
      trailing: IconButton(
        key: Key('delete-credit-${credit.id}'),
        tooltip: l10n.actionDelete,
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String action,
  String? body,
  Key? actionKey,
}) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: body == null ? null : Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: actionKey ?? const Key('confirm-yes'),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(action),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Asks how long to silence an invoice's payment reminders (S4-13).
Future<DateTime?> askReminderSnooze(
  BuildContext context,
  WidgetRef ref, {
  DateTime? dueDate,
}) {
  final l10n = AppLocalizations.of(context);
  final today = ref.read(todayDateProvider);
  DateTime inDays(int n) => DateTime(today.year, today.month, today.day + n);
  return showDialog<DateTime>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text(l10n.snoozeRemindersTitle),
      children: [
        SimpleDialogOption(
          key: const Key('rsnooze-1d'),
          onPressed: () => Navigator.pop(ctx, inDays(1)),
          child: Text(l10n.snooze1d),
        ),
        SimpleDialogOption(
          key: const Key('rsnooze-3d'),
          onPressed: () => Navigator.pop(ctx, inDays(3)),
          child: Text(l10n.snooze3d),
        ),
        SimpleDialogOption(
          key: const Key('rsnooze-1w'),
          onPressed: () => Navigator.pop(ctx, inDays(7)),
          child: Text(l10n.snooze1w),
        ),
        if (dueDate != null && dueDate.isAfter(today))
          SimpleDialogOption(
            key: const Key('rsnooze-due'),
            onPressed: () => Navigator.pop(ctx, dueDate),
            child: Text(l10n.snoozeNext(formatDate(ctx, dueDate))),
          ),
      ],
    ),
  );
}

/// Calls, messages or mails a supplier; if no app can, says so and offers to
/// copy the number or address instead (SUP-2).
Future<void> reachSupplier(
  BuildContext context,
  WidgetRef ref, {
  required Future<bool> Function() open,
  required String value,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final ok = await open();
  if (ok) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.contactFailed),
        action: SnackBarAction(
          key: const Key('contact-copy'),
          label: l10n.contactCopyAction,
          onPressed: () {
            unawaited(Clipboard.setData(ClipboardData(text: value)));
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(l10n.contactCopied)));
          },
        ),
      ),
    );
}
