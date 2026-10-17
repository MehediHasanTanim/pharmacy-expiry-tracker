import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/expiry.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';

/// The near-expiry window for [medicine]: its own override when set,
/// otherwise the global setting.
int effectiveWindowDays(Medicine medicine, int globalWindowDays) =>
    medicine.alertWindowDays ?? globalWindowDays;

/// Whether a batch expiring on [expiry] belongs on the Expiry tab today:
/// expired stock always does; otherwise it must fall inside the window.
bool isInExpiryWindow({
  required ExpiryDate expiry,
  required DateTime today,
  required int windowDays,
}) => expiry.daysUntil(today) <= windowDays;

/// The first alert date strictly after [today] among `expiry - lead` for each
/// of [leadDays]; null when every lead date has already passed.
DateTime? nextLeadDate(ExpiryDate expiry, DateTime today, List<int> leadDays) {
  final base = DateTime(today.year, today.month, today.day);
  DateTime? best;
  for (final lead in leadDays) {
    final d = DateTime(
      expiry.date.year,
      expiry.date.month,
      expiry.date.day - lead,
    );
    if (d.isAfter(base) && (best == null || d.isBefore(best))) best = d;
  }
  return best;
}

/// Where "snooze until next alert" ends: the next lead date, or the expiry
/// day itself when no lead date is left.
DateTime snoozeUntilNextAlert(
  ExpiryDate expiry,
  DateTime today,
  List<int> leadDays,
) {
  return nextLeadDate(expiry, today, leadDays) ??
      DateTime(expiry.date.year, expiry.date.month, expiry.date.day);
}

/// Value of stock on hand. Batches without a cost price add nothing to the
/// total and are counted in [ValueAtRisk.missingCost].
ValueAtRisk valueAtRisk(Iterable<({int quantity, Money? cost})> batches) {
  var total = Money.zero;
  var missing = 0;
  for (final b in batches) {
    final cost = b.cost;
    if (cost == null) {
      missing++;
    } else {
      total += cost.times(b.quantity);
    }
  }
  return ValueAtRisk(total: total, missingCost: missing);
}
