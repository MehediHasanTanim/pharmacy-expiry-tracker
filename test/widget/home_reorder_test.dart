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
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';
import 'package:pharmacy_expiry_tracker/features/more/reorder_screen.dart';

import '../support/fake_notification_plugin.dart';
import '../support/fake_platform_alert_settings.dart';
import '../support/pump_app.dart';
import '../support/stub_alert_engine.dart';
import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late FakePlatformAlertSettings platform;

  setUp(() {
    env = TestEnv();
    platform = FakePlatformAlertSettings();
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

  Future<ProviderContainer> open(
    WidgetTester t, {
    FakeNotificationPlugin? plugin,
    AlertEngine? engine,
  }) async {
    t.view
      ..physicalSize = const Size(900, 2600)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(env.db),
          clockProvider.overrideWithValue(env.clock),
          dataChangeBusProvider.overrideWithValue(env.bus),
          alertEngineEnabledProvider.overrideWithValue(false),
          onboardingEnabledProvider.overrideWithValue(false),
          ...lockTestOverrides,
          notificationPluginProvider.overrideWithValue(plugin ?? env.plugin),
          platformAlertSettingsProvider.overrideWithValue(platform),
          alertCoordinatorProvider.overrideWith((ref) {
            final c = AlertCoordinator(engine ?? StubAlertEngine(env));
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

  Text textAt(WidgetTester t, String key) =>
      t.widget<Text>(find.byKey(Key(key)));

  group('first run empty state (HOM-5)', () {
    testWidgets('invites adding the first medicine', (t) async {
      await open(t);
      expect(find.byKey(const Key('home-first-medicine')), findsOneWidget);
      expect(find.byKey(const Key('card-expired')), findsNothing);
      await tapKey(t, 'home-add-medicine');
      expect(find.text('New medicine'), findsOneWidget);
      await disposeApp(t);
    });
  });

  group('needs-attention cards (HOM-1)', () {
    testWidgets('counts and values, each a link to its list', (t) async {
      final m = await db(t, () => env.medicine(reorderLevel: 100));
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
          env.batchInput(
            m,
            number: 'S2',
            quantity: 1,
            expiry: in_(25),
            costMinor: 100,
          ),
        ),
      );
      final s = await db(t, env.supplier);
      await db(
        t,
        () => env.invoice(
          s,
          totalMinor: 9900,
          date: DateTime(2026, 9),
          due: DateTime(2026, 10, 1),
        ),
      );
      await open(t);

      expect(find.byKey(const Key('home-first-medicine')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('card-expired')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
      expect(find.text('1 batch · 10.00'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('card-soon')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
      expect(find.text('2 batches · 11.00'), findsOneWidget);
      // 3 units usable (expired stock does not count), level 100.
      expect(
        find.descendant(
          of: find.byKey(const Key('card-reorder')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
      expect(find.text('1 medicine'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('card-dues')),
          matching: find.text('99.00'),
        ),
        findsOneWidget,
      );
      expect(find.text('1 invoice'), findsOneWidget);
      expect(textAt(t, 'home-at-risk').data, 'Value at risk: 21.00');
      await disposeApp(t);
    });

    testWidgets('all clear says so', (t) async {
      final m = await db(t, env.medicine);
      await db(t, () => env.addBatch(env.batchInput(m, expiry: in_(300))));
      await open(t);
      expect(find.text('Nothing needs attention'), findsNWidgets(3));
      expect(find.text('All stocked'), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('the Expired card opens the Expiry tab on expired stock', (
      t,
    ) async {
      final m = await db(t, env.medicine);
      final old = await db(
        t,
        () => env.addBatch(env.batchInput(m, number: 'OLD', expiry: in_(-3))),
      );
      final soon = await db(
        t,
        () => env.addBatch(env.batchInput(m, number: 'SOON', expiry: in_(10))),
      );
      await open(t);
      await tapKey(t, 'card-expired');
      expect(find.byKey(Key('expiry-row-${old.batch.id}')), findsOneWidget);
      expect(find.byKey(Key('expiry-row-${soon.batch.id}')), findsNothing);
      await disposeApp(t);
    });

    testWidgets('the soon card and "see all" open the 30-day group', (t) async {
      final m = await db(t, env.medicine);
      final old = await db(
        t,
        () => env.addBatch(env.batchInput(m, number: 'OLD', expiry: in_(-3))),
      );
      final soon = await db(
        t,
        () => env.addBatch(env.batchInput(m, number: 'SOON', expiry: in_(10))),
      );
      await open(t);
      await tapKey(t, 'home-see-all');
      expect(find.byKey(Key('expiry-row-${soon.batch.id}')), findsOneWidget);
      expect(find.byKey(Key('expiry-row-${old.batch.id}')), findsNothing);
      await disposeApp(t);
    });

    testWidgets('the Reorder and dues cards navigate', (t) async {
      final m = await db(t, () => env.medicine(reorderLevel: 50));
      await db(t, () => env.addBatch(env.batchInput(m, expiry: in_(200))));
      final s = await db(t, env.supplier);
      await db(
        t,
        () =>
            env.invoice(s, date: DateTime(2026, 9), due: DateTime(2026, 10, 1)),
      );
      await open(t);
      await tapKey(t, 'card-reorder');
      expect(find.text('Reorder list'), findsOneWidget);
      await t.pageBack();
      await settle(t);
      await tapKey(t, 'card-dues');
      expect(find.byKey(Key('supplier-$s')), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('cards update as the data changes', (t) async {
      final m = await db(t, env.medicine);
      final b = await db(
        t,
        () => env.addBatch(env.batchInput(m, expiry: in_(10), quantity: 5)),
      );
      await open(t);
      expect(find.text('1 batch · 0.00'), findsOneWidget);
      await db(
        t,
        () => env.adjustStock(
          batchId: b.batch.id,
          delta: -5,
          reason: AdjustmentReason.sold,
        ),
      );
      await settle(t);
      expect(find.text('Nothing needs attention'), findsNWidgets(3));
      await disposeApp(t);
    });
  });

  group('expiring this week (HOM-3)', () {
    testWidgets('lists the five soonest within seven days', (t) async {
      final m = await db(t, env.medicine);
      final ids = <String>[];
      for (var d = 0; d < 7; d++) {
        final b = await db(
          t,
          () => env.addBatch(env.batchInput(m, number: 'B$d', expiry: in_(d))),
        );
        ids.add(b.batch.id);
      }
      await db(
        t,
        () => env.addBatch(env.batchInput(m, number: 'LATER', expiry: in_(20))),
      );
      await open(t);
      for (var d = 0; d < 5; d++) {
        expect(
          find.byKey(Key('week-${ids[d]}')),
          findsOneWidget,
          reason: 'B$d',
        );
      }
      expect(find.byKey(Key('week-${ids[5]}')), findsNothing);
      expect(find.byKey(Key('week-${ids[6]}')), findsNothing);
      await disposeApp(t);
    });

    testWidgets('says so when nothing is due', (t) async {
      final m = await db(t, env.medicine);
      await db(t, () => env.addBatch(env.batchInput(m, expiry: in_(40))));
      await open(t);
      expect(find.byKey(const Key('home-week-empty')), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('a row opens its batch', (t) async {
      final m = await db(t, env.medicine);
      final b = await db(
        t,
        () => env.addBatch(env.batchInput(m, number: 'OPEN', expiry: in_(3))),
      );
      await open(t);
      await tapKey(t, 'week-${b.batch.id}');
      expect(find.text('Batch OPEN'), findsWidgets);
      expect(find.text('Adjust stock'), findsOneWidget);
      await disposeApp(t);
    });
  });

  group('alert status banner (HOM-2)', () {
    testWidgets('silent when everything is fine', (t) async {
      await open(t);
      expect(find.byKey(const Key('alert-status-banner')), findsNothing);
      expect(find.byKey(const Key('alert-permission-banner')), findsNothing);
      await disposeApp(t);
    });

    testWidgets('blocked notifications show the permission banner', (t) async {
      await open(
        t,
        plugin: FakeNotificationPlugin(notificationsGranted: false),
      );
      expect(find.byKey(const Key('alert-permission-banner')), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('battery saving on a phone known to stop alerts is flagged', (
      t,
    ) async {
      platform
        ..battery = false
        ..manufacturer = 'xiaomi';
      await open(t);
      expect(
        find.text('Battery saving may delay your alerts.'),
        findsOneWidget,
      );
      await tapKey(t, 'alert-status-action');
      expect(find.text('Alert health'), findsWidgets);
      await disposeApp(t);
    });

    testWidgets('a restricted but well-behaved phone is not nagged', (t) async {
      platform
        ..battery = false
        ..manufacturer = 'google';
      await open(t);
      expect(find.byKey(const Key('alert-status-banner')), findsNothing);
      await disposeApp(t);
    });

    testWidgets('a failed planning pass is flagged, and Check retries', (
      t,
    ) async {
      final engine = _FailingThenOk(env);
      final c = await open(t, engine: engine);
      await c.read(alertCoordinatorProvider).replanNow();
      await settle(t);
      expect(
        find.text('Alerts could not be updated. Check again.'),
        findsOneWidget,
      );
      await tapKey(t, 'alert-status-action');
      expect(engine.calls, 2);
      expect(find.byKey(const Key('alert-status-banner')), findsNothing);
      await disposeApp(t);
    });
  });

  group('reorder list (ROR-2)', () {
    Future<(String, String)> twoLowMedicines(WidgetTester t) async {
      final sup = await db(t, () => env.supplier(name: 'ABC Pharma'));
      final a = await db(
        t,
        () => env.saveMedicine(
          MedicineInput(
            brandName: 'Napa',
            strength: '500 mg',
            reorderLevel: 20,
            preferredSupplierId: sup,
          ),
        ),
      );
      await db(
        t,
        () => env.addBatch(env.batchInput(a, quantity: 4, expiry: in_(200))),
      );
      final b = await db(
        t,
        () => env.saveMedicine(
          const MedicineInput(brandName: 'Zinc', reorderLevel: 10),
        ),
      );
      await db(
        t,
        () =>
            env.addBatch(env.batchInput(b, quantity: 0 + 1, expiry: in_(200))),
      );
      return (a, b);
    }

    testWidgets('grouped by preferred supplier, unassigned last', (t) async {
      final (a, b) = await twoLowMedicines(t);
      final c = await open(t);
      await go(t, c, '/more/reorder');
      final supplierGroup = find.byWidgetPredicate(
        (w) =>
            w.key.toString().contains('reorder-group-') &&
            !w.key.toString().contains('none'),
      );
      expect(supplierGroup, findsOneWidget);
      expect(find.text('ABC Pharma'), findsOneWidget);
      expect(find.text('No preferred supplier'), findsOneWidget);
      expect(
        t.getTopLeft(find.text('ABC Pharma')).dy,
        lessThan(t.getTopLeft(find.text('No preferred supplier')).dy),
      );
      expect(find.text('4 on hand · reorder at 20'), findsOneWidget);
      expect(find.byKey(Key('reorder-qty-$a')), findsOneWidget);
      expect(find.byKey(Key('reorder-qty-$b')), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('suggested quantity tops up to twice the level', (t) async {
      final (a, _) = await twoLowMedicines(t);
      final c = await open(t);
      await go(t, c, '/more/reorder');
      TextField field(String id) =>
          t.widget<TextField>(find.byKey(Key('reorder-qty-$id')));
      expect(field(a).controller!.text, '36'); // 2 x 20 - 4
      await tapKey(t, 'reorder-plus-$a');
      expect(field(a).controller!.text, '37');
      await tapKey(t, 'reorder-minus-$a');
      await tapKey(t, 'reorder-minus-$a');
      expect(field(a).controller!.text, '35');
      await t.enterText(find.byKey(Key('reorder-qty-$a')), '48');
      await t.pump();
      expect(c.read(reorderQuantitiesProvider)[a], 48);
      await disposeApp(t);
    });

    testWidgets('restocking removes a medicine from the list', (t) async {
      final (a, _) = await twoLowMedicines(t);
      final batch = (await db(
        t,
        () => env.db.select(env.db.batches).get(),
      )).firstWhere((x) => x.medicineId == a);
      final c = await open(t);
      await go(t, c, '/more/reorder');
      expect(find.byKey(Key('reorder-qty-$a')), findsOneWidget);
      await db(
        t,
        () => env.adjustStock(
          batchId: batch.id,
          delta: 100,
          reason: AdjustmentReason.received,
        ),
      );
      await settle(t);
      expect(find.byKey(Key('reorder-qty-$a')), findsNothing);
      await disposeApp(t);
    });

    testWidgets('empty state', (t) async {
      final c = await open(t);
      await go(t, c, '/more/reorder');
      expect(find.byKey(const Key('reorder-empty')), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('reminders can be snoozed with undo, and resumed', (t) async {
      final (a, _) = await twoLowMedicines(t);
      final c = await open(t);
      await go(t, c, '/more/reorder');
      await tapKey(t, 'reorder-menu-$a');
      await tapKey(t, 'reorder-snooze-$a');
      await tapKey(t, 'rsnooze-3d');
      expect(find.text('Reorder reminders snoozed'), findsOneWidget);
      expect(find.text('Snoozed until Oct 20, 2026'), findsOneWidget);
      await tapKey(t, 'snack-undo');
      expect(find.textContaining('Snoozed until'), findsNothing);

      await tapKey(t, 'reorder-menu-$a');
      await tapKey(t, 'reorder-snooze-$a');
      await tapKey(t, 'rsnooze-1w');
      await tapKey(t, 'reorder-menu-$a');
      await tapKey(t, 'reorder-resume-$a');
      expect(find.textContaining('Snoozed until'), findsNothing);
      await disposeApp(t);
    });

    testWidgets('More shows how many need reordering', (t) async {
      await twoLowMedicines(t);
      final c = await open(t);
      await go(t, c, '/more');
      expect(
        find.descendant(
          of: find.byKey(const Key('more-reorder-count')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
      await tapKey(t, 'more-reorder');
      expect(find.text('Reorder list'), findsOneWidget);
      await disposeApp(t);
    });
  });
}

/// Fails the first pass, succeeds afterwards.
class _FailingThenOk extends StubAlertEngine {
  _FailingThenOk(super.env) : _env = env;

  final TestEnv _env;
  int calls = 0;

  @override
  Future<ReplanSummary> replan() async {
    calls++;
    return ReplanSummary(
      at: _env.clock.now(),
      took: Duration.zero,
      error: calls == 1 ? StateError('boom') : null,
    );
  }
}
