import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/db/db_encryption.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/report_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/report.dart';

/// S8-08: reports and the one-time encryption stay fast at the planned scale
/// (5 000 medicines, 50 000 batches, a year of write-offs, 2 000 invoices).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<void> fill(AppDatabase db) async {
    await db.customStatement('''
      INSERT INTO suppliers (id, name, is_archived, created_at, updated_at)
      WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 50)
      SELECT 's-' || i, 'Supplier ' || i, 0, 0, 0 FROM n
    ''');
    await db.customStatement('''
      INSERT INTO medicines (id, brand_name, dosage_form, unit, reorder_level,
        is_archived, search_text, category, created_at, updated_at)
      WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 5000)
      SELECT 'med-' || i, 'Brand ' || i, 'tablet', 'strip', 0, 0,
             'brand ' || i, 'Cat ' || (i % 20), 0, 0 FROM n
    ''');
    await db.customStatement('''
      INSERT INTO batches (id, medicine_id, batch_number, expiry_date,
        expiry_precision, quantity_received, quantity_on_hand, cost_price_minor,
        supplier_id, received_date, status, created_at, updated_at)
      WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 50000)
      SELECT 'b-' || i, 'med-' || (1 + i % 5000), 'L' || i,
             date('2026-10-17', ((i * 7919) % 400 - 100) || ' days'),
             'DAY', 10, CASE WHEN i % 3 = 0 THEN 0 ELSE 10 END,
             100 + i % 900, 's-' || (1 + i % 50), '2026-10-17',
             CASE WHEN i % 3 = 0 THEN 'DEPLETED' ELSE 'ACTIVE' END, 0, 0 FROM n
    ''');
    // Write-offs spread over 12 months (ms since epoch, 2026).
    await db.customStatement('''
      INSERT INTO stock_adjustments (id, batch_id, delta_qty, reason,
        value_impact_minor, created_at)
      WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 30000)
      SELECT 'a-' || i, 'b-' || i, -5, 'DISCARDED_EXPIRED', 5 * (100 + i % 900),
             1767225600000 + (i % 365) * 86400000 FROM n
    ''');
    await db.customStatement('''
      INSERT INTO supplier_invoices (id, supplier_id, invoice_date, due_date,
        total_minor, created_at, updated_at)
      WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 2000)
      SELECT 'i-' || i, 's-' || (1 + i % 50), '2026-01-01',
             date('2026-10-17', ((i * 37) % 200 - 60) || ' days'),
             10000 + i, 0, 0 FROM n
    ''');
  }

  test('report queries on 50k batches', () async {
    final db = AppDatabase.forTesting();
    addTearDown(db.close);
    await fill(db);
    final repo = ReportRepositoryImpl(db);
    final year = DateRange(DateTime(2026), DateTime(2026, 12, 31));

    Future<int> time(Future<Object?> Function() f) async {
      final sw = Stopwatch()..start();
      await f();
      return sw.elapsedMilliseconds;
    }

    // Warm up.
    await repo.stockValuation(ValuationGroup.medicine);
    final loss = await time(() => repo.expiryLoss(year, LossGroup.month));
    final lossMed = await time(() => repo.expiryLoss(year, LossGroup.medicine));
    final stock = await time(
      () => repo.stockValuation(ValuationGroup.medicine),
    );
    final stockSup = await time(
      () => repo.stockValuation(ValuationGroup.supplier),
    );
    final dues = await time(() => repo.duesAging(DateTime(2026, 10, 17)));
    // The timings are the record of this test.
    // ignore: avoid_print
    print(
      'reports on 50k: loss/month ${loss}ms, loss/medicine ${lossMed}ms, '
      'stock/medicine ${stock}ms, stock/supplier ${stockSup}ms, dues ${dues}ms',
    );

    expect((await repo.expiryLoss(year, LossGroup.month)).rows, hasLength(12));
    expect(
      (await repo.stockValuation(ValuationGroup.medicine)).rows,
      hasLength(5000),
    );
    for (final ms in [loss, lossMed, stock, stockSup, dues]) {
      expect(ms, lessThan(2000));
    }
  });

  test('encrypting a 50k-batch database', () async {
    final dir = Directory.systemTemp.createTempSync('enc_perf');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File(p.join(dir.path, 'big.sqlite'));
    final db = AppDatabase.forFile(file, background: false);
    await fill(db);
    await db.close();
    final sw = Stopwatch()..start();
    expect(encryptInPlace(file, 'ab' * 32), isTrue);
    sw.stop();
    // The timing is the record of this test.
    // ignore: avoid_print
    print(
      'encrypting 50k batches (${file.lengthSync() ~/ 1024} KB): ${sw.elapsedMilliseconds} ms',
    );
    expect(sw.elapsed, lessThan(const Duration(seconds: 30)));
    final enc = AppDatabase.forFile(file, hexKey: 'ab' * 32, background: false);
    addTearDown(enc.close);
    final first = Stopwatch()..start();
    final rows = await ReportRepositoryImpl(enc)
        .stockValuation(ValuationGroup.medicine);
    first.stop();
    // Same here.
    // ignore: avoid_print
    print(
      'first report on the encrypted file: ${first.elapsedMilliseconds} ms',
    );
    expect(rows.rows, hasLength(5000));
  });
}
