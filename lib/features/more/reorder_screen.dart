import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/reorder.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/common/share_text.dart';
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

class _SupplierCard extends ConsumerWidget {
  const _SupplierCard({
    required this.supplierId,
    required this.title,
    required this.items,
  });

  final String? supplierId;
  final String title;
  final List<ReorderItem> items;

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final edited = ref.read(reorderQuantitiesProvider);
    // Things already on order are not asked for again.
    final open = items.where((i) => i.order == null).toList();
    final lines = [
      for (final i in open.isEmpty ? items : open)
        (name: i.name, quantity: orderQuantityFor(i, edited[i.medicineId])),
    ];
    final name = supplierId == null ? l10n.orderShareNoSupplier : title;
    await ref
        .read(fileExchangeProvider)
        .shareText(
          buildOrderText(l10n, supplierName: name, lines: lines),
          subject: l10n.orderShareSubject(name),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Card(
      key: Key('reorder-group-${supplierId ?? 'none'}'),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                IconButton(
                  key: Key('reorder-share-${supplierId ?? 'none'}'),
                  tooltip: l10n.orderShareSupplier,
                  icon: const Icon(Icons.ios_share),
                  onPressed: () => unawaited(_share(context, ref)),
                ),
              ],
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

  Future<void> _markOrdered(
    BuildContext context,
    WidgetRef ref,
    int quantity,
  ) async {
    final l10n = AppLocalizations.of(context);
    final today = ref.read(todayDateProvider);
    final result = await showDialog<_OrderChoice>(
      context: context,
      builder: (_) => _OrderDialog(quantity: quantity, today: today),
    );
    if (result == null) return;
    try {
      await ref
          .read(orderTrackerProvider)
          .place(
            item.medicineId,
            quantity: result.quantity,
            supplierId: item.supplierId,
            expectedOn: result.expectedOn,
          );
    } on ValidationException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.orderUndoNote)));
    }
  }

  /// The goods arrived: close the order and open "receive a batch" with the
  /// ordered quantity and supplier filled in (ROR-7).
  Future<void> _received(BuildContext context, WidgetRef ref) async {
    final order = await ref
        .read(orderTrackerProvider)
        .markReceived(item.medicineId);
    if (!context.mounted) return;
    await context.push(
      Uri(
        path: '${Routes.stock}/medicine/${item.medicineId}/batch/new',
        queryParameters: {
          'qty': '${order.quantity}',
          'supplier': ?order.supplierId,
        },
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final qty =
        ref.watch(reorderQuantitiesProvider)[item.medicineId] ?? item.suggested;
    final today = ref.watch(todayDateProvider);
    final snoozed =
        item.snoozedUntil != null && !item.snoozedUntil!.isBefore(today);

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
                if (item.order != null)
                  _OrderLine(order: item.order!, today: today),
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
              } else if (v == 'ordered') {
                await _markOrdered(context, ref, qty);
              } else if (v == 'received') {
                await _received(context, ref);
              } else if (v == 'cancel') {
                await ref.read(orderTrackerProvider).cancel(item.medicineId);
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.orderCancelled)));
                }
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
              if (item.order == null)
                PopupMenuItem(
                  key: Key('reorder-ordered-${item.medicineId}'),
                  value: 'ordered',
                  child: Text(l10n.orderMarkOrdered),
                )
              else ...[
                PopupMenuItem(
                  key: Key('reorder-received-${item.medicineId}'),
                  value: 'received',
                  child: Text(l10n.orderReceived),
                ),
                PopupMenuItem(
                  key: Key('reorder-cancel-${item.medicineId}'),
                  value: 'cancel',
                  child: Text(l10n.orderCancel),
                ),
              ],
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

/// "Ordered 40, due 24 Oct" or, once late, "Ordered 40, late since 24 Oct".
class _OrderLine extends StatelessWidget {
  const _OrderLine({required this.order, required this.today});

  final PlacedOrder order;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final late = order.dueOn.isBefore(today);
    final when = late
        ? l10n.orderChipLate(formatDate(context, order.dueOn))
        : l10n.orderChipDue(formatDate(context, order.dueOn));
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(
            late ? Icons.schedule : Icons.local_shipping_outlined,
            size: 14,
            color: late ? scheme.error : scheme.primary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '${l10n.orderChipOrdered(order.quantity)}, $when',
              key: Key('order-line-${order.medicineId}'),
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: late ? scheme.error : null),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderChoice {
  const _OrderChoice(this.quantity, this.expectedOn);

  final int quantity;
  final DateTime? expectedOn;
}

class _OrderDialog extends StatefulWidget {
  const _OrderDialog({required this.quantity, required this.today});

  final int quantity;
  final DateTime today;

  @override
  State<_OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<_OrderDialog> {
  late final _qty = TextEditingController(text: '${widget.quantity}');
  DateTime? _expected;

  @override
  void dispose() {
    _qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.orderDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('order-qty'),
            controller: _qty,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l10n.orderQuantity),
          ),
          ListTile(
            key: const Key('order-date'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.orderExpected),
            subtitle: Text(
              _expected == null
                  ? l10n.orderNoDate
                  : formatDate(context, _expected!),
            ),
            trailing: _expected == null
                ? null
                : IconButton(
                    key: const Key('order-date-clear'),
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _expected = null),
                  ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: widget.today.add(const Duration(days: 7)),
                firstDate: widget.today,
                lastDate: widget.today.add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _expected = picked);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const Key('order-confirm'),
          onPressed: () {
            final q = int.tryParse(_qty.text.trim());
            if (q == null || q < 1) return;
            Navigator.pop(context, _OrderChoice(q, _expected));
          },
          child: Text(l10n.actionConfirm),
        ),
      ],
    );
  }
}
