import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_planner.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 10, 17, 8);

  // Only payment reminders: no expiry alerts, no digest.
  const base = AppSettings(digestEnabled: false, alertLeadDays: []);

  PlanInvoice invoice(
    String id,
    DateTime due, {
    String supplier = 'ABC Pharma',
    String supplierId = 's1',
    int balance = 18500,
    DateTime? snoozedUntil,
  }) => PlanInvoice(
    id: id,
    supplierId: supplierId,
    supplierName: supplier,
    dueDay: dayNumber(due),
    balanceMinor: balance,
    snoozeDay: snoozedUntil == null ? null : dayNumber(snoozedUntil),
  );

  List<PlannedAlert> plan(
    List<PlanInvoice> invoices, {
    AppSettings settings = base,
    DateTime? at,
    int maxPending = maxPendingAlerts,
  }) => planAlerts(
    now: at ?? now,
    settings: settings,
    batches: const [],
    invoices: invoices,
    l10n: l10n,
    maxPending: maxPending,
  );

  List<String> keys(List<PlannedAlert> a) => a.map((e) => e.key).toList();

  group('before and on the due date (SUP-9)', () {
    test(
      'default 3 days before and on the day, 10 minutes after the digest',
      () {
        final a = plan([invoice('1', DateTime(2026, 10, 25))]);
        expect(keys(a), [
          'pay:2026-10-22',
          'paydue:2026-10-25',
          'overdue:2026-10-28',
          'overdue:2026-10-31',
        ]);
        expect(a.first.fireAt, DateTime(2026, 10, 22, 9, 10));
        expect(a.first.kind, AlertKind.payment);
      },
    );

    test('titles', () {
      final a = plan([invoice('1', DateTime(2026, 10, 25))]);
      final byKey = {for (final x in a) x.key: x};
      expect(byKey['pay:2026-10-22']!.title, 'Payment due in 3 days');
      expect(byKey['paydue:2026-10-25']!.title, 'Payment due today');
      expect(byKey['overdue:2026-10-28']!.title, 'Payment overdue');
    });

    test('body names the supplier, the amount and the total', () {
      final a = plan([
        invoice('1', DateTime(2026, 10, 25)),
      ], settings: base.copyWith(currencySymbol: '৳', languageCode: 'en'));
      expect(a.first.body, '1 invoice: ABC Pharma ৳185.00 · ৳185.00');
    });

    test('the route opens the supplier when only one is involved', () {
      final a = plan([
        invoice('1', DateTime(2026, 10, 25), supplierId: 'sup-9'),
      ]);
      expect(a.first.route, '/suppliers/sup-9');
    });

    test('several suppliers on one day share one notification', () {
      final a = plan([
        invoice(
          '1',
          DateTime(2026, 10, 25),
          supplier: 'Alpha',
          supplierId: 'a',
          balance: 1000,
        ),
        invoice(
          '2',
          DateTime(2026, 10, 25),
          supplier: 'Beta',
          supplierId: 'b',
          balance: 2000,
        ),
      ]);
      final due = a.firstWhere((x) => x.key == 'paydue:2026-10-25');
      expect(due.body, '2 invoices: Alpha 10.00, Beta 20.00 · 30.00');
      expect(due.route, '/suppliers');
      expect(a.where((x) => x.key == 'paydue:2026-10-25'), hasLength(1));
    });

    test('long groups list three, then "and N more"', () {
      final a = plan([
        for (var i = 0; i < 5; i++)
          invoice(
            '$i',
            DateTime(2026, 10, 25),
            supplier: 'S$i',
            supplierId: 's$i',
            balance: 100,
          ),
      ]);
      expect(
        a.firstWhere((x) => x.key == 'paydue:2026-10-25').body,
        '5 invoices: S0 1.00, S1 1.00, S2 1.00 and 2 more · 5.00',
      );
    });

    test('a mixed group (different lead times) uses a general title', () {
      final a = plan([
        invoice('1', DateTime(2026, 10, 25)), // lead 3 on Oct 22
        invoice(
          '2',
          DateTime(2026, 10, 22),
          supplier: 'Soon',
          supplierId: 's2',
        ), // due Oct 22
      ]);
      // Only the lead-3 invoice reminds ahead on Oct 22; the other is due.
      expect(
        a.firstWhere((x) => x.key == 'pay:2026-10-22').title,
        'Payment due in 3 days',
      );
      expect(
        a.firstWhere((x) => x.key == 'paydue:2026-10-22').title,
        'Payment due today',
      );
    });

    test('custom lead days', () {
      final a = plan(
        [invoice('1', DateTime(2026, 11, 20))],
        settings: base.copyWith(
          paymentLeadDays: [14, 7, 0],
          overdueRepeatDays: 0,
        ),
      );
      expect(keys(a), [
        'pay:2026-11-06',
        'pay:2026-11-13',
        'paydue:2026-11-20',
      ]);
    });
  });

  group('skipped reminders', () {
    test('lead dates that have passed, and times earlier today', () {
      // Due in 2 days: the 3-day lead is yesterday; the due-day one remains.
      final a = plan([invoice('1', DateTime(2026, 10, 19))]);
      expect(keys(a).first, 'paydue:2026-10-19');
      // Due today and it is already past reminder time.
      final late = plan([
        invoice('1', DateTime(2026, 10, 17)),
      ], at: DateTime(2026, 10, 17, 10));
      expect(keys(late).contains('paydue:2026-10-17'), isFalse);
      expect(keys(late).first, 'overdue:2026-10-20');
    });

    test('settled invoices produce nothing', () {
      expect(plan([invoice('1', DateTime(2026, 10, 25), balance: 0)]), isEmpty);
    });

    test('snooze silences reminders until that day, then they resume', () {
      final a = plan([
        invoice(
          '1',
          DateTime(2026, 10, 25),
          snoozedUntil: DateTime(2026, 10, 25),
        ),
      ]);
      expect(keys(a).first, 'paydue:2026-10-25');
      expect(keys(a), isNot(contains('pay:2026-10-22')));
    });

    test('a snooze past every date silences the invoice for the horizon', () {
      final a = plan([
        invoice('1', DateTime(2026, 10, 25), snoozedUntil: DateTime(2027)),
      ]);
      expect(a, isEmpty);
    });
  });

  group('overdue reminders every N days', () {
    test('anchored on the due date: due+3, due+6, ...', () {
      final a = plan([invoice('1', DateTime(2026, 10, 1))]);
      final overdue = a.where((x) => x.key.startsWith('overdue:'));
      expect(overdue.map((x) => x.key), [
        'overdue:2026-10-19',
        'overdue:2026-10-22',
        'overdue:2026-10-25',
        'overdue:2026-10-28',
        'overdue:2026-10-31',
      ]);
    });

    test('N is configurable and zero turns them off', () {
      final every5 = plan(
        [invoice('1', DateTime(2026, 10, 10))],
        settings: base.copyWith(
          paymentLeadDays: const [],
          overdueRepeatDays: 5,
        ),
      );
      expect(keys(every5), [
        'overdue:2026-10-20',
        'overdue:2026-10-25',
        'overdue:2026-10-30',
      ]);
      final off = plan(
        [invoice('1', DateTime(2026, 10, 10))],
        settings: base.copyWith(
          paymentLeadDays: const [],
          overdueRepeatDays: 0,
        ),
      );
      expect(off, isEmpty);
    });

    test('they run for the next two weeks only', () {
      final a = plan(
        [invoice('1', DateTime(2026, 9))],
        settings: base.copyWith(
          paymentLeadDays: const [],
          overdueRepeatDays: 1,
        ),
      );
      expect(a, hasLength(15)); // today (if still ahead) .. +14
      expect(a.first.key, 'overdue:2026-10-17');
      expect(a.last.key, 'overdue:2026-10-31');
    });

    test('several overdue invoices on a shared day are one notification', () {
      final a = plan([
        invoice('1', DateTime(2026, 10, 1), supplier: 'Alpha', supplierId: 'a'),
        invoice('2', DateTime(2026, 10, 4), supplier: 'Beta', supplierId: 'b'),
      ]);
      final shared = a.where((x) => x.key == 'overdue:2026-10-19').toList();
      // Oct 1 + 18 (6x3) and Oct 4 + 15 (5x3) both land on the 19th.
      expect(shared, hasLength(1));
      expect(shared.single.title, 'Payments overdue');
    });

    test('snooze applies to the repeats too', () {
      final a = plan([
        invoice(
          '1',
          DateTime(2026, 10, 1),
          snoozedUntil: DateTime(2026, 10, 26),
        ),
      ]);
      expect(a.where((x) => x.key.startsWith('overdue:')).map((x) => x.key), [
        'overdue:2026-10-28',
        'overdue:2026-10-31',
      ]);
    });
  });

  group('interplay with the rest of the plan', () {
    test('quiet hours move payment reminders like any other alert', () {
      final a = plan(
        [invoice('1', DateTime(2026, 10, 25))],
        settings: base.copyWith(
          paymentLeadDays: const [0],
          overdueRepeatDays: 0,
          digestMinutes: 23 * 60,
          quietHoursEnabled: true,
        ),
      );
      expect(a.single.fireAt, DateTime(2026, 10, 26, 7));
    });

    test('they compete with expiry alerts for the cap', () {
      final a = plan([
        for (var i = 0; i < 20; i++)
          invoice('$i', DateTime(2026, 10, 20 + i), supplierId: 's$i'),
      ], maxPending: 10);
      expect(a, hasLength(10));
      for (var i = 1; i < a.length; i++) {
        expect(
          a[i].fireAt.isAfter(a[i - 1].fireAt) ||
              a[i].fireAt == a[i - 1].fireAt,
          isTrue,
        );
      }
    });

    test('with no invoices the plan is exactly what it was', () {
      expect(plan(const []), isEmpty);
    });

    test('planning is deterministic and independent of input order', () {
      final r = Random(3);
      final invoices = [
        for (var i = 0; i < 200; i++)
          invoice(
            'i$i',
            DateTime(2026, 9 + r.nextInt(3), 1 + r.nextInt(28)),
            supplier: 'S${r.nextInt(15)}',
            supplierId: 'sup${r.nextInt(15)}',
            balance: 100 + r.nextInt(100000),
            snoozedUntil: r.nextInt(6) == 0
                ? DateTime(2026, 10, 17 + r.nextInt(20))
                : null,
          ),
      ];
      final shuffled = [...invoices]..shuffle(Random(8));
      expect(plan(invoices), plan(shuffled));
      expect(plan(invoices), plan(invoices));
      final a = plan(invoices);
      expect(a.map((x) => x.key).toSet(), hasLength(a.length));
    });
  });
}
