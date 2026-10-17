import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/notification_plugin.dart';
import 'package:pharmacy_expiry_tracker/features/more/alert_lab_screen.dart';

import '../support/fake_notification_plugin.dart';
import '../support/pump_app.dart';

void main() {
  Future<FakeNotificationPlugin> pumpLab(
    WidgetTester t, {
    FakeNotificationPlugin? plugin,
  }) async {
    final fake = plugin ?? FakeNotificationPlugin();
    t.view
      ..physicalSize = const Size(900, 2400)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      ProviderScope(
        overrides: [notificationPluginProvider.overrideWithValue(fake)],
        child: const MaterialApp(home: AlertLabScreen()),
      ),
    );
    await settle(t);
    return fake;
  }

  testWidgets('initialises the plugin and shows permission status', (t) async {
    final fake = await pumpLab(
      t,
      plugin: FakeNotificationPlugin(exactAlarmsGranted: false),
    );
    expect(fake.calls, contains('initialize'));
    expect(find.text('Notifications allowed: true'), findsOneWidget);
    expect(find.text('Exact alarms allowed: false'), findsOneWidget);
    expect(find.text('Pending in OS: 0'), findsOneWidget);
  });

  testWidgets('schedules a two-minute test alert with a deep-link payload', (
    t,
  ) async {
    final fake = await pumpLab(t);
    await t.tap(find.byKey(const Key('lab-2m-exact')));
    await settle(t);

    expect(fake.scheduled, hasLength(1));
    final n = fake.scheduled.values.single;
    final inFuture = n.fireAt.difference(DateTime.now());
    expect(inFuture, greaterThan(const Duration(seconds: 100)));
    expect(inFuture, lessThanOrEqualTo(const Duration(minutes: 2)));
    expect(n.preferExact, isTrue);
    expect(n.payload, '/expiry?bucket=d30');
    expect(find.text('Pending in OS: 1'), findsOneWidget);
  });

  testWidgets('inexact alert does not ask for exact delivery', (t) async {
    final fake = await pumpLab(t);
    await t.tap(find.byKey(const Key('lab-2m-inexact')));
    await settle(t);
    expect(fake.scheduled.values.single.preferExact, isFalse);
  });

  testWidgets('cap test shows the OS accepting only a limited number', (
    t,
  ) async {
    final fake = await pumpLab(
      t,
      plugin: FakeNotificationPlugin(maxPending: 64),
    );
    await t.ensureVisible(find.byKey(const Key('lab-70')));
    await t.tap(find.byKey(const Key('lab-70')));
    await settle(t);
    expect(fake.scheduled, hasLength(64));
    expect(find.text('Pending in OS: 64'), findsOneWidget);
    expect(find.textContaining('OS reports 64 pending'), findsOneWidget);

    await t.tap(find.text('Cancel all'));
    await settle(t);
    expect(fake.scheduled, isEmpty);
  });

  testWidgets('shows a notification that launched the app and taps', (t) async {
    final fake = FakeNotificationPlugin()..launch = '/expiry?bucket=expired';
    await pumpLab(t, plugin: fake);
    expect(
      find.text('Launched by notification: /expiry?bucket=expired'),
      findsOneWidget,
    );
    fake.scheduled[1] = ScheduledNotification(
      id: 1,
      fireAt: DateTime(2030),
      title: 't',
      body: 'b',
      payload: '/stock',
    );
    fake.tap(1);
    await settle(t);
    expect(find.text('Last tapped payload: /stock'), findsOneWidget);
  });

  group('FakeNotificationPlugin', () {
    test('same id replaces; cancel and cancelAll remove', () async {
      final f = FakeNotificationPlugin();
      ScheduledNotification n(int id, String title) => ScheduledNotification(
        id: id,
        fireAt: DateTime(2030),
        title: title,
        body: '',
      );
      await f.schedule(n(1, 'a'));
      await f.schedule(n(1, 'b'));
      await f.schedule(n(2, 'c'));
      expect((await f.pending()).map((p) => p.title), ['b', 'c']);
      await f.cancel(1);
      expect((await f.pending()).map((p) => p.id), [2]);
      await f.cancelAll();
      expect(await f.pending(), isEmpty);
    });

    test('drops notifications while permission is denied', () async {
      final f = FakeNotificationPlugin(notificationsGranted: false);
      await f.schedule(
        ScheduledNotification(
          id: 1,
          fireAt: DateTime(2030),
          title: 't',
          body: '',
        ),
      );
      expect(await f.pending(), isEmpty);
      expect((await f.permissions()).notifications, isFalse);
    });
  });
}
