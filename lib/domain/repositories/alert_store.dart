import 'package:pharmacy_expiry_tracker/domain/alerts/alert_planner.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_records.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';

/// Persistence for the alert engine: what is scheduled, and what was sent.
abstract interface class AlertStore {
  /// Every row, whatever its state (ids stay reserved after firing).
  Future<List<ScheduledAlertRecord>> all();

  /// Records [alert] as pending, replacing any row with the same key.
  Future<void> upsertPending(PlannedAlert alert);

  Future<void> markState(List<String> keys, ScheduledState state);

  /// Pending rows whose time has passed become fired; returns them.
  Future<List<ScheduledAlertRecord>> markPastDueFired(DateTime now);

  /// Deletes fired/cancelled rows and log entries older than the cutoffs.
  Future<void> prune({required DateTime rows, required DateTime log});

  Future<void> addLog(AlertLogEntry entry);

  /// Newest first.
  Stream<List<AlertLogEntry>> watchLog({int limit = 100});

  Future<void> markLogOpened(String id, DateTime at);

  /// Earliest pending alert after [now], if any.
  Future<DateTime?> nextPendingFireAt(DateTime now);

  Stream<int> watchPendingCount();

  /// Records that a reorder reminder for each medicine was delivered on [day].
  Future<void> markReorderNotified(List<String> medicineIds, DateTime day);
}

/// Reads the batches alert planning needs.
abstract interface class AlertSource {
  /// Active, unhandled batches with stock from medicines that are not
  /// archived. Expired stock is included. When [horizonDays] is given, only
  /// batches expiring on or before `today + horizonDays` are returned.
  Future<List<PlanBatch>> loadPlanBatches({
    required DateTime today,
    required int globalWindowDays,
    int? horizonDays,
  });

  /// Unpaid invoices that have a due date, from any supplier.
  Future<List<PlanInvoice>> loadPlanInvoices();

  /// Medicines below their reorder level as of [today].
  Future<List<PlanReorder>> loadPlanReorders({required DateTime today});
}
