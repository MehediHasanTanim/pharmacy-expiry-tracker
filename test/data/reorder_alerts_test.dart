import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/reorder_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_records.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/reorder_usecases.dart';

import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late String med;

  ExpiryDate in_(int days) {
    final d = DateTime(2026, 10, 17 + days);
    return ExpiryDate.day(d.year, d.month, d.day);
  }

  setUp(() async {
    env = TestEnv();
    med = await env.medicine(
      brand: 'Napa',
      strength: '500 mg',
      reorderLevel: 20,
    );
    await env.settings.update(
      (s) => s.copyWith(
        digestEnabled: false,
        alertLeadDays: const [],
        backupReminderDays: 0,
      ),
    );
  });
  tearDown(() => env.dispose());

  Future<void> replan() async {
    final r = await env.alertEngine.replan();
    expect(r.error, isNull, reason: '${r.error}');
  }

  Future<List<ScheduledAlertRecord>> pending() async => [
    for (final r in await env.alertStore.all())
      if (r.isPending && r.kind == AlertKind.reorder) r,
  ];

  Future<void> setStock(String batchNumber, int qty) async {
    await env.addBatch(
      env.batchInput(med, number: batchNumber, quantity: qty, expiry: in_(120)),
    );
  }

  test('stock below the level schedules reminders', () async {
    await setStock('A', 5);
    await replan();
    final rows = await pending();
    // The fake clock is at 09:00, before the 09:15 reminder time, so the
    // first reminder is today.
    expect(rows.first.key, 'reorder:2026-10-17');
    expect(rows.first.refs, [med]);
  });

  test('restocking cancels the pending reminders', () async {
    final b = (await env.addBatch(
      env.batchInput(med, quantity: 5, expiry: in_(120)),
    )).batch;
    await replan();
    expect(await pending(), isNotEmpty);
    await env.adjustStock(
      batchId: b.id,
      delta: 40,
      reason: AdjustmentReason.received,
    );
    await replan();
    expect(await pending(), isEmpty);
    expect(env.plugin.scheduled, isEmpty);
  });

  test('dropping below the level later starts reminders', () async {
    final b = (await env.addBatch(
      env.batchInput(med, quantity: 50, expiry: in_(120)),
    )).batch;
    await replan();
    expect(await pending(), isEmpty);
    await env.adjustStock(
      batchId: b.id,
      delta: -40,
      reason: AdjustmentReason.sold,
    );
    await replan();
    expect(await pending(), isNotEmpty);
  });

  test('re-planning does not duplicate', () async {
    await setStock('A', 5);
    await replan();
    final count = env.plugin.scheduled.length;
    for (var i = 0; i < 3; i++) {
      expect((await env.alertEngine.replan()).isNoop, isTrue);
    }
    expect(env.plugin.scheduled, hasLength(count));
  });

  test('a delivered reminder starts the wait before the next (SET-7)', () async {
    await setStock('A', 5);
    await replan();
    final first = (await pending()).first;
    // Time passes; the first reminder is delivered while the app is closed.
    env.clock.current = first.fireAt.add(const Duration(hours: 1));
    await replan();
    final state = await env.db.select(env.db.reorderReminderState).get();
    expect(state.single.medicineId, med);
    expect(
      state.single.lastNotifiedOn,
      '${first.fireAt.year}-${first.fireAt.month.toString().padLeft(2, '0')}-${first.fireAt.day.toString().padLeft(2, '0')}',
    );
    // The next reminder is three days after the one delivered.
    final next = (await pending()).first;
    expect(next.fireAt.difference(first.fireAt).inDays, 3);
    expect(
      (await env.alertStore.watchLog().first).single.title,
      '1 medicine to reorder',
    );
  });

  test('snoozing silences reminders until the date; undo restores', () async {
    await setStock('A', 5);
    final snooze = UpdateReorderSnooze(
      reorder: ReorderRepositoryImpl(env.db),
      clock: env.clock,
      bus: env.bus,
    );
    await replan();
    await snooze.snooze(med, DateTime(2026, 10, 25));
    await replan();
    // Reminders keep their 3-day rhythm (17, 20, 23, 26 ...); those before the
    // snooze date are skipped.
    expect((await pending()).first.key, 'reorder:2026-10-26');
    await snooze.clear(med);
    await replan();
    expect((await pending()).first.key, 'reorder:2026-10-17');
  });

  test('the interval setting changes the schedule', () async {
    await setStock('A', 5);
    await env.settings.update((s) => s.copyWith(reorderRefireDays: 7));
    await replan();
    final days = [for (final r in await pending()) r.fireAt.day];
    expect(days.take(2).toList(), [17, 24]);
  });

  test(
    'expired stock does not count, so an all-expired medicine is reminded',
    () async {
      await env.addBatch(
        env.batchInput(med, number: 'OLD', quantity: 100, expiry: in_(-2)),
      );
      await replan();
      expect(await pending(), isNotEmpty);
    },
  );

  test('medicines without a level are never reminded', () async {
    final other = await env.medicine(brand: 'Plain', strength: null);
    await env.addBatch(env.batchInput(other, quantity: 1, expiry: in_(100)));
    await env.saveMedicine(
      (await env.medicines.getById(med))!.toInput(),
      id: med,
    );
    await env.medicines.setArchived(med, archived: true);
    await replan();
    expect(await pending(), isEmpty);
  });

  test('reminders sit beside expiry and payment alerts', () async {
    await setStock('A', 5);
    final s = await env.supplier();
    await env.invoice(s, due: DateTime(2026, 10, 25));
    await env.settings.update((x) => x.copyWith(alertLeadDays: const [0]));
    await replan();
    final kinds = (await env.alertStore.all()).map((r) => r.kind).toSet();
    expect(
      kinds,
      containsAll([AlertKind.reorder, AlertKind.payment, AlertKind.expiryDay]),
    );
  });
}
