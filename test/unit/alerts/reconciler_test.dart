import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_reconciler.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_records.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';

void main() {
  PlannedAlert alert(
    String key,
    int osId, {
    String body = 'body',
    DateTime? at,
  }) => PlannedAlert(
    key: key,
    kind: AlertKind.expiryLead,
    fireAt: at ?? DateTime(2026, 11),
    title: 'title',
    body: body,
    route: '/expiry',
    osId: osId,
  );

  ScheduledAlertRecord record(PlannedAlert a, {ScheduledState? state}) =>
      ScheduledAlertRecord(
        key: a.key,
        kind: a.kind,
        fireAt: a.fireAt,
        osId: a.osId,
        title: a.title,
        body: a.body,
        route: a.route,
        contentHash: a.contentHash,
        state: state ?? ScheduledState.pending,
      );

  ReconcileResult run({
    List<PlannedAlert> desired = const [],
    List<ScheduledAlertRecord> existing = const [],
    Set<int>? os,
  }) => reconcile(
    desired: desired,
    existingPending: existing,
    osPendingIds: os ?? {for (final e in existing) e.osId},
  );

  test('everything is new on first run', () {
    final r = run(desired: [alert('a', 1), alert('b', 2)]);
    expect(r.toSchedule.map((a) => a.key), ['a', 'b']);
    expect(r.toCancel, isEmpty);
    expect(r.unchanged, 0);
  });

  test('identical plan is a no-op', () {
    final a = alert('a', 1);
    final r = run(desired: [a], existing: [record(a)]);
    expect(r.isEmpty, isTrue);
    expect(r.unchanged, 1);
  });

  test('changed text or time reschedules under the same id', () {
    final old = alert('a', 1);
    final r1 = run(
      desired: [alert('a', 1, body: 'new')],
      existing: [record(old)],
    );
    expect(r1.toSchedule.single.osId, 1);
    final r2 = run(
      desired: [alert('a', 1, at: DateTime(2026, 11, 2))],
      existing: [record(old)],
    );
    expect(r2.toSchedule, hasLength(1));
    expect(r2.toCancel, isEmpty);
  });

  test('alerts no longer wanted are cancelled', () {
    final a = alert('a', 1);
    final b = alert('b', 2);
    final r = run(desired: [a], existing: [record(a), record(b)]);
    expect(r.toCancel.map((x) => x.key), ['b']);
    expect(r.toSchedule, isEmpty);
    expect(r.unchanged, 1);
  });

  test('an alert the OS lost is scheduled again', () {
    final a = alert('a', 1);
    final r = run(desired: [a], existing: [record(a)], os: {});
    expect(r.toSchedule.single.key, 'a');
    expect(r.unchanged, 0);
  });

  test('notifications unknown to the engine are orphans, except the lab', () {
    final a = alert('a', 1);
    final r = run(desired: [a], existing: [record(a)], os: {1, 77, 9000005});
    expect(r.orphanOsIds, [77]);
  });

  test('a desired alert about to be scheduled is not an orphan', () {
    final r = run(desired: [alert('a', 5)], os: {5});
    expect(r.orphanOsIds, isEmpty);
    expect(r.toSchedule, hasLength(1));
  });

  test('applying a diff and reconciling again yields nothing (idempotent)', () {
    final desired = [alert('a', 1), alert('b', 2), alert('c', 3)];
    final first = run(
      desired: desired,
      existing: [record(alert('stale', 9))],
      os: {9},
    );
    expect(first.toSchedule, hasLength(3));
    expect(first.toCancel.single.key, 'stale');

    // After applying: the three are pending in both table and OS.
    final second = run(
      desired: desired,
      existing: [for (final d in desired) record(d)],
      os: {1, 2, 3},
    );
    expect(second.isEmpty, isTrue);
    expect(second.unchanged, 3);
  });
}
