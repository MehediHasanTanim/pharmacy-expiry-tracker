import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/reorder_repository.dart';

/// Silences reorder reminders for one medicine (until restocked or snoozed,
/// ROR-4).
class UpdateReorderSnooze {
  UpdateReorderSnooze({
    required ReorderRepository reorder,
    required Clock clock,
    required DataChangeBus bus,
  }) : _reorder = reorder,
       _clock = clock,
       _bus = bus;

  final ReorderRepository _reorder;
  final Clock _clock;
  final DataChangeBus _bus;

  Future<void> snooze(String medicineId, DateTime until) async {
    final day = dateOnly(until);
    if (day.isBefore(dateOnly(_clock.now()))) {
      throw const ValidationException(
        'until',
        'Snooze date cannot be in the past',
      );
    }
    await _set(medicineId, day);
  }

  Future<void> clear(String medicineId) => _set(medicineId, null);

  /// Puts back a previous value (Undo).
  Future<void> restore(String medicineId, DateTime? previous) =>
      _set(medicineId, previous);

  Future<void> _set(String medicineId, DateTime? until) async {
    await _reorder.setSnooze(medicineId, until);
    _bus.emit(
      DataChange(DataChangeKind.reorderChanged, medicineId: medicineId),
    );
  }
}
