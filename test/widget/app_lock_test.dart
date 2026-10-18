import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/app/router.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/data/security/secure_pin_store.dart';
import 'package:pharmacy_expiry_tracker/features/home/home_screen.dart';
import 'package:pharmacy_expiry_tracker/features/lock/app_lock_controller.dart';

import '../support/fake_biometrics.dart';
import '../support/pump_app.dart';
import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late MemorySecretStore secrets;
  late SecurePinStore pins;
  late FakeBiometrics bio;

  setUp(() {
    env = TestEnv();
    secrets = MemorySecretStore();
    pins = SecurePinStore(secrets, iterations: 50);
    bio = FakeBiometrics();
    EditableText.debugDeterministicCursor = true;
  });
  tearDown(() async {
    EditableText.debugDeterministicCursor = false;
    await env.dispose();
  });

  Future<void> real(WidgetTester t, {int rounds = 4}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<ProviderContainer> open(
    WidgetTester t, {
    bool lockOn = false,
    String pin = '4821',
    int timeout = 30,
    bool biometrics = true,
  }) async {
    if (lockOn) {
      await t.runAsync(() async {
        await pins.setPin(pin);
        await env.settings.update(
          (s) => s.copyWith(
            appLockEnabled: true,
            appLockTimeoutSeconds: timeout,
            appLockBiometrics: biometrics,
          ),
        );
      });
    }
    t.view
      ..physicalSize = const Size(900, 2400)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await pumpApp(
      t,
      env,
      defaultLock: false,
      overrides: [
        pinStoreProvider.overrideWithValue(pins),
        biometricAuthProvider.overrideWithValue(bio),
      ],
    );
    await real(t);
    return ProviderScope.containerOf(t.element(find.byType(MaterialApp)));
  }

  Future<void> tapKey(WidgetTester t, String key) async {
    await t.tap(find.byKey(Key(key)));
    await t.pump();
  }

  Future<void> typePin(WidgetTester t, String pin, {bool submit = true}) async {
    for (final d in pin.split('')) {
      await tapKey(t, 'lock-$d');
    }
    if (submit) {
      await tapKey(t, 'lock-ok');
      await real(t);
    }
  }

  /// Sends the app to the background for [away], then back.
  Future<void> background(WidgetTester t, Duration away) async {
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    env.clock.current = env.clock.current.add(away);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await real(t, rounds: 2);
  }

  testWidgets('no lock configured: the app opens straight away', (t) async {
    await open(t);
    expect(find.byKey(const Key('lock-screen')), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('a locked app starts locked, and the right PIN opens it', (
    t,
  ) async {
    await open(t, lockOn: true);
    expect(find.byKey(const Key('lock-screen')), findsOneWidget);
    // The app is still running beneath, hidden.
    expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);

    await typePin(t, '4821');
    expect(find.byKey(const Key('lock-screen')), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('wrong PINs are counted, then there is a wait', (t) async {
    await open(t, lockOn: true);
    await typePin(t, '1111');
    expect(find.textContaining('4 tries left'), findsOneWidget);
    expect(find.byKey(const Key('lock-screen')), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await typePin(t, '1111');
    }
    await typePin(t, '1111');
    expect(find.textContaining('Wait'), findsOneWidget);
    // The right PIN is refused while waiting.
    await typePin(t, '4821');
    expect(find.byKey(const Key('lock-screen')), findsOneWidget);
    await t.pump(const Duration(seconds: 40));
    await disposeApp(t);
  });

  testWidgets('a short trip to the background does not lock; a long one does', (
    t,
  ) async {
    await open(t, lockOn: true, timeout: 60);
    await typePin(t, '4821');
    await background(t, const Duration(seconds: 20));
    expect(find.byKey(const Key('lock-screen')), findsNothing);
    await background(t, const Duration(seconds: 61));
    expect(find.byKey(const Key('lock-screen')), findsOneWidget);
    await typePin(t, '4821');
    expect(find.byType(HomeScreen), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('"right away" locks on every return', (t) async {
    await open(t, lockOn: true, timeout: 0);
    await typePin(t, '4821');
    await background(t, const Duration(seconds: 1));
    expect(find.byKey(const Key('lock-screen')), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets(
    'the phone lock opens it too, and is the way past a forgotten PIN',
    (t) async {
      bio
        ..available = true
        ..succeeds = true;
      await open(t, lockOn: true);
      // Offered automatically as the lock screen appears.
      await real(t);
      expect(bio.prompts, greaterThanOrEqualTo(1));
      expect(find.byKey(const Key('lock-screen')), findsNothing);
      await disposeApp(t);
    },
  );

  testWidgets('if the phone lock is cancelled the PIN pad stays', (t) async {
    bio
      ..available = true
      ..succeeds = false;
    await open(t, lockOn: true);
    await real(t);
    expect(find.byKey(const Key('lock-screen')), findsOneWidget);
    expect(find.byKey(const Key('lock-device')), findsOneWidget);
    bio.succeeds = true;
    await tapKey(t, 'lock-device');
    await real(t);
    expect(find.byKey(const Key('lock-screen')), findsNothing);
    await disposeApp(t);
  });

  testWidgets('unlocking with the phone can be switched off', (t) async {
    bio.available = true;
    await open(t, lockOn: true, biometrics: false);
    await real(t);
    expect(bio.prompts, 0);
    expect(find.byKey(const Key('lock-device')), findsNothing);
    await disposeApp(t);
  });

  testWidgets('a backup from a locked phone does not lock this one out', (
    t,
  ) async {
    // Settings say "on" but there is no PIN here.
    await t.runAsync(
      () => env.settings.update((s) => s.copyWith(appLockEnabled: true)),
    );
    await open(t);
    expect(find.byKey(const Key('lock-screen')), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets(
    'turning the lock on in Settings asks for a PIN twice, and does not lock at once',
    (t) async {
      final c = await open(t);
      c.read(routerProvider).go(Routes.settings);
      await real(t);
      await t.scrollUntilVisible(
        find.byKey(const Key('applock-switch')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await t.tap(find.byKey(const Key('applock-switch')));
      await real(t);
      await t.enterText(find.byKey(const Key('pin-new')), '12');
      await t.enterText(find.byKey(const Key('pin-confirm')), '12');
      await t.tap(find.byKey(const Key('pin-save')));
      await t.pump();
      expect(find.text('Use 4 to 8 digits.'), findsOneWidget);
      await t.enterText(find.byKey(const Key('pin-new')), '2468');
      await t.enterText(find.byKey(const Key('pin-confirm')), '2469');
      await t.tap(find.byKey(const Key('pin-save')));
      await t.pump();
      expect(find.text('The PINs do not match.'), findsOneWidget);
      await t.enterText(find.byKey(const Key('pin-confirm')), '2468');
      await t.tap(find.byKey(const Key('pin-save')));
      await real(t);

      expect(find.byKey(const Key('lock-screen')), findsNothing);
      expect(await t.runAsync(pins.hasPin), isTrue);
      expect((await t.runAsync(env.settings.load))!.appLockEnabled, isTrue);
      // Now it locks after a long absence.
      await background(t, const Duration(minutes: 5));
      expect(find.byKey(const Key('lock-screen')), findsOneWidget);
      await typePin(t, '2468');
      expect(find.byKey(const Key('lock-screen')), findsNothing);
      await disposeApp(t);
    },
  );

  testWidgets('turning it off needs the current PIN', (t) async {
    final c = await open(t, lockOn: true);
    await typePin(t, '4821');
    c.read(routerProvider).go(Routes.settings);
    await real(t);
    await t.scrollUntilVisible(
      find.byKey(const Key('applock-switch')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await t.tap(find.byKey(const Key('applock-switch')));
    await real(t);
    await t.enterText(find.byKey(const Key('pin-current')), '0000');
    await t.tap(find.byKey(const Key('pin-current-ok')));
    await real(t);
    expect(await t.runAsync(pins.hasPin), isTrue);

    await t.tap(find.byKey(const Key('applock-switch')));
    await real(t);
    await t.enterText(find.byKey(const Key('pin-current')), '4821');
    await t.tap(find.byKey(const Key('pin-current-ok')));
    await real(t);
    expect(await t.runAsync(pins.hasPin), isFalse);
    expect((await t.runAsync(env.settings.load))!.appLockEnabled, isFalse);
    await disposeApp(t);
  });
}
