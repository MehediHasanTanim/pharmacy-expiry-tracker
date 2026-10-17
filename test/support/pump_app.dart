import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/app/app.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';

import 'test_env.dart';

/// Pumps the whole app on top of a [TestEnv]'s in-memory database, with the
/// clock fixed at the env's date.
Future<void> pumpApp(WidgetTester tester, TestEnv env) async {
  await tester.pumpWidget(wrap(env));
  await settle(tester);
}

/// The app wrapped with overrides for [env].
Widget wrap(TestEnv env) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(env.db),
      clockProvider.overrideWithValue(env.clock),
      dataChangeBusProvider.overrideWithValue(env.bus),
    ],
    child: const App(),
  );
}

/// Unmounts the app and lets Drift flush the zero-duration timer it schedules
/// when a stream is cancelled, so the test ends with no pending timers.
Future<void> disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
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
