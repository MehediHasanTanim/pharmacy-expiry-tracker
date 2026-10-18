import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/app/error_ui.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/router.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/data/diagnostics/diagnostics_report.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';

import '../support/fake_file_exchange.dart';
import '../support/pump_app.dart';
import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late FakeFileExchange files;

  setUp(() {
    env = TestEnv();
    files = FakeFileExchange();
  });
  tearDown(() => env.dispose());

  testWidgets('diagnostics list versions and counts but no names or amounts', (
    t,
  ) async {
    t.view
      ..physicalSize = const Size(900, 2400)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.runAsync(() async {
      final m = await env.medicine(brand: 'Secretin', strength: '500 mg');
      await env.addBatch(
        env.batchInput(
          m,
          number: 'LOTX99',
          quantity: 7,
          expiry: ExpiryDate.day(2027, 1, 31),
          costMinor: 123456,
        ),
      );
      await env.supplier(name: 'Rahman Traders');
      await env.settings.update(
        (s) => s.copyWith(pharmacyName: 'Green Cross Pharmacy'),
      );
    });
    await pumpApp(
      t,
      env,
      overrides: [
        fileExchangeProvider.overrideWithValue(files),
        appVersionProvider.overrideWithValue('1.2.3+4'),
      ],
    );
    final c = ProviderScope.containerOf(t.element(find.byType(Scaffold).first));
    c
        .read(errorLogProvider)
        .record(
          'test',
          StateError("failed for 'Secretin' lot LOTX99 amount 1234.56"),
        );
    c.read(routerProvider).go(Routes.more);
    await settle(t);

    await t.tap(find.byKey(const Key('more-diagnostics')));
    for (var i = 0; i < 8; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await t.pump(const Duration(milliseconds: 100));
    }
    final text = utf8.decode(files.sharedBytes.single);
    expect(text, contains('version: 1.2.3+4'));
    expect(text, contains('schema: 1'));
    expect(text, contains('medicines: 1'));
    expect(text, contains('batches: 1'));
    expect(text, contains('suppliers: 1'));
    expect(text, contains('StateError'));
    for (final secret in [
      'Secretin',
      'LOTX99',
      'Rahman',
      'Green Cross',
      '123456',
      '1234.56',
    ]) {
      expect(text, isNot(contains(secret)), reason: secret);
    }
    await disposeApp(t);
  });

  test('the report is built from plain values', () {
    final text = buildDiagnosticsReport(
      DiagnosticsInput(
        now: DateTime(2026, 10, 17),
        appVersion: '1.0.0',
        flavor: 'prod',
        platform: 'android',
        settings: const AppSettings(),
        counts: const {'medicines': 3},
        pendingAlerts: 12,
        lastReplan: 'ok',
      ),
    );
    expect(text, contains('pending: 12'));
    expect(text, contains('last backup: never'));
    expect(text, contains('none'));
  });

  testWidgets('the friendly error and the startup-failed screens render', (
    t,
  ) async {
    await t.pumpWidget(const MaterialApp(home: FriendlyError()));
    expect(find.text('Something went wrong'), findsOneWidget);
    await t.pumpWidget(const StartupFailedApp());
    await t.pump();
    expect(find.byKey(const Key('startup-failed')), findsOneWidget);
    expect(find.textContaining('put back exactly as it was'), findsOneWidget);
  });
}
