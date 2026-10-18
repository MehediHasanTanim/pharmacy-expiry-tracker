import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';

/// An order placed with a supplier for a medicine (ROR-5).
@immutable
class PlacedOrder {
  const PlacedOrder({
    required this.id,
    required this.medicineId,
    required this.quantity,
    required this.orderedOn,
    this.supplierId,
    this.expectedOn,
  });

  final String id;
  final String medicineId;
  final String? supplierId;
  final int quantity;
  final DateTime orderedOn;

  /// When the goods are due; null when the user did not say.
  final DateTime? expectedOn;

  /// Without a stated date, an order is assumed to arrive within a week.
  static const defaultLeadDays = 7;

  DateTime get dueOn =>
      expectedOn ?? orderedOn.add(const Duration(days: defaultLeadDays));
}

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
    this.order,
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

  /// The open order for it, if one was placed.
  final PlacedOrder? order;
}
