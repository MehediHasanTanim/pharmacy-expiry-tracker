import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';

import '../support/pump_app.dart';
import '../support/test_env.dart';

void main() {
  late TestEnv env;

  setUp(() {
    env = TestEnv();
    // A blinking cursor keeps scheduling frames, so pumpAndSettle would never
    // settle while a text field has focus.
    EditableText.debugDeterministicCursor = true;
  });
  tearDown(() async {
    EditableText.debugDeterministicCursor = false;
    await env.dispose();
  });

  Future<void> useTallScreen(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(900, 2400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await settle(tester);
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).first);
    await settle(tester);
  }

  testWidgets('empty state leads to creating a medicine (MED-1)', (t) async {
    await useTallScreen(t);
    await pumpApp(t, env);
    await tapText(t, 'Stock');
    expect(find.text('No medicines yet'), findsOneWidget);

    await tapKey(t, 'empty-add-medicine');
    expect(find.text('New medicine'), findsOneWidget);

    // Brand is required.
    await tapKey(t, 'medicine-save');
    expect(find.text('Brand name is required'), findsOneWidget);

    await enter(t, 'field-brand', 'Amoxil');
    await enter(t, 'field-generic', 'Amoxicillin');
    await enter(t, 'field-strength', '500 mg');
    await enter(t, 'field-reorder', '20');
    await tapKey(t, 'medicine-save');

    expect(find.text('Amoxil 500 mg'), findsOneWidget);
    final saved = await db(t, () => env.medicines.watchAll().first);
    expect(saved.single.medicine.reorderLevel, 20);
    expect(saved.single.medicine.genericName, 'Amoxicillin');
    await disposeApp(t);
  });

  testWidgets('invalid reorder level and pack size are rejected', (t) async {
    await useTallScreen(t);
    await pumpApp(t, env);
    await tapText(t, 'Stock');
    await tapKey(t, 'empty-add-medicine');
    await enter(t, 'field-brand', 'X');
    await enter(t, 'field-pack-size', '0');
    await tapKey(t, 'medicine-save');
    expect(find.text('Enter a whole number above 0'), findsOneWidget);
    expect(await db(t, () => env.medicines.watchAll().first), isEmpty);
    await disposeApp(t);
  });

  testWidgets('saving a duplicate medicine asks first (MED-5)', (t) async {
    await db(t, () => env.medicine());
    await useTallScreen(t);
    await pumpApp(t, env);
    await tapText(t, 'Stock');
    await tapKey(t, 'add-stock');
    await tapKey(t, 'picker-create');

    await enter(t, 'field-brand', 'amoxil');
    await enter(t, 'field-strength', '500 MG');
    // Default form is Tablet; the existing one is a capsule, so no clash yet.
    await selectForm(t, 'Capsule');
    await tapKey(t, 'medicine-save');
    expect(find.text('Possible duplicate'), findsOneWidget);

    await tapText(t, 'Cancel');
    expect(find.text('Possible duplicate'), findsNothing);
    expect(await db(t, () => env.medicines.watchAll().first), hasLength(1));

    await tapKey(t, 'medicine-save');
    await tapText(t, 'Save anyway');
    expect(await db(t, () => env.medicines.watchAll().first), hasLength(2));
    await disposeApp(t);
  });

  testWidgets('archiving hides a medicine; the filter shows it again', (
    t,
  ) async {
    final id = await db(t, () => env.medicine());
    await useTallScreen(t);
    await pumpApp(t, env);
    await tapText(t, 'Stock');
    await tapText(t, 'Amoxil 500 mg');
    await tapKey(t, 'medicine-edit');
    await tapKey(t, 'medicine-archive');
    await tapText(t, 'Archive');

    // The form closes onto the (now archived) medicine; go back to the list.
    expect(find.text('Archived'), findsWidgets);
    await t.pageBack();
    await settle(t);
    expect(find.text('Amoxil 500 mg'), findsNothing);
    expect((await db(t, () => env.medicines.getById(id)))!.isArchived, isTrue);

    await tapKey(t, 'filter-archived');
    expect(find.text('Amoxil 500 mg'), findsOneWidget);
    expect(find.textContaining('Archived'), findsWidgets);
    await disposeApp(t);
  });

  testWidgets(
    'sprint demo: receive two batches, adjust stock, search by batch number',
    (t) async {
      await db(t, () => env.medicine());
      await useTallScreen(t);
      await pumpApp(t, env);
      await tapText(t, 'Stock');
      await tapText(t, 'Amoxil 500 mg');
      expect(find.text('No batches yet'), findsOneWidget);

      // Batch 1: month-only expiry typed as 08 / 2027 (BAT-2, BAT-7).
      await tapKey(t, 'add-batch');
      await enter(t, 'field-batch-number', 'a1');
      await enter(t, 'expiry-month', '08');
      await enter(t, 'expiry-year', '2027');
      expect(find.text('Expires Aug 31, 2027'), findsOneWidget);
      await enter(t, 'field-quantity', '10');
      await enter(t, 'field-cost', '2.50');
      await tapKey(t, 'batch-save-another');
      expect(find.text('Batch saved'), findsOneWidget);
      // Form is cleared for the next batch, medicine stays.
      expect(find.text('Amoxil 500 mg'), findsOneWidget);
      expect(find.text('Expires Aug 31, 2027'), findsNothing);

      // Batch 2: exact date.
      await enter(t, 'field-batch-number', 'B2');
      await tapKey(t, 'expiry-exact-toggle');
      await enter(t, 'expiry-day', '15');
      await enter(t, 'expiry-month', '03');
      await enter(t, 'expiry-year', '2028');
      await enter(t, 'field-quantity', '4');
      await tapKey(t, 'batch-save');

      // Back on the medicine: both batches, soonest expiry first.
      expect(find.text('Batch A1'), findsOneWidget);
      expect(find.text('Batch B2'), findsOneWidget);
      final a1y = t.getTopLeft(find.text('Batch A1')).dy;
      final b2y = t.getTopLeft(find.text('Batch B2')).dy;
      expect(a1y, lessThan(b2y));

      final batches = await db(t, () => env.db.select(env.db.batches).get());
      expect(batches.map((b) => b.batchNumber).toSet(), {'A1', 'B2'});
      expect(
        batches.singleWhere((b) => b.batchNumber == 'A1').expiryPrecision,
        'MONTH',
      );
      expect(
        batches.singleWhere((b) => b.batchNumber == 'B2').expiryPrecision,
        'DAY',
      );

      // Adjust stock: sell 3 of A1 (BAT-5).
      await tapText(t, 'Batch A1');
      await tapKey(t, 'batch-adjust');
      await tapKey(t, 'qty-plus');
      await tapKey(t, 'qty-plus');
      expect(
        t
            .widget<TextField>(find.byKey(const Key('adjust-qty')))
            .controller!
            .text,
        '3',
      );
      await enter(t, 'adjust-note', 'counter sale');
      await tapKey(t, 'adjust-apply');

      expect(find.text('−3 · Sold / used'), findsOneWidget);
      expect(find.textContaining('counter sale'), findsOneWidget);
      final a1 = (await db(
        t,
        () => env.db.select(env.db.batches).get(),
      )).singleWhere((b) => b.batchNumber == 'A1');
      expect(a1.quantityOnHand, 7);

      // Search by batch number from the Stock tab (SCN-1).
      await t.pageBack();
      await settle(t);
      await t.pageBack();
      await settle(t);
      await enter(t, 'stock-search', 'b2');
      await settle(t);
      expect(find.text('Batches'), findsOneWidget);
      expect(find.text('Batch B2'), findsOneWidget);
      expect(find.text('Medicines'), findsNothing);
      await disposeApp(t);
    },
  );

  testWidgets('duplicate batch number offers to add to the existing batch', (
    t,
  ) async {
    final med = await db(t, () => env.medicine());
    await db(t, () => env.addBatch(env.batchInput(med, number: 'A1')));
    await useTallScreen(t);
    await pumpApp(t, env);
    await tapText(t, 'Stock');
    await tapText(t, 'Amoxil 500 mg');
    await tapKey(t, 'add-batch');
    await enter(t, 'field-batch-number', 'A1');
    await enter(t, 'expiry-month', '08');
    await enter(t, 'expiry-year', '2027');
    await enter(t, 'field-quantity', '5');
    await tapKey(t, 'batch-save');

    expect(find.text('Batch already exists'), findsOneWidget);
    // Same number and same expiry: merging is the only option.
    expect(find.byKey(const Key('duplicate-separate')), findsNothing);
    await tapKey(t, 'duplicate-merge');

    final batches = await db(t, () => env.db.select(env.db.batches).get());
    expect(batches, hasLength(1));
    expect(batches.single.quantityOnHand, 15);
    await disposeApp(t);
  });

  testWidgets('same number but different expiry can be kept separate', (
    t,
  ) async {
    final med = await db(t, () => env.medicine());
    await db(t, () => env.addBatch(env.batchInput(med, number: 'A1')));
    await useTallScreen(t);
    await pumpApp(t, env);
    await tapText(t, 'Stock');
    await tapText(t, 'Amoxil 500 mg');
    await tapKey(t, 'add-batch');
    await enter(t, 'field-batch-number', 'A1');
    await enter(t, 'expiry-month', '01');
    await enter(t, 'expiry-year', '2029');
    await enter(t, 'field-quantity', '5');
    await tapKey(t, 'batch-save');
    await tapKey(t, 'duplicate-separate');
    expect(
      await db(t, () => env.db.select(env.db.batches).get()),
      hasLength(2),
    );
    await disposeApp(t);
  });

  testWidgets('batch form validates required fields', (t) async {
    final med = await db(t, () => env.medicine());
    await useTallScreen(t);
    await pumpApp(t, env);
    await tapText(t, 'Stock');
    await tapText(t, 'Amoxil 500 mg');
    await tapKey(t, 'add-batch');
    await tapKey(t, 'batch-save');
    expect(find.text('Batch number is required'), findsOneWidget);
    expect(find.text('Enter the expiry date'), findsOneWidget);
    expect(find.text('Enter a quantity above 0'), findsOneWidget);
    expect(await db(t, () => env.batches.watchByMedicine(med).first), isEmpty);
    await disposeApp(t);
  });

  testWidgets('received date is remembered between consecutive adds', (
    t,
  ) async {
    await db(t, () => env.medicine());
    await useTallScreen(t);
    await pumpApp(t, env);
    await tapText(t, 'Stock');
    await tapText(t, 'Amoxil 500 mg');
    await tapKey(t, 'add-batch');
    // Pick the 5th of the current month in the date picker.
    await tapKey(t, 'field-received');
    await tapText(t, '5');
    await tapText(t, 'OK');
    await enter(t, 'field-batch-number', 'R1');
    await enter(t, 'expiry-month', '08');
    await enter(t, 'expiry-year', '2027');
    await enter(t, 'field-quantity', '1');
    await tapKey(t, 'batch-save');

    await tapKey(t, 'add-batch');
    expect(find.text('Oct 5, 2026'), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('adjust sheet: cannot exceed stock; write-offs ask to confirm', (
    t,
  ) async {
    final med = await db(t, () => env.medicine());
    final b = await db(t, () => env.addBatch(env.batchInput(med, quantity: 3)));
    await useTallScreen(t);
    await pumpApp(t, env);
    await tapText(t, 'Stock');
    await tapText(t, 'Amoxil 500 mg');
    await tapText(t, 'Batch A1');
    await tapKey(t, 'batch-adjust');

    await enter(t, 'adjust-qty', '9');
    expect(find.text('Only 3 on hand'), findsOneWidget);
    expect(
      t.widget<FilledButton>(find.byKey(const Key('adjust-apply'))).onPressed,
      isNull,
    );

    await tapKey(t, 'reason-DISCARDED_EXPIRED');
    // "All" jumps to the full on-hand quantity.
    await tapKey(t, 'qty-all');
    await tapKey(t, 'adjust-apply');
    expect(find.text('Write off stock?'), findsOneWidget);
    // Nothing is written until confirmed.
    expect(
      (await db(t, () => env.batches.getById(b.batch.id)))!.quantityOnHand,
      3,
    );
    await tapKey(t, 'adjust-confirm');

    final after = (await db(t, () => env.batches.getById(b.batch.id)))!;
    expect(after.quantityOnHand, 0);
    expect(after.status, BatchStatus.discarded);
    await disposeApp(t);
  });

  testWidgets('recent searches are offered and can be cleared', (t) async {
    await db(t, () => env.medicine());
    await useTallScreen(t);
    await pumpApp(t, env);
    await tapText(t, 'Stock');

    await t.tap(find.byKey(const Key('stock-search')));
    await t.pump();
    await enter(t, 'stock-search', 'amox');
    await t.testTextInput.receiveAction(TextInputAction.done);
    await settle(t);
    expect(await db(t, () => env.recent.load()), ['amox']);

    // Empty + focused field shows the history.
    await enter(t, 'stock-search', '');
    await settle(t);
    expect(find.text('Recent searches'), findsOneWidget);
    expect(find.byKey(const Key('recent-amox')), findsOneWidget);

    await tapKey(t, 'recent-amox');
    expect(find.text('Amoxil 500 mg'), findsOneWidget);

    await enter(t, 'stock-search', '');
    await settle(t);
    await tapKey(t, 'clear-recent');
    expect(await db(t, () => env.recent.load()), isEmpty);
    await disposeApp(t);
  });

  testWidgets('medicine tile shows stock total and nearest expiry chip', (
    t,
  ) async {
    final med = await db(t, () => env.medicine());
    await db(
      t,
      () => env.addBatch(
        env.batchInput(med, expiry: ExpiryDate.day(2026, 11, 1), quantity: 6),
      ),
    );
    await useTallScreen(t);
    await pumpApp(t, env);
    await tapText(t, 'Stock');
    expect(find.text('6 on hand'), findsOneWidget);
    expect(find.text('15 days left'), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('editing a batch keeps quantity locked', (t) async {
    final med = await db(t, () => env.medicine());
    final b = await db(t, () => env.addBatch(env.batchInput(med, quantity: 8)));
    await useTallScreen(t);
    await pumpApp(t, env);
    await tapText(t, 'Stock');
    await tapText(t, 'Amoxil 500 mg');
    await tapText(t, 'Batch A1');
    await tapKey(t, 'batch-edit');

    final qty = t.widget<TextFormField>(
      find.byKey(const Key('field-quantity')),
    );
    expect(qty.enabled, isFalse);
    expect(find.text('To change quantity, use Adjust stock'), findsOneWidget);

    await enter(t, 'field-batch-number', 'z9');
    await tapKey(t, 'batch-save');
    final saved = (await db(t, () => env.batches.getById(b.batch.id)))!;
    expect(saved.batchNumber, 'Z9');
    expect(saved.quantityOnHand, 8);
    await disposeApp(t);
  });
}

/// Picks [label] in the dosage form dropdown.
Future<void> selectForm(WidgetTester tester, String label) async {
  await tester.tap(find.byKey(const Key('field-form')));
  await settle(tester);
  await tester.tap(find.text(label).last);
  await settle(tester);
}
