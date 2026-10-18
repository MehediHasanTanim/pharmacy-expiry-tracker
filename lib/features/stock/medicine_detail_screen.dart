import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';
import 'package:pharmacy_expiry_tracker/features/common/expiry_chip.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/stock/stock_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

class MedicineDetailScreen extends ConsumerWidget {
  const MedicineDetailScreen({required this.medicineId, super.key});

  final String medicineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final medicine = ref.watch(medicineProvider(medicineId));
    final batches = ref.watch(batchesByMedicineProvider(medicineId));
    final m = medicine.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(m?.displayName ?? ''),
        actions: [
          if (m != null)
            IconButton(
              key: const Key('medicine-edit'),
              tooltip: l10n.actionEdit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.push('${Routes.stock}/medicine/$medicineId/edit'),
            ),
        ],
      ),
      floatingActionButton: m == null || m.isArchived
          ? null
          : FloatingActionButton.extended(
              // Tabs stay alive side by side; a shared default hero tag would clash.
              heroTag: null,
              key: const Key('add-batch'),
              onPressed: () => context.push(
                '${Routes.stock}/medicine/$medicineId/batch/new',
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.detailAddBatch),
            ),
      body: medicine.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorGeneric)),
        data: (m) {
          if (m == null) return Center(child: Text(l10n.errorGeneric));
          final list = batches.value ?? const <Batch>[];
          final onHand = list
              .where((b) => b.status == BatchStatus.active)
              .fold<int>(0, (a, b) => a + b.quantityOnHand);
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              _Header(medicine: m, onHand: onHand),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.detailBatches,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(l10n.detailNoBatches)),
                )
              else
                for (final b in list) _BatchTile(batch: b, unit: m.unit),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.medicine, required this.onHand});

  final Medicine medicine;
  final int onHand;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final meta = [
      dosageFormLabel(l10n, medicine.dosageForm),
      if (medicine.genericName != null) medicine.genericName!,
      if (medicine.manufacturer != null) medicine.manufacturer!,
      if (medicine.category != null) medicine.category!,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(medicine.displayName, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(meta, style: theme.textTheme.bodyMedium),
          if (medicine.isArchived)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Chip(
                avatar: const Icon(Icons.archive_outlined, size: 18),
                label: Text(l10n.archivedBadge),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Stat(
                label: l10n.detailOnHandLabel,
                value: '$onHand ${unitLabel(l10n, medicine.unit)}',
              ),
              const SizedBox(width: 32),
              _Stat(
                label: l10n.detailReorderLabel,
                value: '${medicine.reorderLevel}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        Text(value, style: theme.textTheme.titleLarge),
      ],
    );
  }
}

class _BatchTile extends StatelessWidget {
  const _BatchTile({required this.batch, required this.unit});

  final Batch batch;
  final StockUnit unit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inStock = batch.quantityOnHand > 0;
    return ListTile(
      key: Key('batch-${batch.batchNumber}'),
      title: Text(l10n.batchBy(batch.batchNumber)),
      subtitle: Text(
        l10n.batchTileSubtitle(
          batch.quantityOnHand,
          formatDate(context, batch.expiry.date),
        ),
      ),
      trailing: inStock
          ? ExpiryChip(expiry: batch.expiry)
          : Chip(label: Text(batchStatusLabel(l10n, batch.status))),
      onTap: () => context.push('${Routes.stock}/batch/${batch.id}'),
    );
  }
}
