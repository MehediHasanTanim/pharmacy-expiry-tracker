import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/expiry.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/expiry_rules.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/stock/adjust_stock_sheet.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// What the user can do with one Expiry row (EXP-5): sell down, discard,
/// snooze, mark handled. Non-destructive changes offer Undo.
class ExpiryActions {
  ExpiryActions(this.context, this.ref);

  final BuildContext context;
  final WidgetRef ref;

  AppLocalizations get _l10n => AppLocalizations.of(context);

  Future<void> sold(ExpiryItem item) async {
    await showAdjustStockSheet(context, item.batch);
  }

  void open(ExpiryItem item) {
    unawaited(context.push('${Routes.stock}/batch/${item.batch.id}'));
  }

  /// Writes off everything left, after confirmation.
  Future<void> discard(ExpiryItem item) async {
    final l10n = _l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adjustConfirmTitle),
        content: Text(
          l10n.adjustConfirmBody(
            l10n.adjustDelta(item.batch.quantityOnHand),
            item.batch.batchNumber,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const Key('discard-confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionDiscard),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await _guard(() async {
      await ref.read(discardBatchesProvider).call([item.batch.id]);
      _snack(l10n.snackDiscarded(1));
    });
  }

  /// Writes off several batches at once (selection mode).
  Future<void> discardMany(List<String> ids) async {
    final l10n = _l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adjustConfirmTitle),
        content: Text(l10n.bulkDiscardBody(ids.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const Key('bulk-discard-confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionDiscard),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await _guard(() async {
      final n = await ref.read(discardBatchesProvider).call(ids);
      _snack(l10n.snackDiscarded(n));
    });
  }

  /// Asks how long to snooze, then snoozes with Undo.
  Future<void> snooze(ExpiryItem item) async {
    final l10n = _l10n;
    final today = ref.read(todayDateProvider);
    final leads =
        ref.read(settingsProvider).value?.alertLeadDays ??
        const AppSettings().alertLeadDays;
    final nextAlert = snoozeUntilNextAlert(item.expiry, today, leads);
    DateTime inDays(int n) => DateTime(today.year, today.month, today.day + n);

    final until = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.snoozeTitle),
        children: [
          SimpleDialogOption(
            key: const Key('snooze-1d'),
            onPressed: () => Navigator.pop(ctx, inDays(1)),
            child: Text(l10n.snooze1d),
          ),
          SimpleDialogOption(
            key: const Key('snooze-3d'),
            onPressed: () => Navigator.pop(ctx, inDays(3)),
            child: Text(l10n.snooze3d),
          ),
          SimpleDialogOption(
            key: const Key('snooze-1w'),
            onPressed: () => Navigator.pop(ctx, inDays(7)),
            child: Text(l10n.snooze1w),
          ),
          SimpleDialogOption(
            key: const Key('snooze-next'),
            onPressed: () => Navigator.pop(ctx, nextAlert),
            child: Text(l10n.snoozeNext(formatDate(ctx, nextAlert))),
          ),
        ],
      ),
    );
    if (until == null || !context.mounted) return;
    await _guard(() async {
      final svc = ref.read(updateAlertStateProvider);
      final previous = await svc.snooze(item.batch.id, until);
      if (context.mounted) {
        _snack(
          l10n.snackSnoozed(formatDate(context, until)),
          undo: () => svc.restore(item.batch.id, previous),
        );
      }
    });
  }

  Future<void> toggleHandled(ExpiryItem item) async {
    final l10n = _l10n;
    final handled = item.batch.handledAt != null;
    await _guard(() async {
      final svc = ref.read(updateAlertStateProvider);
      final previous = handled
          ? await svc.unmarkHandled(item.batch.id)
          : await svc.markHandled(item.batch.id);
      _snack(
        handled ? l10n.snackUnhandled : l10n.snackHandled,
        undo: () => svc.restore(item.batch.id, previous),
      );
    });
  }

  /// Shows the full action list for [item] (long-press or the row menu).
  Future<void> showMenu(ExpiryItem item) {
    final l10n = _l10n;
    final handled = item.batch.handledAt != null;
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        Widget tile(
          String key,
          IconData icon,
          String label,
          Future<void> Function() action,
        ) {
          return ListTile(
            key: Key(key),
            leading: Icon(icon),
            title: Text(label),
            onTap: () {
              Navigator.pop(ctx);
              unawaited(action());
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(item.medicine.displayName),
                subtitle: Text(l10n.batchBy(item.batch.batchNumber)),
              ),
              const Divider(height: 1),
              tile(
                'action-sold',
                Icons.sell_outlined,
                l10n.actionSold,
                () => sold(item),
              ),
              tile(
                'action-discard',
                Icons.delete_outline,
                l10n.actionDiscardAll,
                () => discard(item),
              ),
              tile(
                'action-snooze',
                Icons.snooze,
                l10n.actionSnooze,
                () => snooze(item),
              ),
              tile(
                'action-handled',
                handled ? Icons.undo : Icons.task_alt,
                handled ? l10n.actionUnhandled : l10n.actionHandled,
                () => toggleHandled(item),
              ),
              tile(
                'action-open',
                Icons.open_in_new,
                l10n.actionOpenBatch,
                () async => open(item),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _guard(Future<void> Function() body) async {
    try {
      await body();
    } on ValidationException catch (e) {
      if (context.mounted) _snack(e.message);
    } on InsufficientStockException {
      if (context.mounted) _snack(_l10n.errorGeneric);
    } on NotFoundException {
      if (context.mounted) _snack(_l10n.errorGeneric);
    }
  }

  void _snack(String text, {Future<void> Function()? undo}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          action: undo == null
              ? null
              : SnackBarAction(
                  key: const Key('snack-undo'),
                  label: _l10n.snackUndo,
                  onPressed: () => unawaited(undo()),
                ),
        ),
      );
  }
}
