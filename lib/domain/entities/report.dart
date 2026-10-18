import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';

/// What an expiry-loss report is grouped by (RPT-1).
enum LossGroup { month, supplier, medicine }

/// What the stock valuation is grouped by (RPT-2).
enum ValuationGroup { medicine, supplier, category }

/// A date range, whole days, both ends included.
@immutable
class DateRange {
  const DateRange(this.from, this.to);

  final DateTime from;
  final DateTime to;

  /// Milliseconds since the epoch for local midnight at the start of [from].
  int get fromMs =>
      DateTime(from.year, from.month, from.day).millisecondsSinceEpoch;

  /// The first millisecond after [to]'s last day (exclusive end).
  int get toMsExclusive =>
      DateTime(to.year, to.month, to.day + 1).millisecondsSinceEpoch;

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

/// One line of a report: a month, supplier, medicine or category.
@immutable
class ReportRow {
  const ReportRow({
    required this.key,
    required this.label,
    required this.quantity,
    required this.value,
    required this.batches,
    this.unpriced = 0,
  });

  /// Stable id for drilling down (a month `2026-10`, or a database id).
  final String key;
  final String label;
  final int quantity;
  final Money value;
  final int batches;

  /// Batches in this row with no cost price, so [value] understates them.
  final int unpriced;
}

/// A grouped report with its totals.
@immutable
class GroupedReport {
  const GroupedReport(this.rows);

  final List<ReportRow> rows;

  int get quantity => rows.fold(0, (a, r) => a + r.quantity);
  Money get value => rows.fold(Money.zero, (a, r) => a + r.value);
  int get batches => rows.fold(0, (a, r) => a + r.batches);
  int get unpriced => rows.fold(0, (a, r) => a + r.unpriced);
}

/// One written-off batch, behind a loss row.
@immutable
class LossDetail {
  const LossDetail({
    required this.on,
    required this.medicineName,
    required this.batchNumber,
    required this.quantity,
    this.value,
    this.supplierName,
  });

  final DateTime on;
  final String medicineName;
  final String batchNumber;
  final int quantity;
  final Money? value;
  final String? supplierName;
}

/// One batch in stock, behind a valuation row.
@immutable
class StockDetail {
  const StockDetail({
    required this.medicineName,
    required this.batchNumber,
    required this.expiry,
    required this.quantity,
    this.value,
  });

  final String medicineName;
  final String batchNumber;
  final DateTime expiry;
  final int quantity;
  final Money? value;
}

/// How overdue an unpaid balance is.
enum AgingBucket { current, d1to30, d31to60, d61to90, over90 }

AgingBucket agingBucketFor({required int daysOverdue}) {
  if (daysOverdue <= 0) return AgingBucket.current;
  if (daysOverdue <= 30) return AgingBucket.d1to30;
  if (daysOverdue <= 60) return AgingBucket.d31to60;
  if (daysOverdue <= 90) return AgingBucket.d61to90;
  return AgingBucket.over90;
}

/// What one supplier is owed, by age (RPT-3).
@immutable
class AgingRow {
  const AgingRow({
    required this.supplierId,
    required this.supplierName,
    required this.buckets,
  });

  final String supplierId;
  final String supplierName;
  final Map<AgingBucket, Money> buckets;

  Money of(AgingBucket b) => buckets[b] ?? Money.zero;

  Money get total => buckets.values.fold(Money.zero, (a, m) => a + m);
}

@immutable
class AgingReport {
  const AgingReport(this.rows);

  final List<AgingRow> rows;

  Money of(AgingBucket b) => rows.fold(Money.zero, (a, r) => a + r.of(b));

  Money get total => rows.fold(Money.zero, (a, r) => a + r.total);
}
