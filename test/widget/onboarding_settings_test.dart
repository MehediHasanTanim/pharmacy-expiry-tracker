import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/app/app.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/router.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_engine.dart';

import '../support/fake_notification_plugin.dart';
import '../support/pump_app.dart';
import '../support/stub_alert_engine.dart';
import '../support/test_env.dart';

void main() {
  late TestEnv env;

  setUp(() {
    env = TestEnv();
    EditableText.debugDeterministicCursor = true;
  });
  tearDown(() async {
    EditableText.debugDeterministicCursor = false;
    await env.dispose();
  });

  Future<ProviderContainer> open(
    WidgetTester t, {
    FakeNotificationPlugin? plugin,
  }) async {
    t.view
      ..physicalSize = const Size(900, 2600)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      ProviderScope(
        // Onboarding is ON here: that is what is under test.
        overrides: [
          databaseProvider.overrideWithValue(env.db),
          clockProvider.overrideWithValue(env.clock),
          dataChangeBusProvider.overrideWithValue(env.bus),
          alertEngineEnabledProvider.overrideWithValue(false),
          ...lockTestOverrides,
          notificationPluginProvider.overrideWithValue(plugin ?? env.plugin),
          alertCoordinatorProvider.overrideWith((ref) {
            final c = AlertCoordinator(StubAlertEngine(env));
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

  Future<void> tapKey(WidgetTester t, String key) async {
    await t.tap(find.byKey(Key(key)));
    await settle(t);
  }

  Future<void> type(WidgetTester t, String key, String text) async {
    await t.enterText(find.byKey(Key(key)), text);
    await t.pump();
  }

  group('first run (HOM-5)', () {
    testWidgets('a fresh install starts on onboarding, not Home', (t) async {
      await open(t);
      expect(find.byKey(const Key('onb-page-0')), findsOneWidget);
      expect(find.text('Never let medicine expire unnoticed'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      await disposeApp(t);
    });

    testWidgets('three intro cards, with Back', (t) async {
      await open(t);
      expect(find.byKey(const Key('onb-back')), findsNothing);
      await tapKey(t, 'onb-next');
      expect(find.byKey(const Key('onb-page-1')), findsOneWidget);
      await tapKey(t, 'onb-next');
      expect(find.byKey(const Key('onb-page-2')), findsOneWidget);
      await tapKey(t, 'onb-back');
      expect(find.byKey(const Key('onb-page-1')), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('Skip goes straight Home with defaults, and is remembered', (
      t,
    ) async {
      await open(t);
      await tapKey(t, 'onb-skip');
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byKey(const Key('home-first-medicine')), findsOneWidget);
      final s = await db(t, () => env.settings.load());
      expect(s.onboardingDone, isTrue);
      expect(s.nearExpiryWindowDays, 90);
      await disposeApp(t);
    });

    testWidgets('setup choices are saved', (t) async {
      final plugin = FakeNotificationPlugin();
      await open(t, plugin: plugin);
      for (var i = 0; i < 3; i++) {
        await tapKey(t, 'onb-next');
      }
      expect(find.byKey(const Key('onb-page-3')), findsOneWidget);
      await type(t, 'onb-name', 'City Pharmacy');
      await tapKey(t, 'onb-window-60');
      await t.tap(find.byKey(const Key('onb-currency')));
      await settle(t);
      await t.tap(find.text('৳').last);
      await settle(t);
      await tapKey(t, 'onb-next');

      // Alerts step.
      expect(find.byKey(const Key('onb-page-4')), findsOneWidget);
      await tapKey(t, 'onb-allow-alerts');
      expect(find.byKey(const Key('onb-alerts-on')), findsOneWidget);
      expect(
        plugin.calls.any((c) => c.startsWith('requestPermissions')),
        isTrue,
      );
      await tapKey(t, 'onb-next');

      await tapKey(t, 'onb-explore');
      final s = await db(t, () => env.settings.load());
      expect(s.pharmacyName, 'City Pharmacy');
      expect(s.nearExpiryWindowDays, 60);
      expect(s.currencySymbol, '৳');
      expect(s.alertPermissionAsked, isTrue);
      expect(s.onboardingDone, isTrue);
      expect(find.byType(NavigationBar), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('the alerts step can be passed over', (t) async {
      final plugin = FakeNotificationPlugin(notificationsGranted: false);
      await open(t, plugin: plugin);
      for (var i = 0; i < 5; i++) {
        await tapKey(t, 'onb-next');
      }
      expect(find.byKey(const Key('onb-page-5')), findsOneWidget);
      await tapKey(t, 'onb-explore');
      expect(
        plugin.calls.where((c) => c.startsWith('requestPermissions')),
        isEmpty,
      );
      // Home then explains alerts are off (the banner from Sprint 3).
      expect(find.byKey(const Key('alert-permission-banner')), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('demo: fresh install to first batch in one pass', (t) async {
      await open(t);
      for (var i = 0; i < 3; i++) {
        await tapKey(t, 'onb-next');
      }
      await type(t, 'onb-name', 'City Pharmacy');
      await tapKey(t, 'onb-next'); // to alerts
      await tapKey(t, 'onb-next'); // to done
      await tapKey(t, 'onb-add-first');

      // Lands on the new-medicine form, Home behind it.
      expect(find.text('New medicine'), findsOneWidget);
      await type(t, 'field-brand', 'Napa');
      await type(t, 'field-strength', '500 mg');
      await tapKey(t, 'medicine-save');
      expect(
        find.byKey(const Key('home-first-medicine')),
        findsNothing,
        reason: 'a medicine now exists',
      );
      await t.tap(find.text('Stock').first);
      await settle(t);
      await t.tap(find.text('Napa 500 mg').first);
      await settle(t);
      await tapKey(t, 'add-batch');
      await type(t, 'field-batch-number', 'B1');
      await type(t, 'expiry-month', '08');
      await type(t, 'expiry-year', '2027');
      await type(t, 'field-quantity', '20');
      await tapKey(t, 'batch-save');
      expect(find.text('Batch B1'), findsOneWidget);
      expect(
        (await db(
          t,
          () => env.db.select(env.db.batches).get(),
        )).single.quantityOnHand,
        20,
      );
      await disposeApp(t);
    });

    testWidgets('after onboarding the app opens on Home and never asks again', (
      t,
    ) async {
      await db(
        t,
        () => env.settings.update((s) => s.copyWith(onboardingDone: true)),
      );
      final c = await open(t);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byKey(const Key('onb-page-0')), findsNothing);
      // Even a stale link to onboarding bounces back to Home.
      c.read(routerProvider).go('/onboarding');
      await settle(t);
      expect(find.byKey(const Key('onb-page-0')), findsNothing);
      expect(find.byType(NavigationBar), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('while onboarding, other links are redirected to it', (
      t,
    ) async {
      final c = await open(t);
      c.read(routerProvider).go('/expiry?bucket=expired');
      await settle(t);
      expect(find.byKey(const Key('onb-page-0')), findsOneWidget);
      await disposeApp(t);
    });
  });

  group('settings screen (SET-1, 2, 8, 9, 11)', () {
    Future<ProviderContainer> openSettings(WidgetTester t) async {
      await db(
        t,
        () => env.settings.update((s) => s.copyWith(onboardingDone: true)),
      );
      final c = await open(t);
      c.read(routerProvider).go('/more/settings');
      await settle(t);
      return c;
    }

    testWidgets('pharmacy name and currency save as you type', (t) async {
      await openSettings(t);
      await type(t, 'settings-name', 'Green Cross');
      await type(t, 'settings-currency', '৳');
      await settle(t);
      final s = await db(t, () => env.settings.load());
      expect(s.pharmacyName, 'Green Cross');
      expect(s.currencySymbol, '৳');
      await disposeApp(t);
    });

    testWidgets('near-expiry window', (t) async {
      await openSettings(t);
      await t.tap(find.byKey(const Key('settings-window')));
      await settle(t);
      await t.tap(find.text('180 days').last);
      await settle(t);
      expect(
        (await db(t, () => env.settings.load())).nearExpiryWindowDays,
        180,
      );
      await disposeApp(t);
    });

    testWidgets('urgency groups must be increasing; valid ones save', (
      t,
    ) async {
      await openSettings(t);
      await type(t, 'settings-bucket-a', '45');
      await type(t, 'settings-bucket-b', '30');
      await settle(t);
      expect(find.byKey(const Key('settings-bucket-error')), findsOneWidget);
      // 45 / 60 / 90 was valid and saved; 45 / 30 / 90 is rejected, not saved.
      expect((await db(t, () => env.settings.load())).bucketThresholds, [
        45,
        60,
        90,
      ]);

      await type(t, 'settings-bucket-b', '75');
      await type(t, 'settings-bucket-c', '120');
      await settle(t);
      expect(find.byKey(const Key('settings-bucket-error')), findsNothing);
      expect((await db(t, () => env.settings.load())).bucketThresholds, [
        45,
        75,
        120,
      ]);
      await disposeApp(t);
    });

    testWidgets('date format is applied everywhere dates are shown', (t) async {
      final m = await db(t, env.medicine);
      await db(
        t,
        () => env.addBatch(
          env.batchInput(m, number: 'A', expiry: ExpiryDate.day(2026, 11, 5)),
        ),
      );
      await openSettings(t);
      await t.tap(find.byKey(const Key('settings-date-format')));
      await settle(t);
      await t.tap(find.textContaining('dd/MM/yyyy').last);
      await settle(t);
      expect((await db(t, () => env.settings.load())).dateFormat, 'dd/MM/yyyy');

      await t.pageBack();
      await settle(t);
      await t.tap(find.text('Expiry').first);
      await settle(t);
      expect(find.text('Expires 05/11/2026'), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('currency symbol shows next to amounts', (t) async {
      final s = await db(t, env.supplier);
      await db(t, () => env.invoice(s, totalMinor: 18550));
      await db(
        t,
        () => env.settings.update(
          (x) => x.copyWith(onboardingDone: true, currencySymbol: '৳'),
        ),
      );
      final c = await open(t);
      c.read(routerProvider).go('/suppliers');
      await settle(t);
      expect(
        t.widget<Text>(find.byKey(const Key('dues-owed'))).data,
        '৳185.50',
      );
      await disposeApp(t);
    });

    testWidgets('theme choice switches light and dark', (t) async {
      await openSettings(t);
      Brightness brightness() =>
          Theme.of(t.element(find.byType(Scaffold).first)).brightness;
      await t.tap(find.text('Dark'));
      await settle(t);
      expect(brightness(), Brightness.dark);
      expect((await db(t, () => env.settings.load())).themeMode, 'dark');
      await t.tap(find.text('Light'));
      await settle(t);
      expect(brightness(), Brightness.light);
      await disposeApp(t);
    });

    testWidgets('More leads to Settings', (t) async {
      await db(
        t,
        () => env.settings.update((s) => s.copyWith(onboardingDone: true)),
      );
      final c = await open(t);
      c.read(routerProvider).go('/more');
      await settle(t);
      await tapKey(t, 'more-settings');
      expect(find.text('Pharmacy name'), findsOneWidget);
      await disposeApp(t);
    });
  });
}
