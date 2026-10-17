import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/features/common/expiry_chip.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/stock/adjust_stock_sheet.dart';
import 'package:pharmacy_expiry_tracker/features/stock/stock_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

class BatchDetailScreen extends ConsumerWidget {
  const BatchDetailScreen({required this.batchId, super.key});

  final String batchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final batch = ref.watch(batchProvider(batchId));
    final b = batch.value;
    final medicine = b == null
        ? null
        : ref.watch(medicineProvider(b.medicineId)).value;
    final history = ref.watch(adjustmentsProvider(batchId));
    final theme = Theme.of(context);
    final currency = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          b == null ? l10n.batchDetailTitle : l10n.batchBy(b.batchNumber),
        ),
        actions: [
          if (b != null)
            IconButton(
              key: const Key('batch-edit'),
              tooltip: l10n.actionEdit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.push('${Routes.stock}/batch/$batchId/edit'),
            ),
        ],
      ),
      body: batch.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorGeneric)),
        data: (b) {
          if (b == null) return Center(child: Text(l10n.errorGeneric));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (medicine != null)
                Text(medicine.displayName, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (b.quantityOnHand > 0)
                    ExpiryChip(expiry: b.expiry)
                  else
                    Chip(label: Text(batchStatusLabel(l10n, b.status))),
                  Text(l10n.expiresOn(formatDate(context, b.expiry.date))),
                ],
              ),
              const SizedBox(height: 16),
              _Row(l10n.batchDetailOnHand, '${b.quantityOnHand}'),
              _Row(l10n.batchDetailLifetime, '${b.quantityReceived}'),
              _Row(
                l10n.batchDetailReceived,
                formatDate(context, b.receivedDate),
              ),
              if (b.costPrice != null)
                _Row(
                  l10n.batchDetailCost,
                  b.costPrice!.format(symbol: currency),
                ),
              if (b.sellingPrice != null)
                _Row(
                  l10n.batchDetailSelling,
                  b.sellingPrice!.format(symbol: currency),
                ),
              if (b.notes != null) _Row(l10n.batchDetailNotes, b.notes!),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('batch-adjust'),
                onPressed: () => showAdjustStockSheet(context, b),
                icon: const Icon(Icons.tune),
                label: Text(l10n.adjustTitle),
              ),
              const SizedBox(height: 24),
              Text(l10n.adjustHistory, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...history.when(
                loading: () => const [SizedBox.shrink()],
                error: (e, _) => [Text(l10n.errorGeneric)],
                data: (items) => items.isEmpty
                    ? [Text(l10n.adjustNoHistory)]
                    : [for (final a in items) _HistoryTile(adjustment: a)],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.adjustment});

  final StockAdjustment adjustment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final a = adjustment;
    final adds = a.deltaQty > 0;
    final theme = Theme.of(context);
    final color = adds ? theme.colorScheme.primary : theme.colorScheme.error;
    final currency = ref.watch(currencySymbolProvider);
    final lines = [
      if (a.note != null) a.note!,
      formatDateTime(context, a.createdAt),
      if (a.valueImpact != null)
        '${l10n.batchDetailWriteOff}: ${a.valueImpact!.format(symbol: currency)}',
    ];
    return ListTile(
      key: Key('history-${a.id}'),
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(adds ? Icons.add : Icons.remove, color: color),
      ),
      title: Text(
        '${adds ? '+' : '−'}${a.deltaQty.abs()} · ${reasonLabel(l10n, a.reason)}',
      ),
      subtitle: Text(lines.join('\n')),
      isThreeLine: lines.length > 2,
    );
  }
}
