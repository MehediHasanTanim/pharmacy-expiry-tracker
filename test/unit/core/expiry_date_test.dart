import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';

void main() {
  group('monthYear resolves to last day of month', () {
    test('31-day month', () {
      expect(ExpiryDate.monthYear(2027, 8).toIso(), '2027-08-31');
    });
    test('30-day month', () {
      expect(ExpiryDate.monthYear(2027, 4).toIso(), '2027-04-30');
    });
    test('February, non-leap year', () {
      expect(ExpiryDate.monthYear(2027, 2).toIso(), '2027-02-28');
    });
    test('February, leap year', () {
      expect(ExpiryDate.monthYear(2028, 2).toIso(), '2028-02-29');
    });
    test('century non-leap and 400-year leap', () {
      expect(ExpiryDate.monthYear(2100, 2).toIso(), '2100-02-28');
      expect(ExpiryDate.monthYear(2000, 2).toIso(), '2000-02-29');
    });
    test('December rolls the year correctly', () {
      expect(ExpiryDate.monthYear(2027, 12).toIso(), '2027-12-31');
    });
    test('records month precision', () {
      expect(ExpiryDate.monthYear(2027, 8).precision, ExpiryPrecision.month);
    });
    test('rejects invalid month', () {
      expect(() => ExpiryDate.monthYear(2027, 13), throwsRangeError);
      expect(() => ExpiryDate.monthYear(2027, 0), throwsRangeError);
    });
  });

  group('day', () {
    test('rejects impossible dates', () {
      expect(() => ExpiryDate.day(2027, 2, 29), throwsArgumentError);
      expect(() => ExpiryDate.day(2027, 4, 31), throwsArgumentError);
    });
    test('accepts leap day', () {
      expect(ExpiryDate.day(2028, 2, 29).toIso(), '2028-02-29');
    });
  });

  group('parse / toIso round trip', () {
    test('round trips', () {
      expect(ExpiryDate.parse('2027-08-31').toIso(), '2027-08-31');
      expect(ExpiryDate.parse('0999-01-05').toIso(), '0999-01-05');
    });
    test('rejects malformed input', () {
      expect(() => ExpiryDate.parse('2027-08'), throwsFormatException);
      expect(() => ExpiryDate.parse('2027-02-30'), throwsArgumentError);
    });
  });

  group('daysUntil / isExpired', () {
    final expiry = ExpiryDate.day(2026, 11, 17);

    test('counts whole days', () {
      expect(expiry.daysUntil(DateTime(2026, 10, 18)), 30);
      expect(expiry.daysUntil(DateTime(2026, 11, 16)), 1);
    });
    test('ignores time of day', () {
      expect(expiry.daysUntil(DateTime(2026, 11, 17, 23, 59)), 0);
      expect(expiry.daysUntil(DateTime(2026, 11, 17, 0, 1)), 0);
    });
    test('valid through the expiry day, expired the next day', () {
      expect(expiry.isExpired(DateTime(2026, 11, 17, 23, 59)), isFalse);
      expect(expiry.isExpired(DateTime(2026, 11, 18)), isTrue);
      expect(expiry.daysUntil(DateTime(2026, 11, 18)), -1);
    });
    test('spans a leap day', () {
      final e = ExpiryDate.day(2028, 3, 1);
      expect(e.daysUntil(DateTime(2028, 2, 28)), 2);
      expect(ExpiryDate.day(2027, 3, 1).daysUntil(DateTime(2027, 2, 28)), 1);
    });
    test('is unaffected by DST changes in between', () {
      // 2026-03-29 and 2026-10-25 are EU DST switches; the count must stay
      // exact calendar days regardless of the machine time zone.
      final e = ExpiryDate.day(2026, 10, 26);
      expect(e.daysUntil(DateTime(2026, 10, 24)), 2);
      expect(ExpiryDate.day(2026, 3, 30).daysUntil(DateTime(2026, 3, 28)), 2);
    });
    test('month-only batch is valid through the last day of the month', () {
      final e = ExpiryDate.monthYear(2027, 2);
      expect(e.isExpired(DateTime(2027, 2, 28)), isFalse);
      expect(e.isExpired(DateTime(2027, 3)), isTrue);
    });
  });

  test('orders and compares by date', () {
    final a = ExpiryDate.day(2026, 1, 1);
    final b = ExpiryDate.day(2026, 1, 2);
    expect(a.compareTo(b), lessThan(0));
    expect(a, ExpiryDate.day(2026, 1, 1));
    expect(a.hashCode, ExpiryDate.day(2026, 1, 1).hashCode);
  });
}
