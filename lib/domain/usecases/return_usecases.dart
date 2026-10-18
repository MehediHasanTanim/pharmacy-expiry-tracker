import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier_return.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/return_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/batch_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/ledger_usecases.dart';

class ReturnResult {
  const ReturnResult(this.ret, this.credit);

  final ReturnRecord ret;
  final Credit? credit;
}

/// Sends stock back to a supplier (SUP-10): takes the quantities off the
/// batches, records the return, and optionally issues a credit against the
/// supplier's account, all in one transaction. If any line is invalid, or the
/// credit is refused, nothing is changed.
class ReturnToSupplier {
  ReturnToSupplier({
    required LedgerDeps deps,
    required ReturnRepository returns,
    required AdjustStock adjustStock,
    required RecordCredit recordCredit,
  }) : _d = deps,
       _returns = returns,
       _adjust = adjustStock,
       _credit = recordCredit;

  final LedgerDeps _d;
  final ReturnRepository _returns;
  final AdjustStock _adjust;
  final RecordCredit _credit;

  /// [credit], when given, is issued against [creditInvoiceId] or, without
  /// one, the account in general.
  Future<ReturnResult> call({
    required String supplierId,
    required List<ReturnLineInput> lines,
    required DateTime returnedOn,
    String? note,
    Money? credit,
    String? creditInvoiceId,
  }) async {
    if (lines.isEmpty) {
      throw const ValidationException('lines', 'Choose something to return');
    }
    final seen = <String>{};
    for (final l in lines) {
      if (l.quantity <= 0) {
        throw const ValidationException(
          'quantity',
          'Quantity must be positive',
        );
      }
      if (!seen.add(l.batchId)) {
        throw const ValidationException('lines', 'A batch is listed twice');
      }
    }
    if (credit != null && credit.minor <= 0) {
      throw const ValidationException('credit', 'Credit must be positive');
    }

    final result = await _d.transaction.run(() async {
      final supplier = await _d.suppliers.getById(supplierId);
      if (supplier == null) throw NotFoundException('supplier', supplierId);
      final now = _d.clock.now();
      final returnId = _d.newId();
      final built = <ReturnLine>[];
      for (final l in lines) {
        final batch = await _d.batches.getById(l.batchId);
        if (batch == null) throw NotFoundException('batch', l.batchId);
        if (batch.supplierId != null && batch.supplierId != supplierId) {
          throw const ValidationException(
            'lines',
            'A batch came from a different supplier',
          );
        }
        if (batch.status != BatchStatus.active) {
          throw const ValidationException('lines', 'A batch is not in stock');
        }
        // Throws InsufficientStockException when there is not enough.
        await _adjust(
          batchId: l.batchId,
          delta: -l.quantity,
          reason: AdjustmentReason.returned,
          note: 'Returned to ${supplier.name}',
        );
        built.add(
          ReturnLine(
            id: _d.newId(),
            batchId: l.batchId,
            quantity: l.quantity,
            value: batch.costPrice?.times(l.quantity),
          ),
        );
      }
      final ret = ReturnRecord(
        id: returnId,
        supplierId: supplierId,
        returnedOn: DateTime(returnedOn.year, returnedOn.month, returnedOn.day),
        createdAt: now,
        note: note?.trim().isEmpty ?? true ? null : note!.trim(),
        lines: built,
      );
      await _returns.insert(ret);
      Credit? issued;
      if (credit != null) {
        issued = await _credit(
          supplierId: supplierId,
          amount: credit,
          issuedOn: returnedOn,
          invoiceId: creditInvoiceId,
          returnId: returnId,
          note: 'Return',
        );
      }
      return ReturnResult(ret, issued);
    });
    _d.announce();
    return result;
  }
}
