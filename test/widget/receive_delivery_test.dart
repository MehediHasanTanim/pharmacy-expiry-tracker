import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/app/router.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';

import '../support/pump_app.dart';
import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late String sup;

  setUp(() async {
    env = TestEnv();
    await env.medicine(brand: 'Napa', strength: '500 mg');
    await env.medicine(brand: 'Amoxil', strength: '250 mg');
    sup = await env.supplier(name: 'ABC Pharma');
    EditableText.debugDeterministicCursor = true;
  });
  tearDown(() async {
    EditableText.debugDeterministicCursor = false;
    await env.dispose();
  });

  Future<void> real(WidgetTester t, {int rounds = 5}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)),
      );
      await t.pump(const Duration(milliseconds: 150));
    }
  }

  Future<void> open(WidgetTester t) async {
    t.view
      ..physicalSize = const Size(900, 3200)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await pumpApp(t, env);
    final c = ProviderScope.containerOf(t.element(find.byType(Scaffold).first));
    c.read(routerProvider).go(Routes.receiveDelivery);
    await settle(t);
    await real(t);
  }

  Future<void> tapKey(WidgetTester t, String key) async {
    await t.tap(find.byKey(Key(key)));
    await real(t);
  }

  Future<void> enter(WidgetTester t, String key, String text) async {
    await t.enterText(find.byKey(Key(key)), text);
    await t.pump();
  }

  Future<void> expiry(
    WidgetTester t,
    int lineId,
    String mm,
    String yyyy,
  ) async {
    final line = find.byKey(ValueKey('receive-line-$lineId'));
    await t.enterText(
      find.descendant(
        of: line,
        matching: find.byKey(const Key('expiry-month')),
      ),
      mm,
    );
    await t.enterText(
      find.descendant(of: line, matching: find.byKey(const Key('expiry-year'))),
      yyyy,
    );
    await t.pump();
  }

  Future<void> pickMedicine(WidgetTester t, int i, String name) async {
    await tapKey(t, 'receive-medicine-$i');
    await t.tap(find.text(name).first);
    await real(t);
  }

  Future<int> batchCount(WidgetTester t) async =>
      (await t.runAsync(() => env.db.select(env.db.batches).get()))!.length;

  testWidgets('two batches and one invoice from the total', (t) async {
    await open(t);
    await pickMedicine(t, 0, 'Napa 500 mg');
    await enter(t, 'receive-batch-0', 'N1');
    await expiry(t, 0, '08', '2027');
    await enter(t, 'receive-qty-0', '20');
    await enter(t, 'receive-cost-0', '1.50');

    await tapKey(t, 'receive-add-line');
    await pickMedicine(t, 1, 'Amoxil 250 mg');
    await enter(t, 'receive-batch-1', 'A9');
    await expiry(t, 1, '03', '2028');
    await enter(t, 'receive-qty-1', '5');

    await tapKey(t, 'receive-supplier');
    await t.tap(find.text('ABC Pharma').last);
    await real(t);
    await enter(t, 'receive-number', 'INV-7');
    await enter(t, 'receive-total', '350.00');

    await tapKey(t, 'receive-save');
    expect(find.textContaining('Delivery saved: 2 batches'), findsOneWidget);

    final batches = await t.runAsync(() => env.db.select(env.db.batches).get());
    expect(batches!.map((b) => b.batchNumber).toSet(), {'N1', 'A9'});
    expect(
      batches.every((b) => b.supplierId == sup && b.invoiceId != null),
      isTrue,
    );
    final invoices = await t.runAsync(
      () => env.db.select(env.db.supplierInvoices).get(),
    );
    expect(invoices!.single.totalMinor, 35000);
    expect(invoices.single.invoiceNumber, 'INV-7');
    // The draft is gone once the delivery is saved.
    expect(await t.runAsync(() => env.drafts.load('bulk_receive')), isNull);
    expect(const Money(35000), const Money(35000));
    await disposeApp(t);
  });

  testWidgets('problems are shown on their lines and nothing is saved', (
    t,
  ) async {
    await open(t);
    await pickMedicine(t, 0, 'Napa 500 mg');
    await enter(t, 'receive-batch-0', 'N1');
    await expiry(t, 0, '08', '2027');
    await enter(t, 'receive-qty-0', '20');
    await tapKey(t, 'receive-add-line');
    // A second line for the same batch, and a third with no medicine.
    await pickMedicine(t, 1, 'Napa 500 mg');
    await enter(t, 'receive-batch-1', 'n1');
    await expiry(t, 1, '08', '2027');
    await enter(t, 'receive-qty-1', '4');
    await tapKey(t, 'receive-add-line');
    await enter(t, 'receive-batch-2', 'X');

    await tapKey(t, 'receive-save');
    expect(find.byKey(const Key('receive-line-error-1')), findsOneWidget);
    expect(find.text('This batch is listed twice'), findsOneWidget);
    expect(find.text('Choose a medicine'), findsWidgets);
    expect(await batchCount(t), 0);
    await disposeApp(t);
  });

  testWidgets('an invoice total without a supplier is refused', (t) async {
    await open(t);
    await pickMedicine(t, 0, 'Napa 500 mg');
    await enter(t, 'receive-batch-0', 'N1');
    await expiry(t, 0, '08', '2027');
    await enter(t, 'receive-qty-0', '20');
    await enter(t, 'receive-total', '100');
    await tapKey(t, 'receive-save');
    expect(
      find.text('Choose a supplier to create the invoice.'),
      findsOneWidget,
    );
    expect(await batchCount(t), 0);
    await disposeApp(t);
  });

  testWidgets('an unfinished delivery is kept and can be resumed', (t) async {
    await open(t);
    await pickMedicine(t, 0, 'Napa 500 mg');
    await enter(t, 'receive-batch-0', 'N1');
    await expiry(t, 0, '08', '2027');
    await enter(t, 'receive-qty-0', '20');
    await enter(t, 'receive-number', 'INV-3');
    await t.pump(const Duration(seconds: 1));
    await real(t);
    expect(await t.runAsync(() => env.drafts.load('bulk_receive')), isNotNull);
    await disposeApp(t);

    // Later: open it again.
    await open(t);
    expect(find.byKey(const Key('receive-draft-banner')), findsOneWidget);
    expect(find.text('Napa 500 mg'), findsWidgets);
    expect(
      (t.widget(
        find.byKey(const Key('receive-batch-0')),
      ) as TextField).controller!.text,
      'N1',
    );
    expect(
      (t.widget(
        find.byKey(const Key('receive-number')),
      ) as TextField).controller!.text,
      'INV-3',
    );
    expect(find.byKey(const Key('expiry-resolved')), findsOneWidget);

    await tapKey(t, 'receive-start-over');
    expect(find.byKey(const Key('receive-draft-banner')), findsNothing);
    expect(await t.runAsync(() => env.drafts.load('bulk_receive')), isNull);
    expect(await batchCount(t), 0);
    await disposeApp(t);
  });
}
