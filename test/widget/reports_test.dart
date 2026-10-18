import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/router.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/report.dart';
import 'package:pharmacy_expiry_tracker/features/reports/reports_providers.dart';

import '../support/fake_file_exchange.dart';
import '../support/pump_app.dart';
import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late FakeFileExchange files;
  late String napa;
  late String amoxil;
  late String abc;
  late String xyz;

  setUp(() async {
    env = TestEnv();
    files = FakeFileExchange();
    napa = await env.medicine(brand: 'Napa', strength: '500 mg');
    amoxil = await env.medicine(brand: 'Amoxil', strength: '250 mg');
    abc = await env.supplier(name: 'ABC Pharma');
    xyz = await env.supplier(name: 'XYZ Traders');
    final b1 = (await env.addBatch(
      env.batchInput(
        napa,
        number: 'N1',
        quantity: 10,
        costMinor: 200,
        supplierId: abc,
      ),
    )).batch.id;
    final b2 = (await env.addBatch(
      env.batchInput(
        amoxil,
        number: 'A1',
        quantity: 5,
        costMinor: 1000,
        supplierId: xyz,
      ),
    )).batch.id;
    await env.addBatch(
      env.batchInput(
        napa,
        number: 'N2',
        quantity: 20,
        costMinor: 150,
        supplierId: abc,
      ),
    );
    env.clock.current = DateTime(2026, 9, 10, 10);
    await env.discardBatches([b1]);
    env.clock.current = DateTime(2026, 10, 12, 10);
    await env.discardBatches([b2]);
    env.clock.current = DateTime(2026, 10, 17, 9);
    await env.invoice(
      abc,
      totalMinor: 30000,
      due: DateTime(2026, 10, 1),
      date: DateTime(2026, 9, 1),
    );
    await env.invoice(
      xyz,
      totalMinor: 10000,
      due: DateTime(2026, 6, 1),
      date: DateTime(2026, 5, 1),
    );
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

  Future<void> open(WidgetTester t, String route) async {
    t.view
      ..physicalSize = const Size(900, 3000)
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
  }

  Future<void> tapKey(WidgetTester t, String key) async {
    await t.tap(find.byKey(Key(key)));
    await real(t);
  }

  Text text(WidgetTester t, String key) => t.widget<Text>(find.byKey(Key(key)));

  testWidgets('expiry loss: this month by default, with chart and rows', (
    t,
  ) async {
    await open(t, Routes.reports);
    expect(text(t, 'loss-total').data, '50.00');
    expect(find.byKey(const Key('report-chart')), findsOneWidget);
    expect(find.byKey(const Key('loss-row-2026-10')), findsOneWidget);
    expect(find.byKey(const Key('loss-row-2026-09')), findsNothing);
    await disposeApp(t);
  });

  testWidgets('a wider period and other groupings', (t) async {
    await open(t, Routes.reports);
    await tapKey(t, 'range-year');
    expect(text(t, 'loss-total').data, '70.00');
    expect(find.byKey(const Key('loss-row-2026-09')), findsOneWidget);

    await t.tap(find.text('By supplier'));
    await real(t);
    expect(find.text('XYZ Traders'), findsOneWidget);
    expect(find.text('ABC Pharma'), findsOneWidget);

    await t.tap(find.text('By medicine'));
    await real(t);
    expect(find.text('Amoxil 250 mg'), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('drilling into a month lists the write-offs', (t) async {
    await open(t, Routes.reports);
    await tapKey(t, 'range-year');
    await tapKey(t, 'loss-row-2026-09');
    expect(find.byKey(const Key('loss-details')), findsOneWidget);
    expect(find.textContaining('Napa 500 mg · N1'), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('a period with nothing says so, and damaged stock is opt-in', (
    t,
  ) async {
    await open(t, Routes.reports);
    final c = ProviderScope.containerOf(t.element(find.byType(Scaffold).first));
    c
        .read(reportRangeProvider.notifier)
        .set(DateRange(DateTime(2025), DateTime(2025, 1, 31)));
    await real(t);
    expect(find.byKey(const Key('report-empty')), findsOneWidget);
    expect(find.byKey(const Key('loss-total')), findsNothing);
    // A custom range is shown as such.
    expect(find.byKey(const Key('report-period')), findsOneWidget);

    c
        .read(reportRangeProvider.notifier)
        .set(presetRange(RangePreset.month, DateTime(2026, 10, 17)));
    await real(t);
    await t.tap(find.byKey(const Key('loss-damaged')));
    await real(t);
    expect(text(t, 'loss-total').data, '50.00');
    await disposeApp(t);
  });

  testWidgets('stock value and its drill-down', (t) async {
    await open(t, Routes.reports);
    await tapKey(t, 'tab-stock');
    // Only N2 is still on the shelf: 20 x 1.50.
    expect(text(t, 'stock-total').data, '30.00');
    await tapKey(t, 'stock-row-$napa');
    expect(find.byKey(const Key('stock-details')), findsOneWidget);
    expect(find.textContaining('N2'), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('dues aging with a way to the supplier', (t) async {
    await open(t, Routes.reports);
    await tapKey(t, 'tab-dues');
    expect(text(t, 'dues-total').data, '400.00');
    await tapKey(t, 'dues-row-$xyz');
    expect(find.text('Over 90 days late'), findsWidgets);
    await tapKey(t, 'dues-open-$xyz');
    expect(find.text('XYZ Traders'), findsWidgets);
    await disposeApp(t);
  });

  testWidgets('sharing the loss report as a spreadsheet', (t) async {
    await open(t, Routes.reports);
    await tapKey(t, 'range-year');
    await tapKey(t, 'reports-share');
    await tapKey(t, 'report-format-csv');
    await real(t, rounds: 8);
    final file = files.shared.single;
    expect(file.path, endsWith('.csv'));
    final csv = utf8.decode(files.sharedBytes.single);
    expect(csv, contains('Month,Quantity,Batches,Value'));
    expect(csv, contains('2026-10,5,1,50.00'));
    expect(csv, contains('Total,15,2,70.00'));
    await disposeApp(t);
  });

  testWidgets('sharing the dues report as a PDF', (t) async {
    await open(t, Routes.reports);
    await tapKey(t, 'tab-dues');
    await tapKey(t, 'reports-share');
    await tapKey(t, 'report-format-pdf');
    await real(t, rounds: 12);
    expect(files.shared.single.path, endsWith('.pdf'));
    expect(utf8.decode(files.sharedBytes.single.sublist(0, 5)), '%PDF-');
    await disposeApp(t);
  });

  testWidgets('supplier statement from the supplier page', (t) async {
    await t.runAsync(
      () => env.recordPayment(
        supplierId: abc,
        amount: const Money(5000),
        paidOn: DateTime(2026, 10, 5),
        invoiceId: null,
      ),
    );
    await open(t, '${Routes.suppliers}/$abc');
    await t.scrollUntilVisible(
      find.byKey(const Key('supplier-statement')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tapKey(t, 'supplier-statement');
    await tapKey(t, 'statement-year');
    await tapKey(t, 'report-format-csv');
    await real(t, rounds: 8);
    final csv = utf8.decode(files.sharedBytes.single);
    expect(files.shared.single.path, contains('statement-abc-pharma'));
    expect(csv, contains('Opening balance'));
    expect(csv, contains('Invoice'));
    expect(csv, contains('Closing balance'));
    await disposeApp(t);
  });
}
