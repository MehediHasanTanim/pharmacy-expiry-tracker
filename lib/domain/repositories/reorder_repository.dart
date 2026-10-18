import 'package:pharmacy_expiry_tracker/domain/entities/reorder.dart';

abstract interface class ReorderRepository {
  /// Medicines below their reorder level as of [today], most short first.
  /// Re-emits when stock, levels or reminder state change.
  Stream<List<ReorderItem>> watchBelowLevel({required DateTime today});

  /// Records an order; any earlier open order for the medicine is replaced.
  Future<void> insertOrder(PlacedOrder order, DateTime createdAt);

  Future<PlacedOrder?> getOpenOrder(String medicineId);

  /// Closes an open order as received or cancelled.
  Future<void> closeOrder(String orderId, {required bool received});

  /// Silences reorder reminders for a medicine until [until]; null clears it.
  Future<void> setSnooze(String medicineId, DateTime? until);
}
