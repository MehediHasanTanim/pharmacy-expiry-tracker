import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/app/app.dart';
import 'package:pharmacy_expiry_tracker/app/onboarding_gate.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/router.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_engine.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';

import '../support/fake_platform_alert_settings.dart';
import '../support/pump_app.dart';
import '../support/stub_alert_engine.dart';
import '../support/test_env.dart';

/// Accessibility pass #1 (S5-11): tap targets, labels on tappable things,
/// text contrast in light and dark, and layouts that survive 200% text.
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

  ExpiryDate in_(int days) {
    final d = DateTime(2026, 10, 17 + days);
    return ExpiryDate.day(d.year, d.month, d.day);
  }

  /// A pharmacy with something on every screen.
  Future<String> seed(WidgetTester t) async {
    final s = await db(
      t,
      () => env.supplier(name: 'ABC Pharma', phone: '01711000000'),
    );
    final m = await db(
      t,
      () => env.saveMedicine(
        MedicineInput(
          brandName: 'Napa',
          strength: '500 mg',
          reorderLevel: 100,
          preferredSupplierId: s,
        ),
      ),
    );
    await db(
      t,
      () => env.addBatch(
        env.batchInput(
          m,
          number: 'E1',
          quantity: 4,
          expiry: in_(-3),
          costMinor: 250,
        ),
      ),
    );
    await db(
      t,
      () => env.addBatch(
        env.batchInput(
          m,
          number: 'S1',
          quantity: 2,
          expiry: in_(10),
          costMinor: 500,
        ),
      ),
    );
    await db(
      t,
      () => env.addBatch(
        env.batchInput(m, number: 'M1', quantity: 9, expiry: in_(50)),
      ),
    );
    await db(
      t,
      () => env.invoice(
        s,
        totalMinor: 18550,
        date: DateTime(2026, 9),
        due: DateTime(2026, 10, 1),
        number: 'INV-1',
      ),
    );
    await db(
      t,
      () => env.settings.update(
        (x) => x.copyWith(onboardingDone: true, themeMode: 'light'),
      ),
    );
    return s;
  }

  Future<ProviderContainer> open(
    WidgetTester t, {
    bool dark = false,
    double text = 1,
  }) async {
    t.view
      ..physicalSize = const Size(900, 2600)
      ..devicePixelRatio = 1;
    t.platformDispatcher.textScaleFactorTestValue = text;
    addTearDown(() {
      t.view.reset();
      t.platformDispatcher.clearTextScaleFactorTestValue();
    });
    if (dark) {
      await db(
        t,
        () => env.settings.update((x) => x.copyWith(themeMode: 'dark')),
      );
    }
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(env.db),
          clockProvider.overrideWithValue(env.clock),
          dataChangeBusProvider.overrideWithValue(env.bus),
          alertEngineEnabledProvider.overrideWithValue(false),
          onboardingEnabledProvider.overrideWithValue(false),
          ...lockTestOverrides,
          notificationPluginProvider.overrideWithValue(env.plugin),
          platformAlertSettingsProvider.overrideWithValue(
            FakePlatformAlertSettings(),
          ),
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

  /// Screens to audit: name, route.
  List<(String, String Function(String supplierId))> screens() => [
    ('home', (_) => '/home'),
    ('stock', (_) => '/stock'),
    ('expiry', (_) => '/expiry'),
    ('suppliers', (_) => '/suppliers'),
    ('supplier detail', (s) => '/suppliers/$s'),
    ('more', (_) => '/more'),
    ('reorder', (_) => '/more/reorder'),
    ('settings', (_) => '/more/settings'),
    ('alert settings', (_) => '/more/alerts'),
    ('alert health', (_) => '/more/alerts/health'),
    ('new supplier', (_) => '/suppliers/new'),
    ('new medicine', (_) => '/stock/medicine/new'),
  ];

  /// Runs [guideline] on every audited screen and reports all the problems
  /// together, so one failure does not hide the rest.
  Future<void> audit(
    WidgetTester t,
    ProviderContainer c,
    String supplierId,
    AccessibilityGuideline guideline,
  ) async {
    final problems = <String>[];
    for (final (name, route) in screens()) {
      c.read(routerProvider).go(route(supplierId));
      await settle(t);
      final result = await guideline.evaluate(t);
      if (!result.passed) {
        problems.add('$name: ${result.reason?.replaceAll('\n', ' ')}');
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  }

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';

    testWidgets('tap targets are at least 48 dp ($mode)', (t) async {
      final handle = t.ensureSemantics();
      final s = await seed(t);
      final c = await open(t, dark: dark);
      await audit(t, c, s, androidTapTargetGuideline);
      await audit(t, c, s, iOSTapTargetGuideline);
      handle.dispose();
      await disposeApp(t);
    });

    testWidgets('everything tappable has a label ($mode)', (t) async {
      final handle = t.ensureSemantics();
      final s = await seed(t);
      final c = await open(t, dark: dark);
      await audit(t, c, s, labeledTapTargetGuideline);
      handle.dispose();
      await disposeApp(t);
    });

    testWidgets('text has enough contrast ($mode)', (t) async {
      final handle = t.ensureSemantics();
      final s = await seed(t);
      final c = await open(t, dark: dark);
      await audit(t, c, s, textContrastGuideline);
      handle.dispose();
      await disposeApp(t);
    });
  }

  testWidgets('layouts survive 200% text without overflow', (t) async {
    final s = await seed(t);
    final c = await open(t, text: 2);
    for (final (name, route) in screens()) {
      c.read(routerProvider).go(route(s));
      await settle(t);
      // An overflow throws during layout and fails the test; reaching here
      // with no exception is the assertion.
      expect(tester(t), isNotNull, reason: name);
    }
    await disposeApp(t);
  });

  testWidgets('Expiry rows and the invoice list at 200% text', (t) async {
    final s = await seed(t);
    final c = await open(t, text: 2);
    c.read(routerProvider).go('/expiry');
    await settle(t);
    expect(find.byType(ListTile), findsWidgets);
    c.read(routerProvider).go('/suppliers/$s');
    await settle(t);
    expect(find.text('Invoice INV-1'), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets(
    'status is never colour alone: icon and word on invoices and urgency',
    (t) async {
      final s = await seed(t);
      final c = await open(t);
      c.read(routerProvider).go('/suppliers/$s');
      await settle(t);
      final chip = find.byKey(const Key('status-overdue'));
      expect(
        find.descendant(of: chip, matching: find.byType(Icon)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: chip, matching: find.text('Overdue')),
        findsOneWidget,
      );

      c.read(routerProvider).go('/expiry');
      await settle(t);
      final header = find.byKey(const Key('section-expired'));
      expect(
        find.descendant(of: header, matching: find.byType(Icon)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: header,
          matching: find.textContaining('remove from shelf'),
        ),
        findsOneWidget,
      );
      await disposeApp(t);
    },
  );

  testWidgets('dashboard cards read as one labelled button each', (t) async {
    final handle = t.ensureSemantics();
    await seed(t);
    await open(t);
    final node = t.getSemantics(find.byKey(const Key('card-expired')));
    expect(node.flagsCollection.isButton, isTrue);
    expect(node.label, contains('Expired on shelf'));
    expect(node.label, contains('1 batch'));
    handle.dispose();
    await disposeApp(t);
  });

  testWidgets('section titles are exposed as headers', (t) async {
    final handle = t.ensureSemantics();
    await seed(t);
    final c = await open(t);
    c.read(routerProvider).go('/more');
    await settle(t);
    final header = t.getSemantics(find.text('Alerts').first);
    expect(header.flagsCollection.isHeader, isTrue);
    handle.dispose();
    await disposeApp(t);
  });
}

/// Placeholder so the 200%-text test reads as an assertion about the tree.
WidgetTester tester(WidgetTester t) => t;
