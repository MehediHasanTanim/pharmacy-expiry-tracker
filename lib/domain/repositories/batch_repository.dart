import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';

abstract interface class BatchRepository {
  Future<Batch?> getById(String id);

  Stream<Batch?> watchById(String id);

  /// All non-deleted batches of the medicine with this (normalised) number,
  /// regardless of expiry.
  Future<List<Batch>> findByMedicineAndNumber(
    String medicineId,
    String batchNumber,
  );

  /// Another batch with the same medicine, number and expiry.
  Future<Batch?> findExact(
    String medicineId,
    String batchNumber,
    ExpiryDate expiry, {
    String? excludeId,
  });

  /// All batches of one medicine, soonest expiry first, depleted last.
  Stream<List<Batch>> watchByMedicine(String medicineId);

  /// Batches that are active and hold stock, soonest expiry first.
  Stream<List<BatchWithMedicine>> watchAllActive();

  Future<void> insert(Batch batch);

  /// Replaces all editable fields of an existing batch.
  Future<void> update(Batch batch);

  Future<void> updateQuantity(
    String id, {
    required int onHand,
    required int received,
    required BatchStatus status,
    required DateTime at,
  });

  /// Sets the snooze/handled state exactly (null clears it).
  Future<void> setAlertState(
    String id, {
    required DateTime? snoozedUntil,
    required DateTime? handledAt,
    required DateTime at,
  });

  Future<void> insertAdjustment(StockAdjustment adjustment);

  /// Newest first.
  Stream<List<StockAdjustment>> watchAdjustments(String batchId);
}
