import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_records.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';

/// The difference between the alerts that should exist and those that do.
@immutable
class ReconcileResult {
  const ReconcileResult({
    this.toSchedule = const [],
    this.toCancel = const [],
    this.orphanOsIds = const [],
    this.unchanged = 0,
  });

  /// New or changed alerts (scheduling an existing id replaces it).
  final List<PlannedAlert> toSchedule;

  /// Scheduled alerts that are no longer wanted.
  final List<ScheduledAlertRecord> toCancel;

  /// Notifications the OS holds that the engine has no record of.
  final List<int> orphanOsIds;

  /// Alerts already correctly scheduled.
  final int unchanged;

  bool get isEmpty =>
      toSchedule.isEmpty && toCancel.isEmpty && orphanOsIds.isEmpty;
}

/// Compares [desired] with what is recorded as pending and what the OS
/// actually holds ([osPendingIds]). Running it again after applying the result
/// yields an empty diff, which is what makes re-planning idempotent.
ReconcileResult reconcile({
  required List<PlannedAlert> desired,
  required List<ScheduledAlertRecord> existingPending,
  required Set<int> osPendingIds,
}) {
  final existing = {for (final r in existingPending) r.key: r};
  final desiredKeys = {for (final d in desired) d.key};

  final toSchedule = <PlannedAlert>[];
  var unchanged = 0;
  for (final d in desired) {
    final e = existing[d.key];
    final needsSchedule =
        e == null ||
        e.contentHash != d.contentHash ||
        // Recorded as pending but the OS lost it (force-stop, reboot gap,
        // permission toggled off and on).
        !osPendingIds.contains(e.osId);
    if (needsSchedule) {
      toSchedule.add(d);
    } else {
      unchanged++;
    }
  }

  final toCancel = [
    for (final r in existingPending)
      if (!desiredKeys.contains(r.key)) r,
  ];

  final known = {
    ...existingPending.map((r) => r.osId),
    ...desired.map((d) => d.osId),
  };
  final orphans = [
    for (final id in osPendingIds)
      if (!known.contains(id) && !isLabNotificationId(id)) id,
  ]..sort();

  return ReconcileResult(
    toSchedule: toSchedule,
    toCancel: toCancel,
    orphanOsIds: orphans,
    unchanged: unchanged,
  );
}
