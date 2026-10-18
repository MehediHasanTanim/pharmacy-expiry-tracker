import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';

/// A medicine whose usable stock has fallen below its reorder level.
@immutable
class ReorderItem {
  const ReorderItem({
    required this.medicineId,
    required this.name,
    required this.unit,
    required this.reorderLevel,
    required this.usable,
    required this.suggested,
    this.supplierId,
    this.snoozedUntil,
  });

  final String medicineId;

  /// Display name, e.g. "Amoxil 500 mg".
  final String name;
  final StockUnit unit;
  final int reorderLevel;

  /// Stock that has not expired.
  final int usable;

  /// Quantity to order to reach twice the reorder level.
  final int suggested;

  /// The medicine's preferred supplier, if it has one.
  final String? supplierId;

  /// Reminders for this medicine are silent until this date.
  final DateTime? snoozedUntil;
}
