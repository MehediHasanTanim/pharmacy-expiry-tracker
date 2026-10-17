import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';

abstract interface class MedicineRepository {
  /// Medicines with in-stock totals, ordered by brand name. [query] filters by
  /// brand/generic/strength (all words must match).
  Stream<List<MedicineSummary>> watchAll({
    String query = '',
    bool includeArchived = false,
  });

  Stream<Medicine?> watchById(String id);

  Future<Medicine?> getById(String id);

  /// Returns the new medicine's id.
  Future<String> create(MedicineInput input);

  Future<void> update(String id, MedicineInput input);

  Future<void> setArchived(String id, {required bool archived});

  /// Another (non-deleted) medicine with the same brand, strength and form,
  /// compared case-insensitively. [excludeId] skips the one being edited.
  Future<Medicine?> findDuplicate({
    required String brandName,
    required DosageForm dosageForm,
    String? strength,
    String? excludeId,
  });
}
