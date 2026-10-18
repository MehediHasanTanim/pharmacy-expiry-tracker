import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/data/background/alert_background.dart';
import 'package:pharmacy_expiry_tracker/data/services/alert_engine_factory.dart';

import '../support/fake_notification_plugin.dart';
import '../support/test_env.dart';

void main() {
  late TestEnv env;
  setUp(() => env = TestEnv());
  tearDown(() => env.dispose());

  ExpiryDate in_(int days) {
    final d = DateTime(2026, 10, 17 + days);
    return ExpiryDate.day(d.year, d.month, d.day);
  }

  test(
    'a headless pass plans and schedules like the foreground one (S3-09)',
    () async {
      final med = await env.medicine();
      await env.settings.update((s) => s.copyWith(digestEnabled: false));
      await env.addBatch(env.batchInput(med, expiry: in_(40)));

      final ok = await runBackgroundReplan(
        database: env.db,
        plugin: env.plugin,
        clock: env.clock,
      );
      expect(ok, isTrue);
      expect(env.plugin.calls, contains('initialize'));
      expect(env.plugin.scheduled, hasLength(5));
      // The database was borrowed, not closed: it is still usable.
      expect(await env.alertStore.all(), hasLength(5));
    },
  );

  test('a later background pass picks up the passing of time', () async {
    final med = await env.medicine();
    await env.settings.update((s) => s.copyWith(digestEnabled: false));
    await env.addBatch(env.batchInput(med, expiry: in_(40)));
    await runBackgroundReplan(
      database: env.db,
      plugin: env.plugin,
      clock: env.clock,
    );

    // The app is never opened; a day passes and the first alert is delivered.
    env.clock.current = DateTime(2026, 10, 27, 12);
    await runBackgroundReplan(
      database: env.db,
      plugin: env.plugin,
      clock: env.clock,
    );
    final log = await env.alertStore.watchLog().first;
    expect(log.single.title, 'Expiry in 30 days');
    expect(env.plugin.scheduled, hasLength(4));
  });

  test(
    'a failing OS makes the pass report failure so it can be retried',
    () async {
      final med = await env.medicine();
      await env.settings.update((s) => s.copyWith(digestEnabled: false));
      await env.addBatch(env.batchInput(med, expiry: in_(40)));
      final broken = _Refusing();
      final ok = await runBackgroundReplan(
        database: env.db,
        plugin: broken,
        clock: env.clock,
      );
      expect(ok, isFalse);
      expect(await env.alertStore.all(), isEmpty);
    },
  );

  test(
    'the factory builds an engine that works against any database',
    () async {
      final med = await env.medicine();
      await env.settings.update((s) => s.copyWith(digestEnabled: false));
      await env.addBatch(env.batchInput(med, expiry: in_(40)));
      final plugin = FakeNotificationPlugin();
      final engine = createAlertEngine(
        db: env.db,
        plugin: plugin,
        clock: env.clock,
      );
      final r = await engine.replan();
      expect(r.ok, isTrue);
      expect(plugin.scheduled, hasLength(5));
      expect((await engine.replan()).isNoop, isTrue);
    },
  );
}

class _Refusing extends FakeNotificationPlugin {
  @override
  Future<void> schedule(covariant dynamic notification) =>
      Future.error(StateError('refused'));
}
