import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/app/app.dart';
import 'package:pharmacy_expiry_tracker/app/onboarding_gate.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';

import 'test_env.dart';

/// Pumps the whole app on top of a [TestEnv]'s in-memory database, with the
/// clock fixed at the env's date.
Future<void> pumpApp(
  WidgetTester tester,
  TestEnv env, {
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(wrap(env, overrides: overrides));
  await settle(tester);
}

/// The app wrapped with overrides for [env].
Widget wrap(TestEnv env, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(env.db),
      onboardingEnabledProvider.overrideWithValue(false),
      clockProvider.overrideWithValue(env.clock),
      dataChangeBusProvider.overrideWithValue(env.bus),
      // Screen tests do not need the alert engine running underneath them.
      alertEngineEnabledProvider.overrideWithValue(false),
      notificationPluginProvider.overrideWithValue(env.plugin),
      ...overrides,
    ],
    child: const App(),
  );
}

/// Unmounts the app and lets Drift flush the zero-duration timer it schedules
/// when a stream is cancelled, so the test ends with no pending timers.
Future<void> disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  // Queries that a last change kicked off may still be in flight; closing the
  // database waits for them, and the fake clock cannot move them along, so
  // give them real time. Cancelling Drift streams schedules zero-duration
  // timers, possibly one after another, which the pumps flush.
  for (var round = 0; round < 2; round++) {
    for (var i = 0; i < 5; i++) {
      await tester.pump(Duration.zero);
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
  }
  await tester.pump(Duration.zero);
}

/// Types into the text field with [key].
Future<void> enter(WidgetTester tester, String key, String text) async {
  await tester.enterText(find.byKey(Key(key)), text);
  await tester.pump();
}

/// Advances time in fixed steps instead of `pumpAndSettle`, which never
/// returns while something keeps scheduling frames (an open text field's
/// cursor, a progress indicator).
Future<void> settle(WidgetTester tester, {int steps = 8}) async {
  for (var i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Runs a database call in real time: Drift's stream and timer machinery does
/// not advance inside the widget tester's fake clock while the test body is
/// awaiting.
Future<T> db<T>(WidgetTester t, Future<T> Function() f) async =>
    (await t.runAsync(f)) as T;
