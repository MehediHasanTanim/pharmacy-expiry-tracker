import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting());
  tearDown(() => db.close());

  Future<void> seedMedicine(String id) => db
      .into(db.medicines)
      .insert(
        MedicinesCompanion.insert(
          id: id,
          brandName: 'Amoxil',
          searchText: 'amoxil',
          createdAt: 0,
          updatedAt: 0,
        ),
      );

  BatchesCompanion batch(String id, {String number = 'A1'}) =>
      BatchesCompanion.insert(
        id: id,
        medicineId: 'm1',
        batchNumber: number,
        expiryDate: '2027-08-31',
        expiryPrecision: 'MONTH',
        quantityReceived: 10,
        quantityOnHand: 10,
        receivedDate: '2026-10-17',
        createdAt: 0,
        updatedAt: 0,
      );

  test('foreign keys are enforced', () async {
    final fk = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(fk.read<int>('foreign_keys'), 1);
    await expectLater(
      db.into(db.batches).insert(batch('b1')),
      throwsA(isA<Exception>()),
    );
  });

  test('inserts and reads a batch with column defaults', () async {
    await seedMedicine('m1');
    await db.into(db.batches).insert(batch('b1'));
    final row = await db.select(db.batches).getSingle();
    expect(row.status, 'ACTIVE');
    expect(row.deletedAt, isNull);
    expect(row.expiryDate, '2027-08-31');
    final med = await db.select(db.medicines).getSingle();
    expect(med.dosageForm, 'other');
    expect(med.reorderLevel, 0);
    expect(med.isArchived, isFalse);
  });

  test('batch is unique per medicine, number and expiry', () async {
    await seedMedicine('m1');
    await db.into(db.batches).insert(batch('b1'));
    await expectLater(
      db.into(db.batches).insert(batch('b2')),
      throwsA(isA<Exception>()),
    );
    await db.into(db.batches).insert(batch('b3', number: 'A2'));
  });

  test('barcodes are unique', () async {
    await seedMedicine('m1');
    MedicineBarcodesCompanion bc(String id) => MedicineBarcodesCompanion.insert(
      id: id,
      medicineId: 'm1',
      value: '8901234567890',
    );
    await db.into(db.medicineBarcodes).insert(bc('1'));
    await expectLater(
      db.into(db.medicineBarcodes).insert(bc('2')),
      throwsA(isA<Exception>()),
    );
  });

  test('scheduled_alerts.os_id is unique', () async {
    ScheduledAlertsCompanion alert(String id) =>
        ScheduledAlertsCompanion.insert(
          id: id,
          kind: 'DIGEST',
          fireAt: 1,
          osId: 42,
          payload: '{}',
          contentHash: 'h',
          state: 'PENDING',
        );
    await db.into(db.scheduledAlerts).insert(alert('a'));
    await expectLater(
      db.into(db.scheduledAlerts).insert(alert('b')),
      throwsA(isA<Exception>()),
    );
  });

  test('expected indexes exist', () async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    expect(
      names,
      containsAll([
        'idx_med_search',
        'idx_batch_expiry',
        'idx_batch_med',
        'idx_batch_supplier',
        'idx_inv_due',
        'idx_alert_fire',
      ]),
    );
  });

  test('idx_batch_expiry is partial and used for in-stock lookups', () async {
    final def = await db
        .customSelect(
          "SELECT sql FROM sqlite_master WHERE name = 'idx_batch_expiry'",
        )
        .getSingle();
    expect(def.read<String>('sql'), contains('WHERE quantity_on_hand > 0'));

    final plan = await db
        .customSelect(
          'EXPLAIN QUERY PLAN SELECT id FROM batches '
          "WHERE quantity_on_hand > 0 AND expiry_date <= '2027-01-01' "
          'ORDER BY expiry_date',
        )
        .get();
    final detail = plan.map((r) => r.read<String>('detail')).join(' ');
    expect(detail, contains('idx_batch_expiry'));
  });
}
