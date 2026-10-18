import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/statement.dart';

Invoice inv(String id, DateTime d, int total, {String? number}) => Invoice(
  id: id,
  supplierId: 's',
  invoiceDate: d,
  total: Money(total),
  invoiceNumber: number,
  createdAt: d,
  updatedAt: d,
);

Payment pay(String id, DateTime d, int amount, {String? ref}) => Payment(
  id: id,
  supplierId: 's',
  invoiceId: 'i',
  amount: Money(amount),
  paidOn: d,
  reference: ref,
  createdAt: d,
);

Credit cred(String id, DateTime d, int amount) => Credit(
  id: id,
  supplierId: 's',
  amount: Money(amount),
  issuedOn: d,
  createdAt: d,
);

void main() {
  final invoices = [
    inv('1', DateTime(2026, 8, 10), 10000, number: 'INV-1'),
    inv('2', DateTime(2026, 9, 5), 5000, number: 'INV-2'),
    inv('3', DateTime(2026, 10, 2), 2500),
  ];
  final payments = [
    pay('p1', DateTime(2026, 8, 20), 4000, ref: 'cheque 77'),
    pay('p2', DateTime(2026, 9, 25), 6000),
  ];
  final credits = [cred('c1', DateTime(2026, 9, 6), 500)];

  SupplierStatement make(DateTime from, DateTime to) => buildStatement(
    supplierName: 'ABC Pharma',
    from: from,
    to: to,
    invoices: invoices,
    payments: payments,
    credits: credits,
  );

  test('opening balance folds in everything before the period', () {
    final s = make(DateTime(2026, 9, 1), DateTime(2026, 9, 30));
    // Aug: +10000 invoice, -4000 payment.
    expect(s.opening, const Money(6000));
    expect(s.entries.map((e) => e.kind), [
      StatementKind.invoice,
      StatementKind.credit,
      StatementKind.payment,
    ]);
    expect(s.entries.map((e) => e.balance.minor), [11000, 10500, 4500]);
    expect(s.closing, const Money(4500));
    expect(s.totalInvoiced, const Money(5000));
    expect(s.totalCredited, const Money(500));
    expect(s.totalPaid, const Money(6000));
  });

  test('opening + invoiced - paid - credited = closing', () {
    for (final range in [
      (DateTime(2026, 1, 1), DateTime(2026, 12, 31)),
      (DateTime(2026, 8, 20), DateTime(2026, 9, 6)),
      (DateTime(2026, 10, 1), DateTime(2026, 10, 31)),
      (DateTime(2026, 11, 1), DateTime(2026, 11, 30)),
    ]) {
      final s = make(range.$1, range.$2);
      expect(
        s.opening.minor +
            s.totalInvoiced.minor -
            s.totalPaid.minor -
            s.totalCredited.minor,
        s.closing.minor,
        reason: '$range',
      );
    }
  });

  test('later activity does not leak into an earlier statement', () {
    final s = make(DateTime(2026, 8, 1), DateTime(2026, 8, 31));
    expect(s.opening, Money.zero);
    expect(s.closing, const Money(6000));
    expect(s.entries, hasLength(2));
  });

  test('the whole history from the start', () {
    final s = make(DateTime(2020), DateTime(2030));
    expect(s.opening, Money.zero);
    expect(s.closing, const Money(2500 + 5000 + 10000 - 4000 - 6000 - 500));
    expect(s.entries, hasLength(6));
  });

  test('both ends of the period are included', () {
    final s = make(DateTime(2026, 9, 5), DateTime(2026, 9, 6));
    expect(s.entries.map((e) => e.kind), [
      StatementKind.invoice,
      StatementKind.credit,
    ]);
  });

  test('same-day lines: invoice, then credit, then payment', () {
    final d = DateTime(2026, 9, 9);
    final s = buildStatement(
      supplierName: 'X',
      from: d,
      to: d,
      invoices: [inv('a', d, 1000)],
      payments: [pay('b', d, 300)],
      credits: [cred('c', d, 200)],
    );
    expect(s.entries.map((e) => e.kind), [
      StatementKind.invoice,
      StatementKind.credit,
      StatementKind.payment,
    ]);
    expect(s.entries.last.balance, const Money(500));
  });

  test('references and signs', () {
    final s = make(DateTime(2026, 8, 1), DateTime(2026, 8, 31));
    expect(s.entries.first.reference, 'INV-1');
    expect(s.entries.first.amount, const Money(10000));
    expect(s.entries.last.reference, 'cheque 77');
    expect(s.entries.last.amount, const Money(-4000));
  });

  test('nothing at all', () {
    final s = buildStatement(
      supplierName: 'X',
      from: DateTime(2026),
      to: DateTime(2026, 12, 31),
      invoices: const [],
      payments: const [],
      credits: const [],
    );
    expect(s.entries, isEmpty);
    expect(s.closing, Money.zero);
  });

  test('a supplier we over-paid shows a negative balance', () {
    final d = DateTime(2026, 9, 9);
    final s = buildStatement(
      supplierName: 'X',
      from: d,
      to: d,
      invoices: [inv('a', d, 100)],
      payments: [pay('b', d, 300)],
      credits: const [],
    );
    expect(s.closing, const Money(-200));
  });
}
