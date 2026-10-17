// Named parameters cannot use private initialising formals.
// ignore_for_file: prefer_initializing_formals, async_return_with_no_await

import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/expiry.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/batch_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/transaction_runner.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/batch_usecases.dart';

/// Snooze and "handled" state of a batch's alerts (EXP-5, S2-07). Every
/// change returns the previous [AlertState] so the UI can offer Undo.
class UpdateAlertState {
  UpdateAlertState({
    required BatchRepository batches,
    required Clock clock,
    required DataChangeBus bus,
  }) : _batches = batches,
       _clock = clock,
       _bus = bus;

  final BatchRepository _batches;
  final Clock _clock;
  final DataChangeBus _bus;

  /// Silences lead-time alerts for the batch until [until] (a calendar date).
  Future<AlertState> snooze(String batchId, DateTime until) async {
    final today = dateOnly(_clock.now());
    final day = dateOnly(until);
    if (day.isBefore(today)) {
      throw const ValidationException(
        'until',
        'Snooze date cannot be in the past',
      );
    }
    return _apply(
      batchId,
      (cur) => AlertState(snoozedUntil: day, handledAt: cur.handledAt),
    );
  }

  Future<AlertState> clearSnooze(String batchId) =>
      _apply(batchId, (cur) => AlertState(handledAt: cur.handledAt));

  /// Marks the batch as dealt with: no further lead-time alerts.
  Future<AlertState> markHandled(String batchId) => _apply(
    batchId,
    (cur) =>
        AlertState(snoozedUntil: cur.snoozedUntil, handledAt: _clock.now()),
  );

  Future<AlertState> unmarkHandled(String batchId) =>
      _apply(batchId, (cur) => AlertState(snoozedUntil: cur.snoozedUntil));

  /// Puts back a state captured before a change (Undo).
  Future<void> restore(String batchId, AlertState previous) async {
    await _apply(batchId, (_) => previous);
  }

  Future<AlertState> _apply(
    String batchId,
    AlertState Function(AlertState current) change,
  ) async {
    final batch = await _batches.getById(batchId);
    if (batch == null) throw NotFoundException('batch', batchId);
    final previous = AlertState(
      snoozedUntil: batch.snoozedUntil,
      handledAt: batch.handledAt,
    );
    final next = change(previous);
    await _batches.setAlertState(
      batchId,
      snoozedUntil: next.snoozedUntil,
      handledAt: next.handledAt,
      at: _clock.now(),
    );
    _bus.emit(
      DataChange(
        DataChangeKind.alertStateChanged,
        medicineId: batch.medicineId,
        batchId: batchId,
      ),
    );
    return previous;
  }
}

/// Writes off everything left in the given batches as expired stock, logging
/// the loss (EXP-7). All batches succeed or none do.
class DiscardBatches {
  DiscardBatches({
    required BatchRepository batches,
    required AdjustStock adjustStock,
    required TransactionRunner transaction,
  }) : _batches = batches,
       _adjust = adjustStock,
       _tx = transaction;

  final BatchRepository _batches;
  final AdjustStock _adjust;
  final TransactionRunner _tx;

  /// Returns how many batches were written off (empty ones are skipped).
  Future<int> call(List<String> batchIds, {String? note}) {
    return _tx.run(() async {
      var count = 0;
      for (final id in batchIds) {
        final batch = await _batches.getById(id);
        if (batch == null) throw NotFoundException('batch', id);
        if (batch.quantityOnHand == 0) continue;
        await _adjust(
          batchId: id,
          delta: -batch.quantityOnHand,
          reason: AdjustmentReason.discardedExpired,
          note: note,
        );
        count++;
      }
      return count;
    });
  }
}
