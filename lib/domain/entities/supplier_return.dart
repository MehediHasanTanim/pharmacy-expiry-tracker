import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';

/// One batch (or part of it) sent back to a supplier.
@immutable
class ReturnLine {
  const ReturnLine({
    required this.id,
    required this.batchId,
    required this.quantity,
    this.value,
  });

  final String id;
  final String batchId;
  final int quantity;

  /// Cost of the quantity returned, when the batch had a cost price.
  final Money? value;
}

/// Goods returned to a supplier (SUP-10).
@immutable
class ReturnRecord {
  const ReturnRecord({
    required this.id,
    required this.supplierId,
    required this.returnedOn,
    required this.createdAt,
    required this.lines,
    this.note,
  });

  final String id;
  final String supplierId;
  final DateTime returnedOn;
  final DateTime createdAt;
  final String? note;
  final List<ReturnLine> lines;

  int get totalQuantity => lines.fold(0, (a, l) => a + l.quantity);
}

/// A return line with names, for lists and the shared text.
@immutable
class ReturnLineView {
  const ReturnLineView({
    required this.medicineName,
    required this.batchNumber,
    required this.quantity,
    this.value,
  });

  final String medicineName;
  final String batchNumber;
  final int quantity;
  final Money? value;
}

/// A return as shown on the supplier page.
@immutable
class ReturnView {
  const ReturnView({
    required this.id,
    required this.supplierName,
    required this.returnedOn,
    required this.lines,
    this.note,
    this.credit,
  });

  final String id;
  final String supplierName;
  final DateTime returnedOn;
  final String? note;
  final List<ReturnLineView> lines;

  /// The credit issued for it, if any.
  final Money? credit;
}

/// What the user chose to return: [quantity] of [batchId].
@immutable
class ReturnLineInput {
  const ReturnLineInput(this.batchId, this.quantity);

  final String batchId;
  final int quantity;
}
