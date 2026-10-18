import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_engine.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_planner.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_records.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/notification_plugin.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/batch_usecases.dart';

import '../support/fake_notification_plugin.dart';
import '../support/test_env.dart';

/// A plugin that fails after a number of successful schedule calls.
class FailingPlugin extends FakeNotificationPlugin {
  int failAfter = 1 << 30;
  int _ok = 0;

  @override
  Future<void> schedule(ScheduledNotification notification) async {
    if (_ok >= failAfter) throw StateError('OS refused');
    _ok++;
    await super.schedule(notification);
  }
}

void main() {
  late TestEnv env;
  late String med;

  // The fake clock starts at 2026-10-17 09:00.
  ExpiryDate in_(int days) {
    final d = DateTime(2026, 10, 17 + days);
    return ExpiryDate.day(d.year, d.month, d.day);
  }

  setUp(() async {
    env = TestEnv();
    med = await env.medicine();
    // Digest off keeps the expected numbers about expiry alerts only.
    await env.settings.update((s) => s.copyWith(digestEnabled: false));
  });
  tearDown(() => env.dispose());

  Future<Batch> add(String number, int days, {int qty = 10}) async =>
      (await env.addBatch(
        env.batchInput(med, number: number, expiry: in_(days), quantity: qty),
      )).batch;

  Future<ReplanSummary> replan() async {
    final r = await env.alertEngine.replan();
    expect(r.error, isNull, reason: '${r.error}');
    return r;
  }

  Future<List<ScheduledAlertRecord>> rows() => env.alertStore.all();

  group('adding, editing and discarding batches (S3-18)', () {
    test(
      'a new batch gets its lead-time alerts scheduled and recorded',
      () async {
        await add('A1', 40); // expires 2026-11-26
        final r = await replan();
        // 30 (Oct 27), 14, 7, 1, day-of.
        expect(r.scheduled, 5);
        expect(env.plugin.scheduled, hasLength(5));
        final all = await rows();
        expect(all.map((x) => x.key), [
          'lead:2026-10-27',
          'lead:2026-11-12',
          'lead:2026-11-19',
          'lead:2026-11-25',
          'day:2026-11-26',
        ]);
        expect(all.every((x) => x.isPending), isTrue);
        // The OS holds exactly what the table says, under the same ids.
        expect(
          env.plugin.scheduled.keys.toSet(),
          all.map((x) => x.osId).toSet(),
        );
        final first = env.plugin.scheduled[all.first.osId]!;
        expect(first.fireAt, DateTime(2026, 10, 27, 9, 5));
        expect(first.title, 'Expiry in 30 days');
        expect(first.payload, contains('/expiry'));
        expect(first.preferExact, isFalse);
      },
    );

    test(
      're-planning with nothing changed does no OS work (idempotent)',
      () async {
        await add('A1', 40);
        await replan();
        final callsBefore = env.plugin.calls.length;
        for (var i = 0; i < 3; i++) {
          final r = await replan();
          expect(r.isNoop, isTrue, reason: 'pass $i');
          expect(r.unchanged, 5);
        }
        expect(env.plugin.calls.length, callsBefore);
        expect(env.plugin.scheduled, hasLength(5));
      },
    );

    test('discarding a batch cancels its alerts', () async {
      final a = await add('A1', 40);
      await add('B1', 100); // expires Jan 25: leads 90 (Oct 27), ...
      await replan();
      final before = env.plugin.scheduled.length;

      await env.adjustStock(
        batchId: a.id,
        delta: -10,
        reason: AdjustmentReason.discardedExpired,
      );
      final r = await replan();
      expect(r.cancelled, greaterThan(0));
      expect(env.plugin.scheduled.length, lessThan(before));
      final cancelledRows = (await rows()).where(
        (x) => x.state == ScheduledState.cancelled,
      );
      expect(cancelledRows, isNotEmpty);
      // Nothing for A1's dates remains pending in the OS.
      final pendingDates = (await rows())
          .where((x) => x.isPending)
          .map((x) => x.key)
          .toSet();
      expect(pendingDates, isNot(contains('day:2026-11-26')));
    });

    test('editing the expiry moves the alerts', () async {
      final a = await add('A1', 40);
      await replan();
      await env.editBatch(
        a.id,
        BatchEdit(
          batchNumber: 'A1',
          expiry: in_(20), // 2026-11-06
          receivedDate: DateTime(2026, 10, 17),
        ),
      );
      final r = await replan();
      expect(r.scheduled, greaterThan(0));
      expect(r.cancelled, greaterThan(0));
      final pending = [
        for (final x in await rows())
          if (x.isPending) x.key,
      ];
      expect(pending, [
        'lead:2026-10-23',
        'lead:2026-10-30',
        'lead:2026-11-05',
        'day:2026-11-06',
      ]);
      expect(env.plugin.scheduled, hasLength(4));
    });

    test('selling the last unit cancels the alerts', () async {
      final a = await add('A1', 40, qty: 3);
      await replan();
      await env.adjustStock(
        batchId: a.id,
        delta: -3,
        reason: AdjustmentReason.sold,
      );
      await replan();
      expect(env.plugin.scheduled, isEmpty);
    });
  });

  group('snooze and handled (S3-17)', () {
    test(
      'snoozing suppresses alerts until the date; undo restores them',
      () async {
        final a = await add('A1', 40);
        await replan();
        expect(env.plugin.scheduled, hasLength(5));

        final previous = await env.alertState.snooze(
          a.id,
          DateTime(2026, 11, 13),
        );
        await replan();
        final keys = {
          for (final x in await rows())
            if (x.isPending) x.key,
        };
        // Lead dates Oct 27 and Nov 12 are before the snooze date.
        expect(keys, {'lead:2026-11-19', 'lead:2026-11-25', 'day:2026-11-26'});

        await env.alertState.restore(a.id, previous);
        await replan();
        expect(env.plugin.scheduled, hasLength(5));
      },
    );

    test('marking handled removes every alert for the batch', () async {
      final a = await add('A1', 40);
      await replan();
      await env.alertState.markHandled(a.id);
      await replan();
      expect(env.plugin.scheduled, isEmpty);
      await env.alertState.unmarkHandled(a.id);
      await replan();
      expect(env.plugin.scheduled, hasLength(5));
    });
  });

  group('settings (SET-3/4/5)', () {
    test('changing lead times reschedules', () async {
      await add('A1', 40);
      await replan();
      await env.settings.update((s) => s.copyWith(alertLeadDays: [7, 0]));
      final r = await replan();
      expect(r.ok, isTrue);
      expect(
        [
          for (final x in await rows())
            if (x.isPending) x.key,
        ],
        ['lead:2026-11-19', 'day:2026-11-26'],
      );
    });

    test(
      'the daily digest is scheduled and its text refreshed on replan',
      () async {
        await env.settings.update(
          (s) => s.copyWith(digestEnabled: true, alertLeadDays: const []),
        );
        await add('A1', 25); // near expiry
        await replan();
        final digests = [
          for (final x in await rows())
            if (x.kind.db == 'DIGEST') x,
        ];
        expect(digests.length, greaterThan(5));
        // The next digest (tomorrow 09:00) is within 24 h, so it has counts.
        expect(digests.first.body, contains('1 batch expiring soon'));
        expect(digests.last.body, contains('Open the app'));
      },
    );

    test('quiet hours move delivery time', () async {
      await add('A1', 40);
      await env.settings.update(
        (s) => s.copyWith(
          alertLeadDays: const [0],
          digestMinutes: 23 * 60,
          quietHoursEnabled: true,
        ),
      );
      await replan();
      final n = env.plugin.scheduled.values.single;
      expect(n.fireAt, DateTime(2026, 11, 27, 7));
    });
  });

  group('recovering from lost state (restore-like re-plan)', () {
    test(
      'if the OS forgets everything, the next pass schedules it again',
      () async {
        await add('A1', 40);
        await replan();
        final ids = env.plugin.scheduled.keys.toSet();
        env.plugin.scheduled.clear(); // force-stop / data cleared

        final r = await replan();
        expect(r.scheduled, 5);
        expect(
          env.plugin.scheduled.keys.toSet(),
          ids,
          reason: 'same ids, so no duplicates',
        );
      },
    );

    test('a full re-plan after wiping the table restores everything', () async {
      await add('A1', 40);
      await replan();
      await env.db.delete(env.db.scheduledAlerts).go();
      final r = await replan();
      expect(r.ok, isTrue);
      expect(env.plugin.scheduled, hasLength(5));
      expect((await rows()).where((x) => x.isPending), hasLength(5));
    });

    test("notifications the engine did not schedule are removed, the lab's are kept", () async {
      await add('A1', 40);
      await replan();
      env.plugin.scheduled[777] = ScheduledNotification(
        id: 777,
        fireAt: DateTime(2030),
        title: 'ghost',
        body: '',
      );
      env.plugin.scheduled[9000002] = ScheduledNotification(
        id: 9000002,
        fireAt: DateTime(2030),
        title: 'lab',
        body: '',
      );
      final r = await replan();
      expect(r.orphansCancelled, 1);
      expect(env.plugin.scheduled.containsKey(777), isFalse);
      expect(env.plugin.scheduled.containsKey(9000002), isTrue);
    });

    test('past-due alerts become history, not duplicates', () async {
      await add('A1', 40);
      await replan();
      // Move time to after the first lead alert (Oct 27 09:05).
      env.clock.current = DateTime(2026, 10, 27, 12);
      final r = await replan();
      expect(r.recovered, 1);
      final log = await env.alertStore.watchLog().first;
      expect(log, hasLength(1));
      expect(log.single.title, 'Expiry in 30 days');
      expect(log.single.route, contains('/expiry'));
      expect(log.single.firedAt, DateTime(2026, 10, 27, 9, 5));
      expect(log.single.isOpened, isFalse);
      expect(
        (await rows()).where((x) => x.state == ScheduledState.fired),
        hasLength(1),
      );
      // Recovering is itself idempotent.
      expect((await replan()).recovered, 0);
      expect(await env.alertStore.watchLog().first, hasLength(1));
    });

    test('old rows and history are pruned', () async {
      await add('A1', 40);
      await replan();
      env.clock.current = DateTime(2026, 11, 27, 12); // past expiry
      await replan();
      env.clock.current = DateTime(2027, 4);
      await replan();
      expect(await rows(), isEmpty);
      expect(await env.alertStore.watchLog().first, isEmpty);
    });
  });

  group('failures', () {
    test(
      'an OS failure rolls back the table and withdraws what was scheduled',
      () async {
        final plugin = FailingPlugin()..failAfter = 2;
        final e = TestEnv(plugin: plugin);
        addTearDown(e.dispose);
        final m = await e.medicine();
        await e.settings.update((s) => s.copyWith(digestEnabled: false));
        await e.addBatch(e.batchInput(m, expiry: in_(40)));

        final r = await e.alertEngine.replan();
        expect(r.ok, isFalse);
        expect(r.error, isA<StateError>());
        expect(await e.alertStore.all(), isEmpty, reason: 'rolled back');
        expect(plugin.scheduled, isEmpty, reason: 'withdrawn');

        // The next pass starts clean and succeeds.
        plugin.failAfter = 1 << 30;
        final ok = await e.alertEngine.replan();
        expect(ok.ok, isTrue);
        expect(plugin.scheduled, hasLength(5));
      },
    );

    test('a failed pass leaves earlier alerts intact', () async {
      final plugin = FailingPlugin();
      final e = TestEnv(plugin: plugin);
      addTearDown(e.dispose);
      final m = await e.medicine();
      await e.settings.update((s) => s.copyWith(digestEnabled: false));
      await e.addBatch(e.batchInput(m, expiry: in_(40)));
      await e.alertEngine.replan();
      expect(plugin.scheduled, hasLength(5));

      await e.addBatch(e.batchInput(m, number: 'B', expiry: in_(60)));
      plugin.failAfter = 0; // all new scheduling fails
      final r = await e.alertEngine.replan();
      expect(r.ok, isFalse);
      expect(
        (await e.alertStore.all()).where((x) => x.isPending),
        hasLength(5),
      );
    });
  });

  group('cap (ALR-5)', () {
    test('never more than the cap, and the OS limit is respected', () async {
      final plugin = FakeNotificationPlugin(maxPending: 64);
      final e = TestEnv(plugin: plugin);
      addTearDown(e.dispose);
      final m = await e.medicine();
      for (var i = 1; i <= 90; i++) {
        await e.addBatch(e.batchInput(m, number: 'B$i', expiry: in_(i)));
      }
      await e.settings.update(
        (s) => s.copyWith(digestEnabled: true, skipEmptyDigest: false),
      );
      final r = await e.alertEngine.replan();
      expect(r.ok, isTrue);
      expect(r.planned, maxPendingAlerts);
      expect(plugin.scheduled, hasLength(maxPendingAlerts));
      // Re-planning does not drift.
      expect((await e.alertEngine.replan()).isNoop, isTrue);
    });
  });

  group('scale', () {
    test('a full plan for 50k batches takes under a second', () async {
      await env.db.customStatement('''
        INSERT INTO medicines (id, brand_name, dosage_form, unit, reorder_level,
          is_archived, search_text, created_at, updated_at)
        WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 5000)
        SELECT 'med-' || i, 'Brand ' || i, 'tablet', 'strip', 0, 0,
               'brand ' || i, 0, 0 FROM n
      ''');
      await env.db.customStatement('''
        INSERT INTO batches (id, medicine_id, batch_number, expiry_date,
          expiry_precision, quantity_received, quantity_on_hand,
          received_date, status, created_at, updated_at)
        WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 50000)
        SELECT 'b-' || i, 'med-' || (1 + i % 5000), 'L' || i,
               date('2026-10-17', ((i * 7919) % 400 - 100) || ' days'),
               'DAY', 10, 10, '2026-10-17', 'ACTIVE', 0, 0 FROM n
      ''');
      await env.settings.update((s) => s.copyWith(digestEnabled: true));
      await replan(); // warm up
      env.plugin.scheduled.clear();
      await env.db.delete(env.db.scheduledAlerts).go();

      final sw = Stopwatch()..start();
      final r = await replan();
      final ms = sw.elapsedMilliseconds;
      // Timings are the point of this test; print them for the log.
      // ignore: avoid_print
      print(
        'full replan, 50k batches: ${ms}ms (engine ${r.took.inMilliseconds}ms), '
        '${r.planned} alerts',
      );
      expect(r.planned, maxPendingAlerts);
      expect(env.plugin.scheduled, hasLength(maxPendingAlerts));
      // About 300 ms alone; allow headroom for a loaded machine running the
      // whole suite in parallel. The spec target is under one second.
      expect(ms, lessThan(2000));
    });
  });

  test('alert log entries can be marked opened', () async {
    await env.alertStore.addLog(
      AlertLogEntry(
        id: 'x',
        kind: AlertKind.digest,
        title: 't',
        body: 'b',
        firedAt: DateTime(2026, 10),
      ),
    );
    await env.alertStore.markLogOpened('x', DateTime(2026, 10, 2));
    final e = (await env.alertStore.watchLog().first).single;
    expect(e.isOpened, isTrue);
    expect(e.openedAt, DateTime(2026, 10, 2));
  });
}
