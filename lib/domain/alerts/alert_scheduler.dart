import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_reconciler.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_records.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/notification_plugin.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/alert_store.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/transaction_runner.dart';

/// What one [AlertScheduler.apply] did.
@immutable
class ApplySummary {
  const ApplySummary({
    this.scheduled = 0,
    this.cancelled = 0,
    this.orphansCancelled = 0,
  });

  final int scheduled;
  final int cancelled;
  final int orphansCancelled;
}

/// Carries a [ReconcileResult] out against the OS and the database (S3-07).
///
/// The database changes run in one transaction. If the OS rejects any call the
/// transaction rolls back and the notifications scheduled so far are
/// withdrawn, leaving the next plan to start from a consistent picture.
class AlertScheduler {
  AlertScheduler({
    required NotificationPlugin plugin,
    required AlertStore store,
    required TransactionRunner transaction,
    this.keepRowsFor = const Duration(days: 30),
    this.keepLogFor = const Duration(days: 90),
  }) : _plugin = plugin,
       _store = store,
       _tx = transaction;

  final NotificationPlugin _plugin;
  final AlertStore _store;
  final TransactionRunner _tx;
  final Duration keepRowsFor;
  final Duration keepLogFor;

  /// Pending rows whose time has passed were delivered, or missed while the
  /// app was closed. Mark them fired and add them to the alert history so the
  /// user can still find them (missed-alert recovery). Returns how many.
  Future<int> recoverPastDue(DateTime now) async {
    final fired = await _store.markPastDueFired(now);
    for (final r in fired) {
      // A delivered reorder reminder starts the wait before the next one.
      if (r.kind == AlertKind.reorder && r.refs.isNotEmpty) {
        await _store.markReorderNotified(r.refs, r.fireAt);
      }
      await _store.addLog(
        AlertLogEntry(
          id: '${r.key}@${r.fireAt.millisecondsSinceEpoch}',
          kind: r.kind,
          title: r.title,
          body: r.body,
          route: r.route,
          firedAt: r.fireAt,
        ),
      );
    }
    await _store.prune(
      rows: now.subtract(keepRowsFor),
      log: now.subtract(keepLogFor),
    );
    return fired.length;
  }

  Future<ApplySummary> apply(ReconcileResult diff) async {
    final scheduledIds = <int>[];
    try {
      await _tx.run(() async {
        for (final r in diff.toCancel) {
          await _plugin.cancel(r.osId);
        }
        if (diff.toCancel.isNotEmpty) {
          await _store.markState([
            for (final r in diff.toCancel) r.key,
          ], ScheduledState.cancelled);
        }
        for (final a in diff.toSchedule) {
          await _plugin.schedule(a.toNotification());
          scheduledIds.add(a.osId);
          await _store.upsertPending(a);
        }
      });
    } on Object {
      // The rows were rolled back; take the notifications back too so the OS
      // does not hold alerts the engine knows nothing about.
      for (final id in scheduledIds) {
        try {
          await _plugin.cancel(id);
        } on Object catch (e) {
          debugPrint('Could not withdraw notification $id: $e');
        }
      }
      rethrow;
    }

    var orphans = 0;
    for (final id in diff.orphanOsIds) {
      await _plugin.cancel(id);
      orphans++;
    }
    return ApplySummary(
      scheduled: diff.toSchedule.length,
      cancelled: diff.toCancel.length,
      orphansCancelled: orphans,
    );
  }
}
