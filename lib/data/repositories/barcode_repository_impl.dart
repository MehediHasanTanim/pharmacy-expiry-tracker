import 'package:drift/drift.dart' hide Batch;
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/linked_barcode.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/barcode_repository.dart';

class BarcodeRepositoryImpl implements BarcodeRepository {
  BarcodeRepositoryImpl(this._db);

  final AppDatabase _db;

  LinkedBarcode _from(MedicineBarcode r) => LinkedBarcode(
    id: r.id,
    medicineId: r.medicineId,
    value: r.value,
    symbology: r.symbology,
  );

  @override
  Future<LinkedBarcode?> findByValue(String value) async {
    final row = await (_db.select(
      _db.medicineBarcodes,
    )..where((b) => b.value.equals(value))).getSingleOrNull();
    return row == null ? null : _from(row);
  }

  @override
  Stream<List<LinkedBarcode>> watchForMedicine(String medicineId) {
    return (_db.select(_db.medicineBarcodes)
          ..where((b) => b.medicineId.equals(medicineId))
          ..orderBy([(b) => OrderingTerm.asc(b.value)]))
        .watch()
        .map((rows) => rows.map(_from).toList());
  }

  @override
  Future<void> insert(LinkedBarcode b) {
    return _db
        .into(_db.medicineBarcodes)
        .insert(
          MedicineBarcodesCompanion.insert(
            id: b.id,
            medicineId: b.medicineId,
            value: b.value,
            symbology: Value(b.symbology),
          ),
        );
  }

  @override
  Future<void> delete(String id) =>
      (_db.delete(_db.medicineBarcodes)..where((b) => b.id.equals(id))).go();
}
