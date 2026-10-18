import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/app/app.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_engine.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/notification_plugin.dart';

import '../support/fake_notification_plugin.dart';
import '../support/pump_app.dart';
import '../support/stub_alert_engine.dart';
import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late StubAlertEngine stub;
  var registered = 0;

  setUp(() {
    env = TestEnv();
    stub = StubAlertEngine(env);
    registered = 0;
    EditableText.debugDeterministicCursor = true;
  });
  tearDown(() async {
    EditableText.debugDeterministicCursor = false;
    await env.dispose();
  });

  Future<ProviderContainer> launch(
    WidgetTester t, {
    String? launchPayload,
  }) async {
    env.plugin.launch = launchPayload;
    t.view
      ..physicalSize = const Size(900, 2400)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(env.db),
          clockProvider.overrideWithValue(env.clock),
          dataChangeBusProvider.overrideWithValue(env.bus),
          notificationPluginProvider.overrideWithValue(env.plugin),
          // The engine is switched ON here, which is what is under test.
          alertCoordinatorProvider.overrideWith((ref) {
            final c = AlertCoordinator(stub);
            ref.onDispose(c.dispose);
            return c;
          }),
          backgroundReplanRegistrarProvider.overrideWithValue(() async {
            registered++;
          }),
        ],
        child: const App(),
      ),
    );
    await settle(t);
    return ProviderScope.containerOf(t.element(find.byType(App)));
  }

  testWidgets('starting the app initialises the scheduler and plans once', (
    t,
  ) async {
    await launch(t);
    expect(env.plugin.calls, contains('initialize'));
    expect(stub.replans, greaterThanOrEqualTo(1));
    expect(registered, 1);
    await disposeApp(t);
  });

  testWidgets('returning to the foreground re-plans (ALR-4)', (t) async {
    await launch(t);
    final before = stub.replans;
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(stub.replans, before, reason: 'leaving does not re-plan');
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await settle(t);
    expect(stub.replans, before + 1);
    await disposeApp(t);
  });

  testWidgets('a notification that launched the app opens its screen', (
    t,
  ) async {
    final m = await db(t, env.medicine);
    final old = await db(
      t,
      () => env.addBatch(
        env.batchInput(m, number: 'OLD', expiry: ExpiryDate.day(2026, 10, 10)),
      ),
    );
    await launch(t, launchPayload: '/expiry?bucket=expired');
    expect(find.byKey(Key('expiry-row-${old.batch.id}')), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('tapping a notification while running navigates', (t) async {
    await launch(t);
    expect(find.text('Your dashboard will appear here'), findsOneWidget);
    env.plugin.scheduled[1] = ScheduledNotification(
      id: 1,
      fireAt: DateTime(2030),
      title: 't',
      body: 'b',
      payload: '/more/alerts/health',
    );
    env.plugin.tap(1);
    await settle(t);
    expect(find.text('Alert health'), findsWidgets);
    await disposeApp(t);
  });

  testWidgets('a payload that is not an app route is ignored', (t) async {
    await launch(t, launchPayload: 'https://example.com/steal');
    expect(find.text('Your dashboard will appear here'), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('with the engine disabled nothing is started', (t) async {
    final plugin = FakeNotificationPlugin();
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(env.db),
          alertEngineEnabledProvider.overrideWithValue(false),
          notificationPluginProvider.overrideWithValue(plugin),
        ],
        child: const App(),
      ),
    );
    await settle(t);
    expect(plugin.calls, isEmpty);
    await disposeApp(t);
  });
}
