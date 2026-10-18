import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/router.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';

import '../support/fake_file_exchange.dart';
import '../support/pump_app.dart';
import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late FakeFileExchange files;

  setUp(() {
    env = TestEnv();
    files = FakeFileExchange();
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

  Future<void> open(WidgetTester t, String route) async {
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
    c.read(routerProvider).go(route);
    await settle(t);
  }

  Future<void> real(WidgetTester t) async {
    for (var i = 0; i < 8; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('sharing the Expiry list as CSV', (t) async {
    await t.runAsync(() async {
      final m = await env.medicine(brand: 'Napa', strength: '500 mg');
      await env.addBatch(
        env.batchInput(
          m,
          number: 'A,1',
          quantity: 4,
          expiry: in_(-3),
          costMinor: 250,
        ),
      );
      await env.addBatch(
        env.batchInput(m, number: 'B2', quantity: 9, expiry: in_(20)),
      );
    });
    await open(t, Routes.expiry);
    await t.tap(find.byKey(const Key('expiry-share')));
    await settle(t);
    await t.tap(find.byKey(const Key('expiry-share-csv')));
    await real(t);

    expect(files.shared, hasLength(1));
    expect(files.shared.single.path, endsWith('expiry-list-2026-10-17.csv'));
    // UTF-8 byte-order mark first, so Excel reads accents correctly.
    expect(files.sharedBytes.single.take(3), [0xEF, 0xBB, 0xBF]);
    final csv = utf8.decode(files.sharedBytes.single);
    expect(csv.startsWith('Medicine,Batch,Expiry date'), isTrue);
    expect(csv, contains('Napa 500 mg,"A,1"'));
    expect(csv, contains('Expired 3 days ago'));
    expect(csv, contains('20 days left'));
    // Cost 2.50 x 4 on hand.
    expect(csv, contains(',2.50,10.00'));
    await disposeApp(t);
  });

  testWidgets('sharing as text', (t) async {
    await t.runAsync(() async {
      final m = await env.medicine(brand: 'Napa', strength: '500 mg');
      await env.addBatch(
        env.batchInput(m, number: 'B2', quantity: 9, expiry: in_(20)),
      );
    });
    await open(t, Routes.expiry);
    await t.tap(find.byKey(const Key('expiry-share')));
    await settle(t);
    await t.tap(find.byKey(const Key('expiry-share-text')));
    await real(t);
    final text = utf8.decode(files.sharedBytes.single);
    expect(files.shared.single.path, endsWith('.txt'));
    expect(text, contains('Napa 500 mg · B2'));
    expect(text, contains('20 days left · ×9'));
    await disposeApp(t);
  });

  testWidgets('an empty list says there is nothing to share', (t) async {
    await open(t, Routes.expiry);
    await t.tap(find.byKey(const Key('expiry-share')));
    await settle(t);
    await t.tap(find.byKey(const Key('expiry-share-csv')));
    await real(t);
    expect(files.shared, isEmpty);
    expect(
      find.text('There is nothing in this list to share.'),
      findsOneWidget,
    );
    await disposeApp(t);
  });

  testWidgets('the lock-screen privacy switch is saved', (t) async {
    await open(t, Routes.alertSettings);
    await t.scrollUntilVisible(
      find.byKey(const Key('hide-details-switch')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await t.tap(find.byKey(const Key('hide-details-switch')));
    await settle(t);
    await real(t);
    final s = await t.runAsync(() => env.settings.load());
    expect(s!.hideDetailsOnLockScreen, isTrue);
    await disposeApp(t);
  });
}
