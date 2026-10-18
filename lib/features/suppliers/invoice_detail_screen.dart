import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/credit_dialog.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/invoice_status_chip.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/ledger_widgets.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/suppliers_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

final _linkedBatchesProvider = FutureProvider.autoDispose.family<int, String>((
  ref,
  invoiceId,
) {
  ref.watch(dataChangesProvider);
  return ref.watch(batchRepositoryProvider).countLinkedBatches(invoiceId);
});

class InvoiceDetailScreen extends ConsumerWidget {
  const InvoiceDetailScreen({
    required this.supplierId,
    required this.invoiceId,
    super.key,
  });

  final String supplierId;
  final String invoiceId;

  Future<void> _snooze(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final b = ref.read(invoiceBalanceProvider(invoiceId)).value;
    final until = await askReminderSnooze(
      context,
      ref,
      dueDate: b?.invoice.dueDate,
    );
    if (until == null || !context.mounted) return;
    final svc = ref.read(reminderSnoozeProvider);
    final previous = await svc.snooze(invoiceId, until);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.snackReminderSnoozed(formatDate(context, until))),
          action: SnackBarAction(
            key: const Key('snack-undo'),
            label: l10n.snackUndo,
            onPressed: () => unawaited(svc.restore(invoiceId, previous)),
          ),
        ),
      );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirm(
      context,
      title: l10n.invoiceDeleteTitle,
      body: l10n.invoiceDeleteBody,
      action: l10n.actionDelete,
      actionKey: const Key('confirm-delete'),
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(deleteInvoiceProvider).call(invoiceId);
      if (context.mounted) context.pop();
    } on InvoiceHasPaymentsException {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.invoiceHasPayments)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currency = ref.watch(currencySymbolProvider);
    final b = ref.watch(invoiceBalanceProvider(invoiceId)).value;
    final payments =
        ref.watch(invoicePaymentsProvider(invoiceId)).value ?? const [];
    final linked = ref.watch(_linkedBatchesProvider(invoiceId)).value ?? 0;

    Widget row(String label, String value, {Key? key, Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            key: key,
            style: theme.textTheme.titleSmall?.copyWith(color: color),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          b == null
              ? l10n.invoiceDetailTitle
              : (b.invoice.invoiceNumber == null
                    ? l10n.invoiceDetailTitle
                    : l10n.invoiceNumberLabel(b.invoice.invoiceNumber!)),
        ),
        actions: [
          if (b != null) ...[
            IconButton(
              key: const Key('invoice-edit'),
              tooltip: l10n.actionEdit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(
                '${Routes.suppliers}/$supplierId/invoice/$invoiceId/edit',
              ),
            ),
            IconButton(
              key: const Key('invoice-delete'),
              tooltip: l10n.actionDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref),
            ),
          ],
        ],
      ),
      body: b == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    InvoiceStatusChip(status: b.status),
                    const SizedBox(width: 12),
                    Text(l10n.invoiceBatchesLinked(linked)),
                  ],
                ),
                const SizedBox(height: 16),
                row(
                  l10n.invoiceDateLabel,
                  formatDate(context, b.invoice.invoiceDate),
                ),
                if (b.invoice.dueDate != null)
                  row(
                    l10n.invoiceDueLabel,
                    formatDate(context, b.invoice.dueDate!),
                  ),
                row(
                  l10n.invoiceTotalLabel,
                  b.invoice.total.format(symbol: currency),
                ),
                row(l10n.invoicePaidLabel, b.paid.format(symbol: currency)),
                if (b.credited.minor > 0)
                  row(
                    l10n.invoiceCreditedLabel,
                    b.credited.format(symbol: currency),
                  ),
                row(
                  l10n.invoiceBalanceLabel,
                  b.balance.format(symbol: currency),
                  key: const Key('invoice-balance'),
                  color: b.status == InvoiceStatus.overdue
                      ? theme.colorScheme.error
                      : null,
                ),
                if (b.invoice.remindersSnoozedUntil != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_paused_outlined,
                          size: 16,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.rowSnoozed(
                            formatDate(
                              context,
                              b.invoice.remindersSnoozedUntil!,
                            ),
                          ),
                          key: const Key('reminder-snoozed'),
                        ),
                      ],
                    ),
                  ),
                if (b.invoice.notes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(b.invoice.notes!),
                  ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (!b.isSettled) ...[
                      FilledButton.icon(
                        key: const Key('invoice-pay'),
                        onPressed: () => context.push(
                          '${Routes.suppliers}/$supplierId/pay?invoice=$invoiceId',
                        ),
                        icon: const Icon(Icons.payments_outlined),
                        label: Text(l10n.actionRecordPayment),
                      ),
                      OutlinedButton.icon(
                        key: const Key('invoice-credit'),
                        onPressed: () => showCreditDialog(
                          context,
                          supplierId: supplierId,
                          invoiceId: invoiceId,
                        ),
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: Text(l10n.actionRecordCredit),
                      ),
                      if (b.invoice.dueDate != null &&
                          b.invoice.remindersSnoozedUntil == null)
                        OutlinedButton.icon(
                          key: const Key('invoice-snooze'),
                          onPressed: () => _snooze(context, ref),
                          icon: const Icon(Icons.snooze),
                          label: Text(l10n.actionSnoozeReminders),
                        ),
                      if (b.invoice.dueDate != null &&
                          b.invoice.remindersSnoozedUntil != null)
                        OutlinedButton.icon(
                          key: const Key('invoice-resume'),
                          onPressed: () async {
                            await ref
                                .read(reminderSnoozeProvider)
                                .clear(invoiceId);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.snackReminderResumed),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.notifications_active_outlined),
                          label: Text(l10n.actionClearSnooze),
                        ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Text(l10n.ledgerPayments, style: theme.textTheme.titleMedium),
                if (payments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(l10n.ledgerNoPayments),
                  )
                else
                  for (final p in payments)
                    PaymentTile(
                      payment: p,
                      onDelete: () async {
                        final ok = await confirm(
                          context,
                          title: l10n.paymentDelete,
                          action: l10n.actionDelete,
                          actionKey: const Key('confirm-delete'),
                        );
                        if (ok) {
                          await ref.read(deletePaymentProvider).call(p.id);
                        }
                      },
                    ),
              ],
            ),
    );
  }
}
