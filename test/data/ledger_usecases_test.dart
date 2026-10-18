import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/ledger_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';

import '../support/test_env.dart';

/// A ledger whose payment inserts start failing after a few.
class FlakyLedger extends LedgerRepositoryImpl {
  // The parent's parameter is private, so `super.db` is not available.
  // ignore: use_super_parameters
  FlakyLedger(AppDatabase db) : super(db);

  int paymentsLeft = 1 << 30;

  @override
  Future<void> insertPayment(Payment payment) {
    if (paymentsLeft <= 0) return Future.error(StateError('disk full'));
    paymentsLeft--;
    return super.insertPayment(payment);
  }
}

void main() {
  late TestEnv env;
  late String sup;
  final today = DateTime(2026, 10, 17);

  setUp(() async {
    env = TestEnv();
    sup = await env.supplier();
  });
  tearDown(() => env.dispose());

  Future<InvoiceBalance> bal(String id) async =>
      (await env.ledger.getInvoiceBalance(id, today: today))!;

  Future<List<Payment>> payments() => env.ledger.watchPayments(sup).first;

  group('AddInvoice (SUP-4, S4-04)', () {
    test('stores amounts and dates; a new invoice owes its total', () async {
      final inv = await env.addInvoice(
        InvoiceInput(
          supplierId: sup,
          invoiceNumber: ' INV-77 ',
          invoiceDate: DateTime(2026, 10, 10, 15),
          dueDate: DateTime(2026, 11, 9),
          total: const Money(18500),
          notes: ' first order ',
        ),
      );
      final b = await bal(inv.id);
      expect(b.invoice.invoiceNumber, 'INV-77');
      expect(b.invoice.invoiceDate, DateTime(2026, 10, 10));
      expect(b.invoice.dueDate, DateTime(2026, 11, 9));
      expect(b.invoice.notes, 'first order');
      expect(b.balance, const Money(18500));
      expect(b.status, InvoiceStatus.unpaid);
    });

    test("the supplier's payment terms set a default due date", () async {
      final terms = await env.supplier(name: 'Net 30', terms: 30);
      final inv = await env.invoice(terms, date: DateTime(2026, 10, 1));
      expect(inv.dueDate, DateTime(2026, 10, 31));
    });

    test('an explicit due date wins; terms can be switched off', () async {
      final terms = await env.supplier(name: 'Net 30', terms: 30);
      final explicit = await env.invoice(
        terms,
        date: DateTime(2026, 10, 1),
        due: DateTime(2026, 10, 5),
      );
      expect(explicit.dueDate, DateTime(2026, 10, 5));
      final none = await env.addInvoice(
        InvoiceInput(
          supplierId: terms,
          invoiceDate: DateTime(2026, 10, 1),
          total: const Money(100),
        ),
        defaultDueFromTerms: false,
      );
      expect(none.dueDate, isNull);
    });

    test('no terms and no date: no due date', () async {
      expect((await env.invoice(sup)).dueDate, isNull);
    });

    test(
      'validation: positive total, due date not before invoice date',
      () async {
        await expectLater(
          env.invoice(sup, totalMinor: 0),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          env.invoice(sup, totalMinor: -5),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          env.invoice(
            sup,
            date: DateTime(2026, 10, 10),
            due: DateTime(2026, 10, 9),
          ),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test('unknown and archived suppliers are refused', () async {
      await expectLater(env.invoice('nope'), throwsA(isA<NotFoundException>()));
      await env.setSupplierArchived(sup, archived: true);
      await expectLater(env.invoice(sup), throwsA(isA<ValidationException>()));
    });

    group('linking received batches (BAT-8 lite)', () {
      late String med;
      late String b1;
      late String b2;
      setUp(() async {
        med = await env.medicine();
        b1 = (await env.addBatch(env.batchInput(med, number: 'A'))).batch.id;
        b2 = (await env.addBatch(
          env.batchInput(
            med,
            number: 'B',
            expiry: ExpiryDate.monthYear(2028, 1),
          ),
        )).batch.id;
      });

      test('batches are tied to the invoice and adopt its supplier', () async {
        final inv = await env.invoice(sup, batchIds: [b1, b2]);
        for (final id in [b1, b2]) {
          final b = (await env.batches.getById(id))!;
          expect(b.invoiceId, inv.id);
          expect(b.supplierId, sup);
        }
        expect(await env.batches.countLinkedBatches(inv.id), 2);
      });

      test(
        'a batch already on an invoice cannot be added to another',
        () async {
          await env.invoice(sup, batchIds: [b1]);
          await expectLater(
            env.invoice(sup, batchIds: [b1]),
            throwsA(isA<ValidationException>()),
          );
        },
      );

      test('a batch from a different supplier is refused', () async {
        final other = await env.supplier(name: 'Other');
        final added = await env.addBatch(env.batchInputFrom(med, 'C', other));
        await expectLater(
          env.invoice(sup, batchIds: [added.batch.id]),
          throwsA(isA<ValidationException>()),
        );
      });

      test('a failure rolls the whole invoice back', () async {
        await expectLater(
          env.invoice(sup, batchIds: [b1, 'missing']),
          throwsA(isA<NotFoundException>()),
        );
        expect(
          await env.ledger.watchInvoices(sup, today: today).first,
          isEmpty,
        );
        expect((await env.batches.getById(b1))!.invoiceId, isNull);
      });
    });
  });

  group('EditInvoice', () {
    test('changes details; reminder snooze survives', () async {
      final inv = await env.invoice(
        sup,
        totalMinor: 10000,
        due: DateTime(2026, 11),
      );
      await env.reminderSnooze.snooze(inv.id, DateTime(2026, 10, 25));
      await env.editInvoice(
        inv.id,
        invoiceDate: DateTime(2026, 10, 2),
        total: const Money(12000),
        dueDate: DateTime(2026, 11, 15),
        invoiceNumber: 'N-1',
        notes: 'revised',
      );
      final b = await bal(inv.id);
      expect(b.invoice.total, const Money(12000));
      expect(b.invoice.dueDate, DateTime(2026, 11, 15));
      expect(b.invoice.invoiceNumber, 'N-1');
      expect(b.invoice.remindersSnoozedUntil, DateTime(2026, 10, 25));
      expect(b.balance, const Money(12000));
    });

    test('ledger recomputes: raising the total raises the balance', () async {
      final inv = await env.invoice(sup, totalMinor: 10000);
      await env.recordPayment(
        supplierId: sup,
        amount: const Money(4000),
        paidOn: today,
        invoiceId: inv.id,
      );
      await env.editInvoice(
        inv.id,
        invoiceDate: inv.invoiceDate,
        total: const Money(15000),
      );
      expect((await bal(inv.id)).balance, const Money(11000));
    });

    test('the total cannot drop below what is already settled', () async {
      final inv = await env.invoice(sup, totalMinor: 10000);
      await env.recordPayment(
        supplierId: sup,
        amount: const Money(6000),
        paidOn: today,
        invoiceId: inv.id,
      );
      await env.recordCredit(
        supplierId: sup,
        amount: const Money(1000),
        issuedOn: today,
        invoiceId: inv.id,
      );
      await expectLater(
        env.editInvoice(
          inv.id,
          invoiceDate: inv.invoiceDate,
          total: const Money(6900),
        ),
        throwsA(isA<ValidationException>()),
      );
      await env.editInvoice(
        inv.id,
        invoiceDate: inv.invoiceDate,
        total: const Money(7000),
      );
      expect((await bal(inv.id)).status, InvoiceStatus.paid);
    });

    test('unknown invoice is NotFound', () async {
      await expectLater(
        env.editInvoice('nope', invoiceDate: today, total: const Money(1)),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('DeleteInvoice', () {
    test('removes an untouched invoice and detaches its batches', () async {
      final med = await env.medicine();
      final b = (await env.addBatch(env.batchInput(med))).batch;
      final inv = await env.invoice(sup, batchIds: [b.id]);
      await env.deleteInvoice(inv.id);
      expect(await env.ledger.getInvoiceBalance(inv.id, today: today), isNull);
      expect((await env.batches.getById(b.id))!.invoiceId, isNull);
    });

    test(
      'refused while payments or credits exist; allowed once removed',
      () async {
        final inv = await env.invoice(sup, totalMinor: 10000);
        final paid = (await env.recordPayment(
          supplierId: sup,
          amount: const Money(1000),
          paidOn: today,
          invoiceId: inv.id,
        )).single;
        await expectLater(
          env.deleteInvoice(inv.id),
          throwsA(isA<InvoiceHasPaymentsException>()),
        );
        await env.deletePayment(paid.id);
        await env.deleteInvoice(inv.id);
      },
    );
  });

  group('RecordPayment — explicit invoice (SUP-5)', () {
    test(
      'partial payment leaves a partial status and a smaller balance',
      () async {
        final inv = await env.invoice(
          sup,
          totalMinor: 10000,
          due: DateTime(2026, 11),
        );
        final made = await env.recordPayment(
          supplierId: sup,
          amount: const Money(2500),
          paidOn: DateTime(2026, 10, 16, 20),
          invoiceId: inv.id,
          method: PaymentMethod.bank,
          reference: ' TRX-9 ',
        );
        expect(made, hasLength(1));
        final p = (await env.ledger.getPayment(made.single.id))!;
        expect(p.amount, const Money(2500));
        expect(p.paidOn, DateTime(2026, 10, 16));
        expect(p.method, PaymentMethod.bank);
        expect(p.reference, 'TRX-9');
        final b = await bal(inv.id);
        expect(b.balance, const Money(7500));
        expect(b.status, InvoiceStatus.partial);
      },
    );

    test('paying the rest settles it', () async {
      final inv = await env.invoice(sup, totalMinor: 10000);
      for (final amount in [4000, 6000]) {
        await env.recordPayment(
          supplierId: sup,
          amount: Money(amount),
          paidOn: today,
          invoiceId: inv.id,
        );
      }
      final b = await bal(inv.id);
      expect(b.balance, Money.zero);
      expect(b.status, InvoiceStatus.paid);
      expect(b.isSettled, isTrue);
    });

    test('overpaying is refused with the excess, and writes nothing', () async {
      final inv = await env.invoice(sup, totalMinor: 10000);
      Object? caught;
      try {
        await env.recordPayment(
          supplierId: sup,
          amount: const Money(12000),
          paidOn: today,
          invoiceId: inv.id,
        );
      } on Object catch (e) {
        caught = e;
      }
      expect(caught, isA<OverpaymentException>());
      final e = caught! as OverpaymentException;
      expect(e.owed, const Money(10000));
      expect(e.excess, const Money(2000));
      expect(await payments(), isEmpty);
      expect((await bal(inv.id)).balance, const Money(10000));
    });

    test(
      'overpaying with creditExcess pays the invoice and credits the rest',
      () async {
        final inv = await env.invoice(sup, totalMinor: 10000);
        await env.recordPayment(
          supplierId: sup,
          amount: const Money(12000),
          paidOn: today,
          invoiceId: inv.id,
          creditExcess: true,
        );
        expect((await bal(inv.id)).status, InvoiceStatus.paid);
        final credits = await env.ledger.watchCredits(sup).first;
        expect(credits.single.amount, const Money(2000));
        expect(credits.single.invoiceId, isNull);
        expect(
          (await env.suppliers.watchAll(today: today).first).single.outstanding,
          const Money(-2000),
          reason: 'the supplier now owes the pharmacy',
        );
      },
    );

    test('settled invoice, other supplier, unknown ids, bad amounts', () async {
      final inv = await env.invoice(sup, totalMinor: 1000);
      await env.recordPayment(
        supplierId: sup,
        amount: const Money(1000),
        paidOn: today,
        invoiceId: inv.id,
      );
      await expectLater(
        env.recordPayment(
          supplierId: sup,
          amount: const Money(1),
          paidOn: today,
          invoiceId: inv.id,
        ),
        throwsA(isA<ValidationException>()),
      );
      final other = await env.supplier(name: 'Other');
      final inv2 = await env.invoice(sup, totalMinor: 1000);
      await expectLater(
        env.recordPayment(
          supplierId: other,
          amount: const Money(1),
          paidOn: today,
          invoiceId: inv2.id,
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        env.recordPayment(
          supplierId: sup,
          amount: const Money(1),
          paidOn: today,
          invoiceId: 'nope',
        ),
        throwsA(isA<NotFoundException>()),
      );
      for (final amount in [0, -100]) {
        await expectLater(
          env.recordPayment(
            supplierId: sup,
            amount: Money(amount),
            paidOn: today,
            invoiceId: inv2.id,
          ),
          throwsA(isA<ValidationException>()),
        );
      }
      await expectLater(
        env.recordPayment(
          supplierId: sup,
          amount: const Money(1),
          paidOn: DateTime(2026, 10, 18),
          invoiceId: inv2.id,
        ),
        throwsA(isA<ValidationException>()),
        reason: 'future-dated',
      );
    });
  });

  group('RecordPayment — oldest due first (S4-05)', () {
    late Invoice late;
    late Invoice early;
    late Invoice undated;
    setUp(() async {
      late = await env.invoice(sup, totalMinor: 5000, due: DateTime(2026, 12));
      early = await env.invoice(
        sup,
        totalMinor: 3000,
        due: DateTime(2026, 10, 5),
      );
      undated = await env.invoice(
        sup,
        totalMinor: 4000,
        date: DateTime(2026, 9),
      );
    });

    test('spreads across invoices in due-date order, one row each', () async {
      final made = await env.recordPayment(
        supplierId: sup,
        amount: const Money(7000),
        paidOn: today,
        reference: 'BATCH-PAY',
      );
      expect(made.map((p) => (p.invoiceId, p.amount.minor)).toList(), [
        (early.id, 3000),
        (late.id, 4000),
      ]);
      expect(made.every((p) => p.reference == 'BATCH-PAY'), isTrue);
      expect((await bal(early.id)).status, InvoiceStatus.paid);
      expect((await bal(late.id)).balance, const Money(1000));
      expect((await bal(late.id)).status, InvoiceStatus.partial);
      expect((await bal(undated.id)).balance, const Money(4000));
    });

    test('paying everything owed settles every invoice', () async {
      await env.recordPayment(
        supplierId: sup,
        amount: const Money(12000),
        paidOn: today,
      );
      for (final i in [late, early, undated]) {
        expect((await bal(i.id)).status, InvoiceStatus.paid);
      }
      expect(
        (await env.suppliers.watchAll(today: today).first).single.outstanding,
        Money.zero,
      );
    });

    test('more than everything owed is refused, nothing written', () async {
      Object? caught;
      try {
        await env.recordPayment(
          supplierId: sup,
          amount: const Money(15000),
          paidOn: today,
        );
      } on Object catch (e) {
        caught = e;
      }
      final e = caught! as OverpaymentException;
      expect(e.owed, const Money(12000));
      expect(e.excess, const Money(3000));
      expect(await payments(), isEmpty);
    });

    test('with creditExcess the leftover becomes a general credit', () async {
      await env.recordPayment(
        supplierId: sup,
        amount: const Money(15000),
        paidOn: today,
        creditExcess: true,
      );
      expect(await payments(), hasLength(3));
      expect(
        (await env.ledger.watchCredits(sup).first).single.amount,
        const Money(3000),
      );
    });

    test(
      'a payment after earlier partial payments allocates to what remains',
      () async {
        await env.recordPayment(
          supplierId: sup,
          amount: const Money(2000),
          paidOn: today,
        ); // early: 1000 left
        final made = await env.recordPayment(
          supplierId: sup,
          amount: const Money(1500),
          paidOn: today,
        );
        expect(made.map((p) => (p.invoiceId, p.amount.minor)).toList(), [
          (early.id, 1000),
          (late.id, 500),
        ]);
      },
    );

    test('with nothing owed, any payment is an overpayment', () async {
      final fresh = await env.supplier(name: 'Fresh');
      await expectLater(
        env.recordPayment(
          supplierId: fresh,
          amount: const Money(100),
          paidOn: today,
        ),
        throwsA(isA<OverpaymentException>()),
      );
    });

    test('is atomic: a failure part-way leaves no partial payments', () async {
      late FlakyLedger ledger;
      final flaky = TestEnv(ledgerFactory: (db) => ledger = FlakyLedger(db));
      addTearDown(flaky.dispose);
      final s = await flaky.supplier();
      await flaky.invoice(s, totalMinor: 3000, due: DateTime(2026, 10, 5));
      await flaky.invoice(s, totalMinor: 5000, due: DateTime(2026, 11));
      ledger.paymentsLeft = 1; // the second insert fails
      await expectLater(
        flaky.recordPayment(
          supplierId: s,
          amount: const Money(6000),
          paidOn: today,
        ),
        throwsA(isA<StateError>()),
      );
      expect(await flaky.ledger.watchPayments(s).first, isEmpty);
    });
  });

  group('RecordCredit', () {
    test('a credit on an invoice reduces its balance', () async {
      final inv = await env.invoice(sup, totalMinor: 10000);
      await env.recordCredit(
        supplierId: sup,
        amount: const Money(3000),
        issuedOn: today,
        invoiceId: inv.id,
        note: ' returned goods ',
      );
      final b = await bal(inv.id);
      expect(b.balance, const Money(7000));
      expect(b.credited, const Money(3000));
      expect(b.status, InvoiceStatus.partial);
      expect(
        (await env.ledger.watchCredits(sup).first).single.note,
        'returned goods',
      );
    });

    test('a credit cannot exceed what the invoice still owes', () async {
      final inv = await env.invoice(sup, totalMinor: 10000);
      await env.recordPayment(
        supplierId: sup,
        amount: const Money(8000),
        paidOn: today,
        invoiceId: inv.id,
      );
      Object? caught;
      try {
        await env.recordCredit(
          supplierId: sup,
          amount: const Money(2500),
          issuedOn: today,
          invoiceId: inv.id,
        );
      } on Object catch (e) {
        caught = e;
      }
      final e = caught! as OverpaymentException;
      expect(e.owed, const Money(2000));
      expect(e.excess, const Money(500));
    });

    test('payment plus credit together can settle an invoice', () async {
      final inv = await env.invoice(sup, totalMinor: 10000);
      await env.recordCredit(
        supplierId: sup,
        amount: const Money(2000),
        issuedOn: today,
        invoiceId: inv.id,
      );
      await env.recordPayment(
        supplierId: sup,
        amount: const Money(8000),
        paidOn: today,
        invoiceId: inv.id,
      );
      expect((await bal(inv.id)).status, InvoiceStatus.paid);
    });

    test(
      'rejects zero and negative amounts, unknown supplier or invoice',
      () async {
        for (final amount in [0, -1]) {
          await expectLater(
            env.recordCredit(
              supplierId: sup,
              amount: Money(amount),
              issuedOn: today,
            ),
            throwsA(isA<ValidationException>()),
          );
        }
        await expectLater(
          env.recordCredit(
            supplierId: 'nope',
            amount: const Money(1),
            issuedOn: today,
          ),
          throwsA(isA<NotFoundException>()),
        );
        await expectLater(
          env.recordCredit(
            supplierId: sup,
            amount: const Money(1),
            issuedOn: today,
            invoiceId: 'nope',
          ),
          throwsA(isA<NotFoundException>()),
        );
      },
    );
  });

  group('deleting payments and credits recomputes balances', () {
    test(
      'deleting a payment restores the balance and the old status',
      () async {
        final inv = await env.invoice(
          sup,
          totalMinor: 10000,
          due: DateTime(2026, 11),
        );
        final p = (await env.recordPayment(
          supplierId: sup,
          amount: const Money(10000),
          paidOn: today,
          invoiceId: inv.id,
        )).single;
        expect((await bal(inv.id)).status, InvoiceStatus.paid);
        await env.deletePayment(p.id);
        final b = await bal(inv.id);
        expect(b.balance, const Money(10000));
        expect(b.status, InvoiceStatus.unpaid);
        expect(await payments(), isEmpty);
      },
    );

    test('deleting a credit does the same', () async {
      final inv = await env.invoice(sup, totalMinor: 10000);
      final c = await env.recordCredit(
        supplierId: sup,
        amount: const Money(4000),
        issuedOn: today,
        invoiceId: inv.id,
      );
      await env.deleteCredit(c.id);
      expect((await bal(inv.id)).balance, const Money(10000));
    });

    test('deleting an unknown payment is NotFound', () async {
      await expectLater(
        env.deletePayment('nope'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('reminder snooze (S4-13)', () {
    test('snooze, return the previous value, and restore it', () async {
      final inv = await env.invoice(sup, due: DateTime(2026, 11));
      final first = await env.reminderSnooze.snooze(
        inv.id,
        DateTime(2026, 10, 24, 9),
      );
      expect(first, isNull);
      expect(
        (await bal(inv.id)).invoice.remindersSnoozedUntil,
        DateTime(2026, 10, 24),
      );
      final second = await env.reminderSnooze.snooze(
        inv.id,
        DateTime(2026, 10, 30),
      );
      expect(second, DateTime(2026, 10, 24));
      await env.reminderSnooze.restore(inv.id, second);
      expect(
        (await bal(inv.id)).invoice.remindersSnoozedUntil,
        DateTime(2026, 10, 24),
      );
      await env.reminderSnooze.clear(inv.id);
      expect((await bal(inv.id)).invoice.remindersSnoozedUntil, isNull);
    });

    test('cannot snooze into the past; unknown invoice is NotFound', () async {
      final inv = await env.invoice(sup);
      await expectLater(
        env.reminderSnooze.snooze(inv.id, DateTime(2026, 10, 16)),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        env.reminderSnooze.snooze('nope', DateTime(2026, 10, 20)),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  test('every ledger change is announced to the alert engine', () async {
    final events = <DataChangeKind>[];
    final sub = env.bus.changes.listen((e) => events.add(e.kind));
    final inv = await env.invoice(sup, totalMinor: 1000);
    await env.recordPayment(
      supplierId: sup,
      amount: const Money(500),
      paidOn: today,
      invoiceId: inv.id,
    );
    await env.recordCredit(
      supplierId: sup,
      amount: const Money(100),
      issuedOn: today,
    );
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(
      events.where((k) => k == DataChangeKind.ledgerChanged),
      hasLength(3),
    );
  });
}
