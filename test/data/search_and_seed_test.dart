import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/data/dev/seed_data.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';

import '../support/test_env.dart';

void main() {
  late TestEnv env;
  setUp(() => env = TestEnv());
  tearDown(() => env.dispose());

  group('search (SCN-1)', () {
    test('empty and whitespace queries return nothing', () async {
      await env.medicine();
      expect((await env.search.search('')).isEmpty, isTrue);
      expect((await env.search.search('   ')).isEmpty, isTrue);
    });

    test('ranks prefix, then word-prefix, then substring', () async {
      await env.medicine(brand: 'Calpol', generic: null, strength: null);
      await env.medicine(brand: 'Zol Cal', generic: null, strength: null);
      await env.medicine(brand: 'Excalibur', generic: null, strength: null);
      final r = await env.search.search('cal');
      expect(r.medicines.map((m) => m.medicine.brandName), [
        'Calpol',
        'Zol Cal',
        'Excalibur',
      ]);
    });

    test('matches generic name and strength; all words must match', () async {
      await env.medicine(brand: 'Amoxil', generic: 'Amoxicillin');
      await env.medicine(
        brand: 'Mox',
        generic: 'Amoxicillin',
        strength: '250 mg',
      );
      expect((await env.search.search('amoxicillin')).medicines, hasLength(2));
      final r = await env.search.search('amoxicillin 250');
      expect(r.medicines.single.medicine.brandName, 'Mox');
    });

    test('is case- and accent-insensitive', () async {
      await env.medicine(brand: 'Paracétamol', generic: null);
      final r = await env.search.search('PARACETAMOL');
      expect(r.medicines, hasLength(1));
    });

    test('LIKE wildcards in the query are treated literally', () async {
      await env.medicine(brand: 'Alpha');
      expect((await env.search.search('%')).medicines, isEmpty);
      expect((await env.search.search('_lpha')).medicines, isEmpty);
    });

    test('excludes archived medicines', () async {
      final id = await env.medicine(brand: 'Hidden');
      await env.setArchived(id, archived: true);
      expect((await env.search.search('hidden')).medicines, isEmpty);
    });

    test(
      'finds batches by batch number (case-insensitive) with medicine',
      () async {
        final med = await env.medicine();
        await env.addBatch(env.batchInput(med, number: 'LOT-777'));
        await env.addBatch(
          env.batchInput(
            med,
            number: 'XLOT-778',
            expiry: ExpiryDate.monthYear(2028, 1),
          ),
        );
        final r = await env.search.search('lot-77');
        expect(r.batches.map((b) => b.batch.batchNumber), [
          'LOT-777', // prefix match first
          'XLOT-778', // substring match
        ]);
        expect(r.batches.first.medicine.id, med);
      },
    );

    test('respects the limit', () async {
      for (var i = 0; i < 12; i++) {
        await env.medicine(brand: 'Brand $i', strength: null, generic: null);
      }
      expect(
        (await env.search.search('brand', limit: 5)).medicines,
        hasLength(5),
      );
    });

    test('result summaries carry stock totals', () async {
      final med = await env.medicine(brand: 'Stocked');
      await env.addBatch(env.batchInput(med, quantity: 7));
      final r = await env.search.search('stocked');
      expect(r.medicines.single.onHand, 7);
    });
  });

  group('recent searches', () {
    test('newest first, de-duplicated, capped', () async {
      for (final t in ['a', 'b', 'c', 'A', 'd', 'e', 'f', 'g', 'h', 'i']) {
        await env.recent.add(t);
      }
      final list = await env.recent.load();
      expect(list.first, 'i');
      expect(list.length, 8);
      expect(
        list.where((e) => e.toLowerCase() == 'a'),
        hasLength(lessThanOrEqualTo(1)),
      );
    });

    test('ignores blanks and can be cleared', () async {
      await env.recent.add('  ');
      expect(await env.recent.load(), isEmpty);
      await env.recent.add('x');
      await env.recent.clear();
      expect(await env.recent.load(), isEmpty);
    });
  });

  group('seed generator (S1-08)', () {
    test('is deterministic and produces consistent data', () async {
      final today = DateTime(2026, 10, 17);
      final n = await SeedDataGenerator(env.db)
          .generate(today: today, medicines: 50, batches: 120);
      expect(n, lessThanOrEqualTo(120));
      expect(n, greaterThan(100));
      final meds = await env.db.select(env.db.medicines).get();
      expect(meds, hasLength(50));
      // Every batch has exactly one RECEIVED adjustment matching its stock.
      final batches = await env.db.select(env.db.batches).get();
      final adjusts = await env.db.select(env.db.stockAdjustments).get();
      expect(adjusts, hasLength(batches.length));
      for (final b in batches) {
        final a = adjusts.singleWhere((a) => a.batchId == b.id);
        expect(a.deltaQty, b.quantityOnHand);
        expect(a.reason, AdjustmentReason.received.db);
      }
      // Spread includes already-expired and far-future batches.
      final days = batches
          .map((b) => ExpiryDate.parse(b.expiryDate).daysUntil(today))
          .toList();
      expect(days.any((d) => d < 0), isTrue);
      expect(days.any((d) => d > 365), isTrue);
    });
  });

  group('scale (exit criteria: 10k batches)', () {
    test('5k medicines / 10k batches: search and lists stay fast', () async {
      final today = DateTime(2026, 10, 17);
      await SeedDataGenerator(env.db)
          .generate(today: today, medicines: 5000, batches: 10000);

      final sw = Stopwatch()..start();
      final list = await env.medicines.watchAll().first;
      final listMs = sw.elapsedMilliseconds;
      expect(list, hasLength(5000));

      sw
        ..reset()
        ..start();
      final r = await env.search.search('amoxi');
      final searchMs = sw.elapsedMilliseconds;
      expect(r.medicines, isNotEmpty);
      expect(r.medicines.length, lessThanOrEqualTo(30));
      expect(
        r.medicines.first.medicine.brandName.toLowerCase(),
        startsWith('amoxi'),
      );

      sw
        ..reset()
        ..start();
      final active = await env.batches.watchAllActive().first;
      final activeMs = sw.elapsedMilliseconds;
      expect(active.length, greaterThan(5000));

      // Generous bounds: guard against accidental full-scan regressions.
      expect(listMs, lessThan(2000), reason: 'medicine list ${listMs}ms');
      expect(searchMs, lessThan(500), reason: 'search ${searchMs}ms');
      expect(activeMs, lessThan(2000), reason: 'active batches ${activeMs}ms');
    });
  });
}
