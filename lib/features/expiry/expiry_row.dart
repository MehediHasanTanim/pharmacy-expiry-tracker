import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/expiry.dart';
import 'package:pharmacy_expiry_tracker/features/common/expiry_chip.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/expiry/expiry_actions.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// One batch on the Expiry tab (EXP-3): name, batch, quantity, expiry date,
/// days left, value at risk. Swipe for Sold / Discard; long-press or the menu
/// for everything else.
class ExpiryRow extends ConsumerWidget {
  const ExpiryRow({
    required this.item,
    required this.actions,
    required this.selecting,
    required this.selected,
    required this.onToggleSelected,
    super.key,
  });

  final ExpiryItem item;
  final ExpiryActions actions;
  final bool selecting;
  final bool selected;
  final VoidCallback onToggleSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currency = ref.watch(currencySymbolProvider);
    final b = item.batch;

    final value = item.valueAtRisk;
    final valueText = l10n.rowValue(
      value == null ? l10n.expiryValueNone : value.format(symbol: currency),
    );
    final handled = b.handledAt != null;
    final snoozed = b.snoozedUntil != null;

    final tile = ListTile(
      key: Key('expiry-row-${b.id}'),
      selected: selected,
      leading: selecting
          ? Checkbox(
              key: Key('select-${b.id}'),
              value: selected,
              onChanged: (_) => onToggleSelected(),
            )
          : null,
      title: Text(item.medicine.displayName),
      isThreeLine: true,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Urgency first: icon, colour and words.
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ExpiryChip(expiry: item.expiry),
          ),
          Text(
            '${l10n.batchBy(b.batchNumber)} · '
            '${l10n.stockOnHand(b.quantityOnHand)}',
          ),
          Text(l10n.expiresOn(formatDate(context, b.expiry.date))),
          Text(valueText, key: Key('value-${b.id}')),
          if (handled || snoozed)
            Wrap(
              spacing: 12,
              children: [
                if (handled)
                  _Flag(
                    icon: Icons.task_alt,
                    text: l10n.expiryHandled,
                    color: theme.colorScheme.primary,
                  ),
                if (snoozed)
                  _Flag(
                    icon: Icons.notifications_paused_outlined,
                    text: l10n.rowSnoozed(formatDate(context, b.snoozedUntil!)),
                    color: theme.colorScheme.outline,
                  ),
              ],
            ),
        ],
      ),
      trailing: selecting
          ? null
          : IconButton(
              key: Key('row-menu-${b.id}'),
              tooltip: l10n.rowActionsTooltip,
              icon: const Icon(Icons.more_horiz),
              onPressed: () => actions.showMenu(item),
            ),
      onTap: selecting ? onToggleSelected : () => actions.open(item),
      onLongPress: selecting ? null : () => actions.showMenu(item),
    );

    if (selecting) return tile;
    // One focusable row for screen readers: the swipe actions are exposed as
    // custom actions, and the Slidable's own gesture node takes the row's
    // label instead of being an unlabelled button.
    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.actionSold): () =>
            unawaited(actions.sold(item)),
        CustomSemanticsAction(label: l10n.actionDiscardAll): () =>
            unawaited(actions.discard(item)),
        CustomSemanticsAction(label: l10n.actionSnooze): () =>
            unawaited(actions.snooze(item)),
        CustomSemanticsAction(
          label: handled ? l10n.actionUnhandled : l10n.actionHandled,
        ): () =>
            unawaited(actions.toggleHandled(item)),
      },
      child: MergeSemantics(child: _slidable(context, l10n, theme, b.id, tile)),
    );
  }

  Widget _slidable(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    String id,
    Widget tile,
  ) {
    final b = item.batch;
    return Slidable(
      key: ValueKey('slidable-${b.id}'),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            key: Key('swipe-sold-${b.id}'),
            onPressed: (_) => actions.sold(item),
            icon: Icons.sell_outlined,
            label: l10n.adjustReasonSold,
          ),
          SlidableAction(
            key: Key('swipe-discard-${b.id}'),
            onPressed: (_) => actions.discard(item),
            backgroundColor: theme.colorScheme.errorContainer,
            foregroundColor: theme.colorScheme.onErrorContainer,
            icon: Icons.delete_outline,
            label: l10n.actionDiscard,
          ),
        ],
      ),
      child: tile,
    );
  }
}

class _Flag extends StatelessWidget {
  const _Flag({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
