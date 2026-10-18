import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';

import '../support/test_env.dart';

void main() {
  late TestEnv env;
  final today = DateTime(2026, 10, 17);

  setUp(() => env = TestEnv());
  tearDown(() => env.dispose());

  Future<List<SupplierSummary>> list({
    String query = '',
    bool archived = false,
    SupplierSort sort = SupplierSort.name,
  }) => env.suppliers
      .watchAll(
        today: today,
        query: query,
        includeArchived: archived,
        sort: sort,
      )
      .first;

  group('supplier CRUD (SUP-1)', () {
    test('create trims, nulls blanks, and reads back', () async {
      final id = await env.saveSupplier(
        const SupplierInput(
          name: '  City Distributors ',
          contactPerson: '  ',
          phone: ' 01711 000000 ',
          email: 'orders@city.example',
          paymentTermsDays: 30,
          taxId: 'TIN-9',
        ),
      );
      final s = (await env.suppliers.getById(id))!;
      expect(s.name, 'City Distributors');
      expect(s.contactPerson, isNull);
      expect(s.phone, '01711 000000');
      expect(s.email, 'orders@city.example');
      expect(s.paymentTermsDays, 30);
      expect(s.taxId, 'TIN-9');
      expect(s.isArchived, isFalse);
      expect(s.createdAt, env.clock.current);
    });

    test('update changes fields and keeps createdAt', () async {
      final id = await env.supplier();
      env.clock.advance(const Duration(days: 1));
      await env.saveSupplier(
        const SupplierInput(name: 'Renamed', paymentTermsDays: 7),
        id: id,
      );
      final s = (await env.suppliers.getById(id))!;
      expect(s.name, 'Renamed');
      expect(s.paymentTermsDays, 7);
      expect(s.updatedAt.isAfter(s.createdAt), isTrue);
    });

    test('validation: name, terms, email', () async {
      await expectLater(
        env.saveSupplier(const SupplierInput(name: '  ')),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        env.saveSupplier(const SupplierInput(name: 'A', paymentTermsDays: -1)),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        env.saveSupplier(const SupplierInput(name: 'A', email: 'not-an-email')),
        throwsA(isA<ValidationException>()),
      );
      await env.saveSupplier(const SupplierInput(name: 'A', email: ' '));
    });

    test('updating an unknown supplier is NotFound', () async {
      await expectLater(
        env.saveSupplier(const SupplierInput(name: 'A'), id: 'nope'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test(
      'archive hides from lists and pickers; restore brings it back',
      () async {
        final id = await env.supplier();
        await env.setSupplierArchived(id, archived: true);
        expect(await list(), isEmpty);
        expect((await list(archived: true)).single.supplier.isArchived, isTrue);
        expect(await env.suppliers.watchActive().first, isEmpty);
        await env.setSupplierArchived(id, archived: false);
        expect(await list(), hasLength(1));
        expect(await env.suppliers.watchActive().first, hasLength(1));
      },
    );

    test('changes are announced', () async {
      final events = <DataChange>[];
      final sub = env.bus.changes.listen(events.add);
      await env.supplier();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(events.single.kind, DataChangeKind.supplierChanged);
    });
  });

  group('search and sort (SUP-7)', () {
    test('search by name or contact, all words, literal wildcards', () async {
      await env.saveSupplier(
        const SupplierInput(name: 'Alpha Pharma', contactPerson: 'Rahim'),
      );
      await env.supplier(name: 'Beta Meds');
      expect(await list(query: 'alpha'), hasLength(1));
      expect(await list(query: 'rahim'), hasLength(1));
      expect(await list(query: 'pharma alpha'), hasLength(1));
      expect(await list(query: 'alpha beta'), isEmpty);
      expect(await list(query: '%'), isEmpty);
      expect(await list(query: ''), hasLength(2));
    });

    test('sorted by name case-insensitively', () async {
      await env.supplier(name: 'zeta');
      await env.supplier(name: 'Alpha');
      await env.supplier(name: 'beta');
      expect((await list()).map((s) => s.supplier.name), [
        'Alpha',
        'beta',
        'zeta',
      ]);
    });

    test(
      'sorted by balance (highest owed first) and by next due date',
      () async {
        final a = await env.supplier(name: 'A');
        final b = await env.supplier(name: 'B');
        final c = await env.supplier(name: 'C');
        await env.invoice(a, totalMinor: 1000, due: DateTime(2026, 12));
        await env.invoice(b, totalMinor: 9000, due: DateTime(2026, 11));
        await env.invoice(c, totalMinor: 5000); // no due date
        expect(
          (await list(sort: SupplierSort.balance)).map((s) => s.supplier.name),
          ['B', 'C', 'A'],
        );
        expect(
          (await list(sort: SupplierSort.nextDue)).map((s) => s.supplier.name),
          ['B', 'A', 'C'],
          reason: 'no due date sorts last',
        );
      },
    );
  });

  group('balances on the list (SUP-7, SUP-8)', () {
    test('outstanding, overdue, counts and next due per supplier', () async {
      final s = await env.supplier();
      await env.invoice(
        s,
        totalMinor: 10000,
        due: DateTime(2026, 10, 1),
      ); // overdue
      await env.invoice(
        s,
        totalMinor: 4000,
        due: DateTime(2026, 10, 17),
      ); // due today
      await env.invoice(s, totalMinor: 6000, due: DateTime(2026, 11, 5));
      final sum = (await list()).single;
      expect(sum.outstanding, const Money(20000));
      expect(sum.overdue, const Money(10000));
      expect(sum.overdueCount, 1);
      expect(sum.openInvoiceCount, 3);
      expect(sum.nextDue, DateTime(2026, 10));
      expect(sum.hasOverdue, isTrue);
    });

    test(
      'payments and credits reduce them; settled invoices drop out',
      () async {
        final s = await env.supplier();
        final inv1 = await env.invoice(
          s,
          totalMinor: 10000,
          due: DateTime(2026, 10, 1),
        );
        final inv2 = await env.invoice(
          s,
          totalMinor: 5000,
          due: DateTime(2026, 11),
        );
        await env.recordPayment(
          supplierId: s,
          amount: const Money(10000),
          paidOn: today,
          invoiceId: inv1.id,
        );
        await env.recordCredit(
          supplierId: s,
          amount: const Money(1000),
          issuedOn: today,
          invoiceId: inv2.id,
        );
        final sum = (await list()).single;
        expect(sum.outstanding, const Money(4000));
        expect(sum.overdue, Money.zero);
        expect(sum.overdueCount, 0);
        expect(sum.openInvoiceCount, 1);
        expect(sum.nextDue, DateTime(2026, 11));
      },
    );

    test(
      'a general credit lowers what is owed overall, not any invoice',
      () async {
        final s = await env.supplier();
        final inv = await env.invoice(s, totalMinor: 10000);
        await env.recordCredit(
          supplierId: s,
          amount: const Money(2500),
          issuedOn: today,
        );
        expect((await list()).single.outstanding, const Money(7500));
        final b = (await env.ledger.getInvoiceBalance(inv.id, today: today))!;
        expect(
          b.balance,
          const Money(10000),
          reason: 'invoice itself unchanged',
        );
      },
    );

    test('a supplier with no invoices owes nothing', () async {
      await env.supplier();
      final sum = (await list()).single;
      expect(sum.outstanding, Money.zero);
      expect(sum.nextDue, isNull);
      expect(sum.openInvoiceCount, 0);
    });

    test('deleted invoices are ignored', () async {
      final s = await env.supplier();
      final inv = await env.invoice(s, totalMinor: 10000);
      await env.deleteInvoice(inv.id);
      expect((await list()).single.outstanding, Money.zero);
    });

    test('the list updates as the ledger changes', () async {
      final s = await env.supplier();
      final seen = <int>[];
      final sub = env.suppliers
          .watchAll(today: today)
          .listen((l) => seen.add(l.single.outstanding.minor));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      final inv = await env.invoice(s, totalMinor: 10000);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await env.recordPayment(
        supplierId: s,
        amount: const Money(4000),
        paidOn: today,
        invoiceId: inv.id,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await sub.cancel();
      expect(seen, [0, 10000, 6000]);
    });
  });

  group('dues summary (S4-12)', () {
    Future<DuesSummary> dues() => env.suppliers.watchDues(today: today).first;

    test('empty', () async {
      final d = await dues();
      expect(d.outstanding, Money.zero);
      expect(d.overdueCount, 0);
      expect(d.nextDue, isNull);
    });

    test('totals across suppliers', () async {
      final a = await env.supplier(name: 'A');
      final b = await env.supplier(name: 'B');
      await env.invoice(a, totalMinor: 10000, due: DateTime(2026, 10, 5));
      await env.invoice(b, totalMinor: 7000, due: DateTime(2026, 10, 20));
      await env.invoice(
        b,
        totalMinor: 3000,
        date: DateTime(2026, 8),
        due: DateTime(2026, 9),
      );
      final d = await dues();
      expect(d.outstanding, const Money(20000));
      expect(d.overdue, const Money(13000));
      expect(d.overdueCount, 2);
      expect(d.nextDue, DateTime(2026, 9));
    });

    test(
      'credits and payments are reflected; archived suppliers still count',
      () async {
        final a = await env.supplier(name: 'A');
        final inv = await env.invoice(
          a,
          totalMinor: 10000,
          due: DateTime(2026, 10, 5),
        );
        await env.recordPayment(
          supplierId: a,
          amount: const Money(2500),
          paidOn: today,
          invoiceId: inv.id,
        );
        await env.recordCredit(
          supplierId: a,
          amount: const Money(500),
          issuedOn: today,
        );
        await env.setSupplierArchived(a, archived: true);
        final d = await dues();
        expect(d.outstanding, const Money(7000));
        expect(d.overdue, const Money(7500));
      },
    );
  });
}
