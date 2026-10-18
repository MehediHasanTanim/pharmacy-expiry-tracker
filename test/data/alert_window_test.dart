import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';

import '../support/test_env.dart';

/// A medicine's own alert window limits which lead times apply (MED-3, S7-07).
void main() {
  late TestEnv env;

  setUp(() async {
    env = TestEnv();
    await env.settings.update(
      (s) => s.copyWith(
        digestEnabled: false,
        backupReminderDays: 0,
        alertLeadDays: const [90, 60, 30, 14, 7, 1, 0],
      ),
    );
  });
  tearDown(() => env.dispose());

  ExpiryDate in_(int days) {
    final d = DateTime(2026, 10, 17 + days);
    return ExpiryDate.day(d.year, d.month, d.day);
  }

  Future<List<int>> daysBefore() async {
    expect((await env.alertEngine.replan()).error, isNull);
    final expiry = DateTime(2026, 10, 17 + 200);
    return [
      for (final r in await env.alertStore.all())
        if (r.isPending &&
            (r.kind == AlertKind.expiryLead || r.kind == AlertKind.expiryDay))
          expiry
              .difference(DateTime(r.fireAt.year, r.fireAt.month, r.fireAt.day))
              .inDays,
    ]..sort();
  }

  test('the pharmacy-wide window applies by default', () async {
    final m = await env.medicine();
    await env.addBatch(env.batchInput(m, expiry: in_(200)));
    // 90 days is the default window: every lead time is in.
    expect((await daysBefore()).toSet(), {0, 1, 7, 14, 30, 60, 90});
  });

  test('a shorter window for one medicine drops the long lead times', () async {
    final m = await env.medicine(alertWindowDays: 15);
    await env.addBatch(env.batchInput(m, expiry: in_(200)));
    expect((await daysBefore()).toSet(), {0, 1, 7, 14});
  });

  test('two medicines keep their own windows', () async {
    final fast = await env.medicine(brand: 'Fast', alertWindowDays: 8);
    final slow = await env.medicine(brand: 'Slow', alertWindowDays: 365);
    await env.addBatch(env.batchInput(fast, number: 'F', expiry: in_(200)));
    await env.addBatch(env.batchInput(slow, number: 'S', expiry: in_(200)));
    await env.alertEngine.replan();
    // The slow mover alerts at 90 days out; the fast one does not.
    final lead90 = env.plugin.scheduled.values.where(
      (n) => n.fireAt.difference(DateTime(2026, 10, 17 + 110)).inDays.abs() < 1,
    );
    expect(lead90.map((n) => n.body).join(' '), contains('Slow'));
    expect(lead90.map((n) => n.body).join(' '), isNot(contains('Fast')));
  });
}
