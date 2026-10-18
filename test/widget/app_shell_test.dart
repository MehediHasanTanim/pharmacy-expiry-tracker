import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/app/app.dart';
import 'package:pharmacy_expiry_tracker/app/onboarding_gate.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('shows five tabs and navigates between them', (tester) async {
    final db = AppDatabase.forTesting();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          onboardingEnabledProvider.overrideWithValue(false),
          // This test is about navigation, not the alert engine.
          alertEngineEnabledProvider.overrideWithValue(false),
        ],
        child: const App(),
      ),
    );
    await settle(tester);

    for (final label in ['Home', 'Stock', 'Expiry', 'Suppliers', 'More']) {
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
        findsOneWidget,
        reason: label,
      );
    }
    expect(find.byKey(const Key('home-first-medicine')), findsOneWidget);

    await tester.tap(find.text('Expiry'));
    await settle(tester);
    expect(find.text('Nothing is near expiry'), findsOneWidget);

    await tester.tap(find.text('Suppliers'));
    await settle(tester);
    expect(find.text('No suppliers yet'), findsOneWidget);

    // Dispose the tree, then flush the zero-duration timer Drift schedules
    // when a stream is cancelled.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
