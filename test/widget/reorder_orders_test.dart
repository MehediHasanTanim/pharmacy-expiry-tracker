import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/router.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/features/stock/batch_form_screen.dart';

import '../support/fake_file_exchange.dart';
import '../support/pump_app.dart';
import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late FakeFileExchange files;
  late String napa;
  late String amoxil;
  late String sup;

  setUp(() async {
    env = TestEnv();
    files = FakeFileExchange();
    sup = await env.supplier(name: 'ABC Pharma');
    napa = await env.medicine(
      brand: 'Napa',
      strength: '500 mg',
      reorderLevel: 20,
      preferredSupplierId: sup,
    );
    amoxil = await env.medicine(
      brand: 'Amoxil',
      strength: '250 mg',
      reorderLevel: 30,
      preferredSupplierId: sup,
    );
    await env.addBatch(env.batchInput(napa, quantity: 5));
    await env.addBatch(env.batchInput(amoxil, number: 'Z', quantity: 10));
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
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> open(WidgetTester t) async {
    t.view
      ..physicalSize = const Size(900, 2400)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await pumpApp(
      t,
      env,
      overrides: [fileExchangeProvider.overrideWithValue(files)],
    );
    final c = ProviderScope.containerOf(t.element(find.byType(Scaffold).first));
    c.read(routerProvider).go(Routes.reorder);
    await settle(t);
    await real(t);
  }

  Future<void> tapKey(WidgetTester t, String key) async {
    await t.tap(find.byKey(Key(key)));
    await real(t);
  }

  testWidgets(
    'mark as ordered shows quantity and due date; cancel removes it',
    (t) async {
      await open(t);
      await tapKey(t, 'reorder-menu-$napa');
      await tapKey(t, 'reorder-ordered-$napa');
      await t.enterText(find.byKey(const Key('order-qty')), '35');
      await tapKey(t, 'order-confirm');
      // No date given: assumed a week out, from the fake "today" 17 Oct.
      final line = t.widget<Text>(find.byKey(Key('order-line-$napa'))).data!;
      expect(line, startsWith('Ordered 35, due '));
      final open_ = await t.runAsync(() => env.reorderRepo.getOpenOrder(napa));
      expect(open_!.quantity, 35);
      expect(open_.supplierId, sup);

      await tapKey(t, 'reorder-menu-$napa');
      await tapKey(t, 'reorder-cancel-$napa');
      expect(find.byKey(Key('order-line-$napa')), findsNothing);
      expect(
        await t.runAsync(() => env.reorderRepo.getOpenOrder(napa)),
        isNull,
      );
      await disposeApp(t);
    },
  );

  testWidgets('a late order says so', (t) async {
    await t.runAsync(
      () => env.orders.place(
        napa,
        quantity: 12,
        expectedOn: DateTime(2026, 10, 17),
      ),
    );
    env.clock.current = DateTime(2026, 10, 20, 9);
    await open(t);
    final line = t.widget<Text>(find.byKey(Key('order-line-$napa'))).data!;
    expect(line, startsWith('Ordered 12, late since '));
    await disposeApp(t);
  });

  testWidgets('received closes the order and opens the batch form filled in', (
    t,
  ) async {
    await t.runAsync(
      () => env.orders.place(napa, quantity: 40, supplierId: sup),
    );
    await open(t);
    await tapKey(t, 'reorder-menu-$napa');
    await tapKey(t, 'reorder-received-$napa');
    expect(find.byType(BatchFormScreen), findsOneWidget);
    expect(
      (t.widget(
        find.byKey(const Key('field-quantity')),
      ) as TextFormField).controller!.text,
      '40',
    );
    expect(await t.runAsync(() => env.reorderRepo.getOpenOrder(napa)), isNull);
    await disposeApp(t);
  });

  testWidgets('the order list for a supplier is shared as a message', (
    t,
  ) async {
    await open(t);
    // Change one quantity first; the shared text follows it.
    await t.enterText(find.byKey(Key('reorder-qty-$napa')), '60');
    await t.pump();
    await tapKey(t, 'reorder-share-$sup');
    final text = files.texts.single;
    expect(text, startsWith('*Order for ABC Pharma*'));
    expect(text, contains('• Napa 500 mg × 60'));
    expect(text, contains('• Amoxil 250 mg × 50'));
    expect(text, contains('Please confirm availability'));
    await disposeApp(t);
  });

  testWidgets('items already on order are left out of the shared list', (
    t,
  ) async {
    await t.runAsync(
      () => env.orders.place(napa, quantity: 40, supplierId: sup),
    );
    await open(t);
    await tapKey(t, 'reorder-share-$sup');
    final text = files.texts.single;
    expect(text, isNot(contains('Napa')));
    expect(text, contains('Amoxil 250 mg'));
    await disposeApp(t);
  });
}
