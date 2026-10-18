import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_engine.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';

import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late String sup;
  final today = DateTime(2026, 10, 17);

  setUp(() async {
    env = TestEnv();
    sup = await env.supplier(name: 'ABC Pharma');
    // Isolate payment reminders from the expiry digest.
    await env.settings.update(
      (s) => s.copyWith(digestEnabled: false, backupReminderDays: 0),
    );
  });
  tearDown(() => env.dispose());

  Future<ReplanSummary> replan() async {
    final r = await env.alertEngine.replan();
    expect(r.error, isNull, reason: '${r.error}');
    return r;
  }

  Future<List<String>> pendingKeys() async => [
    for (final r in await env.alertStore.all())
      if (r.isPending && r.kind == AlertKind.payment) r.key,
  ];

  test('an invoice with a due date schedules its reminders', () async {
    await env.invoice(sup, due: DateTime(2026, 10, 25), totalMinor: 18500);
    final r = await replan();
    expect(r.scheduled, 4);
    expect(await pendingKeys(), [
      'pay:2026-10-22',
      'paydue:2026-10-25',
      'overdue:2026-10-28',
      'overdue:2026-10-31',
    ]);
    final first = env.plugin.scheduled.values.firstWhere(
      (n) => n.title.contains('due in 3 days'),
    );
    expect(first.fireAt, DateTime(2026, 10, 22, 9, 10));
    expect(first.body, '1 invoice: ABC Pharma 185.00 · 185.00');
    expect(first.payload, startsWith('/suppliers/'));
    expect(first.channel.id, 'payments');
  });

  test('an invoice with no due date never reminds', () async {
    await env.invoice(sup);
    await replan();
    expect(env.plugin.scheduled, isEmpty);
  });

  test('re-planning changes nothing', () async {
    await env.invoice(sup, due: DateTime(2026, 10, 25));
    await replan();
    for (var i = 0; i < 3; i++) {
      expect((await replan()).isNoop, isTrue);
    }
    expect(env.plugin.scheduled, hasLength(4));
  });

  group('payment cancels the reminders (exit criterion)', () {
    test('paying in full removes every pending reminder', () async {
      final inv = await env.invoice(
        sup,
        due: DateTime(2026, 10, 25),
        totalMinor: 10000,
      );
      await replan();
      expect(env.plugin.scheduled, hasLength(4));
      await env.recordPayment(
        supplierId: sup,
        amount: const Money(10000),
        paidOn: today,
        invoiceId: inv.id,
      );
      final r = await replan();
      expect(r.cancelled, 4);
      expect(env.plugin.scheduled, isEmpty);
      expect(await pendingKeys(), isEmpty);
    });

    test(
      'a partial payment keeps reminders but updates the amount owed',
      () async {
        final inv = await env.invoice(
          sup,
          due: DateTime(2026, 10, 25),
          totalMinor: 10000,
        );
        await replan();
        await env.recordPayment(
          supplierId: sup,
          amount: const Money(4000),
          paidOn: today,
          invoiceId: inv.id,
        );
        final r = await replan();
        expect(r.scheduled, 4, reason: 'text changed, so each is replaced');
        expect(r.cancelled, 0);
        expect(
          env.plugin.scheduled.values.every((n) => n.body.contains('60.00')),
          isTrue,
        );
        expect(env.plugin.scheduled, hasLength(4), reason: 'no duplicates');
      },
    );

    test(
      'a payment spread over invoices settles only the oldest due',
      () async {
        await env.invoice(
          sup,
          due: DateTime(2026, 10, 25),
          totalMinor: 3000,
          number: 'A',
        );
        await env.invoice(
          sup,
          due: DateTime(2026, 11, 5),
          totalMinor: 5000,
          number: 'B',
        );
        await replan();
        await env.recordPayment(
          supplierId: sup,
          amount: const Money(3000),
          paidOn: today,
        );
        await replan();
        final keys = await pendingKeys();
        expect(keys, contains('pay:2026-11-02'));
        expect(keys, isNot(contains('paydue:2026-10-25')));
      },
    );

    test('deleting the payment brings the reminders back', () async {
      final inv = await env.invoice(
        sup,
        due: DateTime(2026, 10, 25),
        totalMinor: 10000,
      );
      final paid = (await env.recordPayment(
        supplierId: sup,
        amount: const Money(10000),
        paidOn: today,
        invoiceId: inv.id,
      )).single;
      await replan();
      expect(env.plugin.scheduled, isEmpty);
      await env.deletePayment(paid.id);
      await replan();
      expect(env.plugin.scheduled, hasLength(4));
    });

    test('a credit that clears the invoice also stops reminders', () async {
      final inv = await env.invoice(
        sup,
        due: DateTime(2026, 10, 25),
        totalMinor: 10000,
      );
      await replan();
      await env.recordCredit(
        supplierId: sup,
        amount: const Money(10000),
        issuedOn: today,
        invoiceId: inv.id,
      );
      await replan();
      expect(env.plugin.scheduled, isEmpty);
    });

    test('deleting an unpaid invoice stops them', () async {
      final inv = await env.invoice(sup, due: DateTime(2026, 10, 25));
      await replan();
      await env.deleteInvoice(inv.id);
      await replan();
      expect(env.plugin.scheduled, isEmpty);
    });

    test('editing the due date moves the reminders', () async {
      final inv = await env.invoice(sup, due: DateTime(2026, 10, 25));
      await replan();
      await env.editInvoice(
        inv.id,
        invoiceDate: inv.invoiceDate,
        total: inv.total,
        dueDate: DateTime(2026, 11, 10),
      );
      await replan();
      final keys = await pendingKeys();
      expect(keys.first, 'pay:2026-11-07');
      expect(keys, contains('paydue:2026-11-10'));
    });
  });

  group('snooze (S4-13)', () {
    test('per-invoice snooze silences reminders; undo restores them', () async {
      final inv = await env.invoice(sup, due: DateTime(2026, 10, 25));
      await replan();
      final previous = await env.reminderSnooze.snooze(
        inv.id,
        DateTime(2026, 10, 25),
      );
      await replan();
      expect(await pendingKeys(), [
        'paydue:2026-10-25',
        'overdue:2026-10-28',
        'overdue:2026-10-31',
      ]);
      await env.reminderSnooze.restore(inv.id, previous);
      await replan();
      expect(await pendingKeys(), hasLength(4));
    });

    test('snoozing one invoice leaves another supplier reminding', () async {
      final other = await env.supplier(name: 'Other');
      final a = await env.invoice(sup, due: DateTime(2026, 10, 25));
      await env.invoice(other, due: DateTime(2026, 10, 25));
      await replan();
      await env.reminderSnooze.snooze(a.id, DateTime(2026, 12));
      await replan();
      final body = env.plugin.scheduled.values
          .firstWhere((n) => n.title == 'Payment due today')
          .body;
      expect(body, contains('Other'));
      expect(body, isNot(contains('ABC')));
    });
  });

  test('archived suppliers still remind about what they are owed', () async {
    await env.invoice(sup, due: DateTime(2026, 10, 25));
    await env.setSupplierArchived(sup, archived: true);
    await replan();
    expect(env.plugin.scheduled, hasLength(4));
  });

  test('payment settings (SET-6) change the schedule', () async {
    await env.invoice(sup, due: DateTime(2026, 10, 25));
    await env.settings.update(
      (s) => s.copyWith(paymentLeadDays: [7, 1, 0], overdueRepeatDays: 0),
    );
    await replan();
    expect(await pendingKeys(), [
      'pay:2026-10-18',
      'pay:2026-10-24',
      'paydue:2026-10-25',
    ]);
  });

  test('expiry alerts and payment reminders live side by side', () async {
    final med = await env.medicine();
    await env.addBatch(
      env.batchInput(med, expiry: ExpiryDate.day(2026, 11, 26)),
    );
    await env.invoice(sup, due: DateTime(2026, 10, 25));
    await replan();
    final kinds = (await env.alertStore.all()).map((r) => r.kind).toSet();
    expect(
      kinds,
      containsAll([
        AlertKind.expiryLead,
        AlertKind.expiryDay,
        AlertKind.payment,
      ]),
    );
    // Paying cancels only the payment ones.
    final inv =
        (await env.ledger.watchInvoices(sup, today: today).first).single;
    await env.recordPayment(
      supplierId: sup,
      amount: inv.balance,
      paidOn: today,
      invoiceId: inv.invoice.id,
    );
    await replan();
    expect(await pendingKeys(), isEmpty);
    expect(env.plugin.scheduled, hasLength(5), reason: 'expiry alerts remain');
  });
}
