import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/router.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier_return.dart';

import '../support/fake_file_exchange.dart';
import '../support/pump_app.dart';
import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late FakeFileExchange files;
  late String med;
  late String sup;
  late String batchA;
  late String batchB;

  ExpiryDate in_(int d) {
    final t = DateTime(2026, 10, 17 + d);
    return ExpiryDate.day(t.year, t.month, t.day);
  }

  setUp(() async {
    env = TestEnv();
    files = FakeFileExchange();
    med = await env.medicine(brand: 'Napa', strength: '500 mg');
    sup = await env.supplier(name: 'ABC Pharma');
    batchA = (await env.addBatch(
      env.batchInput(
        med,
        number: 'A1',
        quantity: 10,
        costMinor: 200,
        expiry: in_(-5),
        supplierId: sup,
      ),
    )).batch.id;
    batchB = (await env.addBatch(
      env.batchInput(
        med,
        number: 'B2',
        quantity: 6,
        costMinor: 300,
        expiry: in_(20),
        supplierId: sup,
      ),
    )).batch.id;
    EditableText.debugDeterministicCursor = true;
  });
  tearDown(() async {
    EditableText.debugDeterministicCursor = false;
    await env.dispose();
  });

  Future<void> real(WidgetTester t) async {
    for (var i = 0; i < 5; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)),
      );
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<ProviderContainer> open(WidgetTester t, String route) async {
    t.view
      ..physicalSize = const Size(900, 2600)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await pumpApp(
      t,
      env,
      overrides: [fileExchangeProvider.overrideWithValue(files)],
    );
    final c = ProviderScope.containerOf(t.element(find.byType(Scaffold).first));
    c.read(routerProvider).go(route);
    await settle(t);
    await real(t);
    return c;
  }

  Future<void> tapKey(WidgetTester t, String key) async {
    await t.tap(find.byKey(Key(key)));
    await real(t);
  }

  testWidgets(
    'from the supplier page: choose a batch, take a credit, share the list',
    (t) async {
      await open(t, '${Routes.suppliers}/$sup');
      await t.scrollUntilVisible(
        find.byKey(const Key('return-stock')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tapKey(t, 'return-stock');
      expect(find.byKey(const Key('return-line-A1')), findsOneWidget);
      // Nothing is chosen yet.
      await tapKey(t, 'return-save');
      expect(find.byKey(const Key('return-error')), findsOneWidget);

      await tapKey(t, 'return-check-A1');
      await t.enterText(find.byKey(const Key('return-qty-A1')), '4');
      await t.pump();
      // Credit defaults to cost x quantity: 4 x 2.00.
      expect(
        (t.widget(
          find.byKey(const Key('return-credit')),
        ) as TextField).controller!.text,
        '8.00',
      );
      await tapKey(t, 'return-save');
      expect(find.text('Return recorded.'), findsOneWidget);
      await tapKey(t, 'return-share');

      expect(files.texts.single, contains('Return to ABC Pharma'));
      expect(files.texts.single, contains('4 × Napa 500 mg, batch A1'));
      expect(files.texts.single, contains('Credit expected: 8.00'));

      final stored = await t.runAsync(() => env.batches.getById(batchA));
      expect(stored!.quantityOnHand, 6);
      final credits = await t.runAsync(
        () => env.ledger.watchCredits(sup).first,
      );
      expect(credits!.single.amount, const Money(800));
      await disposeApp(t);
    },
  );

  testWidgets('quantity above stock is refused and nothing changes', (t) async {
    await open(t, '${Routes.suppliers}/return?supplier=$sup');
    await tapKey(t, 'return-check-B2');
    await t.enterText(find.byKey(const Key('return-qty-B2')), '99');
    await t.pump();
    await tapKey(t, 'return-save');
    expect(find.text('Check the quantities.'), findsOneWidget);
    expect(
      (await t.runAsync(() => env.batches.getById(batchB)))!.quantityOnHand,
      6,
    );
    await disposeApp(t);
  });

  testWidgets('from the Expiry tab: select, return, selection mode ends', (
    t,
  ) async {
    await open(t, Routes.expiry);
    await tapKey(t, 'expiry-select');
    await t.tap(find.byKey(Key('expiry-row-$batchA')));
    await real(t);
    await tapKey(t, 'return-selected');
    // The supplier is found from the batch itself.
    expect(find.byKey(const Key('return-line-A1')), findsOneWidget);
    expect(find.byKey(const Key('return-line-B2')), findsNothing);
    await tapKey(t, 'return-save');
    await tapKey(t, 'return-finish');
    final a = await t.runAsync(() => env.batches.getById(batchA));
    expect(a!.quantityOnHand, 0);
    expect(a.status, BatchStatus.returned);
    expect(find.byKey(const Key('discard-selected')), findsNothing);
    await disposeApp(t);
  });

  testWidgets('returns are listed on the supplier page', (t) async {
    await t.runAsync(
      () => env.returnToSupplier.call(
        supplierId: sup,
        returnedOn: DateTime(2026, 10, 16),
        lines: [ReturnLineInput(batchB, 2)],
        credit: const Money(600),
      ),
    );
    await open(t, '${Routes.suppliers}/$sup');
    await t.scrollUntilVisible(
      find.text('Returns'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('2 items'), findsOneWidget);
    expect(find.textContaining('Credit expected: 6.00'), findsOneWidget);
    await disposeApp(t);
  });
}
