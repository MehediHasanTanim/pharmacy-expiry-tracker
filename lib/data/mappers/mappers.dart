import 'package:drift/drift.dart' hide Batch;
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';

DateTime _ms(int ms) => DateTime.fromMillisecondsSinceEpoch(ms);
int _toMs(DateTime d) => d.millisecondsSinceEpoch;

String dateToIso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime dateFromIso(String s) {
  final p = s.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

String? _blankToNull(String? s) {
  final t = s?.trim();
  return t == null || t.isEmpty ? null : t;
}

extension MedicineRowMapper on MedicineRow {
  Medicine toEntity() => Medicine(
    id: id,
    brandName: brandName,
    genericName: genericName,
    strength: strength,
    dosageForm: DosageForm.fromDb(dosageForm),
    unit: StockUnit.fromDb(unit),
    packSize: packSize,
    manufacturer: manufacturer,
    category: category,
    reorderLevel: reorderLevel,
    preferredSupplierId: preferredSupplierId,
    alertWindowDays: alertWindowDays,
    storageCondition: storageCondition,
    notes: notes,
    isArchived: isArchived,
    createdAt: _ms(createdAt),
    updatedAt: _ms(updatedAt),
  );
}

/// Trims text fields and turns blanks into null.
MedicinesCompanion medicineCompanion(
  MedicineInput i, {
  required String searchText,
  required DateTime now,
  String? id,
}) {
  return MedicinesCompanion(
    id: id == null ? const Value.absent() : Value(id),
    brandName: Value(i.brandName.trim()),
    genericName: Value(_blankToNull(i.genericName)),
    strength: Value(_blankToNull(i.strength)),
    dosageForm: Value(i.dosageForm.name),
    unit: Value(i.unit.name),
    packSize: Value(i.packSize),
    manufacturer: Value(_blankToNull(i.manufacturer)),
    category: Value(_blankToNull(i.category)),
    reorderLevel: Value(i.reorderLevel),
    preferredSupplierId: Value(i.preferredSupplierId),
    alertWindowDays: Value(i.alertWindowDays),
    storageCondition: Value(_blankToNull(i.storageCondition)),
    notes: Value(_blankToNull(i.notes)),
    searchText: Value(searchText),
    updatedAt: Value(_toMs(now)),
  );
}

extension BatchRowMapper on BatchRow {
  Batch toEntity() => Batch(
    id: id,
    medicineId: medicineId,
    batchNumber: batchNumber,
    expiry: ExpiryDate.parse(
      expiryDate,
      precision: expiryPrecision == 'MONTH'
          ? ExpiryPrecision.month
          : ExpiryPrecision.day,
    ),
    quantityReceived: quantityReceived,
    quantityOnHand: quantityOnHand,
    costPrice: costPriceMinor == null ? null : Money(costPriceMinor!),
    sellingPrice: sellingPriceMinor == null ? null : Money(sellingPriceMinor!),
    receivedDate: dateFromIso(receivedDate),
    supplierId: supplierId,
    invoiceId: invoiceId,
    status: BatchStatus.fromDb(status),
    snoozedUntil: snoozedUntil == null ? null : dateFromIso(snoozedUntil!),
    handledAt: handledAt == null ? null : _ms(handledAt!),
    notes: notes,
    createdAt: _ms(createdAt),
    updatedAt: _ms(updatedAt),
  );
}

BatchesCompanion batchCompanion(Batch b) {
  return BatchesCompanion(
    id: Value(b.id),
    medicineId: Value(b.medicineId),
    batchNumber: Value(b.batchNumber),
    expiryDate: Value(b.expiry.toIso()),
    expiryPrecision: Value(
      b.expiry.precision == ExpiryPrecision.month ? 'MONTH' : 'DAY',
    ),
    quantityReceived: Value(b.quantityReceived),
    quantityOnHand: Value(b.quantityOnHand),
    costPriceMinor: Value(b.costPrice?.minor),
    sellingPriceMinor: Value(b.sellingPrice?.minor),
    receivedDate: Value(dateToIso(b.receivedDate)),
    supplierId: Value(b.supplierId),
    invoiceId: Value(b.invoiceId),
    status: Value(b.status.db),
    snoozedUntil: Value(
      b.snoozedUntil == null ? null : dateToIso(b.snoozedUntil!),
    ),
    handledAt: Value(b.handledAt == null ? null : _toMs(b.handledAt!)),
    notes: Value(_blankToNull(b.notes)),
    createdAt: Value(_toMs(b.createdAt)),
    updatedAt: Value(_toMs(b.updatedAt)),
  );
}

extension StockAdjustmentRowMapper on StockAdjustmentRow {
  StockAdjustment toEntity() => StockAdjustment(
    id: id,
    batchId: batchId,
    deltaQty: deltaQty,
    reason: AdjustmentReason.fromDb(reason),
    note: note,
    valueImpact: valueImpactMinor == null ? null : Money(valueImpactMinor!),
    returnId: returnId,
    createdAt: _ms(createdAt),
  );
}

StockAdjustmentsCompanion adjustmentCompanion(StockAdjustment a) {
  return StockAdjustmentsCompanion(
    id: Value(a.id),
    batchId: Value(a.batchId),
    deltaQty: Value(a.deltaQty),
    reason: Value(a.reason.db),
    note: Value(_blankToNull(a.note)),
    valueImpactMinor: Value(a.valueImpact?.minor),
    returnId: Value(a.returnId),
    createdAt: Value(_toMs(a.createdAt)),
  );
}
