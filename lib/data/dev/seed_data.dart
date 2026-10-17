import 'dart:math';

import 'package:drift/drift.dart' hide Batch;
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/text/search_text.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/mappers/mappers.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:uuid/uuid.dart';

const List<String> _stems = [
  'Amoxi',
  'Para',
  'Cefi',
  'Ibu',
  'Metro',
  'Omepra',
  'Azithro',
  'Cipro',
  'Napro',
  'Losar',
  'Atorva',
  'Metfor',
  'Levo',
  'Ranit',
  'Diclo',
  'Cetiri',
  'Predni',
  'Salbu',
  'Clopi',
  'Amlo',
  'Rosuva',
  'Panto',
  'Doxy',
  'Fluco',
];
const List<String> _tails = [
  'cillin',
  'cetamol',
  'xime',
  'profen',
  'nidazole',
  'zole',
];
const List<String> _generics = [
  'Amoxicillin',
  'Paracetamol',
  'Cefixime',
  'Ibuprofen',
  'Metronidazole',
  'Omeprazole',
  'Azithromycin',
  'Ciprofloxacin',
];
const List<String> _strengths = [
  '10 mg',
  '20 mg',
  '50 mg',
  '100 mg',
  '250 mg',
  '500 mg',
];
const List<DosageForm> _forms = [
  DosageForm.tablet,
  DosageForm.capsule,
  DosageForm.syrup,
  DosageForm.injection,
  DosageForm.ointment,
  DosageForm.drops,
];
const List<StockUnit> _units = [
  StockUnit.strip,
  StockUnit.box,
  StockUnit.bottle,
];

/// Fills the database with plausible, deterministic demo data: medicines with
/// batches whose expiries spread from long-expired to years away. Dev flavor
/// only (see the More tab).
class SeedDataGenerator {
  SeedDataGenerator(this._db, {int seed = 42}) : _random = Random(seed);

  final AppDatabase _db;
  final Random _random;

  /// Inserts [medicines] medicines and about [batches] batches in total.
  /// Returns the number of batches written.
  Future<int> generate({
    required DateTime today,
    int medicines = 500,
    int batches = 1000,
  }) async {
    const uuid = Uuid();
    final nowMs = today.millisecondsSinceEpoch;
    final medCompanions = <MedicinesCompanion>[];
    final medIds = <String>[];
    for (var i = 0; i < medicines; i++) {
      final id = uuid.v4();
      final brand =
          '${_stems[i % _stems.length]}${_tails[(i ~/ _stems.length) % _tails.length]} ${i ~/ (_stems.length * _tails.length) + 1}';
      final strength = _strengths[_random.nextInt(_strengths.length)];
      final generic = _generics[_random.nextInt(_generics.length)];
      final form = _forms[_random.nextInt(_forms.length)];
      medIds.add(id);
      medCompanions.add(
        MedicinesCompanion.insert(
          id: id,
          brandName: brand,
          genericName: Value(generic),
          strength: Value(strength),
          dosageForm: Value(form.name),
          unit: Value(_units[_random.nextInt(_units.length)].name),
          reorderLevel: Value(_random.nextInt(5) * 10),
          searchText: normalizeSearchText('$brand $generic $strength'),
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );
    }

    final batchCompanions = <BatchesCompanion>[];
    final adjustCompanions = <StockAdjustmentsCompanion>[];
    final used = <String>{};
    for (var i = 0; i < batches; i++) {
      final medId = medIds[i % medIds.length];
      final number = 'B${(1000 + i).toRadixString(36).toUpperCase()}';
      // Expiry between ~3 months ago and ~3 years ahead, skewed towards soon.
      final offsetDays = (pow(_random.nextDouble(), 2) * 1100).round() - 90;
      final raw = DateTime(today.year, today.month, today.day + offsetDays);
      final monthOnly = _random.nextBool();
      final expiry = monthOnly
          ? ExpiryDate.monthYear(raw.year, raw.month)
          : ExpiryDate.day(raw.year, raw.month, raw.day);
      if (!used.add('$medId|$number|${expiry.toIso()}')) continue;
      final qty = 5 + _random.nextInt(95);
      final id = uuid.v4();
      final cost = 100 + _random.nextInt(9900);
      batchCompanions.add(
        BatchesCompanion.insert(
          id: id,
          medicineId: medId,
          batchNumber: number,
          expiryDate: expiry.toIso(),
          expiryPrecision: monthOnly ? 'MONTH' : 'DAY',
          quantityReceived: qty,
          quantityOnHand: qty,
          costPriceMinor: Value(cost),
          sellingPriceMinor: Value((cost * 1.3).round()),
          receivedDate: dateToIso(today),
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );
      adjustCompanions.add(
        StockAdjustmentsCompanion.insert(
          id: uuid.v4(),
          batchId: id,
          deltaQty: qty,
          reason: AdjustmentReason.received.db,
          createdAt: nowMs,
        ),
      );
    }

    await _db.transaction(() async {
      await _db.batch((b) {
        b
          ..insertAll(_db.medicines, medCompanions)
          ..insertAll(_db.batches, batchCompanions)
          ..insertAll(_db.stockAdjustments, adjustCompanions);
      });
    });
    return batchCompanions.length;
  }
}
