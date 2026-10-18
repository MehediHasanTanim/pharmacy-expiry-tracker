import 'dart:math' as math;

import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';

/// A batch's contribution to stock, for reorder maths.
typedef StockLot = ({int quantity, ExpiryDate expiry});

/// Units that can still be sold: batches that have not expired. Expired stock
/// is on the shelf but does not count (ROR-1).
int usableStock(Iterable<StockLot> lots, DateTime today) {
  var total = 0;
  for (final l in lots) {
    if (!l.expiry.isExpired(today)) total += l.quantity;
  }
  return total;
}

/// Whether to reorder: stock has fallen below the level. A level of 0 means
/// the medicine is not tracked.
bool needsReorder(int usable, int reorderLevel) =>
    reorderLevel > 0 && usable < reorderLevel;

/// Suggested order: enough to reach twice the reorder level, at least one
/// (ROR-2).
int suggestedOrderQty(int usable, int reorderLevel) =>
    math.max(reorderLevel * 2 - usable, 1);

/// The first day stock will drop below [reorderLevel] purely because batches
/// expire, or null if it already has, or never will (ROR-3).
///
/// A batch counts through its expiry date, so the shortfall starts the day
/// after the batch that tips it expires.
DateTime? projectedShortfall(
  Iterable<StockLot> lots,
  int reorderLevel,
  DateTime today,
) {
  if (reorderLevel <= 0) return null;
  final live = [
    for (final l in lots)
      if (!l.expiry.isExpired(today) && l.quantity > 0) l,
  ]..sort((a, b) => a.expiry.compareTo(b.expiry));
  var remaining = live.fold<int>(0, (s, l) => s + l.quantity);
  if (remaining < reorderLevel) return null;

  var i = 0;
  while (i < live.length) {
    final day = live[i].expiry;
    // Every batch expiring on the same day leaves together.
    while (i < live.length && live[i].expiry.toIso() == day.toIso()) {
      remaining -= live[i].quantity;
      i++;
    }
    if (remaining < reorderLevel) {
      final d = day.date;
      return DateTime(d.year, d.month, d.day + 1);
    }
  }
  return null;
}
