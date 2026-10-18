import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/reorder.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/medicine_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/reorder_repository.dart';
import 'package:uuid/uuid.dart';

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

/// Tracks orders placed with suppliers (ROR-5, ROR-7).
class OrderTracker {
  OrderTracker({
    required ReorderRepository reorder,
    required MedicineRepository medicines,
    required Clock clock,
    required DataChangeBus bus,
    String Function()? newId,
  }) : _reorder = reorder,
       _medicines = medicines,
       _clock = clock,
       _bus = bus,
       _newId = newId ?? (() => const Uuid().v4());

  final ReorderRepository _reorder;
  final MedicineRepository _medicines;
  final Clock _clock;
  final DataChangeBus _bus;
  final String Function() _newId;

  /// Records that [quantity] of the medicine was ordered. Reminders to reorder
  /// pause until [expectedOn] (a week from now if not given), then the order
  /// is chased.
  Future<PlacedOrder> place(
    String medicineId, {
    required int quantity,
    String? supplierId,
    DateTime? expectedOn,
  }) async {
    if (quantity <= 0) {
      throw const ValidationException('quantity', 'Quantity must be positive');
    }
    if (await _medicines.getById(medicineId) == null) {
      throw NotFoundException('medicine', medicineId);
    }
    final today = dateOnly(_clock.now());
    final expected = expectedOn == null ? null : dateOnly(expectedOn);
    if (expected != null && expected.isBefore(today)) {
      throw const ValidationException(
        'expectedOn',
        'The expected date cannot be in the past',
      );
    }
    final order = PlacedOrder(
      id: _newId(),
      medicineId: medicineId,
      supplierId: supplierId,
      quantity: quantity,
      orderedOn: today,
      expectedOn: expected,
    );
    await _reorder.insertOrder(order, _clock.now());
    _announce(medicineId);
    return order;
  }

  /// The goods arrived: closes the order and returns it, so the caller can
  /// open the receive form pre-filled with its quantity and supplier.
  Future<PlacedOrder> markReceived(String medicineId) async {
    final order = await _reorder.getOpenOrder(medicineId);
    if (order == null) throw NotFoundException('order', medicineId);
    await _reorder.closeOrder(order.id, received: true);
    _announce(medicineId);
    return order;
  }

  Future<void> cancel(String medicineId) async {
    final order = await _reorder.getOpenOrder(medicineId);
    if (order == null) return;
    await _reorder.closeOrder(order.id, received: false);
    _announce(medicineId);
  }

  void _announce(String medicineId) => _bus.emit(
    DataChange(DataChangeKind.reorderChanged, medicineId: medicineId),
  );
}
