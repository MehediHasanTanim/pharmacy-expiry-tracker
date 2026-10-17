import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/app/app.dart';
import 'package:pharmacy_expiry_tracker/app/router.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/settings_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';

import '../support/pump_app.dart';
import '../support/test_env.dart';

void main() {
  late TestEnv env;
  final today = DateTime(2026, 10, 17);

  setUp(() {
    env = TestEnv();
    EditableText.debugDeterministicCursor = true;
  });
  tearDown(() async {
    EditableText.debugDeterministicCursor = false;
    await env.dispose();
  });

  Future<void> tallScreen(WidgetTester t) async {
    t.view
      ..physicalSize = const Size(900, 2400)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
  }

  ExpiryDate inDays(int n) {
    final d = DateTime(today.year, today.month, today.day + n);
    return ExpiryDate.day(d.year, d.month, d.day);
  }

  Future<Batch> add(
    WidgetTester t,
    String med,
    String number,
    int days, {
    int qty = 10,
    int? cost,
  }) async => (await db(
    t,
    () => env.addBatch(
      env.batchInput(
        med,
        number: number,
        expiry: inDays(days),
        quantity: qty,
        costMinor: cost,
      ),
    ),
  )).batch;

  Future<void> openExpiry(WidgetTester t) async {
    await pumpApp(t, env);
    await t.tap(find.text('Expiry').first);
    await settle(t);
  }

  Future<void> tapKey(WidgetTester t, String key) async {
    await t.tap(find.byKey(Key(key)));
    await settle(t);
  }

  Finder row(String batchId) => find.byKey(Key('expiry-row-$batchId'));

  testWidgets('empty state explains the window', (t) async {
    await tallScreen(t);
    await openExpiry(t);
    expect(find.text('Nothing is near expiry'), findsOneWidget);
    expect(find.text('Nothing expires within 90 days.'), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets(
    'groups by urgency with counts, highlights expired, shows value at risk',
    (t) async {
      final m = await db(t, env.medicine);
      final expired = await add(t, m, 'OLD1', -3, qty: 4, cost: 250);
      final soon = await add(t, m, 'SOON1', 10, qty: 2, cost: 600);
      await add(t, m, 'MID1', 45);
      await add(t, m, 'LATE1', 80, qty: 1, cost: 100);
      await tallScreen(t);
      await openExpiry(t);

      // Header chips with counts (EXP-2).
      expect(find.text('All · 4'), findsOneWidget);
      expect(find.text('Expired · 1'), findsOneWidget);
      expect(find.text('0–30 d · 1'), findsOneWidget);
      expect(find.text('31–60 d · 1'), findsOneWidget);
      expect(find.text('61–90 d · 1'), findsOneWidget);
      expect(find.byKey(const Key('chip-ok')), findsNothing);

      // Sections in expiry order; expired is the highlighted one (EXP-8).
      expect(find.byKey(const Key('section-expired')), findsOneWidget);
      expect(find.text('Expired · remove from shelf, 1'), findsOneWidget);
      expect(find.byKey(const Key('section-d30')), findsOneWidget);
      final yExpired = t.getTopLeft(row(expired.id)).dy;
      final ySoon = t.getTopLeft(row(soon.id)).dy;
      expect(yExpired, lessThan(ySoon));

      // Row content (EXP-3).
      expect(find.text('Expired 3 days ago'), findsOneWidget);
      expect(find.text('10 days left'), findsOneWidget);
      expect(find.text('Batch OLD1 · 4 on hand'), findsOneWidget);
      expect(find.text('Expires Oct 14, 2026'), findsOneWidget);
      expect(find.text('Value: 10.00'), findsOneWidget); // 4 x 2.50
      expect(find.text('Value: —'), findsOneWidget); // MID1 has no price

      expect(find.text('Value: 12.00'), findsOneWidget); // 2 x 6.00
      // 10.00 + 12.00 + 1.00, one batch unpriced (S2-09).
      expect(find.text('Value at risk: 23.00'), findsOneWidget);
      expect(find.text('1 batch has no price'), findsOneWidget);
      await disposeApp(t);
    },
  );

  testWidgets('a bucket chip filters the list', (t) async {
    final m = await db(t, env.medicine);
    final expired = await add(t, m, 'OLD1', -3);
    final soon = await add(t, m, 'SOON1', 10);
    await tallScreen(t);
    await openExpiry(t);

    await tapKey(t, 'chip-expired');
    expect(row(expired.id), findsOneWidget);
    expect(row(soon.id), findsNothing);
    // Counts keep describing every bucket.
    expect(find.text('0–30 d · 1'), findsOneWidget);

    await tapKey(t, 'chip-all');
    expect(row(soon.id), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('search by batch number and by name', (t) async {
    final a = await db(t, () => env.medicine(brand: 'Amoxil'));
    final b = await db(t, () => env.medicine(brand: 'Panadol', generic: null));
    final ba = await add(t, a, 'LOT-AAA', 5);
    final bb = await add(t, b, 'LOT-BBB', 6);
    await tallScreen(t);
    await openExpiry(t);

    await tapKey(t, 'expiry-search-toggle');
    await t.enterText(find.byKey(const Key('expiry-search')), 'bbb');
    await settle(t);
    expect(row(bb.id), findsOneWidget);
    expect(row(ba.id), findsNothing);

    await t.enterText(find.byKey(const Key('expiry-search')), 'amox');
    await settle(t);
    expect(row(ba.id), findsOneWidget);
    expect(row(bb.id), findsNothing);

    await t.enterText(find.byKey(const Key('expiry-search')), 'zzz');
    await settle(t);
    expect(find.text('No batches match these filters'), findsOneWidget);
    await tapKey(t, 'expiry-clear-filters');
    await disposeApp(t);
  });

  testWidgets('filter sheet sorts, filters and remembers the selection', (
    t,
  ) async {
    final a = await db(
      t,
      () => env.medicine(brand: 'Amoxil', category: 'Antibiotic'),
    );
    final p = await db(
      t,
      () =>
          env.medicine(brand: 'Panadol', generic: null, category: 'Analgesic'),
    );
    final cheapSoon = await add(t, a, 'CHEAP', 5, qty: 1, cost: 100);
    final bigLater = await add(t, p, 'BIG', 40, qty: 10, cost: 1000);
    await tallScreen(t);
    await openExpiry(t);

    // Default: soonest first.
    expect(
      t.getTopLeft(row(cheapSoon.id)).dy,
      lessThan(t.getTopLeft(row(bigLater.id)).dy),
    );

    await tapKey(t, 'expiry-filter');
    await tapKey(t, 'sort-value');
    await tapKey(t, 'filter-apply');
    expect(
      t.getTopLeft(row(bigLater.id)).dy,
      lessThan(t.getTopLeft(row(cheapSoon.id)).dy),
    );
    // Section headers are only for expiry order.
    expect(find.byKey(const Key('section-d30')), findsNothing);

    // The choice is stored (S2-05).
    final stored = await db(t, () => SettingsRepositoryImpl(env.db).load());
    expect(stored.expirySort, 'value');

    // Category filter.
    await tapKey(t, 'expiry-filter');
    await tapKey(t, 'filter-category');
    await t.tap(find.text('Analgesic').last);
    await settle(t);
    await tapKey(t, 'filter-apply');
    expect(row(bigLater.id), findsOneWidget);
    expect(row(cheapSoon.id), findsNothing);
    expect(
      (await db(t, () => SettingsRepositoryImpl(env.db).load())).expiryCategory,
      'Analgesic',
    );

    // Reset.
    await tapKey(t, 'expiry-filter');
    await tapKey(t, 'filter-reset');
    await tapKey(t, 'filter-apply');
    expect(row(cheapSoon.id), findsOneWidget);
    expect(row(bigLater.id), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('snooze from the menu, with Undo (EXP-5)', (t) async {
    final m = await db(t, env.medicine);
    final b = await add(t, m, 'SN1', 20);
    await tallScreen(t);
    await openExpiry(t);

    await tapKey(t, 'row-menu-${b.id}');
    await tapKey(t, 'action-snooze');
    expect(find.text('Snooze alerts for this batch'), findsOneWidget);
    await tapKey(t, 'snooze-3d');
    expect(find.text('Alerts snoozed until Oct 20, 2026'), findsOneWidget);
    expect(find.text('Snoozed until Oct 20, 2026'), findsOneWidget);
    expect(
      (await db(t, () => env.batches.getById(b.id)))!.snoozedUntil,
      DateTime(2026, 10, 20),
    );

    await tapKey(t, 'snack-undo');
    expect(
      (await db(t, () => env.batches.getById(b.id)))!.snoozedUntil,
      isNull,
    );
    expect(find.textContaining('Snoozed until'), findsNothing);
    await disposeApp(t);
  });

  testWidgets('snooze until the next alert uses the lead-time settings', (
    t,
  ) async {
    final m = await db(t, env.medicine);
    final b = await add(t, m, 'SN2', 20); // expires 2026-11-06
    await tallScreen(t);
    await openExpiry(t);
    await tapKey(t, 'row-menu-${b.id}');
    await tapKey(t, 'action-snooze');
    // Leads 90,60,30,14,7,1,0 -> Oct 23 (14 d), the first after today.
    expect(find.text('Until the next alert (Oct 23, 2026)'), findsOneWidget);
    await tapKey(t, 'snooze-next');
    expect(
      (await db(t, () => env.batches.getById(b.id)))!.snoozedUntil,
      DateTime(2026, 10, 23),
    );
    await disposeApp(t);
  });

  testWidgets('mark handled, show the flag, undo', (t) async {
    final m = await db(t, env.medicine);
    final b = await add(t, m, 'H1', -2);
    await tallScreen(t);
    await openExpiry(t);

    await t.longPress(row(b.id));
    await settle(t);
    await tapKey(t, 'action-handled');
    expect(find.text('Marked as handled'), findsOneWidget);
    expect(find.text('Handled'), findsOneWidget);
    expect(
      (await db(t, () => env.batches.getById(b.id)))!.handledAt,
      isNotNull,
    );

    await tapKey(t, 'snack-undo');
    expect(find.text('Handled'), findsNothing);
    expect((await db(t, () => env.batches.getById(b.id)))!.handledAt, isNull);
    await disposeApp(t);
  });

  testWidgets('hide handled filter keeps expired stock visible', (t) async {
    final m = await db(t, env.medicine);
    final expired = await add(t, m, 'E1', -2);
    final near = await add(t, m, 'N1', 5);
    await db(t, () => env.alertState.markHandled(expired.id));
    await db(t, () => env.alertState.markHandled(near.id));
    await tallScreen(t);
    await openExpiry(t);

    await tapKey(t, 'expiry-filter');
    await tapKey(t, 'filter-hide-handled');
    await tapKey(t, 'filter-apply');
    expect(row(expired.id), findsOneWidget);
    expect(row(near.id), findsNothing);
    await disposeApp(t);
  });

  testWidgets('sell down from the menu updates the row', (t) async {
    final m = await db(t, env.medicine);
    final b = await add(t, m, 'S1', 10, qty: 8);
    await tallScreen(t);
    await openExpiry(t);

    await tapKey(t, 'row-menu-${b.id}');
    await tapKey(t, 'action-sold');
    await t.enterText(find.byKey(const Key('adjust-qty')), '3');
    await t.pump();
    await tapKey(t, 'adjust-apply');

    expect(find.text('Batch S1 · 5 on hand'), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets(
    'swipe to discard writes the stock off after confirming (EXP-7)',
    (t) async {
      final m = await db(t, env.medicine);
      final b = await add(t, m, 'D1', -1, qty: 6, cost: 200);
      await tallScreen(t);
      await openExpiry(t);

      await t.drag(row(b.id), const Offset(-500, 0));
      await settle(t);
      await tapKey(t, 'swipe-discard-${b.id}');
      expect(find.text('Write off stock?'), findsOneWidget);
      // Nothing happens until confirmed.
      expect((await db(t, () => env.batches.getById(b.id)))!.quantityOnHand, 6);
      await tapKey(t, 'discard-confirm');

      final after = (await db(t, () => env.batches.getById(b.id)))!;
      expect(after.quantityOnHand, 0);
      expect(after.status, BatchStatus.discarded);
      final h = await db(t, () => env.batches.watchAdjustments(b.id).first);
      expect(h.first.reason, AdjustmentReason.discardedExpired);
      expect(h.first.valueImpact?.minor, 1200);
      expect(row(b.id), findsNothing);
      expect(find.text('1 batch discarded'), findsOneWidget);
      expect(find.text('Nothing is near expiry'), findsOneWidget);
      await disposeApp(t);
    },
  );

  testWidgets('swipe to sell opens the adjust sheet', (t) async {
    final m = await db(t, env.medicine);
    final b = await add(t, m, 'SW1', 12);
    await tallScreen(t);
    await openExpiry(t);
    await t.drag(row(b.id), const Offset(-500, 0));
    await settle(t);
    await tapKey(t, 'swipe-sold-${b.id}');
    expect(find.text('Adjust stock'), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('select mode: bulk discard of several batches', (t) async {
    final m = await db(t, env.medicine);
    final a = await add(t, m, 'A', -5);
    final b = await add(t, m, 'B', -4);
    final c = await add(t, m, 'C', -3);
    await tallScreen(t);
    await openExpiry(t);

    await tapKey(t, 'expiry-select');
    expect(find.text('0 selected'), findsOneWidget);
    expect(
      t
          .widget<FilledButton>(find.byKey(const Key('discard-selected')))
          .onPressed,
      isNull,
    );
    await tapKey(t, 'select-${a.id}');
    await tapKey(t, 'select-${c.id}');
    expect(find.text('2 selected'), findsOneWidget);
    await tapKey(t, 'discard-selected');
    expect(
      find.text(
        'Write off the remaining stock of 2 batches? This is recorded as a loss.',
      ),
      findsOneWidget,
    );
    await tapKey(t, 'bulk-discard-confirm');

    expect(row(a.id), findsNothing);
    expect(row(c.id), findsNothing);
    expect(row(b.id), findsOneWidget);
    expect(find.text('2 batches discarded'), findsOneWidget);
    // Selection mode ends.
    expect(find.byKey(const Key('discard-selected')), findsNothing);
    await disposeApp(t);
  });

  testWidgets('tapping a row opens the batch', (t) async {
    final m = await db(t, env.medicine);
    final b = await add(t, m, 'OPEN1', 10);
    await tallScreen(t);
    await openExpiry(t);
    await t.tap(row(b.id));
    await settle(t);
    expect(find.text('Batch OPEN1'), findsWidgets);
    expect(find.text('Adjust stock'), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('loads further pages while scrolling (S2-02)', (t) async {
    await db(t, () async {
      await env.db.customStatement('''
        INSERT INTO medicines (id, brand_name, dosage_form, unit, reorder_level,
          is_archived, search_text, created_at, updated_at)
        VALUES ('m1', 'Bulk', 'tablet', 'strip', 0, 0, 'bulk', 0, 0)
      ''');
      await env.db.customStatement('''
        INSERT INTO batches (id, medicine_id, batch_number, expiry_date,
          expiry_precision, quantity_received, quantity_on_hand,
          received_date, status, created_at, updated_at)
        WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 130)
        SELECT 'b' || printf('%03d', i), 'm1', 'L' || printf('%03d', i),
               date('2026-10-17', (i % 80) || ' days'),
               'DAY', 1, 1, '2026-10-17', 'ACTIVE', 0, 0 FROM n
      ''');
    });
    await tallScreen(t);
    await openExpiry(t);

    expect(find.text('All · 130'), findsOneWidget);
    // The last batch by id order is on a later page; scrolling must fetch it.
    expect(find.text('Batch L130 · 1 on hand'), findsNothing);
    await t.scrollUntilVisible(
      find.text('Batch L130 · 1 on hand'),
      600,
      scrollable: find.descendant(
        of: find.byKey(const Key('expiry-list')),
        matching: find.byType(Scrollable),
      ),
      maxScrolls: 200,
    );
    await settle(t);
    expect(find.text('Batch L130 · 1 on hand'), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('a notification deep link can preselect a bucket', (t) async {
    final m = await db(t, env.medicine);
    final expired = await add(t, m, 'OLD', -3);
    final soon = await add(t, m, 'SOON', 10);
    await tallScreen(t);
    await pumpApp(t, env);

    final container = ProviderScope.containerOf(t.element(find.byType(App)));
    container.read(routerProvider).go('/expiry?bucket=expired');
    await settle(t);
    expect(row(expired.id), findsOneWidget);
    expect(row(soon.id), findsNothing);
    await disposeApp(t);
  });
}
