import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/app.dart';
import 'package:pharmacy_expiry_tracker/app/deep_links.dart';
import 'package:pharmacy_expiry_tracker/app/onboarding_gate.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/router.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_engine.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_records.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';

import '../support/fake_notification_plugin.dart';
import '../support/fake_platform_alert_settings.dart';
import '../support/pump_app.dart';
import '../support/stub_alert_engine.dart';
import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late FakePlatformAlertSettings platform;
  late StubAlertEngine stub;

  setUp(() {
    env = TestEnv();
    platform = FakePlatformAlertSettings();
    stub = StubAlertEngine(env);
    EditableText.debugDeterministicCursor = true;
  });
  tearDown(() async {
    EditableText.debugDeterministicCursor = false;
    await env.dispose();
  });

  Future<ProviderContainer> open(
    WidgetTester t, {
    FakeNotificationPlugin? plugin,
    bool realEngine = false,
  }) async {
    t.view
      ..physicalSize = const Size(900, 2400)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(env.db),
          onboardingEnabledProvider.overrideWithValue(false),
          ...lockTestOverrides,
          clockProvider.overrideWithValue(env.clock),
          dataChangeBusProvider.overrideWithValue(env.bus),
          alertEngineEnabledProvider.overrideWithValue(false),
          notificationPluginProvider.overrideWithValue(plugin ?? env.plugin),
          platformAlertSettingsProvider.overrideWithValue(platform),
          alertCoordinatorProvider.overrideWith((ref) {
            final c = AlertCoordinator(realEngine ? env.alertEngine : stub);
            ref.onDispose(c.dispose);
            return c;
          }),
        ],
        child: const App(),
      ),
    );
    await settle(t);
    return ProviderScope.containerOf(t.element(find.byType(App)));
  }

  Future<void> go(WidgetTester t, ProviderContainer c, String route) async {
    c.read(routerProvider).go(route);
    await settle(t);
  }

  Future<void> tapKey(WidgetTester t, String key) async {
    await t.tap(find.byKey(Key(key)));
    await settle(t);
  }

  group('permission banner and pre-prompt (ALR-7)', () {
    testWidgets('hidden while notifications are allowed', (t) async {
      await open(t);
      expect(find.byKey(const Key('alert-permission-banner')), findsNothing);
      await disposeApp(t);
    });

    testWidgets('first-time: offers to turn alerts on, via an explanation', (
      t,
    ) async {
      final plugin = FakeNotificationPlugin(notificationsGranted: false);
      await open(t, plugin: plugin);
      expect(
        find.text('Turn on expiry alerts so nothing expires unnoticed.'),
        findsOneWidget,
      );
      await tapKey(t, 'alert-permission-action');
      expect(find.text('Get expiry alerts'), findsWidgets);
      expect(find.textContaining('even when it is closed'), findsOneWidget);

      plugin.notificationsGranted = true;
      await tapKey(t, 'permission-allow');
      expect(
        plugin.calls.any((c) => c.startsWith('requestPermissions')),
        isTrue,
      );
      final saved = await db(t, () => env.settings.load());
      expect(saved.alertPermissionAsked, isTrue);
      expect(find.byKey(const Key('alert-permission-banner')), findsNothing);
      expect(stub.replans, greaterThan(0), reason: 'plan again after granting');
      await disposeApp(t);
    });

    testWidgets('after a refusal the banner points to system settings', (
      t,
    ) async {
      await db(
        t,
        () =>
            env.settings.update((s) => s.copyWith(alertPermissionAsked: true)),
      );
      await open(
        t,
        plugin: FakeNotificationPlugin(notificationsGranted: false),
      );
      expect(
        find.text('Alerts are off — expiry warnings will not reach you.'),
        findsOneWidget,
      );
      await tapKey(t, 'alert-permission-action');
      expect(platform.opened, ['notifications']);
      await disposeApp(t);
    });

    testWidgets('"Not now" leaves things as they were', (t) async {
      final plugin = FakeNotificationPlugin(notificationsGranted: false);
      await open(t, plugin: plugin);
      await tapKey(t, 'alert-permission-action');
      await tapKey(t, 'permission-later');
      expect(
        plugin.calls.where((c) => c.startsWith('requestPermissions')),
        isEmpty,
      );
      expect(find.byKey(const Key('alert-permission-banner')), findsOneWidget);
      await disposeApp(t);
    });
  });

  group('alert settings (SET-3/4/5)', () {
    testWidgets('lead times can be removed and added; saved at once', (
      t,
    ) async {
      final c = await open(t);
      await go(t, c, '/more/alerts');
      expect(find.byKey(const Key('lead-chip-90')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('lead-chip-0')),
          matching: find.text('On expiry day'),
        ),
        findsOneWidget,
      );

      final chip = t.widget<InputChip>(find.byKey(const Key('lead-chip-90')));
      chip.onDeleted!();
      await settle(t);
      expect(find.byKey(const Key('lead-chip-90')), findsNothing);
      expect((await db(t, () => env.settings.load())).alertLeadDays, [
        60,
        30,
        14,
        7,
        1,
        0,
      ]);

      await tapKey(t, 'lead-add');
      await t.enterText(find.byKey(const Key('lead-days-field')), '45');
      await tapKey(t, 'lead-days-add');
      expect(find.text('45 days before'), findsOneWidget);
      expect((await db(t, () => env.settings.load())).alertLeadDays, [
        60,
        45,
        30,
        14,
        7,
        1,
        0,
      ]);
      await disposeApp(t);
    });

    testWidgets('rejects out-of-range and duplicate lead times', (t) async {
      final c = await open(t);
      await go(t, c, '/more/alerts');
      await tapKey(t, 'lead-add');
      await t.enterText(find.byKey(const Key('lead-days-field')), '400');
      await tapKey(t, 'lead-days-add');
      expect(find.text('Enter a whole number from 0 to 365'), findsOneWidget);
      await t.enterText(find.byKey(const Key('lead-days-field')), '30');
      await tapKey(t, 'lead-days-add'); // already present: set semantics
      expect((await db(t, () => env.settings.load())).alertLeadDays, [
        90,
        60,
        30,
        14,
        7,
        1,
        0,
      ]);
      await disposeApp(t);
    });

    testWidgets('payment reminder lead times and overdue repeat (SET-6)', (
      t,
    ) async {
      final c = await open(t);
      await go(t, c, '/more/alerts');
      await t.scrollUntilVisible(
        find.byKey(const Key('pay-lead-add')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('pay-lead-chip-3')), findsOneWidget);
      t
          .widget<InputChip>(find.byKey(const Key('pay-lead-chip-3')))
          .onDeleted!();
      await settle(t);
      expect((await db(t, () => env.settings.load())).paymentLeadDays, [0]);

      await tapKey(t, 'pay-lead-add');
      await t.enterText(find.byKey(const Key('lead-days-field')), '7');
      await tapKey(t, 'lead-days-add');
      expect((await db(t, () => env.settings.load())).paymentLeadDays, [7, 0]);

      await tapKey(t, 'overdue-repeat');
      await t.tap(find.text('Every 5 days').last);
      await settle(t);
      expect((await db(t, () => env.settings.load())).overdueRepeatDays, 5);
      await disposeApp(t);
    });

    testWidgets('digest, skip-empty and quiet-hours switches persist', (
      t,
    ) async {
      final c = await open(t);
      await go(t, c, '/more/alerts');
      await tapKey(t, 'digest-switch');
      var s = await db(t, () => env.settings.load());
      expect(s.digestEnabled, isFalse);
      // Skip-empty only matters with a digest.
      expect(
        t
            .widget<SwitchListTile>(find.byKey(const Key('skip-empty-switch')))
            .onChanged,
        isNull,
      );
      await tapKey(t, 'digest-switch');
      await tapKey(t, 'skip-empty-switch');
      await tapKey(t, 'quiet-switch');
      s = await db(t, () => env.settings.load());
      expect(s.digestEnabled, isTrue);
      expect(s.skipEmptyDigest, isFalse);
      expect(s.quietHoursEnabled, isTrue);
      await disposeApp(t);
    });
  });

  group('alert health (ALR-8)', () {
    testWidgets('shows permission, battery and scheduled-alert status', (
      t,
    ) async {
      platform
        ..battery = false
        ..manufacturer = 'xiaomi';
      final c = await open(t);
      final m = await db(t, env.medicine);
      await db(
        t,
        () => env.addBatch(
          env.batchInput(m, expiry: ExpiryDate.day(2026, 11, 26)),
        ),
      );
      // A real pass so there is something scheduled to report.
      await db(t, () => env.alertEngine.replan());
      await go(t, c, '/more/alerts/health');

      expect(find.text('Allowed'), findsWidgets);
      expect(find.byKey(const Key('health-battery')), findsOneWidget);
      expect(find.textContaining('Restricted'), findsOneWidget);
      expect(find.textContaining('On xiaomi phones'), findsOneWidget);
      expect(find.textContaining('turn on Autostart'), findsOneWidget);
      expect(find.text('None yet'), findsOneWidget);
      expect(find.byKey(const Key('health-history')), findsOneWidget);
      expect(find.byKey(const Key('health-open-battery')), findsOneWidget);
      await tapKey(t, 'health-open-battery');
      expect(platform.opened, ['battery']);
      await disposeApp(t);
    });

    testWidgets('blocked notifications offer system settings', (t) async {
      final c = await open(
        t,
        plugin: FakeNotificationPlugin(notificationsGranted: false),
      );
      await go(t, c, '/more/alerts/health');
      expect(find.text('Blocked'), findsOneWidget);
      await tapKey(t, 'health-open-settings');
      expect(platform.opened, ['notifications']);
      await disposeApp(t);
    });

    testWidgets('"Send test alert" schedules through the real path', (t) async {
      final c = await open(t);
      await go(t, c, '/more/alerts/health');
      await tapKey(t, 'health-test');
      final n = env.plugin.scheduled.values.single;
      expect(n.title, 'Test alert');
      expect(
        n.fireAt.difference(env.clock.current),
        const Duration(seconds: 10),
      );
      expect(
        isLabNotificationId(n.id),
        isTrue,
        reason: 'the engine must never cancel it',
      );
      expect(find.textContaining('A test alert will arrive'), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('shows the next alert and when planning last ran', (t) async {
      final c = await open(t, realEngine: true);
      final m = await db(t, env.medicine);
      await db(
        t,
        () => env.addBatch(
          env.batchInput(m, expiry: ExpiryDate.day(2026, 11, 26)),
        ),
      );
      await go(t, c, '/more/alerts/health');
      expect(find.text('Never'), findsOneWidget);

      // "Check again" runs a real pass.
      await tapKey(t, 'health-refresh');
      expect(find.text('Never'), findsNothing);
      expect(find.textContaining('Oct 27, 2026'), findsWidgets);
      expect(env.plugin.scheduled, isNotEmpty);
      await disposeApp(t);
    });
  });

  group('alert history (ALR-12)', () {
    testWidgets('empty state', (t) async {
      final c = await open(t);
      await go(t, c, '/more/alerts/history');
      expect(find.byKey(const Key('history-empty')), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('lists fired alerts, opens one and marks it read', (t) async {
      await db(
        t,
        () => env.alertStore.addLog(
          AlertLogEntry(
            id: 'lead:2026-10-10@1',
            kind: AlertKind.expiryLead,
            title: 'Expiry in 30 days',
            body: '1 batch: Amoxil (A1)',
            route: '/expiry?bucket=d30',
            firedAt: DateTime(2026, 10, 10, 9, 5),
          ),
        ),
      );
      final c = await open(t);
      await go(t, c, '/more/alerts/history');
      expect(find.text('Expiry in 30 days'), findsOneWidget);

      await tapKey(t, 'history-lead:2026-10-10@1');
      final log = await db(t, () => env.alertStore.watchLog().first);
      expect(log.single.isOpened, isTrue);
      // Opened through to the Expiry tab with its bucket preselected, so the
      // (empty) list reports a filter rather than "nothing near expiry".
      expect(find.text('No batches match these filters'), findsOneWidget);
      expect(find.byKey(const Key('chip-d30')), findsOneWidget);
      await disposeApp(t);
    });
  });

  group('deep links (S3-12)', () {
    testWidgets('only in-app routes are accepted', (t) async {
      expect(DeepLinks.isValid('/expiry?bucket=d30&date=2026-10-18'), isTrue);
      expect(DeepLinks.isValid('/more/alerts/health'), isTrue);
      expect(DeepLinks.isValid('/stock/batch/abc'), isTrue);
      expect(DeepLinks.isValid('https://evil.example/'), isFalse);
      expect(DeepLinks.isValid('/admin'), isFalse);
      expect(DeepLinks.isValid(''), isFalse);
      expect(DeepLinks.isValid(null), isFalse);
      expect(DeepLinks.isValid('/expiryx'), isFalse);
    });

    testWidgets('a tapped payload opens the Expiry tab with its bucket', (
      t,
    ) async {
      final m = await db(t, env.medicine);
      final old = await db(
        t,
        () => env.addBatch(
          env.batchInput(
            m,
            number: 'OLD',
            expiry: ExpiryDate.day(2026, 10, 10),
          ),
        ),
      );
      final soon = await db(
        t,
        () => env.addBatch(
          env.batchInput(
            m,
            number: 'SOON',
            expiry: ExpiryDate.day(2026, 10, 25),
          ),
        ),
      );
      final c = await open(t);
      c
          .read(deepLinksProvider)
          .handle('/expiry?bucket=expired&date=2026-10-17');
      await settle(t);
      expect(find.byKey(Key('expiry-row-${old.batch.id}')), findsOneWidget);
      expect(find.byKey(Key('expiry-row-${soon.batch.id}')), findsNothing);

      // A second tap with a different bucket re-filters the open tab.
      c.read(deepLinksProvider).handle('/expiry?bucket=d30');
      await settle(t);
      expect(find.byKey(Key('expiry-row-${soon.batch.id}')), findsOneWidget);
      expect(find.byKey(Key('expiry-row-${old.batch.id}')), findsNothing);
      await disposeApp(t);
    });

    testWidgets('an invalid payload is ignored', (t) async {
      final c = await open(t);
      c.read(deepLinksProvider).handle('/nonsense');
      await settle(t);
      expect(find.byKey(const Key('home-first-medicine')), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('a link is held until the app is ready, then followed', (
      t,
    ) async {
      final c = await open(t);
      c.read(deepLinkReadyProvider.notifier).set(ready: false);
      c.read(deepLinksProvider).handle('/more/alerts/health');
      await settle(t);
      expect(find.text('Alert health'), findsNothing);
      expect(c.read(pendingDeepLinkProvider), '/more/alerts/health');

      c.read(deepLinkReadyProvider.notifier).set(ready: true);
      c.read(deepLinksProvider).flush();
      await settle(t);
      expect(find.text('Alert health'), findsWidgets);
      expect(c.read(pendingDeepLinkProvider), isNull);
      expect(GoRouter.of(t.element(find.byType(Scaffold).first)), isNotNull);
      await disposeApp(t);
    });
  });
}
