import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';

import '../support/test_env.dart';

void main() {
  late TestEnv env;
  setUp(() => env = TestEnv());
  tearDown(() => env.dispose());

  test('create trims fields, nulls blanks, and builds search text', () async {
    final id = await env.saveMedicine(
      const MedicineInput(
        brandName: '  Paracétamol ',
        genericName: '  ',
        strength: '500MG',
        dosageForm: DosageForm.tablet,
        unit: StockUnit.strip,
        reorderLevel: 20,
      ),
    );
    final m = (await env.medicines.getById(id))!;
    expect(m.brandName, 'Paracétamol');
    expect(m.genericName, isNull);
    expect(m.reorderLevel, 20);
    expect(m.unit, StockUnit.strip);
    expect(m.isArchived, isFalse);
    expect(m.createdAt, env.clock.current);
    final row = await env.db.select(env.db.medicines).getSingle();
    expect(row.searchText, 'paracetamol 500mg');
  });

  test('update changes fields and search text, keeps createdAt', () async {
    final id = await env.medicine();
    env.clock.advance(const Duration(days: 1));
    await env.saveMedicine(
      const MedicineInput(brandName: 'Moxatag', reorderLevel: 5),
      id: id,
    );
    final m = (await env.medicines.getById(id))!;
    expect(m.brandName, 'Moxatag');
    expect(m.reorderLevel, 5);
    expect(m.updatedAt.isAfter(m.createdAt), isTrue);
    final hits = await env.medicines.watchAll(query: 'moxatag').first;
    expect(hits, hasLength(1));
    expect(await env.medicines.watchAll(query: 'amoxil').first, isEmpty);
  });

  test('update of unknown id throws NotFound', () async {
    await expectLater(
      env.saveMedicine(const MedicineInput(brandName: 'X'), id: 'nope'),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('validation rejects blank brand, negative level, bad pack size', () {
    expect(
      () => env.saveMedicine(const MedicineInput(brandName: '  ')),
      throwsA(isA<ValidationException>()),
    );
    expect(
      () => env.saveMedicine(
        const MedicineInput(brandName: 'A', reorderLevel: -1),
      ),
      throwsA(isA<ValidationException>()),
    );
    expect(
      () => env.saveMedicine(const MedicineInput(brandName: 'A', packSize: 0)),
      throwsA(isA<ValidationException>()),
    );
  });

  test('archive hides from default list and can be restored', () async {
    final id = await env.medicine();
    await env.setArchived(id, archived: true);
    expect(await env.medicines.watchAll().first, isEmpty);
    final all = await env.medicines.watchAll(includeArchived: true).first;
    expect(all.single.medicine.isArchived, isTrue);
    await env.setArchived(id, archived: false);
    expect(await env.medicines.watchAll().first, hasLength(1));
  });

  test('watchAll orders by name and filters by all words', () async {
    await env.medicine(brand: 'Zinc', strength: '20 mg', generic: null);
    await env.medicine(brand: 'Amoxil');
    await env.medicine(brand: 'Augmentin', strength: '625 mg');
    final all = await env.medicines.watchAll().first;
    expect(all.map((s) => s.medicine.brandName), [
      'Amoxil',
      'Augmentin',
      'Zinc',
    ]);
    final hits = await env.medicines.watchAll(query: 'aug 625').first;
    expect(hits.single.medicine.brandName, 'Augmentin');
    expect(await env.medicines.watchAll(query: 'aug 500').first, isEmpty);
  });

  test('summary totals only stock-holding active batches', () async {
    final id = await env.medicine();
    await env.addBatch(
      env.batchInput(id, number: 'A', expiry: ExpiryDate.day(2027, 3, 1)),
    );
    final b = await env.addBatch(
      env.batchInput(
        id,
        number: 'B',
        quantity: 5,
        expiry: ExpiryDate.day(2026, 12, 31),
      ),
    );
    var s = (await env.medicines.watchAll().first).single;
    expect(s.onHand, 15);
    expect(s.nearestExpiry!.toIso(), '2026-12-31');

    await env.adjustStock(
      batchId: b.batch.id,
      delta: -5,
      reason: AdjustmentReason.sold,
    );
    s = (await env.medicines.watchAll().first).single;
    expect(s.onHand, 10);
    expect(s.nearestExpiry!.toIso(), '2027-03-01');
  });

  test('medicine with no stock has zero on hand and no expiry', () async {
    await env.medicine();
    final s = (await env.medicines.watchAll().first).single;
    expect(s.onHand, 0);
    expect(s.nearestExpiry, isNull);
  });

  group('findDuplicate (MED-5)', () {
    test('matches brand + strength + form case-insensitively', () async {
      final id = await env.medicine();
      final dup = await env.medicines.findDuplicate(
        brandName: ' AMOXIL ',
        strength: '500 MG',
        dosageForm: DosageForm.capsule,
      );
      expect(dup?.id, id);
    });
    test('different strength or form is not a duplicate', () async {
      await env.medicine();
      expect(
        await env.medicines.findDuplicate(
          brandName: 'Amoxil',
          strength: '250 mg',
          dosageForm: DosageForm.capsule,
        ),
        isNull,
      );
      expect(
        await env.medicines.findDuplicate(
          brandName: 'Amoxil',
          strength: '500 mg',
          dosageForm: DosageForm.syrup,
        ),
        isNull,
      );
    });
    test('null and empty strength are equal; excludeId skips self', () async {
      final id = await env.medicine(strength: null);
      expect(
        await env.medicines.findDuplicate(
          brandName: 'Amoxil',
          strength: '',
          dosageForm: DosageForm.capsule,
        ),
        isNotNull,
      );
      expect(
        await env.medicines.findDuplicate(
          brandName: 'Amoxil',
          dosageForm: DosageForm.capsule,
          excludeId: id,
        ),
        isNull,
      );
    });
  });
}
