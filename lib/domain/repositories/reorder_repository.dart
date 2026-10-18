import 'package:pharmacy_expiry_tracker/domain/entities/reorder.dart';

abstract interface class ReorderRepository {
  /// Medicines below their reorder level as of [today], most short first.
  /// Re-emits when stock, levels or reminder state change.
  Stream<List<ReorderItem>> watchBelowLevel({required DateTime today});

  /// Silences reorder reminders for a medicine until [until]; null clears it.
  Future<void> setSnooze(String medicineId, DateTime? until);
}
