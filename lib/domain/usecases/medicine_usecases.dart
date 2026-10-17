import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/medicine_repository.dart';

void validateMedicineInput(MedicineInput i) {
  if (i.brandName.trim().isEmpty) {
    throw const ValidationException('brandName', 'Brand name is required');
  }
  if (i.reorderLevel < 0) {
    throw const ValidationException(
      'reorderLevel',
      'Reorder level cannot be negative',
    );
  }
  if (i.packSize != null && i.packSize! <= 0) {
    throw const ValidationException('packSize', 'Pack size must be positive');
  }
  if (i.alertWindowDays != null && i.alertWindowDays! <= 0) {
    throw const ValidationException(
      'alertWindowDays',
      'Alert window must be positive',
    );
  }
}

/// Creates or updates a medicine (MED-1, MED-2). Duplicate detection (MED-5)
/// is a warning the UI raises via `MedicineRepository.findDuplicate`, so this
/// use case itself never blocks on duplicates.
class SaveMedicine {
  SaveMedicine(this._medicines, this._bus);

  final MedicineRepository _medicines;
  final DataChangeBus _bus;

  /// Creates when [id] is null, otherwise updates. Returns the medicine id.
  Future<String> call(MedicineInput input, {String? id}) async {
    validateMedicineInput(input);
    final String savedId;
    if (id == null) {
      savedId = await _medicines.create(input);
    } else {
      await _medicines.update(id, input);
      savedId = id;
    }
    _bus.emit(DataChange(DataChangeKind.medicineChanged, medicineId: savedId));
    return savedId;
  }
}

/// Archiving hides a medicine and (from Sprint 3) stops its alerts, while
/// keeping history (MED-6).
class SetMedicineArchived {
  SetMedicineArchived(this._medicines, this._bus);

  final MedicineRepository _medicines;
  final DataChangeBus _bus;

  Future<void> call(String id, {required bool archived}) async {
    await _medicines.setArchived(id, archived: archived);
    _bus.emit(DataChange(DataChangeKind.medicineChanged, medicineId: id));
  }
}
