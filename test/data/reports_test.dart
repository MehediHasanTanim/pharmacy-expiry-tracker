import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/report.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier_return.dart';

import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late String napa;
  late String amoxil;
  late String abc;
  late String xyz;

  DateRange range(DateTime a, DateTime b) => DateRange(a, b);
  final wide = range(DateTime(2026, 1, 1), DateTime(2026, 12, 31));

  setUp(() async {
    env = TestEnv();
    napa = await env.medicine(
      brand: 'Napa',
      strength: '500 mg',
      category: 'Painkiller',
    );
    amoxil = await env.medicine(
      brand: 'Amoxil',
      strength: '250 mg',
      category: 'Antibiotic',
    );
    abc = await env.supplier(name: 'ABC Pharma');
    xyz = await env.supplier(name: 'XYZ Traders');
  });
  tearDown(() => env.dispose());

  Future<String> batch(
    String med,
    String number, {
    int qty = 10,
    int? cost,
    String? supplier,
    ExpiryDate? expiry,
  }) async => (await env.addBatch(
    env.batchInput(
      med,
      number: number,
      quantity: qty,
      costMinor: cost,
      supplierId: supplier,
      expiry: expiry ?? ExpiryDate.day(2027, 6, 30),
    ),
  )).batch.id;

  Future<void> discardOn(DateTime when, String id) async {
    env.clock.current = when;
    await env.discardBatches([id]);
  }

  group('expiry loss (RPT-1)', () {
    late String b1;
    late String b2;
    late String b3;
    late String b4;

    setUp(() async {
      b1 = await batch(napa, 'N1', qty: 10, cost: 200, supplier: abc);
      b2 = await batch(napa, 'N2', qty: 4, cost: 200, supplier: xyz);
      b3 = await batch(amoxil, 'A1', qty: 5, cost: 1000, supplier: abc);
      b4 = await batch(amoxil, 'A2', qty: 3, supplier: abc); // no cost price
      await discardOn(DateTime(2026, 8, 31, 23, 30), b1); // late on the 31st
      await discardOn(DateTime(2026, 9, 1, 0, 30), b2);
      await discardOn(DateTime(2026, 9, 15, 10), b3);
      await discardOn(DateTime(2026, 9, 20, 10), b4);
    });

    test('by month, newest first, with totals', () async {
      final r = await env.reports.expiryLoss(wide, LossGroup.month);
      expect(r.rows.map((x) => x.key), ['2026-09', '2026-08']);
      final sep = r.rows.first;
      expect(sep.value, const Money(4 * 200 + 5 * 1000));
      expect(sep.quantity, 4 + 5 + 3);
      expect(sep.batches, 3);
      expect(sep.unpriced, 1);
      expect(r.rows.last.value, const Money(2000));
      expect(r.value, const Money(2000 + 800 + 5000));
      expect(r.quantity, 22);
      expect(r.unpriced, 1);
    });

    test('by supplier, biggest loss first', () async {
      final r = await env.reports.expiryLoss(wide, LossGroup.supplier);
      expect(r.rows.map((x) => x.label), ['ABC Pharma', 'XYZ Traders']);
      expect(r.rows.first.value, const Money(2000 + 5000));
      expect(r.rows.last.value, const Money(800));
    });

    test('by medicine', () async {
      final r = await env.reports.expiryLoss(wide, LossGroup.medicine);
      expect(r.rows.map((x) => x.label), ['Amoxil 250 mg', 'Napa 500 mg']);
      expect(r.rows.first.value, const Money(5000));
      expect(r.rows.first.unpriced, 1);
      expect(r.rows.last.quantity, 14);
    });

    test('only the chosen days count, both ends included', () async {
      final sep = await env.reports.expiryLoss(
        range(DateTime(2026, 9, 1), DateTime(2026, 9, 15)),
        LossGroup.month,
      );
      expect(sep.rows.single.batches, 2); // b2 (00:30 on the 1st) and b3
      final onlyAug31 = await env.reports.expiryLoss(
        range(DateTime(2026, 8, 31), DateTime(2026, 8, 31)),
        LossGroup.month,
      );
      expect(onlyAug31.value, const Money(2000));
      final none = await env.reports.expiryLoss(
        range(DateTime(2027, 1, 1), DateTime(2027, 1, 31)),
        LossGroup.month,
      );
      expect(none.rows, isEmpty);
      expect(none.value, Money.zero);
    });

    test('the rows behind a line add up to the line', () async {
      for (final g in LossGroup.values) {
        final r = await env.reports.expiryLoss(wide, g);
        for (final row in r.rows) {
          final d = await env.reports.expiryLossDetails(wide, g, row.key);
          expect(
            d.fold<int>(0, (a, x) => a + x.quantity),
            row.quantity,
            reason: '$g ${row.key}',
          );
          expect(
            d.fold<int>(0, (a, x) => a + (x.value?.minor ?? 0)),
            row.value.minor,
            reason: '$g ${row.key}',
          );
          expect(d.length, row.batches);
        }
      }
      final d = await env.reports.expiryLossDetails(
        wide,
        LossGroup.month,
        '2026-09',
      );
      expect(d.first.medicineName, 'Amoxil 250 mg'); // newest first
      expect(d.first.supplierName, 'ABC Pharma');
    });

    test('damaged stock is a separate choice', () async {
      final b5 = await batch(napa, 'N5', qty: 6, cost: 300, supplier: abc);
      env.clock.current = DateTime(2026, 9, 25, 10);
      await env.adjustStock(
        batchId: b5,
        delta: -2,
        reason: AdjustmentReason.damaged,
      );
      final without = await env.reports.expiryLoss(wide, LossGroup.month);
      final withDamaged = await env.reports.expiryLoss(
        wide,
        LossGroup.month,
        includeDamaged: true,
      );
      expect(withDamaged.value.minor - without.value.minor, 600);
    });

    test('returns and sales are not losses', () async {
      final b6 = await batch(napa, 'N6', qty: 6, cost: 300, supplier: abc);
      env.clock.current = DateTime(2026, 9, 26, 10);
      await env.adjustStock(
        batchId: b6,
        delta: -2,
        reason: AdjustmentReason.sold,
      );
      await env.returnToSupplier.call(
        supplierId: abc,
        returnedOn: DateTime(2026, 9, 26),
        lines: [ReturnLineInput(b6, 2)],
      );
      final r = await env.reports.expiryLoss(wide, LossGroup.month);
      expect(r.value, const Money(2000 + 800 + 5000));
    });
  });

  group('stock valuation (RPT-2)', () {
    setUp(() async {
      await batch(napa, 'N1', qty: 10, cost: 200, supplier: abc);
      await batch(napa, 'N2', qty: 5, cost: 300, supplier: xyz);
      await batch(amoxil, 'A1', qty: 4, cost: 1000, supplier: abc);
      await batch(amoxil, 'A2', qty: 2, supplier: abc); // no cost price
      // Expired but still on the shelf: counted (it is stock you own).
      await batch(
        napa,
        'OLD',
        qty: 1,
        cost: 100,
        supplier: abc,
        expiry: ExpiryDate.day(2026, 1, 31),
      );
    });

    test('by medicine, with totals and unpriced stock flagged', () async {
      final r = await env.reports.stockValuation(ValuationGroup.medicine);
      expect(r.rows.map((x) => x.label), ['Amoxil 250 mg', 'Napa 500 mg']);
      expect(r.rows.first.value, const Money(4000));
      expect(r.rows.first.quantity, 6);
      expect(r.rows.first.unpriced, 1);
      expect(r.rows.last.value, const Money(2000 + 1500 + 100));
      expect(r.value, const Money(4000 + 3600));
      expect(r.quantity, 22);
    });

    test('by supplier and by category', () async {
      final s = await env.reports.stockValuation(ValuationGroup.supplier);
      expect(s.rows.map((x) => x.label), ['ABC Pharma', 'XYZ Traders']);
      expect(s.rows.first.value, const Money(2000 + 4000 + 100));
      final c = await env.reports.stockValuation(ValuationGroup.category);
      expect(c.rows.map((x) => x.label).toSet(), {'Antibiotic', 'Painkiller'});
    });

    test(
      'empty, discarded, returned and archived-away stock is left out',
      () async {
        final id = await batch(napa, 'GONE', qty: 3, cost: 999, supplier: abc);
        await env.discardBatches([id]);
        final id2 = await batch(napa, 'BACK', qty: 3, cost: 999, supplier: abc);
        await env.returnToSupplier.call(
          supplierId: abc,
          returnedOn: DateTime(2026, 10, 17),
          lines: [ReturnLineInput(id2, 3)],
        );
        final r = await env.reports.stockValuation(ValuationGroup.medicine);
        expect(r.value, const Money(4000 + 3600));
      },
    );

    test('the batches behind a row add up to it', () async {
      for (final g in ValuationGroup.values) {
        final r = await env.reports.stockValuation(g);
        for (final row in r.rows) {
          final d = await env.reports.stockDetails(g, row.key);
          expect(d.length, row.batches);
          expect(d.fold<int>(0, (a, x) => a + x.quantity), row.quantity);
          expect(
            d.fold<int>(0, (a, x) => a + (x.value?.minor ?? 0)),
            row.value.minor,
          );
        }
      }
      final med = await env.reports.stockDetails(ValuationGroup.medicine, napa);
      expect(med.first.batchNumber, 'OLD'); // soonest expiry first
    });

    test('an empty store reports zero', () async {
      final fresh = TestEnv();
      addTearDown(fresh.dispose);
      final r = await fresh.reports.stockValuation(ValuationGroup.medicine);
      expect(r.rows, isEmpty);
      expect(r.value, Money.zero);
    });
  });

  group('dues aging (RPT-3)', () {
    final today = DateTime(2026, 10, 17);

    Future<void> invoice(String supplier, int total, DateTime? due) =>
        env.invoice(
          supplier,
          totalMinor: total,
          due: due,
          date: DateTime(2026, 6, 1),
        );

    test('buckets by days overdue, edges included', () async {
      await invoice(abc, 100, DateTime(2026, 10, 17)); // due today: 0 days
      await invoice(abc, 200, DateTime(2026, 10, 16)); // 1
      await invoice(abc, 300, DateTime(2026, 9, 17)); // 30
      await invoice(abc, 400, DateTime(2026, 9, 16)); // 31
      await invoice(abc, 500, DateTime(2026, 8, 18)); // 60
      await invoice(abc, 600, DateTime(2026, 8, 17)); // 61
      await invoice(abc, 700, DateTime(2026, 7, 19)); // 90
      await invoice(abc, 800, DateTime(2026, 7, 18)); // 91
      await invoice(abc, 900, null); // no due date
      final r = await env.reports.duesAging(today);
      final row = r.rows.single;
      expect(row.of(AgingBucket.current), const Money(100 + 900));
      expect(row.of(AgingBucket.d1to30), const Money(200 + 300));
      expect(row.of(AgingBucket.d31to60), const Money(400 + 500));
      expect(row.of(AgingBucket.d61to90), const Money(600 + 700));
      expect(row.of(AgingBucket.over90), const Money(800));
      expect(row.total, const Money(4500));
    });

    test(
      'payments and credits reduce what is owed; paid invoices vanish',
      () async {
        final a = await env.invoice(
          abc,
          totalMinor: 1000,
          due: DateTime(2026, 9, 1),
          date: DateTime(2026, 8, 1),
        );
        await env.recordPayment(
          supplierId: abc,
          amount: const Money(300),
          paidOn: DateTime(2026, 9, 2),
          invoiceId: a.id,
        );
        await env.recordCredit(
          supplierId: abc,
          amount: const Money(200),
          issuedOn: DateTime(2026, 9, 3),
          invoiceId: a.id,
        );
        final paid = await env.invoice(
          abc,
          totalMinor: 500,
          due: DateTime(2026, 9, 1),
          date: DateTime(2026, 8, 1),
        );
        await env.recordPayment(
          supplierId: abc,
          amount: const Money(500),
          paidOn: DateTime(2026, 9, 2),
          invoiceId: paid.id,
        );
        final r = await env.reports.duesAging(today);
        expect(r.total, const Money(500));
        expect(r.rows.single.of(AgingBucket.d31to60), const Money(500));
      },
    );

    test(
      'suppliers are ordered by what they are owed; totals add up',
      () async {
        await invoice(abc, 1000, DateTime(2026, 10, 1));
        await invoice(xyz, 5000, DateTime(2026, 6, 1));
        final r = await env.reports.duesAging(today);
        expect(r.rows.map((x) => x.supplierName), [
          'XYZ Traders',
          'ABC Pharma',
        ]);
        expect(r.total, const Money(6000));
        expect(r.of(AgingBucket.over90), const Money(5000));
        expect(r.of(AgingBucket.d1to30), const Money(1000));
      },
    );

    test('deleted invoices and nothing owed give an empty report', () async {
      expect((await env.reports.duesAging(today)).rows, isEmpty);
      final i = await env.invoice(
        abc,
        totalMinor: 100,
        due: DateTime(2026, 9, 1),
        date: DateTime(2026, 8, 1),
      );
      await env.deleteInvoice(i.id);
      expect((await env.reports.duesAging(today)).total, Money.zero);
    });

    test('the bucket function', () {
      expect(agingBucketFor(daysOverdue: -5), AgingBucket.current);
      expect(agingBucketFor(daysOverdue: 0), AgingBucket.current);
      expect(agingBucketFor(daysOverdue: 1), AgingBucket.d1to30);
      expect(agingBucketFor(daysOverdue: 90), AgingBucket.d61to90);
      expect(agingBucketFor(daysOverdue: 91), AgingBucket.over90);
    });
  });
}
