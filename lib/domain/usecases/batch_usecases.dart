// Named parameters cannot use private initialising formals, and the
// transaction callbacks return futures from `async` closures on purpose.
// ignore_for_file: prefer_initializing_formals, async_return_with_no_await

import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/core/text/search_text.dart';
import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/batch_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/medicine_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/transaction_runner.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/stock_rules.dart';
import 'package:uuid/uuid.dart';

/// How [AddBatch] reacts when the medicine already has a batch with the same
/// number.
sealed class DuplicateResolution {
  const DuplicateResolution();

  /// Throw [DuplicateBatchException] so the caller can ask the user.
  static const DuplicateResolution ask = _Ask();

  /// Add the quantity to the existing batch [batchId].
  static DuplicateResolution mergeInto(String batchId) => _Merge(batchId);

  /// Keep both; only possible when the expiry differs.
  static const DuplicateResolution separate = _Separate();
}

class _Ask extends DuplicateResolution {
  const _Ask();
}

class _Merge extends DuplicateResolution {
  const _Merge(this.batchId);
  final String batchId;
}

class _Separate extends DuplicateResolution {
  const _Separate();
}

class AddBatchResult {
  const AddBatchResult(this.batch, {required this.merged});

  final Batch batch;

  /// True when the quantity was added to an existing batch.
  final bool merged;
}

Money? _validPrice(Money? m, String field) {
  if (m != null && m.isNegative) {
    throw ValidationException(field, 'Price cannot be negative');
  }
  return m;
}

String _validBatchNumber(String raw) {
  final n = normalizeBatchNumber(raw);
  if (n.isEmpty) {
    throw const ValidationException('batchNumber', 'Batch number is required');
  }
  return n;
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Receives stock as a batch (BAT-1…5, 7). Writes the batch and its initial
/// RECEIVED adjustment in one transaction.
class AddBatch {
  AddBatch({
    required BatchRepository batches,
    required MedicineRepository medicines,
    required TransactionRunner transaction,
    required Clock clock,
    required DataChangeBus bus,
    String Function()? newId,
  }) : _batches = batches,
       _medicines = medicines,
       _tx = transaction,
       _clock = clock,
       _bus = bus,
       _newId = newId ?? (() => const Uuid().v4());

  final BatchRepository _batches;
  final MedicineRepository _medicines;
  final TransactionRunner _tx;
  final Clock _clock;
  final DataChangeBus _bus;
  final String Function() _newId;

  Future<AddBatchResult> call(
    BatchInput input, {
    DuplicateResolution onDuplicate = DuplicateResolution.ask,
  }) async {
    final number = _validBatchNumber(input.batchNumber);
    if (input.quantity <= 0) {
      throw const ValidationException('quantity', 'Quantity must be positive');
    }
    final cost = _validPrice(input.costPrice, 'costPrice');
    final selling = _validPrice(input.sellingPrice, 'sellingPrice');

    final result = await _tx.run(() async {
      final medicine = await _medicines.getById(input.medicineId);
      if (medicine == null) {
        throw NotFoundException('medicine', input.medicineId);
      }
      if (medicine.isArchived) {
        throw const ValidationException('medicineId', 'Medicine is archived');
      }
      final now = _clock.now();
      final existing = await _batches.findByMedicineAndNumber(
        input.medicineId,
        number,
      );

      if (existing.isNotEmpty) {
        switch (onDuplicate) {
          case _Merge(:final batchId):
            final target = existing.where((b) => b.id == batchId).firstOrNull;
            if (target == null) throw NotFoundException('batch', batchId);
            return _merge(target, input.quantity, now);
          case _Separate():
            final exact = existing.any(
              (b) =>
                  b.expiry == input.expiry ||
                  b.expiry.toIso() == input.expiry.toIso(),
            );
            if (exact) {
              throw DuplicateBatchException(existing, exactMatch: true);
            }
          case _Ask():
            final exact = existing.any(
              (b) => b.expiry.toIso() == input.expiry.toIso(),
            );
            throw DuplicateBatchException(existing, exactMatch: exact);
        }
      }

      final batch = Batch(
        id: _newId(),
        medicineId: input.medicineId,
        batchNumber: number,
        expiry: input.expiry,
        quantityReceived: input.quantity,
        quantityOnHand: input.quantity,
        costPrice: cost,
        sellingPrice: selling,
        receivedDate: _dateOnly(input.receivedDate),
        supplierId: input.supplierId,
        invoiceId: input.invoiceId,
        status: BatchStatus.active,
        notes: input.notes,
        createdAt: now,
        updatedAt: now,
      );
      await _batches.insert(batch);
      await _batches.insertAdjustment(
        StockAdjustment(
          id: _newId(),
          batchId: batch.id,
          deltaQty: input.quantity,
          reason: AdjustmentReason.received,
          createdAt: now,
        ),
      );
      return AddBatchResult(batch, merged: false);
    });
    _bus.emit(
      DataChange(
        DataChangeKind.batchAdded,
        medicineId: input.medicineId,
        batchId: result.batch.id,
      ),
    );
    return result;
  }

  Future<AddBatchResult> _merge(Batch target, int qty, DateTime now) async {
    final onHand = target.quantityOnHand + qty;
    final received = target.quantityReceived + qty;
    await _batches.updateQuantity(
      target.id,
      onHand: onHand,
      received: received,
      status: BatchStatus.active,
      at: now,
    );
    await _batches.insertAdjustment(
      StockAdjustment(
        id: _newId(),
        batchId: target.id,
        deltaQty: qty,
        reason: AdjustmentReason.received,
        note: 'Merged into existing batch',
        createdAt: now,
      ),
    );
    final updated = await _batches.getById(target.id);
    return AddBatchResult(updated!, merged: true);
  }
}

/// Editable batch fields (BAT-9). Quantity is changed only by adjustments.
class BatchEdit {
  const BatchEdit({
    required this.batchNumber,
    required this.expiry,
    required this.receivedDate,
    this.costPrice,
    this.sellingPrice,
    this.supplierId,
    this.notes,
  });

  final String batchNumber;
  final ExpiryDate expiry;
  final DateTime receivedDate;
  final Money? costPrice;
  final Money? sellingPrice;
  final String? supplierId;
  final String? notes;
}

class EditBatch {
  EditBatch({
    required BatchRepository batches,
    required TransactionRunner transaction,
    required Clock clock,
    required DataChangeBus bus,
  }) : _batches = batches,
       _tx = transaction,
       _clock = clock,
       _bus = bus;

  final BatchRepository _batches;
  final TransactionRunner _tx;
  final Clock _clock;
  final DataChangeBus _bus;

  Future<Batch> call(String batchId, BatchEdit edit) async {
    final number = _validBatchNumber(edit.batchNumber);
    final cost = _validPrice(edit.costPrice, 'costPrice');
    final selling = _validPrice(edit.sellingPrice, 'sellingPrice');

    final saved = await _tx.run(() async {
      final current = await _batches.getById(batchId);
      if (current == null) throw NotFoundException('batch', batchId);

      final clash = await _batches.findExact(
        current.medicineId,
        number,
        edit.expiry,
        excludeId: batchId,
      );
      if (clash != null) {
        throw DuplicateBatchException([clash], exactMatch: true);
      }

      final expiryChanged = current.expiry.toIso() != edit.expiry.toIso();
      final updated = Batch(
        id: current.id,
        medicineId: current.medicineId,
        batchNumber: number,
        expiry: edit.expiry,
        quantityReceived: current.quantityReceived,
        quantityOnHand: current.quantityOnHand,
        costPrice: cost,
        sellingPrice: selling,
        receivedDate: _dateOnly(edit.receivedDate),
        supplierId: edit.supplierId,
        invoiceId: current.invoiceId,
        status: current.status,
        // A new expiry restarts alerting: old snooze/handled no longer apply.
        snoozedUntil: expiryChanged ? null : current.snoozedUntil,
        handledAt: expiryChanged ? null : current.handledAt,
        notes: edit.notes,
        createdAt: current.createdAt,
        updatedAt: _clock.now(),
      );
      await _batches.update(updated);
      return updated;
    });
    _bus.emit(
      DataChange(
        DataChangeKind.batchEdited,
        medicineId: saved.medicineId,
        batchId: saved.id,
      ),
    );
    return saved;
  }
}

/// Changes a batch's quantity with a reason, keeping an audit trail (BAT-5).
class AdjustStock {
  AdjustStock({
    required BatchRepository batches,
    required TransactionRunner transaction,
    required Clock clock,
    required DataChangeBus bus,
    String Function()? newId,
  }) : _batches = batches,
       _tx = transaction,
       _clock = clock,
       _bus = bus,
       _newId = newId ?? (() => const Uuid().v4());

  final BatchRepository _batches;
  final TransactionRunner _tx;
  final Clock _clock;
  final DataChangeBus _bus;
  final String Function() _newId;

  /// [delta] is signed: positive adds stock, negative removes it.
  Future<Batch> call({
    required String batchId,
    required int delta,
    required AdjustmentReason reason,
    String? note,
  }) async {
    validateDelta(reason, delta);

    final updated = await _tx.run(() async {
      final batch = await _batches.getById(batchId);
      if (batch == null) throw NotFoundException('batch', batchId);

      final onHand = batch.quantityOnHand + delta;
      if (onHand < 0) {
        throw InsufficientStockException(
          available: batch.quantityOnHand,
          requested: -delta,
        );
      }
      final now = _clock.now();
      // Receiving more also raises the lifetime received total.
      final received = reason == AdjustmentReason.received
          ? batch.quantityReceived + delta
          : batch.quantityReceived;

      await _batches.updateQuantity(
        batchId,
        onHand: onHand,
        received: received,
        status: deriveStatus(onHand, reason),
        at: now,
      );
      await _batches.insertAdjustment(
        StockAdjustment(
          id: _newId(),
          batchId: batchId,
          deltaQty: delta,
          reason: reason,
          note: note,
          valueImpact: valueImpact(reason, delta, batch.costPrice),
          createdAt: now,
        ),
      );
      return (await _batches.getById(batchId))!;
    });
    _bus.emit(
      DataChange(
        DataChangeKind.stockAdjusted,
        medicineId: updated.medicineId,
        batchId: batchId,
      ),
    );
    return updated;
  }
}
