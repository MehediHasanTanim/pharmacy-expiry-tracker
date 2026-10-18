import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/linked_barcode.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/barcode_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/medicine_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/transaction_runner.dart';
import 'package:uuid/uuid.dart';

/// Longest barcode value accepted (GS1 DataMatrix payloads can be long).
const maxBarcodeLength = 128;

/// Cleans up a scanned value: whitespace and control characters removed.
/// Throws if nothing sensible is left.
String normalizeBarcode(String raw) {
  final v = raw.replaceAll(RegExp(r'[\s\x00-\x1f\x7f]'), '');
  if (v.isEmpty) {
    throw const ValidationException('barcode', 'Barcode is empty');
  }
  if (v.length > maxBarcodeLength) {
    throw const ValidationException('barcode', 'Barcode is too long');
  }
  return v;
}

/// Finding and linking medicines by barcode (SCN-2, MED-3). A value belongs
/// to exactly one medicine; a medicine may have many values.
class BarcodeService {
  BarcodeService({
    required BarcodeRepository barcodes,
    required MedicineRepository medicines,
    required TransactionRunner transaction,
    required DataChangeBus bus,
    String Function()? newId,
  }) : _barcodes = barcodes,
       _medicines = medicines,
       _tx = transaction,
       _bus = bus,
       _newId = newId ?? (() => const Uuid().v4());

  final BarcodeRepository _barcodes;
  final MedicineRepository _medicines;
  final TransactionRunner _tx;
  final DataChangeBus _bus;
  final String Function() _newId;

  /// The medicine this value is linked to, or null if it is new.
  Future<Medicine?> lookup(String raw) async {
    final linked = await _barcodes.findByValue(normalizeBarcode(raw));
    return linked == null ? null : _medicines.getById(linked.medicineId);
  }

  /// Links [raw] to [medicineId]. Linking the same pair again does nothing; a
  /// value already on another medicine throws [BarcodeTakenException].
  Future<LinkedBarcode> link(
    String medicineId,
    String raw, {
    String? symbology,
  }) async {
    final value = normalizeBarcode(raw);
    final result = await _tx.run(() async {
      if (await _medicines.getById(medicineId) == null) {
        throw NotFoundException('medicine', medicineId);
      }
      final existing = await _barcodes.findByValue(value);
      if (existing != null) {
        if (existing.medicineId == medicineId) return existing;
        throw BarcodeTakenException(value, existing.medicineId);
      }
      final created = LinkedBarcode(
        id: _newId(),
        medicineId: medicineId,
        value: value,
        symbology: symbology,
      );
      await _barcodes.insert(created);
      return created;
    });
    _bus.emit(
      DataChange(DataChangeKind.barcodeChanged, medicineId: medicineId),
    );
    return result;
  }

  Future<void> unlink(LinkedBarcode barcode) async {
    await _barcodes.delete(barcode.id);
    _bus.emit(
      DataChange(DataChangeKind.barcodeChanged, medicineId: barcode.medicineId),
    );
  }
}
