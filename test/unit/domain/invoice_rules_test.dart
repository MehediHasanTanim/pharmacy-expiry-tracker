import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/invoice_rules.dart';

void main() {
  final today = DateTime(2026, 10, 17);

  InvoiceStatus status({
    int total = 10000,
    int paid = 0,
    int credited = 0,
    DateTime? due,
    DateTime? at,
  }) => invoiceStatus(
    total: Money(total),
    paid: Money(paid),
    credited: Money(credited),
    dueDate: due,
    today: at ?? today,
  );

  group('invoiceStatus (S4-03)', () {
    test('nothing paid, not yet due: unpaid', () {
      expect(status(due: DateTime(2026, 11)), InvoiceStatus.unpaid);
      expect(status(), InvoiceStatus.unpaid, reason: 'no due date at all');
    });

    test('something paid, not yet due: partial', () {
      expect(
        status(paid: 2500, due: DateTime(2026, 11)),
        InvoiceStatus.partial,
      );
    });

    test('a credit counts as partly settled too', () {
      expect(
        status(credited: 100, due: DateTime(2026, 11)),
        InvoiceStatus.partial,
      );
    });

    test('settled in full by payments, credits or both: paid', () {
      expect(status(paid: 10000), InvoiceStatus.paid);
      expect(status(credited: 10000), InvoiceStatus.paid);
      expect(status(paid: 6000, credited: 4000), InvoiceStatus.paid);
    });

    test('over-settled still reads as paid', () {
      expect(status(paid: 12000), InvoiceStatus.paid);
    });

    test('paid wins over a passed due date', () {
      expect(status(paid: 10000, due: DateTime(2026, 9)), InvoiceStatus.paid);
    });

    test('overdue starts the day after the due date', () {
      expect(
        status(due: DateTime(2026, 10, 17)),
        InvoiceStatus.unpaid,
        reason: 'due today is not yet overdue',
      );
      expect(status(due: DateTime(2026, 10, 16)), InvoiceStatus.overdue);
      expect(
        status(due: DateTime(2026, 10, 17), at: DateTime(2026, 10, 18)),
        InvoiceStatus.overdue,
      );
    });

    test('overdue takes precedence over partial', () {
      expect(
        status(paid: 2500, due: DateTime(2026, 10, 1)),
        InvoiceStatus.overdue,
      );
    });

    test('time of day is ignored', () {
      expect(
        status(due: DateTime(2026, 10, 17, 23), at: DateTime(2026, 10, 17, 1)),
        InvoiceStatus.unpaid,
      );
    });

    test('a zero-total invoice is settled', () {
      expect(status(total: 0), InvoiceStatus.paid);
    });
  });

  group('defaultDueDate', () {
    test('adds the terms in days', () {
      expect(defaultDueDate(DateTime(2026, 10, 1), 30), DateTime(2026, 10, 31));
    });
    test('rolls over months and years', () {
      expect(defaultDueDate(DateTime(2026, 12, 20), 30), DateTime(2027, 1, 19));
      expect(defaultDueDate(DateTime(2028, 2, 1), 30), DateTime(2028, 3, 2));
    });
    test(
      'zero terms means due on the invoice date; none means no due date',
      () {
        expect(defaultDueDate(DateTime(2026, 10, 1), 0), DateTime(2026, 10, 1));
        expect(defaultDueDate(DateTime(2026, 10, 1), null), isNull);
      },
    );
  });

  group('allocatePayment (S4-05)', () {
    OpenInvoice inv(String id, int balance, {DateTime? due, DateTime? date}) =>
        OpenInvoice(
          id: id,
          balance: Money(balance),
          invoiceDate: date ?? DateTime(2026, 9),
          dueDate: due,
        );

    List<(String, int)> pairs(AllocationResult r) => [
      for (final a in r.allocations) (a.invoiceId, a.amount.minor),
    ];

    test('fills the oldest due date first', () {
      final r = allocatePayment(const Money(7000), [
        inv('late', 5000, due: DateTime(2026, 11)),
        inv('early', 5000, due: DateTime(2026, 10)),
      ]);
      expect(pairs(r), [('early', 5000), ('late', 2000)]);
      expect(r.leftover, Money.zero);
    });

    test('exact payment settles exactly', () {
      final r = allocatePayment(const Money(8000), [
        inv('a', 3000, due: DateTime(2026, 10)),
        inv('b', 5000, due: DateTime(2026, 11)),
      ]);
      expect(pairs(r), [('a', 3000), ('b', 5000)]);
      expect(r.leftover, Money.zero);
    });

    test('a small payment touches only the first invoice', () {
      final r = allocatePayment(const Money(1000), [
        inv('a', 3000, due: DateTime(2026, 10)),
        inv('b', 5000, due: DateTime(2026, 11)),
      ]);
      expect(pairs(r), [('a', 1000)]);
    });

    test('anything beyond the total owed is left over', () {
      final r = allocatePayment(const Money(10000), [
        inv('a', 3000, due: DateTime(2026, 10)),
        inv('b', 5000, due: DateTime(2026, 11)),
      ]);
      expect(r.leftover, const Money(2000));
      expect(r.allocations.fold<int>(0, (s, a) => s + a.amount.minor), 8000);
    });

    test('undated invoices come after dated ones, in invoice-date order', () {
      final r = allocatePayment(const Money(30000), [
        inv('undated-new', 1000, date: DateTime(2026, 10)),
        inv('dated', 1000, due: DateTime(2026, 12)),
        inv('undated-old', 1000, date: DateTime(2026, 8)),
      ]);
      expect(r.allocations.map((a) => a.invoiceId), [
        'dated',
        'undated-old',
        'undated-new',
      ]);
    });

    test('equal due dates fall back to invoice date, then id', () {
      final r = allocatePayment(const Money(30000), [
        inv('b', 1000, due: DateTime(2026, 10), date: DateTime(2026, 9, 2)),
        inv('a', 1000, due: DateTime(2026, 10), date: DateTime(2026, 9, 2)),
        inv('c', 1000, due: DateTime(2026, 10), date: DateTime(2026, 9)),
      ]);
      expect(r.allocations.map((a) => a.invoiceId), ['c', 'a', 'b']);
    });

    test(
      'settled invoices are skipped; no invoices leaves everything over',
      () {
        expect(
          pairs(
            allocatePayment(const Money(500), [inv('done', 0), inv('x', 900)]),
          ),
          [('x', 500)],
        );
        final none = allocatePayment(const Money(500), const []);
        expect(none.allocations, isEmpty);
        expect(none.leftover, const Money(500));
      },
    );

    test('never allocates more than the payment or more than a balance', () {
      for (var amount = 0; amount <= 12000; amount += 750) {
        final open = [
          inv('a', 3000, due: DateTime(2026, 10)),
          inv('b', 5000, due: DateTime(2026, 11)),
        ];
        final r = allocatePayment(Money(amount), open);
        final total = r.allocations.fold<int>(0, (s, a) => s + a.amount.minor);
        expect(total + r.leftover.minor, amount, reason: '$amount');
        for (final a in r.allocations) {
          final balance = open.firstWhere((o) => o.id == a.invoiceId).balance;
          expect(a.amount.minor, lessThanOrEqualTo(balance.minor));
          expect(a.amount.minor, greaterThan(0));
        }
      }
    });
  });
}
