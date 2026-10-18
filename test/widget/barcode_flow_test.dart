import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/app/router.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/features/scan/barcode_scan_screen.dart';
import 'package:pharmacy_expiry_tracker/features/stock/batch_form_screen.dart';

import '../support/fake_scanner.dart';
import '../support/pump_app.dart';
import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late FakeScanner scanner;
  late String napa;

  setUp(() async {
    env = TestEnv();
    scanner = FakeScanner();
    napa = await env.medicine(brand: 'Napa', strength: '500 mg');
    await env.medicine(brand: 'Amoxil', strength: '250 mg');
    EditableText.debugDeterministicCursor = true;
  });
  tearDown(() async {
    EditableText.debugDeterministicCursor = false;
    await env.dispose();
  });

  Future<void> open(WidgetTester t, String route) async {
    t.view
      ..physicalSize = const Size(900, 2400)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await pumpApp(
      t,
      env,
      overrides: [barcodeScanProvider.overrideWithValue(scanner.scan)],
    );
    final c = ProviderScope.containerOf(t.element(find.byType(Scaffold).first));
    c.read(routerProvider).go(route);
    await settle(t);
  }

  Future<void> tapKey(WidgetTester t, String key) async {
    await t.tap(find.byKey(Key(key)));
    await settle(t);
  }

  Future<void> real(WidgetTester t) async {
    for (var i = 0; i < 4; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)),
      );
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('Stock search: a known barcode opens the medicine', (t) async {
    await t.runAsync(() => env.barcodes.link(napa, '8901234567890'));
    scanner.queue.add('8901234567890');
    await open(t, Routes.stock);
    await tapKey(t, 'search-scan');
    await real(t);
    expect(find.text('Napa 500 mg'), findsWidgets);
    expect(find.byKey(const Key('barcode-8901234567890')), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('cancelling the scan changes nothing', (t) async {
    scanner.queue.add(null);
    await open(t, Routes.stock);
    await tapKey(t, 'search-scan');
    await real(t);
    expect(scanner.calls, 1);
    expect(find.byKey(const Key('stock-search')), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('unknown barcode: link it to an existing medicine', (t) async {
    scanner.queue.add('5551230001');
    await open(t, Routes.stock);
    await tapKey(t, 'search-scan');
    await real(t);
    expect(find.text('New barcode'), findsOneWidget);
    expect(
      find.text('5551230001 is not linked to a medicine yet.'),
      findsOneWidget,
    );
    await tapKey(t, 'scan-link-existing');
    await real(t);
    expect(find.text('Choose a medicine'), findsOneWidget);
    await t.tap(find.text('Amoxil 250 mg').first);
    await real(t);
    expect(find.byKey(const Key('barcode-5551230001')), findsOneWidget);
    final found = await t.runAsync(() => env.barcodes.lookup('5551230001'));
    expect(found!.brandName, 'Amoxil');
    await disposeApp(t);
  });

  testWidgets('unknown barcode: create a new medicine that carries it', (
    t,
  ) async {
    scanner.queue.add('7770001112');
    await open(t, Routes.stock);
    await tapKey(t, 'search-scan');
    await real(t);
    await tapKey(t, 'scan-create-new');
    await real(t);
    expect(find.text('New medicine'), findsOneWidget);
    await t.enterText(find.byKey(const Key('field-brand')), 'Ceevit');
    await tapKey(t, 'medicine-save');
    await real(t);
    final found = await t.runAsync(() => env.barcodes.lookup('7770001112'));
    expect(found!.brandName, 'Ceevit');
    await disposeApp(t);
  });

  testWidgets(
    'Add stock: scanning a known pack goes straight to the batch form',
    (t) async {
      await t.runAsync(() => env.barcodes.link(napa, '123456'));
      scanner.queue.add('123456');
      await open(t, '${Routes.stock}/pick');
      await tapKey(t, 'search-scan');
      await real(t);
      expect(find.byType(BatchFormScreen), findsOneWidget);
      await disposeApp(t);
    },
  );

  testWidgets('a barcode on another medicine is refused with its name', (
    t,
  ) async {
    await t.runAsync(() => env.barcodes.link(napa, '999'));
    final amoxil = (await t.runAsync(() => env.medicines.watchAll().first))!
        .firstWhere((m) => m.medicine.brandName == 'Amoxil')
        .medicine
        .id;
    scanner.queue.add('999');
    await open(t, '${Routes.stock}/medicine/$amoxil');
    await tapKey(t, 'barcode-add');
    await real(t);
    expect(
      find.text('That barcode already belongs to Napa 500 mg.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('barcode-999')), findsNothing);
    await disposeApp(t);
  });

  testWidgets('a medicine can hold several barcodes and drop one', (t) async {
    scanner.queue.addAll(['AAA111', 'BBB222']);
    await open(t, '${Routes.stock}/medicine/$napa');
    await tapKey(t, 'barcode-add');
    await real(t);
    await tapKey(t, 'barcode-add');
    await real(t);
    expect(find.byKey(const Key('barcode-AAA111')), findsOneWidget);
    expect(find.byKey(const Key('barcode-BBB222')), findsOneWidget);
    await tapKey(t, 'barcode-remove-AAA111');
    await real(t);
    expect(find.byKey(const Key('barcode-AAA111')), findsNothing);
    expect(find.byKey(const Key('barcode-BBB222')), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('a blank scan result is reported, not saved', (t) async {
    scanner.queue.add('   ');
    await open(t, Routes.stock);
    await tapKey(t, 'search-scan');
    await real(t);
    expect(find.text('That barcode could not be read.'), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('the alert window is saved with the medicine (S7-07)', (t) async {
    await open(t, '${Routes.stock}/medicine/$napa/edit');
    await t.scrollUntilVisible(
      find.byKey(const Key('field-alert-window')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await t.enterText(find.byKey(const Key('field-alert-window')), '180');
    await tapKey(t, 'medicine-save');
    await real(t);
    final m = await t.runAsync(() => env.medicines.getById(napa));
    expect(m!.alertWindowDays, 180);
    await disposeApp(t);
  });
}
