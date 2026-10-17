import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/expiry_bucket.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/expiry_rules.dart';

Medicine med({int? window}) => Medicine(
  id: 'm',
  brandName: 'X',
  dosageForm: DosageForm.tablet,
  unit: StockUnit.strip,
  reorderLevel: 0,
  isArchived: false,
  alertWindowDays: window,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  final today = DateTime(2026, 10, 17);

  group('bucketFor boundaries (S2-01)', () {
    test('every edge of the default 30/60/90 buckets', () {
      const expected = {
        -30: ExpiryBucket.expired,
        -1: ExpiryBucket.expired,
        0: ExpiryBucket.d30,
        1: ExpiryBucket.d30,
        29: ExpiryBucket.d30,
        30: ExpiryBucket.d30,
        31: ExpiryBucket.d60,
        60: ExpiryBucket.d60,
        61: ExpiryBucket.d90,
        90: ExpiryBucket.d90,
        91: ExpiryBucket.ok,
        1000: ExpiryBucket.ok,
      };
      expected.forEach((days, bucket) {
        expect(bucketFor(days), bucket, reason: '$days days');
      });
    });
    test('respects custom thresholds', () {
      const t = [7, 14, 21];
      expect(bucketFor(7, thresholds: t), ExpiryBucket.d30);
      expect(bucketFor(8, thresholds: t), ExpiryBucket.d60);
      expect(bucketFor(22, thresholds: t), ExpiryBucket.ok);
    });
  });

  group('bucketDayRange', () {
    test('ranges tile the timeline without gaps or overlap', () {
      final r = {for (final b in ExpiryBucket.values) b: bucketDayRange(b)};
      expect(r[ExpiryBucket.expired], (minDays: null, maxDays: -1));
      expect(r[ExpiryBucket.d30], (minDays: 0, maxDays: 30));
      expect(r[ExpiryBucket.d60], (minDays: 31, maxDays: 60));
      expect(r[ExpiryBucket.d90], (minDays: 61, maxDays: 90));
      expect(r[ExpiryBucket.ok], (minDays: 91, maxDays: null));
      // Every day maps to the bucket whose range contains it.
      for (var d = -5; d < 200; d++) {
        final b = bucketFor(d);
        final range = bucketDayRange(b);
        expect(
          range.minDays == null || d >= range.minDays!,
          isTrue,
          reason: '$d',
        );
        expect(
          range.maxDays == null || d <= range.maxDays!,
          isTrue,
          reason: '$d',
        );
      }
    });
  });

  group('per-medicine window (S2-01)', () {
    test('override beats the global window', () {
      expect(effectiveWindowDays(med(window: 180), 90), 180);
      expect(effectiveWindowDays(med(window: 30), 90), 30);
      expect(effectiveWindowDays(med(), 90), 90);
    });
    test('isInExpiryWindow includes expired stock and the window edge', () {
      bool inWin(ExpiryDate e, int w) =>
          isInExpiryWindow(expiry: e, today: today, windowDays: w);
      expect(inWin(ExpiryDate.day(2026, 10, 1), 90), isTrue, reason: 'expired');
      expect(inWin(ExpiryDate.day(2027, 1, 15), 90), isTrue, reason: 'day 90');
      expect(inWin(ExpiryDate.day(2027, 1, 16), 90), isFalse, reason: 'day 91');
      expect(inWin(ExpiryDate.day(2027, 1, 16), 180), isTrue);
    });
  });

  group('nextLeadDate / snooze until next alert', () {
    final expiry = ExpiryDate.day(2026, 12, 31);
    const leads = [90, 60, 30, 14, 7, 1, 0];

    test('picks the earliest lead date after today', () {
      // Leads: Oct 2, Nov 1, Dec 1, Dec 17, Dec 24, Dec 30, Dec 31.
      expect(nextLeadDate(expiry, today, leads), DateTime(2026, 11));
    });
    test('skips a lead date that is today', () {
      expect(
        nextLeadDate(expiry, DateTime(2026, 11), leads),
        DateTime(2026, 12),
      );
    });
    test('null once every lead date has passed', () {
      expect(nextLeadDate(expiry, DateTime(2026, 12, 31), leads), isNull);
      expect(nextLeadDate(expiry, today, const []), isNull);
    });
    test('snoozeUntilNextAlert falls back to the expiry day', () {
      expect(
        snoozeUntilNextAlert(expiry, DateTime(2026, 12, 31), leads),
        DateTime(2026, 12, 31),
      );
      expect(snoozeUntilNextAlert(expiry, today, leads), DateTime(2026, 11));
    });
    test('month-end arithmetic across year boundary', () {
      final e = ExpiryDate.day(2027, 1, 5);
      expect(
        nextLeadDate(e, DateTime(2026, 12, 20), const [30, 7]),
        DateTime(2026, 12, 29),
      );
    });
  });

  group('valueAtRisk (S2-09)', () {
    test('sums quantity x cost', () {
      final v = valueAtRisk([
        (quantity: 10, cost: const Money(250)),
        (quantity: 2, cost: const Money(1000)),
      ]);
      expect(v.total, const Money(4500));
      expect(v.isPartial, isFalse);
    });
    test('batches without a cost are counted, not guessed', () {
      final v = valueAtRisk([
        (quantity: 10, cost: const Money(100)),
        (quantity: 5, cost: null),
        (quantity: 1, cost: null),
      ]);
      expect(v.total, const Money(1000));
      expect(v.missingCost, 2);
      expect(v.isPartial, isTrue);
    });
    test('empty is zero and complete', () {
      final v = valueAtRisk(const []);
      expect(v.total, Money.zero);
      expect(v.isPartial, isFalse);
    });
  });
}
