import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/core/text/search_text.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/expiry_bucket.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/expiry_input.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/stock_rules.dart';

void main() {
  group('normalizers', () {
    test('search text lowercases, strips accents, collapses space', () {
      expect(
        normalizeSearchText('  Paracétamol   500MG '),
        'paracetamol 500mg',
      );
      expect(normalizeSearchText('Crème Brûlée'), 'creme brulee');
    });
    test('batch numbers are trimmed and upper-cased', () {
      expect(normalizeBatchNumber(' ab-12 '), 'AB-12');
    });
  });

  group('parseExpiryInput', () {
    ExpiryParse month(String m, String y) =>
        parseExpiryInput(month: m, year: y);

    test('month/year resolves to last day of the month', () {
      final r = month('08', '2027') as ExpiryParsed;
      expect(r.value.toIso(), '2027-08-31');
      expect(r.value.precision, ExpiryPrecision.month);
    });
    test('two-digit year means 20YY', () {
      expect((month('2', '28') as ExpiryParsed).value.toIso(), '2028-02-29');
    });
    test('incomplete until both parts are typed', () {
      expect(month('', '2027'), isA<ExpiryIncomplete>());
      expect(month('08', ''), isA<ExpiryIncomplete>());
      expect(month('08', '202'), isA<ExpiryIncomplete>());
    });
    test('invalid month, year and non-numbers', () {
      expect(month('13', '2027'), isA<ExpiryInvalid>());
      expect(month('0', '2027'), isA<ExpiryInvalid>());
      expect(month('08', '1999'), isA<ExpiryInvalid>());
      expect(month('ab', '2027'), isA<ExpiryInvalid>());
    });
    test('exact mode parses the day and rejects impossible dates', () {
      final ok = parseExpiryInput(
        day: '15',
        month: '3',
        year: '2027',
        exact: true,
      ) as ExpiryParsed;
      expect(ok.value.toIso(), '2027-03-15');
      expect(ok.value.precision, ExpiryPrecision.day);
      expect(
        parseExpiryInput(day: '31', month: '4', year: '2027', exact: true),
        isA<ExpiryInvalid>(),
      );
      expect(
        parseExpiryInput(day: '29', month: '2', year: '2027', exact: true),
        isA<ExpiryInvalid>(),
      );
      expect(
        parseExpiryInput(day: '', month: '3', year: '2027', exact: true),
        isA<ExpiryIncomplete>(),
      );
    });
  });

  group('expiryWarning', () {
    final today = DateTime(2026, 10, 17);
    test('past expiry warns, today does not', () {
      expect(
        expiryWarning(ExpiryDate.day(2026, 10, 16), today),
        ExpiryWarning.inPast,
      );
      expect(expiryWarning(ExpiryDate.day(2026, 10, 17), today), isNull);
    });
    test('more than ten years out warns', () {
      expect(
        expiryWarning(ExpiryDate.day(2037, 10, 18), today),
        ExpiryWarning.farFuture,
      );
      expect(expiryWarning(ExpiryDate.day(2030, 1, 1), today), isNull);
    });
  });

  group('bucketFor', () {
    test('boundaries belong to the nearer bucket', () {
      expect(bucketFor(-1), ExpiryBucket.expired);
      expect(bucketFor(0), ExpiryBucket.d30);
      expect(bucketFor(30), ExpiryBucket.d30);
      expect(bucketFor(31), ExpiryBucket.d60);
      expect(bucketFor(60), ExpiryBucket.d60);
      expect(bucketFor(61), ExpiryBucket.d90);
      expect(bucketFor(90), ExpiryBucket.d90);
      expect(bucketFor(91), ExpiryBucket.ok);
    });
    test('custom thresholds', () {
      expect(bucketFor(10, thresholds: [7, 14, 21]), ExpiryBucket.d60);
    });
  });

  group('stock rules', () {
    test('deriveStatus', () {
      expect(deriveStatus(5, AdjustmentReason.sold), BatchStatus.active);
      expect(deriveStatus(0, AdjustmentReason.sold), BatchStatus.depleted);
      expect(deriveStatus(0, AdjustmentReason.returned), BatchStatus.returned);
      expect(deriveStatus(0, AdjustmentReason.damaged), BatchStatus.discarded);
      expect(
        deriveStatus(0, AdjustmentReason.discardedExpired),
        BatchStatus.discarded,
      );
      expect(
        deriveStatus(0, AdjustmentReason.correction),
        BatchStatus.depleted,
      );
    });
    test('validateDelta signs', () {
      validateDelta(AdjustmentReason.received, 1);
      validateDelta(AdjustmentReason.correction, -1);
      validateDelta(AdjustmentReason.correction, 1);
      validateDelta(AdjustmentReason.sold, -1);
      expect(
        () => validateDelta(AdjustmentReason.sold, 1),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => validateDelta(AdjustmentReason.received, -1),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => validateDelta(AdjustmentReason.correction, 0),
        throwsA(isA<ValidationException>()),
      );
    });
    test('valueImpact only for loss reasons with a cost', () {
      const cost = Money(250);
      expect(
        valueImpact(AdjustmentReason.damaged, -4, cost),
        const Money(1000),
      );
      expect(
        valueImpact(AdjustmentReason.discardedExpired, -1, cost),
        const Money(250),
      );
      expect(valueImpact(AdjustmentReason.sold, -4, cost), isNull);
      expect(valueImpact(AdjustmentReason.damaged, -4, null), isNull);
    });
  });
}
