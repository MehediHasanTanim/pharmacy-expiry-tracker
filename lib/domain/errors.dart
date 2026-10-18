import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';

/// Input failed validation; [field] names the offending input.
class ValidationException implements Exception {
  const ValidationException(this.field, this.message);

  final String field;
  final String message;

  @override
  String toString() => 'ValidationException($field: $message)';
}

/// A batch with the same medicine and batch number already exists.
class DuplicateBatchException implements Exception {
  const DuplicateBatchException(this.existing, {required this.exactMatch});

  /// Existing batches of this medicine with the same batch number.
  final List<Batch> existing;

  /// True when one of them also has the same expiry, so a separate batch
  /// cannot be created and the only option is to merge.
  final bool exactMatch;

  @override
  String toString() => 'DuplicateBatchException(${existing.length} existing)';
}

/// An adjustment would take a batch below zero.
class InsufficientStockException implements Exception {
  const InsufficientStockException({
    required this.available,
    required this.requested,
  });

  final int available;
  final int requested;

  @override
  String toString() =>
      'InsufficientStockException(available: $available, requested: $requested)';
}

class NotFoundException implements Exception {
  const NotFoundException(this.what, this.id);

  final String what;
  final String id;

  @override
  String toString() => 'NotFoundException($what $id)';
}

/// A payment or credit is larger than what is owed.
class OverpaymentException implements Exception {
  const OverpaymentException({required this.owed, required this.excess});

  /// What can still be paid.
  final Money owed;

  /// The part that cannot be applied; offer to record it as a credit.
  final Money excess;

  @override
  String toString() => 'OverpaymentException(owed: $owed, excess: $excess)';
}

/// An invoice cannot be deleted while payments or credits are recorded on it.
class InvoiceHasPaymentsException implements Exception {
  const InvoiceHasPaymentsException(this.invoiceId);

  final String invoiceId;

  @override
  String toString() => 'InvoiceHasPaymentsException($invoiceId)';
}
