import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier_return.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/credit_dialog.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/ledger_widgets.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/return_screen.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/statement_action.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/suppliers_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// A supplier's contact details, what is owed, and the ledger of invoices,
/// payments and credits (SUP-3).
class SupplierDetailScreen extends ConsumerWidget {
  const SupplierDetailScreen({required this.supplierId, super.key});

  final String supplierId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currency = ref.watch(currencySymbolProvider);
    final summary = ref.watch(supplierSummaryProvider(supplierId)).value;
    final invoices =
        ref.watch(supplierInvoicesProvider(supplierId)).value ?? const [];
    final payments =
        ref.watch(supplierPaymentsProvider(supplierId)).value ?? const [];
    final credits =
        ref.watch(supplierCreditsProvider(supplierId)).value ?? const [];
    final returns =
        ref.watch(supplierReturnsProvider(supplierId)).value ?? const [];
    final s = summary?.supplier;
    final launcher = ref.watch(contactLauncherProvider);

    Widget contact(
      String key,
      IconData icon,
      String label,
      bool Function() show,
      Future<bool> Function() open,
      String value,
    ) {
      return ActionChip(
        key: Key(key),
        avatar: Icon(icon, size: 18),
        label: Text(label),
        onPressed: () => reachSupplier(context, ref, open: open, value: value),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(s?.name ?? ''),
        actions: [
          if (s != null)
            IconButton(
              key: const Key('supplier-edit'),
              tooltip: l10n.actionEdit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.push('${Routes.suppliers}/$supplierId/edit'),
            ),
        ],
      ),
      body: summary == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (s!.contactPerson != null)
                        Text(
                          s.contactPerson!,
                          style: theme.textTheme.titleMedium,
                        ),
                      if (s.phone != null) Text(s.phone!),
                      if (s.email != null) Text(s.email!),
                      if (s.address != null) Text(s.address!),
                      if (s.isArchived)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Chip(
                            avatar: const Icon(
                              Icons.archive_outlined,
                              size: 18,
                            ),
                            label: Text(l10n.archivedBadge),
                          ),
                        ),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (s.phone != null) ...[
                            contact(
                              'contact-call',
                              Icons.call_outlined,
                              l10n.contactCall,
                              () => true,
                              () => launcher.call(s.phone!),
                              s.phone!,
                            ),
                            contact(
                              'contact-sms',
                              Icons.sms_outlined,
                              l10n.contactSms,
                              () => true,
                              () => launcher.sms(s.phone!),
                              s.phone!,
                            ),
                            contact(
                              'contact-whatsapp',
                              Icons.chat_outlined,
                              l10n.contactWhatsapp,
                              () => true,
                              () => launcher.whatsapp(s.phone!),
                              s.phone!,
                            ),
                          ],
                          if (s.email != null)
                            contact(
                              'contact-email',
                              Icons.mail_outline,
                              l10n.contactEmail,
                              () => true,
                              () => launcher.email(s.email!),
                              s.email!,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        _Stat(
                          label: l10n.duesOwed,
                          value: summary.outstanding.format(symbol: currency),
                          valueKey: const Key('supplier-owed'),
                        ),
                        _Stat(
                          label: l10n.duesOverdue,
                          value: summary.overdue.format(symbol: currency),
                          valueKey: const Key('supplier-overdue'),
                          color: summary.hasOverdue
                              ? theme.colorScheme.error
                              : null,
                        ),
                        _Stat(
                          label: l10n.duesNextDue,
                          value: summary.nextDue == null
                              ? l10n.duesNone
                              : formatDate(context, summary.nextDue!),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (!s.isArchived)
                        FilledButton.icon(
                          key: const Key('add-invoice'),
                          onPressed: () => context.push(
                            '${Routes.suppliers}/$supplierId/invoice/new',
                          ),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.actionAddInvoice),
                        ),
                      OutlinedButton.icon(
                        key: const Key('record-payment'),
                        onPressed: () =>
                            context.push('${Routes.suppliers}/$supplierId/pay'),
                        icon: const Icon(Icons.payments_outlined),
                        label: Text(l10n.actionRecordPayment),
                      ),
                      OutlinedButton.icon(
                        key: const Key('supplier-statement'),
                        onPressed: () => unawaited(
                          shareSupplierStatement(
                            context,
                            ref,
                            supplierId: supplierId,
                          ),
                        ),
                        icon: const Icon(Icons.description_outlined),
                        label: Text(l10n.statementAction),
                      ),
                      OutlinedButton.icon(
                        key: const Key('return-stock'),
                        onPressed: () => context.push(
                          Routes.supplierReturn,
                          extra: ReturnArgs(supplierId: supplierId),
                        ),
                        icon: const Icon(Icons.assignment_return_outlined),
                        label: Text(l10n.returnAction),
                      ),
                      OutlinedButton.icon(
                        key: const Key('record-credit'),
                        onPressed: () =>
                            showCreditDialog(context, supplierId: supplierId),
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: Text(l10n.actionRecordCredit),
                      ),
                    ],
                  ),
                ),
                _Header(l10n.ledgerInvoices),
                if (invoices.isEmpty)
                  _Empty(l10n.ledgerNoInvoices)
                else
                  for (final b in invoices) InvoiceTile(balance: b),
                _Header(l10n.ledgerPayments),
                if (payments.isEmpty)
                  _Empty(l10n.ledgerNoPayments)
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
                _Header(l10n.returnListTitle),
                if (returns.isEmpty)
                  _Empty(l10n.returnListEmpty)
                else
                  for (final r in returns)
                    _ReturnTile(view: r, currency: currency),
                _Header(l10n.ledgerCredits),
                if (credits.isEmpty)
                  _Empty(l10n.ledgerNoCredits)
                else
                  for (final c in credits)
                    CreditTile(
                      credit: c,
                      onDelete: () async {
                        final ok = await confirm(
                          context,
                          title: l10n.paymentDelete,
                          action: l10n.actionDelete,
                          actionKey: const Key('confirm-delete'),
                        );
                        if (ok) {
                          await ref.read(deleteCreditProvider).call(c.id);
                        }
                      },
                    ),
              ],
            ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.valueKey,
    this.color,
  });

  final String label;
  final String value;
  final Key? valueKey;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          Text(
            value,
            key: valueKey,
            style: theme.textTheme.titleMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
    child: Text(text, style: Theme.of(context).textTheme.bodySmall),
  );
}

class _ReturnTile extends ConsumerWidget {
  const _ReturnTile({required this.view, required this.currency});

  final ReturnView view;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final qty = view.lines.fold<int>(0, (a, l) => a + l.quantity);
    return ListTile(
      key: Key('return-${view.id}'),
      leading: const Icon(Icons.assignment_return_outlined),
      title: Text(
        '${formatDate(context, view.returnedOn)} · '
        '${l10n.returnTileQty(qty)}',
      ),
      subtitle: Text(
        [
          view.lines.map((l) => l.medicineName).toSet().join(', '),
          if (view.credit != null)
            l10n.returnCreditText(view.credit!.format(symbol: currency)),
        ].join(' · '),
      ),
      trailing: IconButton(
        key: Key('return-share-${view.id}'),
        tooltip: l10n.returnShare,
        icon: const Icon(Icons.ios_share),
        onPressed: () => unawaited(shareReturn(ref, l10n, view.id, context)),
      ),
    );
  }
}
