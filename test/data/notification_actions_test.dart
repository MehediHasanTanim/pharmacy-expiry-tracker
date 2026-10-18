import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/data/services/notification_actions.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/action_payload.dart';
import 'package:pharmacy_expiry_tracker/features/alerts/alert_health_screen.dart';

import '../support/fake_clock.dart';
import '../support/fake_notification_plugin.dart';
import '../support/test_env.dart';

NotificationResponse response({
  int? id = 123456,
  String? action,
  String? payload,
}) => NotificationResponse(
  notificationResponseType: NotificationResponseType.selectedNotificationAction,
  id: id,
  actionId: action,
  payload: payload,
);

void main() {
  final payload = encodeActionPayload(
    route: '/expiry?bucket=d30',
    title: '3 batches expire in 30 days',
    body: 'Napa 500 mg',
    snoozeLabel: 'Snooze 1 day',
  );

  test('payloads round-trip and plain routes stay plain', () {
    final d = decodeActionPayload(payload)!;
    expect(d.route, '/expiry?bucket=d30');
    expect(d.title, '3 batches expire in 30 days');
    expect(d.body, 'Napa 500 mg');
    expect(d.snoozeLabel, 'Snooze 1 day');
    expect(decodeActionPayload('/home'), isNull);
    expect(decodeActionPayload(null), isNull);
    expect(routeOf(payload), '/expiry?bucket=d30');
    expect(routeOf('/home'), '/home');
    expect(routeOf(null), isNull);
    final noRoute = encodeActionPayload(
      route: null,
      title: 't',
      body: 'b',
      snoozeLabel: 's',
    );
    expect(routeOf(noRoute), isNull);
  });

  test('titles and bodies with odd characters survive', () {
    final p = encodeActionPayload(
      route: '/home',
      title: 'a|b,c',
      body: 'line1\nline2 "x"',
      snoozeLabel: 'Snooze',
    );
    final d = decodeActionPayload(p)!;
    expect(d.title, 'a|b,c');
    expect(d.body, 'line1\nline2 "x"');
  });

  test('pressing Snooze shows the same alert again a day later', () async {
    final plugin = FakeNotificationPlugin();
    final clock = FakeClock(DateTime(2026, 10, 17, 9, 5));
    await handleNotificationAction(
      response(action: snoozeActionId, payload: payload),
      plugin: plugin,
      clock: clock,
    );
    final n = plugin.scheduled.values.single;
    expect(n.fireAt, DateTime(2026, 10, 18, 9, 5));
    expect(n.title, '3 batches expire in 30 days');
    expect(n.body, 'Napa 500 mg');
    expect(n.payload, '/expiry?bucket=d30');
    // It can be snoozed again.
    expect(n.snoozeLabel, 'Snooze 1 day');
    expect(
      n.id,
      inInclusiveRange(snoozedIdBase, snoozedIdBase + snoozedIdCount - 1),
    );
    // Pressing twice replaces, not duplicates.
    await handleNotificationAction(
      response(action: snoozeActionId, payload: payload),
      plugin: plugin,
      clock: clock,
    );
    expect(plugin.scheduled, hasLength(1));
  });

  test('other buttons, taps and plain payloads do nothing', () async {
    final plugin = FakeNotificationPlugin();
    final clock = FakeClock(DateTime(2026, 10, 17, 9));
    await handleNotificationAction(
      response(payload: payload),
      plugin: plugin,
      clock: clock,
    );
    await handleNotificationAction(
      response(action: 'other', payload: payload),
      plugin: plugin,
      clock: clock,
    );
    await handleNotificationAction(
      response(action: snoozeActionId, payload: '/home'),
      plugin: plugin,
      clock: clock,
    );
    expect(plugin.scheduled, isEmpty);
  });

  test('the snoozed id range cannot clash with real alerts', () {
    // Real ids are 31-bit hashes outside the reserved block (see alert-engine).
    for (final id in [0, 1, 299, 300, 2147483647]) {
      final s = snoozedIdFor(id);
      expect(s, inInclusiveRange(9000600, 9000899));
    }
  });

  group('with the engine', () {
    late TestEnv env;
    setUp(() async {
      env = TestEnv();
      final m = await env.medicine();
      await env.addBatch(env.batchInput(m, expiry: env.batchInput(m).expiry));
      await env.settings.update((s) => s.copyWith(backupReminderDays: 0));
    });
    tearDown(() => env.dispose());

    test('every planned alert carries the Snooze button', () async {
      await env.alertEngine.replan();
      expect(env.plugin.scheduled, isNotEmpty);
      expect(
        env.plugin.scheduled.values.every(
          (n) => n.snoozeLabel == 'Snooze 1 day',
        ),
        isTrue,
      );
    });

    test('a snoozed copy survives re-planning', () async {
      await env.alertEngine.replan();
      await handleNotificationAction(
        response(action: snoozeActionId, payload: payload),
        plugin: env.plugin,
        clock: env.clock,
      );
      final snoozedId = snoozedIdFor(123456);
      expect(env.plugin.scheduled.containsKey(snoozedId), isTrue);
      await env.alertEngine.replan();
      await env.alertEngine.resetAndReplan();
      expect(env.plugin.scheduled.containsKey(snoozedId), isTrue);
    });
  });

  test('phone makers map to the right steps', () {
    expect(oemFamily('redmi'), 'xiaomi');
    expect(oemFamily('poco'), 'xiaomi');
    expect(oemFamily('realme'), 'oppo');
    expect(oemFamily('oneplus'), 'oppo');
    expect(oemFamily('iqoo'), 'vivo');
    expect(oemFamily('honor'), 'huawei');
    expect(oemFamily('samsung'), 'samsung');
    expect(oemFamily('tecno'), 'other');
    expect(oemFamily(null), 'other');
  });

  test('the alert kind enum is unchanged by the action work', () {
    expect(AlertKind.values.length, 6);
  });
}
