import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';

@immutable
class Batch {
  const Batch({
    required this.id,
    required this.medicineId,
    required this.batchNumber,
    required this.expiry,
    required this.quantityReceived,
    required this.quantityOnHand,
    required this.receivedDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.costPrice,
    this.sellingPrice,
    this.supplierId,
    this.invoiceId,
    this.snoozedUntil,
    this.handledAt,
    this.notes,
  });

  final String id;
  final String medicineId;
  final String batchNumber;
  final ExpiryDate expiry;
  final int quantityReceived;
  final int quantityOnHand;
  final Money? costPrice;
  final Money? sellingPrice;

  /// Calendar date (no time component).
  final DateTime receivedDate;
  final String? supplierId;
  final String? invoiceId;
  final BatchStatus status;
  final DateTime? snoozedUntil;
  final DateTime? handledAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Batch copyWith({
    String? batchNumber,
    ExpiryDate? expiry,
    int? quantityReceived,
    int? quantityOnHand,
    Money? costPrice,
    Money? sellingPrice,
    DateTime? receivedDate,
    String? supplierId,
    BatchStatus? status,
    DateTime? snoozedUntil,
    DateTime? handledAt,
    String? notes,
    DateTime? updatedAt,
    bool clearSnooze = false,
    bool clearHandled = false,
  }) {
    return Batch(
      id: id,
      medicineId: medicineId,
      batchNumber: batchNumber ?? this.batchNumber,
      expiry: expiry ?? this.expiry,
      quantityReceived: quantityReceived ?? this.quantityReceived,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      receivedDate: receivedDate ?? this.receivedDate,
      supplierId: supplierId ?? this.supplierId,
      invoiceId: invoiceId,
      status: status ?? this.status,
      snoozedUntil: clearSnooze ? null : snoozedUntil ?? this.snoozedUntil,
      handledAt: clearHandled ? null : handledAt ?? this.handledAt,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Editable batch fields on receipt. Quantity changes after receipt go through
/// stock adjustments, never through editing.
@immutable
class BatchInput {
  const BatchInput({
    required this.medicineId,
    required this.batchNumber,
    required this.expiry,
    required this.quantity,
    required this.receivedDate,
    this.costPrice,
    this.sellingPrice,
    this.supplierId,
    this.invoiceId,
    this.notes,
  });

  final String medicineId;
  final String batchNumber;
  final ExpiryDate expiry;
  final int quantity;
  final DateTime receivedDate;
  final Money? costPrice;
  final Money? sellingPrice;
  final String? supplierId;
  final String? invoiceId;
  final String? notes;
}

/// A batch together with its medicine, for cross-medicine lists.
@immutable
class BatchWithMedicine {
  const BatchWithMedicine({required this.batch, required this.medicine});

  final Batch batch;
  final Medicine medicine;
}

@immutable
class StockAdjustment {
  const StockAdjustment({
    required this.id,
    required this.batchId,
    required this.deltaQty,
    required this.reason,
    required this.createdAt,
    this.note,
    this.valueImpact,
    this.returnId,
  });

  final String id;
  final String batchId;

  /// Positive adds stock, negative removes it.
  final int deltaQty;
  final AdjustmentReason reason;
  final String? note;

  /// Cost of stock written off (loss reasons only).
  final Money? valueImpact;
  final String? returnId;
  final DateTime createdAt;
}
