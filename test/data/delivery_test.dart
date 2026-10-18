import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/delivery_usecases.dart';

import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late String napa;
  late String amoxil;
  late String sup;
  final received = DateTime(2026, 10, 17);

  setUp(() async {
    env = TestEnv();
    napa = await env.medicine(brand: 'Napa', strength: '500 mg');
    amoxil = await env.medicine(brand: 'Amoxil', strength: '250 mg');
    sup = await env.supplier();
  });
  tearDown(() => env.dispose());

  DeliveryLine line(
    String med,
    String number, {
    int qty = 10,
    int? cost,
    ExpiryDate? expiry,
  }) => DeliveryLine(
    medicineId: med,
    batchNumber: number,
    expiry: expiry ?? ExpiryDate.monthYear(2027, 8),
    quantity: qty,
    costPrice: cost == null ? null : Money(cost),
  );

  Future<int> batchCount() async =>
      (await env.db.select(env.db.batches).get()).length;

  test('many batches and one invoice from the total, in one go', () async {
    final r = await env.receiveDelivery.call(
      DeliveryInput(
        receivedDate: received,
        supplierId: sup,
        invoiceTotal: const Money(25000),
        invoiceNumber: 'INV-9',
        dueDate: DateTime(2026, 11, 16),
        lines: [
          line(napa, 'N1', cost: 100),
          line(napa, 'N2', qty: 5, expiry: ExpiryDate.monthYear(2027, 9)),
          line(amoxil, 'A1', qty: 20, cost: 300),
        ],
      ),
    );
    expect(r.batches, hasLength(3));
    expect(r.invoice!.total, const Money(25000));
    for (final b in r.batches) {
      final stored = (await env.batches.getById(b.id))!;
      expect(stored.invoiceId, r.invoice!.id);
      expect(stored.supplierId, sup);
    }
    final bal = await env.ledger.getInvoiceBalance(
      r.invoice!.id,
      today: received,
    );
    expect(bal!.balance, const Money(25000));
  });

  test('without a total, no invoice is made', () async {
    final r = await env.receiveDelivery.call(
      DeliveryInput(
        receivedDate: received,
        lines: [line(napa, 'N1'), line(amoxil, 'A1')],
      ),
    );
    expect(r.invoice, isNull);
    expect(await batchCount(), 2);
    expect(r.batches.every((b) => b.supplierId == null), isTrue);
  });

  group('validation reports every problem', () {
    test('per-line problems with positions', () {
      final problems = validateDelivery(
        DeliveryInput(
          receivedDate: received,
          lines: [
            line(napa, '  ', qty: 0),
            line(napa, 'N1', cost: -5),
            line(napa, 'n1'), // same batch as the line above, any case
          ],
        ),
      );
      final text = problems.map((p) => '${p.index}:${p.field}').toSet();
      expect(
        text,
        containsAll([
          '0:batchNumber',
          '0:quantity',
          '1:costPrice',
          '2:batchNumber',
        ]),
      );
    });

    test('an invoice needs a supplier and a positive total; no lines', () {
      final problems = validateDelivery(
        DeliveryInput(
          receivedDate: received,
          invoiceTotal: Money.zero,
          lines: const [],
        ),
      );
      expect(problems.map((p) => p.field).toSet(), {
        'lines',
        'supplier',
        'total',
      });
    });

    test('a valid delivery has none', () {
      expect(
        validateDelivery(
          DeliveryInput(receivedDate: received, lines: [line(napa, 'N1')]),
        ),
        isEmpty,
      );
    });
  });

  group('atomicity: any refused line saves nothing', () {
    test('an invalid line is caught before anything is written', () async {
      await expectLater(
        env.receiveDelivery.call(
          DeliveryInput(
            receivedDate: received,
            supplierId: sup,
            invoiceTotal: const Money(100),
            lines: [line(napa, 'N1'), line(amoxil, 'A1', qty: 0)],
          ),
        ),
        throwsA(
          isA<DeliveryInvalidException>().having(
            (e) => e.problems.single.index,
            'index',
            1,
          ),
        ),
      );
      expect(await batchCount(), 0);
    });

    test('a line that fails inside the transaction rolls back earlier lines and the invoice', () async {
      await expectLater(
        env.receiveDelivery.call(
          DeliveryInput(
            receivedDate: received,
            supplierId: sup,
            invoiceTotal: const Money(100),
            lines: [line(napa, 'N1'), line(amoxil, 'A1'), line('ghost', 'G1')],
          ),
        ),
        throwsA(
          isA<DeliveryInvalidException>().having(
            (e) => e.problems.single.index,
            'index',
            2,
          ),
        ),
      );
      expect(await batchCount(), 0);
      expect(await env.db.select(env.db.supplierInvoices).get(), isEmpty);
      expect(await env.db.select(env.db.stockAdjustments).get(), isEmpty);
    });

    test('a batch that already exists refuses the whole delivery', () async {
      await env.addBatch(env.batchInput(napa, number: 'N2', quantity: 3));
      await expectLater(
        env.receiveDelivery.call(
          DeliveryInput(
            receivedDate: received,
            lines: [line(amoxil, 'A1'), line(napa, 'N2')],
          ),
        ),
        throwsA(
          isA<DeliveryInvalidException>().having(
            (e) => e.problems.single.index,
            'index',
            1,
          ),
        ),
      );
      expect(await batchCount(), 1, reason: 'only the earlier batch remains');
    });

    test(
      'an archived supplier refuses the invoice and so the batches',
      () async {
        await env.setSupplierArchived(sup, archived: true);
        await expectLater(
          env.receiveDelivery.call(
            DeliveryInput(
              receivedDate: received,
              supplierId: sup,
              invoiceTotal: const Money(100),
              lines: [line(napa, 'N1')],
            ),
          ),
          throwsA(isA<Exception>()),
        );
        expect(await batchCount(), 0);
      },
    );
  });

  group('draft', () {
    test('survives a round trip exactly', () {
      const draft = DeliveryDraft(
        supplierId: 's1',
        invoiceNumber: 'I-1',
        invoiceTotal: '250.50',
        lines: [
          DraftLine(
            medicineId: 'm1',
            medicineName: 'Napa 500 mg',
            batchNumber: 'N1',
            expiry: '03/2027',
            quantity: '12',
            cost: '1.5',
          ),
          DraftLine(),
        ],
      );
      final back = DeliveryDraft.fromJson(draft.toJson());
      expect(back.supplierId, 's1');
      expect(back.invoiceTotal, '250.50');
      expect(back.lines, hasLength(2));
      expect(back.lines.first.medicineName, 'Napa 500 mg');
      expect(back.lines.first.expiry, '03/2027');
      expect(back.lines.last.medicineId, isNull);
      expect(back.isEmpty, isFalse);
      expect(const DeliveryDraft().isEmpty, isTrue);
    });

    test('is stored, replaced and cleared', () async {
      expect(await env.drafts.load('bulk'), isNull);
      await env.drafts.save('bulk', 'one');
      await env.drafts.save('bulk', 'two');
      expect(await env.drafts.load('bulk'), 'two');
      await env.drafts.clear('bulk');
      expect(await env.drafts.load('bulk'), isNull);
    });

    test('does not disturb the real settings', () async {
      await env.drafts.save('bulk', '{}');
      expect((await env.settings.load()).pharmacyName, '');
    });
  });
}
