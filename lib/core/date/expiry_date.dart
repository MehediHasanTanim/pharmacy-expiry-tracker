import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';

enum ExpiryPrecision { month, day }

/// A medicine expiry date.
///
/// Packs often print only month/year (`08/2027`). That is interpreted as the
/// **last day of that month**. A batch is valid *through* its expiry date and
/// is expired from the following day.
@immutable
class ExpiryDate implements Comparable<ExpiryDate> {
  ExpiryDate.day(int year, int month, int day)
    : date = _validated(year, month, day),
      precision = ExpiryPrecision.day;

  /// Month/year only; resolves to the last day of the month.
  ExpiryDate.monthYear(int year, int month)
    : date = _lastDayOfMonth(year, month),
      precision = ExpiryPrecision.month;

  const ExpiryDate._(this.date, this.precision);

  /// Parses `YYYY-MM-DD` as stored in the database.
  factory ExpiryDate.parse(
    String iso, {
    ExpiryPrecision precision = ExpiryPrecision.day,
  }) {
    final parts = iso.split('-');
    if (parts.length != 3) throw FormatException('Invalid date', iso);
    final y = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final d = int.parse(parts[2]);
    return ExpiryDate._(_validated(y, m, d), precision);
  }

  /// Like [ExpiryDate.day] but returns null for an impossible date.
  static ExpiryDate? tryDay(int year, int month, int day) {
    final d = DateTime(year, month, day);
    if (d.year != year || d.month != month || d.day != day) return null;
    return ExpiryDate._(d, ExpiryPrecision.day);
  }

  /// Local calendar date (no time component).
  final DateTime date;
  final ExpiryPrecision precision;

  /// Whole days from [today] until expiry. Negative once expired.
  int daysUntil(DateTime today) {
    final t = dateOnly(today);
    // Compare as UTC calendar dates so DST shifts can't skew the day count.
    return DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime.utc(t.year, t.month, t.day)).inDays;
  }

  /// True from the day *after* the expiry date.
  bool isExpired(DateTime today) => daysUntil(today) < 0;

  /// `YYYY-MM-DD`, the database representation.
  String toIso() =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static DateTime _lastDayOfMonth(int year, int month) {
    if (month < 1 || month > 12) {
      throw RangeError.range(month, 1, 12, 'month');
    }
    // Day 0 of the next month is the last day of this one (handles leap years).
    return DateTime(year, month + 1, 0);
  }

  static DateTime _validated(int year, int month, int day) {
    final d = DateTime(year, month, day);
    if (d.year != year || d.month != month || d.day != day) {
      throw ArgumentError('Invalid date: $year-$month-$day');
    }
    return d;
  }

  @override
  int compareTo(ExpiryDate other) => date.compareTo(other.date);

  @override
  bool operator ==(Object other) =>
      other is ExpiryDate && other.date == date && other.precision == precision;

  @override
  int get hashCode => Object.hash(date, precision);

  @override
  String toString() => 'ExpiryDate(${toIso()}, ${precision.name})';
}
