import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/reorder_rules.dart';

void main() {
  final today = DateTime(2026, 10, 17);

  StockLot lot(int qty, DateTime expires) => (
    quantity: qty,
    expiry: ExpiryDate.day(expires.year, expires.month, expires.day),
  );

  group('usableStock (ROR-1)', () {
    test('sums batches that have not expired', () {
      expect(
        usableStock([
          lot(10, DateTime(2026, 12)),
          lot(5, DateTime(2027)),
        ], today),
        15,
      );
    });

    test('expired stock does not count; expiring today still does', () {
      expect(
        usableStock([
          lot(100, DateTime(2026, 10, 16)), // expired yesterday
          lot(7, DateTime(2026, 10, 17)), // valid through today
        ], today),
        7,
      );
    });

    test('nothing in stock is zero', () {
      expect(usableStock(const [], today), 0);
    });
  });

  group('needsReorder', () {
    test('strictly below the level', () {
      expect(needsReorder(9, 10), isTrue);
      expect(needsReorder(10, 10), isFalse);
      expect(needsReorder(0, 10), isTrue);
    });
    test('level 0 means the medicine is not tracked', () {
      expect(needsReorder(0, 0), isFalse);
    });
  });

  group('suggestedOrderQty (ROR-2)', () {
    test('tops up to twice the level', () {
      expect(suggestedOrderQty(4, 20), 36);
      expect(suggestedOrderQty(0, 20), 40);
      expect(suggestedOrderQty(19, 20), 21);
    });
    test('never below one', () {
      expect(suggestedOrderQty(50, 20), 1);
      expect(suggestedOrderQty(40, 20), 1);
    });
  });

  group('projectedShortfall (ROR-3)', () {
    test('the day after the batch that tips stock under the level expires', () {
      // 30 on hand, level 20: when the 15 expire, 15 < 20.
      final d = projectedShortfall(
        [lot(15, DateTime(2026, 12, 1)), lot(15, DateTime(2027, 6))],
        20,
        today,
      );
      expect(d, DateTime(2026, 12, 2));
    });

    test(
      'a small early batch expiring does not trigger it; the big one does',
      () {
        // 5 leave in November (30 left, still above 20); the 30 leave on
        // 2027-01-01, which is when stock finally drops below the level.
        expect(
          projectedShortfall(
            [lot(30, DateTime(2027)), lot(5, DateTime(2026, 11))],
            20,
            today,
          ),
          DateTime(2027, 1, 2),
        );
      },
    );

    test('already below the level is a reorder now, not a projection', () {
      expect(projectedShortfall([lot(5, DateTime(2027))], 20, today), isNull);
    });

    test('batches expiring the same day leave together', () {
      // Each alone would leave 20 (not below), together they leave 10.
      final d = projectedShortfall(
        [
          lot(10, DateTime(2026, 11, 5)),
          lot(10, DateTime(2026, 11, 5)),
          lot(20, DateTime(2027)),
        ],
        25,
        today,
      );
      expect(d, DateTime(2026, 11, 6));
    });

    test('already-expired stock is ignored', () {
      expect(
        projectedShortfall(
          [lot(100, DateTime(2026, 10, 1)), lot(30, DateTime(2027, 3, 31))],
          20,
          today,
        ),
        DateTime(2027, 4),
      );
    });

    test('month and year rollover', () {
      expect(
        projectedShortfall([lot(30, DateTime(2026, 12, 31))], 20, today),
        DateTime(2027),
      );
    });

    test('untracked medicines never project', () {
      expect(
        projectedShortfall([lot(1, DateTime(2026, 11))], 0, today),
        isNull,
      );
    });
  });
}
