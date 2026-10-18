import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier_return.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';

import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late String med;
  late String sup;
  final today = DateTime(2026, 10, 17);

  setUp(() async {
    env = TestEnv();
    med = await env.medicine(brand: 'Napa', strength: '500 mg');
    sup = await env.supplier(name: 'ABC Pharma');
  });
  tearDown(() => env.dispose());

  Future<String> batch(
    String number, {
    int qty = 10,
    int? cost = 200,
    String? supplier,
  }) async {
    final r = await env.addBatch(
      env.batchInput(
        med,
        number: number,
        quantity: qty,
        costMinor: cost,
        supplierId: supplier ?? sup,
      ),
    );
    return r.batch.id;
  }

  Future<int> onHand(String id) async =>
      (await env.batches.getById(id))!.quantityOnHand;

  test(
    'a return takes stock off, records lines and keeps the audit trail',
    () async {
      final a = await batch('A', qty: 10);
      final b = await batch('B', qty: 4);
      final r = await env.returnToSupplier.call(
        supplierId: sup,
        returnedOn: today,
        note: 'Short-dated',
        lines: [ReturnLineInput(a, 6), ReturnLineInput(b, 4)],
      );
      expect(await onHand(a), 4);
      expect(await onHand(b), 0);
      expect((await env.batches.getById(b))!.status, BatchStatus.returned);
      expect(r.ret.totalQuantity, 10);
      expect(r.ret.lines.first.value, const Money(1200));
      expect(r.credit, isNull);

      final adj = await env.batches.watchAdjustments(a).first;
      expect(
        adj.where((x) => x.reason == AdjustmentReason.returned).single.deltaQty,
        -6,
      );
      final view = await env.returnsRepo.getView(r.ret.id);
      expect(view!.lines.map((l) => l.medicineName).toSet(), {'Napa 500 mg'});
      expect(view.lines.map((l) => l.quantity), [6, 4]);
      expect(view.note, 'Short-dated');
      expect(view.credit, isNull);
    },
  );

  test(
    'a credit lowers what is owed, on an invoice or on the account',
    () async {
      final inv = await env.invoice(sup, totalMinor: 5000);
      final a = await batch('A');
      final r = await env.returnToSupplier.call(
        supplierId: sup,
        returnedOn: today,
        lines: [ReturnLineInput(a, 5)],
        credit: const Money(1000),
        creditInvoiceId: inv.id,
      );
      expect(r.credit!.returnId, r.ret.id);
      final bal = await env.ledger.getInvoiceBalance(inv.id, today: today);
      expect(bal!.balance, const Money(4000));
      final view = await env.returnsRepo.getView(r.ret.id);
      expect(view!.credit, const Money(1000));

      // General credit, no invoice.
      final b = await batch('B');
      final r2 = await env.returnToSupplier.call(
        supplierId: sup,
        returnedOn: today,
        lines: [ReturnLineInput(b, 2)],
        credit: const Money(400),
      );
      expect(r2.credit!.invoiceId, isNull);
      final credits = await env.ledger.watchCredits(sup).first;
      expect(credits.map((c) => c.amount.minor).toSet(), {1000, 400});
    },
  );

  group('nothing changes when anything is refused', () {
    Future<void> expectUntouched(String id, int qty) async {
      expect(await onHand(id), qty);
      expect(await env.returnsRepo.watchBySupplier(sup).first, isEmpty);
      expect(await env.ledger.watchCredits(sup).first, isEmpty);
    }

    test(
      'a later line with too little stock rolls back earlier lines',
      () async {
        final a = await batch('A', qty: 10);
        final b = await batch('B', qty: 3);
        await expectLater(
          env.returnToSupplier.call(
            supplierId: sup,
            returnedOn: today,
            lines: [ReturnLineInput(a, 5), ReturnLineInput(b, 4)],
          ),
          throwsA(isA<InsufficientStockException>()),
        );
        await expectUntouched(a, 10);
        expect(await onHand(b), 3);
      },
    );

    test(
      'a credit above the invoice balance rolls back the whole return',
      () async {
        final inv = await env.invoice(sup, totalMinor: 500);
        final a = await batch('A');
        await expectLater(
          env.returnToSupplier.call(
            supplierId: sup,
            returnedOn: today,
            lines: [ReturnLineInput(a, 5)],
            credit: const Money(900),
            creditInvoiceId: inv.id,
          ),
          throwsA(isA<OverpaymentException>()),
        );
        await expectUntouched(a, 10);
      },
    );

    test('invalid input is refused up front', () async {
      final a = await batch('A');
      for (final lines in [
        <ReturnLineInput>[],
        [ReturnLineInput(a, 0)],
        [ReturnLineInput(a, 1), ReturnLineInput(a, 2)],
      ]) {
        await expectLater(
          env.returnToSupplier.call(
            supplierId: sup,
            returnedOn: today,
            lines: lines,
          ),
          throwsA(isA<ValidationException>()),
        );
      }
      await expectLater(
        env.returnToSupplier.call(
          supplierId: sup,
          returnedOn: today,
          lines: [ReturnLineInput(a, 1)],
          credit: Money.zero,
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectUntouched(a, 10);
    });

    test('a batch from another supplier cannot be returned here', () async {
      final other = await env.supplier(name: 'Other');
      final a = await batch('A', supplier: other);
      await expectLater(
        env.returnToSupplier.call(
          supplierId: sup,
          returnedOn: today,
          lines: [ReturnLineInput(a, 1)],
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(await onHand(a), 10);
    });

    test('unknown supplier or batch', () async {
      final a = await batch('A');
      await expectLater(
        env.returnToSupplier.call(
          supplierId: 'nope',
          returnedOn: today,
          lines: [ReturnLineInput(a, 1)],
        ),
        throwsA(isA<NotFoundException>()),
      );
      await expectLater(
        env.returnToSupplier.call(
          supplierId: sup,
          returnedOn: today,
          lines: [const ReturnLineInput('ghost', 1)],
        ),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  test('batches without a supplier can be returned to one', () async {
    final id = (await env.addBatch(
      env.batchInput(med, number: 'N', quantity: 3, costMinor: 100),
    )).batch.id;
    final r = await env.returnToSupplier.call(
      supplierId: sup,
      returnedOn: today,
      lines: [ReturnLineInput(id, 3)],
    );
    expect(r.ret.lines.single.value, const Money(300));
    expect(await onHand(id), 0);
  });

  test('a return with no cost price has no line value', () async {
    final id = await batch('A', cost: null);
    final r = await env.returnToSupplier.call(
      supplierId: sup,
      returnedOn: today,
      lines: [ReturnLineInput(id, 1)],
    );
    expect(r.ret.lines.single.value, isNull);
  });
}
