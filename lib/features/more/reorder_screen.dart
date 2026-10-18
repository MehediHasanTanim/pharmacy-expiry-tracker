import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/reorder.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/home/home_providers.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/ledger_widgets.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/suppliers_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Quantities the user has typed over the suggestions, by medicine id.
class ReorderQuantities extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => const {};

  void set(String medicineId, int quantity) =>
      state = {...state, medicineId: quantity};
}

final reorderQuantitiesProvider =
    NotifierProvider<ReorderQuantities, Map<String, int>>(
      ReorderQuantities.new,
    );

/// Medicines below their reorder level, grouped by preferred supplier, each
/// with an editable suggested order quantity (ROR-2).
class ReorderScreen extends ConsumerWidget {
  const ReorderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(reorderItemsProvider);
    final suppliers = ref.watch(
      supplierListProvider((
        query: '',
        includeArchived: true,
        sort: SupplierSort.name,
      )),
    );
    final names = {
      for (final s in suppliers.value ?? const <SupplierSummary>[])
        s.supplier.id: s.supplier.name,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reorderTitle)),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorGeneric)),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.reorderEmpty,
                      key: const Key('reorder-empty'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.reorderEmptyBody, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          // Suppliers by name, the unassigned group last.
          final bySupplier = <String?, List<ReorderItem>>{};
          for (final i in list) {
            (bySupplier[i.supplierId] ??= []).add(i);
          }
          final keys = bySupplier.keys.toList()
            ..sort((a, b) {
              if (a == null) return 1;
              if (b == null) return -1;
              return (names[a] ?? '').toLowerCase().compareTo(
                (names[b] ?? '').toLowerCase(),
              );
            });
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
            children: [
              for (final k in keys)
                _SupplierCard(
                  supplierId: k,
                  title: k == null
                      ? l10n.reorderUnassigned
                      : (names[k] ?? l10n.fieldSupplier),
                  items: bySupplier[k]!,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SupplierCard extends StatelessWidget {
  const _SupplierCard({
    required this.supplierId,
    required this.title,
    required this.items,
  });

  final String? supplierId;
  final String title;
  final List<ReorderItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('reorder-group-${supplierId ?? 'none'}'),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          for (final i in items) _ReorderRow(item: i),
        ],
      ),
    );
  }
}

class _ReorderRow extends ConsumerWidget {
  const _ReorderRow({required this.item});

  final ReorderItem item;

  Future<void> _snooze(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final svc = ref.read(reorderSnoozeProvider);
    final previous = item.snoozedUntil;
    final until = await askReminderSnooze(
      context,
      ref,
      title: l10n.reorderSnooze,
    );
    if (until == null || !context.mounted) return;
    await svc.snooze(item.medicineId, until);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.snackReorderSnoozed),
          action: SnackBarAction(
            key: const Key('snack-undo'),
            label: l10n.snackUndo,
            onPressed: () => unawaited(svc.restore(item.medicineId, previous)),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final qty =
        ref.watch(reorderQuantitiesProvider)[item.medicineId] ?? item.suggested;
    final snoozed =
        item.snoozedUntil != null &&
        !item.snoozedUntil!.isBefore(ref.watch(todayDateProvider));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: theme.textTheme.titleSmall),
                Text(
                  l10n.reorderLevelLine(item.usable, item.reorderLevel),
                  style: theme.textTheme.bodySmall,
                ),
                if (snoozed)
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_paused_outlined,
                        size: 14,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.rowSnoozed(
                          formatDate(context, item.snoozedUntil!),
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          _QtyStepper(
            medicineId: item.medicineId,
            quantity: qty,
            unitLabel: unitLabel(l10n, item.unit),
          ),
          PopupMenuButton<String>(
            key: Key('reorder-menu-${item.medicineId}'),
            tooltip: l10n.reorderSnooze,
            onSelected: (v) async {
              if (v == 'snooze') {
                await _snooze(context, ref);
              } else {
                await ref.read(reorderSnoozeProvider).clear(item.medicineId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.snackReorderResumed)),
                  );
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                key: Key('reorder-snooze-${item.medicineId}'),
                value: 'snooze',
                child: Text(l10n.reorderSnooze),
              ),
              if (snoozed)
                PopupMenuItem(
                  key: Key('reorder-resume-${item.medicineId}'),
                  value: 'resume',
                  child: Text(l10n.reorderResume),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A minus button, a typed quantity and a plus button; owns its controller.
class _QtyStepper extends ConsumerStatefulWidget {
  const _QtyStepper({
    required this.medicineId,
    required this.quantity,
    required this.unitLabel,
  });

  final String medicineId;
  final int quantity;
  final String unitLabel;

  @override
  ConsumerState<_QtyStepper> createState() => _QtyStepperState();
}

class _QtyStepperState extends ConsumerState<_QtyStepper> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.quantity}',
  );

  @override
  void didUpdateWidget(_QtyStepper old) {
    super.didUpdateWidget(old);
    if (int.tryParse(_controller.text) != widget.quantity) {
      _controller.text = '${widget.quantity}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _set(int value) {
    final v = value < 1 ? 1 : value;
    ref.read(reorderQuantitiesProvider.notifier).set(widget.medicineId, v);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: Key('reorder-minus-${widget.medicineId}'),
          tooltip: '${l10n.reorderSuggested} −',
          icon: const Icon(Icons.remove),
          onPressed: () => _set(widget.quantity - 1),
        ),
        SizedBox(
          width: 56,
          child: Semantics(
            label: '${l10n.reorderSuggested} (${widget.unitLabel})',
            child: TextField(
              key: Key('reorder-qty-${widget.medicineId}'),
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                final n = int.tryParse(v);
                if (n != null && n > 0) _set(n);
              },
            ),
          ),
        ),
        IconButton(
          key: Key('reorder-plus-${widget.medicineId}'),
          tooltip: '${l10n.reorderSuggested} +',
          icon: const Icon(Icons.add),
          onPressed: () => _set(widget.quantity + 1),
        ),
      ],
    );
  }
}
