import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';

void main() {
  group('tryParse', () {
    test('whole and decimal amounts', () {
      expect(Money.tryParse('12'), const Money(1200));
      expect(Money.tryParse('12.5'), const Money(1250));
      expect(Money.tryParse('12.50'), const Money(1250));
      expect(Money.tryParse('0.05'), const Money(5));
      expect(Money.tryParse('12.'), const Money(1200));
    });
    test('accepts comma separator and surrounding space', () {
      expect(Money.tryParse(' 3,25 '), const Money(325));
    });
    test('negative', () {
      expect(Money.tryParse('-1.10'), const Money(-110));
    });
    test('rejects bad input and excess precision', () {
      expect(Money.tryParse(''), isNull);
      expect(Money.tryParse('abc'), isNull);
      expect(Money.tryParse('1.234'), isNull);
      expect(Money.tryParse('1.2.3'), isNull);
    });
    test('avoids floating point error', () {
      expect(
        Money.tryParse('0.10')! + Money.tryParse('0.20')!,
        Money.tryParse('0.30'),
      );
    });
    test('custom decimal digits', () {
      expect(Money.tryParse('5', decimalDigits: 0), const Money(5));
      expect(Money.tryParse('1.5', decimalDigits: 3), const Money(1500));
    });
  });

  group('arithmetic', () {
    test('add, subtract, negate, scale', () {
      expect(const Money(100) + const Money(50), const Money(150));
      expect(const Money(100) - const Money(150), const Money(-50));
      expect(-const Money(100), const Money(-100));
      expect(const Money(250).times(4), const Money(1000));
      expect(const Money(-1).isNegative, isTrue);
    });
    test('orders', () {
      expect(const Money(1).compareTo(const Money(2)), lessThan(0));
    });
  });

  group('format', () {
    test('groups thousands and shows two decimals', () {
      expect(const Money(123456789).format(locale: 'en_US'), '1,234,567.89');
    });
    test('prefixes symbol', () {
      expect(
        const Money(1250).format(locale: 'en_US', symbol: r'$'),
        r'$12.50',
      );
    });
    test('negative amounts', () {
      expect(const Money(-500).format(locale: 'en_US'), contains('5.00'));
    });
    test('zero decimal currency', () {
      expect(
        const Money(1500).format(locale: 'en_US', decimalDigits: 0),
        '1,500',
      );
    });
  });
}
