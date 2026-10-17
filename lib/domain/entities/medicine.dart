import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';

@immutable
class Medicine {
  const Medicine({
    required this.id,
    required this.brandName,
    required this.dosageForm,
    required this.unit,
    required this.reorderLevel,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.genericName,
    this.strength,
    this.packSize,
    this.manufacturer,
    this.category,
    this.preferredSupplierId,
    this.alertWindowDays,
    this.storageCondition,
    this.notes,
  });

  final String id;
  final String brandName;
  final String? genericName;
  final String? strength;
  final DosageForm dosageForm;
  final StockUnit unit;
  final int? packSize;
  final String? manufacturer;
  final String? category;
  final int reorderLevel;
  final String? preferredSupplierId;

  /// Null means "use the global near-expiry window".
  final int? alertWindowDays;
  final String? storageCondition;
  final String? notes;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// "Amoxil 500 mg".
  String get displayName => [
    brandName,
    if (strength != null && strength!.isNotEmpty) strength,
  ].join(' ');

  MedicineInput toInput() => MedicineInput(
    brandName: brandName,
    genericName: genericName,
    strength: strength,
    dosageForm: dosageForm,
    unit: unit,
    packSize: packSize,
    manufacturer: manufacturer,
    category: category,
    reorderLevel: reorderLevel,
    preferredSupplierId: preferredSupplierId,
    alertWindowDays: alertWindowDays,
    storageCondition: storageCondition,
    notes: notes,
  );
}

/// Editable medicine fields, used for both create and update.
@immutable
class MedicineInput {
  const MedicineInput({
    required this.brandName,
    this.genericName,
    this.strength,
    this.dosageForm = DosageForm.other,
    this.unit = StockUnit.piece,
    this.packSize,
    this.manufacturer,
    this.category,
    this.reorderLevel = 0,
    this.preferredSupplierId,
    this.alertWindowDays,
    this.storageCondition,
    this.notes,
  });

  final String brandName;
  final String? genericName;
  final String? strength;
  final DosageForm dosageForm;
  final StockUnit unit;
  final int? packSize;
  final String? manufacturer;
  final String? category;
  final int reorderLevel;
  final String? preferredSupplierId;
  final int? alertWindowDays;
  final String? storageCondition;
  final String? notes;
}

/// A medicine with its in-stock totals, for list screens.
@immutable
class MedicineSummary {
  const MedicineSummary({
    required this.medicine,
    required this.onHand,
    this.nearestExpiry,
  });

  final Medicine medicine;

  /// Units across batches that still hold stock.
  final int onHand;

  /// Soonest expiry among batches that still hold stock.
  final ExpiryDate? nearestExpiry;
}
