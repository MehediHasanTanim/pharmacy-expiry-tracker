import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/core/text/search_text.dart';
import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/transaction_runner.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/batch_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/ledger_usecases.dart';

/// One batch on a delivery note.
@immutable
class DeliveryLine {
  const DeliveryLine({
    required this.medicineId,
    required this.batchNumber,
    required this.expiry,
    required this.quantity,
    this.costPrice,
  });

  final String medicineId;
  final String batchNumber;
  final ExpiryDate expiry;
  final int quantity;
  final Money? costPrice;
}

/// A whole delivery from one supplier (BAT-8).
@immutable
class DeliveryInput {
  const DeliveryInput({
    required this.receivedDate,
    required this.lines,
    this.supplierId,
    this.invoiceTotal,
    this.invoiceNumber,
    this.dueDate,
  });

  final DateTime receivedDate;
  final List<DeliveryLine> lines;
  final String? supplierId;

  /// When given, one invoice for this total is created and covers every line
  /// (needs a supplier).
  final Money? invoiceTotal;
  final String? invoiceNumber;
  final DateTime? dueDate;
}

/// What is wrong with one line, so the form can point at it.
@immutable
class LineProblem {
  const LineProblem(this.index, this.field, this.message);

  /// Position in the lines, or -1 for the delivery as a whole.
  final int index;
  final String field;
  final String message;

  @override
  String toString() => 'LineProblem($index $field: $message)';
}

class DeliveryInvalidException implements Exception {
  const DeliveryInvalidException(this.problems);

  final List<LineProblem> problems;

  @override
  String toString() => 'DeliveryInvalidException($problems)';
}

/// Checks a delivery without touching the database. Returns every problem
/// found, not just the first.
List<LineProblem> validateDelivery(DeliveryInput d) {
  final problems = <LineProblem>[];
  if (d.lines.isEmpty) {
    problems.add(const LineProblem(-1, 'lines', 'Add at least one batch'));
  }
  if (d.invoiceTotal != null) {
    if (d.supplierId == null) {
      problems.add(
        const LineProblem(-1, 'supplier', 'Choose a supplier for the invoice'),
      );
    }
    if (d.invoiceTotal!.minor <= 0) {
      problems.add(
        const LineProblem(-1, 'total', 'The invoice total must be positive'),
      );
    }
  }
  final seen = <String>{};
  for (var i = 0; i < d.lines.length; i++) {
    final l = d.lines[i];
    if (normalizeBatchNumber(l.batchNumber).isEmpty) {
      problems.add(LineProblem(i, 'batchNumber', 'Batch number is required'));
    }
    if (l.quantity <= 0) {
      problems.add(LineProblem(i, 'quantity', 'Quantity must be positive'));
    }
    if (l.costPrice != null && l.costPrice!.isNegative) {
      problems.add(LineProblem(i, 'costPrice', 'Price cannot be negative'));
    }
    final key =
        '${l.medicineId}|${normalizeBatchNumber(l.batchNumber)}|${l.expiry.toIso()}';
    if (!seen.add(key)) {
      problems.add(LineProblem(i, 'batchNumber', 'This batch is listed twice'));
    }
  }
  return problems;
}

class DeliveryResult {
  const DeliveryResult(this.batches, this.invoice);

  final List<Batch> batches;
  final Invoice? invoice;
}

/// Receives many batches at once, optionally with one invoice for the total.
/// Everything is written in one transaction: if any line is refused (an
/// archived medicine, a batch that already exists) nothing is saved.
class ReceiveDelivery {
  ReceiveDelivery({
    required AddBatch addBatch,
    required AddInvoice addInvoice,
    required TransactionRunner transaction,
    required DataChangeBus bus,
  }) : _addBatch = addBatch,
       _addInvoice = addInvoice,
       _tx = transaction,
       _bus = bus;

  final AddBatch _addBatch;
  final AddInvoice _addInvoice;
  final TransactionRunner _tx;
  final DataChangeBus _bus;

  Future<DeliveryResult> call(DeliveryInput input) async {
    final problems = validateDelivery(input);
    if (problems.isNotEmpty) throw DeliveryInvalidException(problems);

    final result = await _tx.run(() async {
      final batches = <Batch>[];
      for (var i = 0; i < input.lines.length; i++) {
        final l = input.lines[i];
        try {
          final added = await _addBatch(
            BatchInput(
              medicineId: l.medicineId,
              batchNumber: l.batchNumber,
              expiry: l.expiry,
              quantity: l.quantity,
              receivedDate: input.receivedDate,
              costPrice: l.costPrice,
              supplierId: input.supplierId,
            ),
            // Never silently merge into an existing batch from a bulk entry;
            // the user should decide, so a clash refuses the whole delivery.
          );
          batches.add(added.batch);
        } on DuplicateBatchException {
          throw DeliveryInvalidException([
            LineProblem(i, 'batchNumber', 'This batch already exists'),
          ]);
        } on NotFoundException {
          throw DeliveryInvalidException([
            LineProblem(i, 'medicine', 'This medicine no longer exists'),
          ]);
        } on ValidationException catch (e) {
          throw DeliveryInvalidException([LineProblem(i, e.field, e.message)]);
        }
      }
      Invoice? invoice;
      if (input.invoiceTotal != null) {
        invoice = await _addInvoice(
          InvoiceInput(
            supplierId: input.supplierId!,
            invoiceDate: input.receivedDate,
            total: input.invoiceTotal!,
            invoiceNumber: input.invoiceNumber,
            dueDate: input.dueDate,
            batchIds: [for (final b in batches) b.id],
          ),
        );
      }
      return DeliveryResult(batches, invoice);
    });
    // Announced once the transaction has committed, so a re-plan triggered by
    // it sees every batch.
    _bus.emit(const DataChange(DataChangeKind.batchAdded));
    return result;
  }
}

/// The delivery form as typed, so an interrupted session can be resumed
/// (BAT-8). Everything is text, exactly as in the fields.
@immutable
class DeliveryDraft {
  const DeliveryDraft({
    this.supplierId,
    this.invoiceNumber = '',
    this.invoiceTotal = '',
    this.receivedDate,
    this.lines = const [],
  });

  factory DeliveryDraft.fromJson(String source) {
    final j = jsonDecode(source) as Map<String, Object?>;
    return DeliveryDraft(
      supplierId: j['supplierId'] as String?,
      invoiceNumber: (j['invoiceNumber'] as String?) ?? '',
      invoiceTotal: (j['invoiceTotal'] as String?) ?? '',
      receivedDate: j['receivedDate'] == null
          ? null
          : DateTime.parse(j['receivedDate']! as String),
      lines: [
        for (final l in (j['lines'] as List?) ?? const [])
          DraftLine.fromMap((l as Map).cast<String, Object?>()),
      ],
    );
  }

  final String? supplierId;
  final String invoiceNumber;
  final String invoiceTotal;
  final DateTime? receivedDate;
  final List<DraftLine> lines;

  bool get isEmpty =>
      lines.isEmpty && invoiceNumber.isEmpty && invoiceTotal.isEmpty;

  String toJson() => jsonEncode({
    'supplierId': supplierId,
    'invoiceNumber': invoiceNumber,
    'invoiceTotal': invoiceTotal,
    'receivedDate': receivedDate?.toIso8601String(),
    'lines': [for (final l in lines) l.toMap()],
  });
}

@immutable
class DraftLine {
  const DraftLine({
    this.medicineId,
    this.medicineName = '',
    this.batchNumber = '',
    this.expiry = '',
    this.quantity = '',
    this.cost = '',
  });

  factory DraftLine.fromMap(Map<String, Object?> m) => DraftLine(
    medicineId: m['medicineId'] as String?,
    medicineName: (m['medicineName'] as String?) ?? '',
    batchNumber: (m['batchNumber'] as String?) ?? '',
    expiry: (m['expiry'] as String?) ?? '',
    quantity: (m['quantity'] as String?) ?? '',
    cost: (m['cost'] as String?) ?? '',
  );

  final String? medicineId;
  final String medicineName;
  final String batchNumber;

  /// As typed, e.g. `03/2027`.
  final String expiry;
  final String quantity;
  final String cost;

  Map<String, Object?> toMap() => {
    'medicineId': medicineId,
    'medicineName': medicineName,
    'batchNumber': batchNumber,
    'expiry': expiry,
    'quantity': quantity,
    'cost': cost,
  };
}
