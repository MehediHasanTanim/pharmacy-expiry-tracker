import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/app/app.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/router.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/data/services/url_contact_launcher.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';

import '../support/fake_contact_launcher.dart';
import '../support/pump_app.dart';
import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late FakeContactLauncher launcher;
  final today = DateTime(2026, 10, 17);

  setUp(() {
    env = TestEnv();
    launcher = FakeContactLauncher();
    EditableText.debugDeterministicCursor = true;
  });
  tearDown(() async {
    EditableText.debugDeterministicCursor = false;
    await env.dispose();
  });

  Future<ProviderContainer> open(WidgetTester t) async {
    t.view
      ..physicalSize = const Size(900, 2600)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(env.db),
          clockProvider.overrideWithValue(env.clock),
          dataChangeBusProvider.overrideWithValue(env.bus),
          alertEngineEnabledProvider.overrideWithValue(false),
          notificationPluginProvider.overrideWithValue(env.plugin),
          contactLauncherProvider.overrideWithValue(launcher),
        ],
        child: const App(),
      ),
    );
    await settle(t);
    return ProviderScope.containerOf(t.element(find.byType(App)));
  }

  Future<void> go(WidgetTester t, ProviderContainer c, String route) async {
    c.read(routerProvider).go(route);
    await settle(t);
  }

  Future<void> tapKey(WidgetTester t, String key) async {
    await t.tap(find.byKey(Key(key)));
    await settle(t);
  }

  Future<void> tapText(WidgetTester t, String text) async {
    await t.tap(find.text(text).first);
    await settle(t);
  }

  Future<void> type(WidgetTester t, String key, String text) async {
    await t.enterText(find.byKey(Key(key)), text);
    await t.pump();
  }

  Future<InvoiceBalance> balance(WidgetTester t, String id) async {
    final b = await db(t, () => env.ledger.getInvoiceBalance(id, today: today));
    return b!;
  }

  group('suppliers list (SUP-1, SUP-7)', () {
    testWidgets('empty state leads to adding a supplier', (t) async {
      await open(t);
      await tapText(t, 'Suppliers');
      expect(find.text('No suppliers yet'), findsOneWidget);
      await tapKey(t, 'empty-add-supplier');
      expect(find.text('New supplier'), findsOneWidget);

      await tapKey(t, 'supplier-save');
      expect(find.text('Supplier name is required'), findsOneWidget);
      await type(t, 'field-supplier-name', 'ABC Pharma');
      await type(t, 'field-email', 'nope');
      await tapKey(t, 'supplier-save');
      expect(find.text('Enter a valid email address'), findsOneWidget);
      await type(t, 'field-email', 'orders@abc.example');
      await type(t, 'field-phone', '01711-000000');
      await type(t, 'field-terms', '30');
      await tapKey(t, 'supplier-save');

      expect(find.text('ABC Pharma'), findsOneWidget);
      final s = (await db(t, () => env.suppliers.watchActive().first)).single;
      expect(s.paymentTermsDays, 30);
      expect(s.email, 'orders@abc.example');
      await disposeApp(t);
    });

    testWidgets('shows what is owed, overdue badge, and next due (SUP-7)', (
      t,
    ) async {
      final a = await db(t, () => env.supplier(name: 'Alpha'));
      final b = await db(t, () => env.supplier(name: 'Beta'));
      await db(
        t,
        () => env.invoice(a, totalMinor: 18550, due: DateTime(2026, 10, 5)),
      );
      await db(
        t,
        () => env.invoice(b, totalMinor: 7000, due: DateTime(2026, 11, 20)),
      );
      await open(t);
      await tapText(t, 'Suppliers');

      expect(find.text('Owed 185.50'), findsOneWidget);
      expect(find.byKey(Key('overdue-$a')), findsOneWidget);
      expect(find.text('185.50 overdue'), findsOneWidget);
      expect(find.byKey(Key('overdue-$b')), findsNothing);
      expect(find.text('Owed 70.00'), findsOneWidget);
      expect(find.text('Next due Nov 20, 2026'), findsOneWidget);

      // The dues bar (SUP-8).
      expect(t.widget<Text>(find.byKey(const Key('dues-owed'))).data, '255.50');
      expect(
        t.widget<Text>(find.byKey(const Key('dues-overdue'))).data,
        '185.50',
      );
      expect(
        t.widget<Text>(find.byKey(const Key('dues-next'))).data,
        'Oct 5, 2026',
      );
      await disposeApp(t);
    });

    testWidgets('search and sort', (t) async {
      final a = await db(t, () => env.supplier(name: 'Alpha'));
      final b = await db(t, () => env.supplier(name: 'Beta'));
      await db(t, () => env.invoice(a, totalMinor: 1000));
      await db(t, () => env.invoice(b, totalMinor: 9000));
      await open(t);
      await tapText(t, 'Suppliers');

      Future<double> y(String id) async =>
          t.getTopLeft(find.byKey(Key('supplier-$id'))).dy;
      expect(await y(a), lessThan(await y(b)), reason: 'by name');
      await tapKey(t, 'supplier-sort-balance');
      expect(await y(b), lessThan(await y(a)), reason: 'biggest debt first');

      await type(t, 'supplier-search', 'alph');
      await settle(t);
      expect(find.byKey(Key('supplier-$a')), findsOneWidget);
      expect(find.byKey(Key('supplier-$b')), findsNothing);
      await disposeApp(t);
    });

    testWidgets('archiving hides a supplier until "show archived"', (t) async {
      final a = await db(t, () => env.supplier(name: 'Alpha'));
      final c = await open(t);
      await go(t, c, '/suppliers/$a/edit');
      await tapKey(t, 'supplier-archive');
      await tapKey(t, 'supplier-archive-confirm');
      await go(t, c, '/suppliers');
      expect(find.byKey(Key('supplier-$a')), findsNothing);
      await tapKey(t, 'supplier-archived');
      expect(find.byKey(Key('supplier-$a')), findsOneWidget);
      await disposeApp(t);
    });
  });

  group('contact actions (SUP-2)', () {
    testWidgets('call, message, WhatsApp and email use the launcher', (
      t,
    ) async {
      final s = await db(t, () async {
        return env.saveSupplier(
          const SupplierInput(
            name: 'Alpha',
            phone: '+880 1711-000000',
            email: 'a@alpha.example',
          ),
        );
      });
      final c = await open(t);
      await go(t, c, '/suppliers/$s');
      for (final key in [
        'contact-call',
        'contact-sms',
        'contact-whatsapp',
        'contact-email',
      ]) {
        await tapKey(t, key);
      }
      expect(launcher.calls, [
        'call:+880 1711-000000',
        'sms:+880 1711-000000',
        'whatsapp:+880 1711-000000',
        'email:a@alpha.example',
      ]);
      await disposeApp(t);
    });

    testWidgets('when no app can handle it, say so and offer to copy', (
      t,
    ) async {
      launcher.succeeds = false;
      final s = await db(t, () => env.supplier(phone: '01711000000'));
      final c = await open(t);
      await go(t, c, '/suppliers/$s');
      await tapKey(t, 'contact-call');
      expect(
        find.text('Could not open that app on this device.'),
        findsOneWidget,
      );
      await tapKey(t, 'contact-copy');
      expect(find.text('Copied to the clipboard'), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('buttons only appear for details the supplier has', (t) async {
      final s = await db(t, env.supplier); // no phone, no email
      final c = await open(t);
      await go(t, c, '/suppliers/$s');
      for (final key in [
        'contact-call',
        'contact-sms',
        'contact-whatsapp',
        'contact-email',
      ]) {
        expect(find.byKey(Key(key)), findsNothing);
      }
      await disposeApp(t);
    });

    test('phone numbers are cleaned for dialling and WhatsApp', () {
      expect(dialable(' +880 (1711) 000-000 '), '+8801711000000');
      expect(dialable('01711 000000'), '01711000000');
      expect(whatsappNumber('+880 1711-000000'), '8801711000000');
    });
  });

  group('invoices and payments (SUP-4, SUP-5, SUP-6)', () {
    testWidgets(
      'demo: add a due with terms, pay part of it, see the status change',
      (t) async {
        final s = await db(t, () => env.supplier(terms: 30));
        final c = await open(t);
        await go(t, c, '/suppliers/$s');
        await tapKey(t, 'add-invoice');
        await type(t, 'field-invoice-number', 'INV-7');
        await type(t, 'field-invoice-total', '185.50');
        // Due date follows the 30-day terms from today (Oct 17).
        expect(find.text('Nov 16, 2026'), findsOneWidget);
        expect(
          find.text("Due date set from the supplier's payment terms"),
          findsOneWidget,
        );
        await tapKey(t, 'invoice-save');

        // Back on the supplier: the invoice is listed as unpaid.
        expect(find.text('Invoice INV-7'), findsOneWidget);
        expect(find.byKey(const Key('status-unpaid')), findsOneWidget);
        expect(
          t.widget<Text>(find.byKey(const Key('supplier-owed'))).data,
          '185.50',
        );

        // Open it and pay part (SUP-5).
        await tapText(t, 'Invoice INV-7');
        await tapKey(t, 'invoice-pay');
        expect(
          t
              .widget<TextFormField>(
                find.byKey(const Key('field-payment-amount')),
              )
              .controller!
              .text,
          '185.50',
          reason: 'prefilled with what is owed',
        );
        await type(t, 'field-payment-amount', '50');
        await tapKey(t, 'method-bank');
        await type(t, 'field-payment-reference', 'TRX-1');
        await tapKey(t, 'payment-save');

        expect(find.text('Payment recorded'), findsOneWidget);
        expect(find.byKey(const Key('status-partial')), findsOneWidget);
        expect(
          t.widget<Text>(find.byKey(const Key('invoice-balance'))).data,
          '135.50',
        );

        final inv = (await db(
          t,
          () => env.ledger.watchInvoices(s, today: today).first,
        )).single;
        expect(inv.paid, const Money(5000));
        final p = (await db(t, () => env.ledger.watchPayments(s).first)).single;
        expect(p.method, PaymentMethod.bank);
        expect(p.reference, 'TRX-1');
        await disposeApp(t);
      },
    );

    testWidgets('overdue invoices show as overdue', (t) async {
      final s = await db(t, env.supplier);
      final inv = await db(
        t,
        () => env.invoice(
          s,
          date: DateTime(2026, 9),
          due: DateTime(2026, 10, 1),
          totalMinor: 9900,
        ),
      );
      final c = await open(t);
      await go(t, c, '/suppliers/$s');
      expect(find.byKey(const Key('status-overdue')), findsOneWidget);
      expect(find.byKey(Key('invoice-balance-${inv.id}')), findsOneWidget);
      expect(
        t.widget<Text>(find.byKey(const Key('supplier-overdue'))).data,
        '99.00',
      );
      await disposeApp(t);
    });

    testWidgets('paying with no invoice picked spreads over the oldest due', (
      t,
    ) async {
      final s = await db(t, env.supplier);
      final late = await db(
        t,
        () => env.invoice(
          s,
          totalMinor: 5000,
          due: DateTime(2026, 12),
          number: 'L',
        ),
      );
      final early = await db(
        t,
        () => env.invoice(
          s,
          totalMinor: 3000,
          due: DateTime(2026, 10, 25),
          number: 'E',
        ),
      );
      final c = await open(t);
      await go(t, c, '/suppliers/$s/pay');
      await type(t, 'field-payment-amount', '40');
      await tapKey(t, 'payment-save');

      expect((await balance(t, early.id)).status, InvoiceStatus.paid);
      expect((await balance(t, late.id)).balance, const Money(4000));
      expect(find.textContaining('Applied to 2 invoices'), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets(
      'paying more than is owed offers to keep the extra as a credit',
      (t) async {
        final s = await db(t, env.supplier);
        final inv = await db(t, () => env.invoice(s, totalMinor: 10000));
        final c = await open(t);
        await go(t, c, '/suppliers/$s/pay?invoice=${inv.id}');
        await type(t, 'field-payment-amount', '120');
        await tapKey(t, 'payment-save');

        expect(find.text('More than is owed'), findsOneWidget);
        expect(find.textContaining('120.00'), findsWidgets);
        expect(find.textContaining('20.00'), findsWidgets);
        // Nothing is written until the user agrees.
        expect(await db(t, () => env.ledger.watchPayments(s).first), isEmpty);

        await tapKey(t, 'pay-with-credit');
        expect((await balance(t, inv.id)).status, InvoiceStatus.paid);
        expect(
          (await db(t, () => env.ledger.watchCredits(s).first)).single.amount,
          const Money(2000),
        );
        await disposeApp(t);
      },
    );

    testWidgets('cancelling the overpayment prompt records nothing', (t) async {
      final s = await db(t, env.supplier);
      final inv = await db(t, () => env.invoice(s, totalMinor: 10000));
      final c = await open(t);
      await go(t, c, '/suppliers/$s/pay?invoice=${inv.id}');
      await type(t, 'field-payment-amount', '120');
      await tapKey(t, 'payment-save');
      await tapText(t, 'Cancel');
      expect(await db(t, () => env.ledger.watchPayments(s).first), isEmpty);
      expect((await balance(t, inv.id)).balance, const Money(10000));
      await disposeApp(t);
    });

    testWidgets('amount validation', (t) async {
      final s = await db(t, env.supplier);
      await db(t, () => env.invoice(s));
      final c = await open(t);
      await go(t, c, '/suppliers/$s/pay');
      await tapKey(t, 'payment-save');
      expect(find.text('Enter an amount above 0, like 185.50'), findsOneWidget);
      await type(t, 'field-payment-amount', '0');
      await tapKey(t, 'payment-save');
      expect(find.text('Enter an amount above 0, like 185.50'), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('deleting a payment recomputes the balance (ledger)', (
      t,
    ) async {
      final s = await db(t, env.supplier);
      final inv = await db(t, () => env.invoice(s, totalMinor: 10000));
      final p = (await db(
        t,
        () => env.recordPayment(
          supplierId: s,
          amount: const Money(10000),
          paidOn: today,
          invoiceId: inv.id,
        ),
      )).single;
      final c = await open(t);
      await go(t, c, '/suppliers/$s');
      expect(
        t.widget<Text>(find.byKey(const Key('supplier-owed'))).data,
        '0.00',
      );
      await tapKey(t, 'delete-payment-${p.id}');
      await tapKey(t, 'confirm-delete');
      expect(
        t.widget<Text>(find.byKey(const Key('supplier-owed'))).data,
        '100.00',
      );
      expect(find.byKey(const Key('status-unpaid')), findsOneWidget);
      await disposeApp(t);
    });
  });

  group('invoice screen', () {
    testWidgets('editing changes the total and recomputes the balance', (
      t,
    ) async {
      final s = await db(t, env.supplier);
      final inv = await db(
        t,
        () => env.invoice(s, totalMinor: 10000, number: 'A'),
      );
      await db(
        t,
        () => env.recordPayment(
          supplierId: s,
          amount: const Money(4000),
          paidOn: today,
          invoiceId: inv.id,
        ),
      );
      final c = await open(t);
      await go(t, c, '/suppliers/$s/invoice/${inv.id}');
      await tapKey(t, 'invoice-edit');
      await type(t, 'field-invoice-total', '150');
      await tapKey(t, 'invoice-save');
      expect(
        t.widget<Text>(find.byKey(const Key('invoice-balance'))).data,
        '110.00',
      );
      await disposeApp(t);
    });

    testWidgets(
      'delete works for an untouched invoice, not one with payments',
      (t) async {
        final s = await db(t, env.supplier);
        final clean = await db(t, () => env.invoice(s, number: 'CLEAN'));
        final paid = await db(t, () => env.invoice(s, number: 'PAID'));
        await db(
          t,
          () => env.recordPayment(
            supplierId: s,
            amount: const Money(100),
            paidOn: today,
            invoiceId: paid.id,
          ),
        );
        final c = await open(t);

        await go(t, c, '/suppliers/$s/invoice/${paid.id}');
        await tapKey(t, 'invoice-delete');
        await tapKey(t, 'confirm-delete');
        expect(
          find.text('Delete its payments and credits first.'),
          findsOneWidget,
        );
        expect(await db(t, () => env.ledger.getInvoice(paid.id)), isNotNull);

        await go(t, c, '/suppliers/$s/invoice/${clean.id}');
        await tapKey(t, 'invoice-delete');
        await tapKey(t, 'confirm-delete');
        expect(await db(t, () => env.ledger.getInvoice(clean.id)), isNull);
        await disposeApp(t);
      },
    );

    testWidgets('reminders can be snoozed, with undo, and resumed (S4-13)', (
      t,
    ) async {
      final s = await db(t, env.supplier);
      final inv = await db(t, () => env.invoice(s, due: DateTime(2026, 11)));
      final c = await open(t);
      await go(t, c, '/suppliers/$s/invoice/${inv.id}');

      await tapKey(t, 'invoice-snooze');
      await tapKey(t, 'rsnooze-3d');
      expect(find.text('Reminders snoozed until Oct 20, 2026'), findsOneWidget);
      expect(find.byKey(const Key('reminder-snoozed')), findsOneWidget);
      expect(
        (await balance(t, inv.id)).invoice.remindersSnoozedUntil,
        DateTime(2026, 10, 20),
      );

      await tapKey(t, 'snack-undo');
      expect((await balance(t, inv.id)).invoice.remindersSnoozedUntil, isNull);

      await tapKey(t, 'invoice-snooze');
      await tapKey(t, 'rsnooze-1w');
      await tapKey(t, 'invoice-resume');
      expect((await balance(t, inv.id)).invoice.remindersSnoozedUntil, isNull);
      await disposeApp(t);
    });

    testWidgets('a credit reduces the balance; too large is refused', (
      t,
    ) async {
      final s = await db(t, env.supplier);
      final inv = await db(t, () => env.invoice(s, totalMinor: 10000));
      final c = await open(t);
      await go(t, c, '/suppliers/$s/invoice/${inv.id}');

      await tapKey(t, 'invoice-credit');
      await type(t, 'credit-amount', '250');
      await tapKey(t, 'credit-save');
      expect(
        find.textContaining('more than the 100.00 still owed'),
        findsOneWidget,
      );

      await type(t, 'credit-amount', '30');
      await tapKey(t, 'credit-save');
      expect(
        t.widget<Text>(find.byKey(const Key('invoice-balance'))).data,
        '70.00',
      );
      await disposeApp(t);
    });
  });

  group('receiving stock with a due (S4-10, BAT-8 lite)', () {
    testWidgets('supplier picker, then "Add a due for this delivery?"', (
      t,
    ) async {
      final s = await db(t, () => env.supplier(name: 'ABC Pharma', terms: 14));
      final med = await db(t, env.medicine);
      final c = await open(t);
      await go(t, c, '/stock/medicine/$med/batch/new');

      await type(t, 'field-batch-number', 'a1');
      await type(t, 'expiry-month', '08');
      await type(t, 'expiry-year', '2027');
      await type(t, 'field-quantity', '10');
      await type(t, 'field-cost', '2.50');
      await t.tap(find.byKey(const Key('field-batch-supplier')));
      await settle(t);
      await t.tap(find.text('ABC Pharma').last);
      await settle(t);
      await tapKey(t, 'batch-save');

      expect(find.text('Add a due for this delivery?'), findsOneWidget);
      expect(find.textContaining('ABC Pharma'), findsWidgets);
      await tapKey(t, 'due-yes');

      // Invoice form: linked batch, suggested total 10 x 2.50, terms-based due.
      expect(find.text('New invoice'), findsOneWidget);
      expect(find.byKey(const Key('invoice-linked')), findsOneWidget);
      expect(
        t
            .widget<TextFormField>(find.byKey(const Key('field-invoice-total')))
            .controller!
            .text,
        '25.00',
      );
      expect(find.text('Oct 31, 2026'), findsOneWidget);
      await tapKey(t, 'invoice-save');

      final inv = (await db(
        t,
        () => env.ledger.watchInvoices(s, today: today).first,
      )).single;
      expect(inv.invoice.total, const Money(2500));
      expect(
        await db(t, () => env.batches.countLinkedBatches(inv.invoice.id)),
        1,
      );
      final batch = (await db(
        t,
        () => env.db.select(env.db.batches).get(),
      )).single;
      expect(batch.supplierId, s);
      expect(batch.invoiceId, inv.invoice.id);
      await disposeApp(t);
    });

    testWidgets('declining the prompt records no invoice', (t) async {
      final s = await db(t, env.supplier);
      final med = await db(t, env.medicine);
      final c = await open(t);
      await go(t, c, '/stock/medicine/$med/batch/new');
      await type(t, 'field-batch-number', 'a1');
      await type(t, 'expiry-month', '08');
      await type(t, 'expiry-year', '2027');
      await type(t, 'field-quantity', '10');
      await t.tap(find.byKey(const Key('field-batch-supplier')));
      await settle(t);
      await t.tap(find.text('ABC Pharma').last);
      await settle(t);
      await tapKey(t, 'batch-save');
      await tapKey(t, 'due-no');
      expect(
        await db(t, () => env.ledger.watchInvoices(s, today: today).first),
        isEmpty,
      );
      await disposeApp(t);
    });

    testWidgets('no supplier chosen: no prompt', (t) async {
      final med = await db(t, env.medicine);
      final c = await open(t);
      await go(t, c, '/stock/medicine/$med/batch/new');
      await type(t, 'field-batch-number', 'a1');
      await type(t, 'expiry-month', '08');
      await type(t, 'expiry-year', '2027');
      await type(t, 'field-quantity', '10');
      await tapKey(t, 'batch-save');
      expect(find.text('Add a due for this delivery?'), findsNothing);
      await disposeApp(t);
    });

    testWidgets('one invoice can cover several batches of a delivery', (
      t,
    ) async {
      final s = await db(t, env.supplier);
      final med = await db(t, env.medicine);
      final c = await open(t);
      await go(t, c, '/stock/medicine/$med/batch/new');
      await t.tap(find.byKey(const Key('field-batch-supplier')));
      await settle(t);
      await t.tap(find.text('ABC Pharma').last);
      await settle(t);

      Future<void> fill(String number, String qty) async {
        await type(t, 'field-batch-number', number);
        await type(t, 'expiry-month', '08');
        await type(t, 'expiry-year', '2027');
        await type(t, 'field-quantity', qty);
        await type(t, 'field-cost', '1.00');
      }

      await fill('b1', '10');
      await tapKey(t, 'batch-save-another');
      // The supplier is remembered for the next batch of the delivery.
      await fill('b2', '5');
      await tapKey(t, 'batch-save-another');
      expect(find.byKey(const Key('batch-done')), findsOneWidget);
      await tapKey(t, 'batch-done');
      await tapKey(t, 'due-yes');

      expect(
        t
            .widget<TextFormField>(find.byKey(const Key('field-invoice-total')))
            .controller!
            .text,
        '15.00',
      );
      await tapKey(t, 'invoice-save');
      final inv = (await db(
        t,
        () => env.ledger.watchInvoices(s, today: today).first,
      )).single;
      expect(
        await db(t, () => env.batches.countLinkedBatches(inv.invoice.id)),
        2,
      );
      await disposeApp(t);
    });

    testWidgets("a medicine's preferred supplier is the default (MED-2)", (
      t,
    ) async {
      final s = await db(t, () => env.supplier(name: 'Preferred Co'));
      await db(t, () => env.supplier(name: 'Other Co'));
      final med = await db(
        t,
        () => env.saveMedicine(
          MedicineInput(brandName: 'Napa', preferredSupplierId: s),
        ),
      );
      final c = await open(t);
      await go(t, c, '/stock/medicine/$med/batch/new');
      expect(
        find.descendant(
          of: find.byKey(const Key('field-batch-supplier')),
          matching: find.text('Preferred Co'),
        ),
        findsOneWidget,
      );
      await disposeApp(t);
    });

    testWidgets('the medicine form can set and clear the preferred supplier', (
      t,
    ) async {
      final s = await db(t, () => env.supplier(name: 'Preferred Co'));
      final med = await db(t, env.medicine);
      final c = await open(t);
      await go(t, c, '/stock/medicine/$med/edit');
      await t.scrollUntilVisible(
        find.byType(DropdownButtonFormField<String?>),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await t.tap(find.byType(DropdownButtonFormField<String?>));
      await settle(t);
      await t.tap(find.text('Preferred Co').last);
      await settle(t);
      await tapKey(t, 'medicine-save');
      expect(
        (await db(t, () => env.medicines.getById(med)))!.preferredSupplierId,
        s,
      );
      await disposeApp(t);
    });
  });
}
