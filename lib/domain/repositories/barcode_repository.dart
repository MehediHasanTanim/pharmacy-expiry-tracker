import 'package:pharmacy_expiry_tracker/domain/entities/linked_barcode.dart';

abstract interface class BarcodeRepository {
  /// The barcode with exactly this value, if linked.
  Future<LinkedBarcode?> findByValue(String value);

  Stream<List<LinkedBarcode>> watchForMedicine(String medicineId);

  Future<void> insert(LinkedBarcode barcode);

  Future<void> delete(String id);
}
