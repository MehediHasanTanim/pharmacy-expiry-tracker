import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/expiry.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/expiry_bucket.dart';

import '../support/test_env.dart';

void main() {
  late TestEnv env;
  final today = DateTime(2026, 10, 17);

  setUp(() => env = TestEnv());
  tearDown(() => env.dispose());

  ExpiryQuery query({
    ExpiryFilter filter = const ExpiryFilter(),
    ExpirySort sort = ExpirySort.soonest,
    int window = 90,
  }) => ExpiryQuery(
    today: today,
    globalWindowDays: window,
    filter: filter,
    sort: sort,
  );

  ExpiryDate inDays(int d) {
    final t = DateTime(today.year, today.month, today.day + d);
    return ExpiryDate.day(t.year, t.month, t.day);
  }

  Future<Batch> add(
    String med,
    String number,
    int days, {
    int qty = 10,
    int? cost,
  }) async => (await env.addBatch(
    env.batchInput(
      med,
      number: number,
      expiry: inDays(days),
      quantity: qty,
      costMinor: cost,
    ),
  )).batch;

  Future<List<String>> numbers(ExpiryQuery q) async =>
      (await env.expiry.fetchPage(q)).items
          .map((i) => i.batch.batchNumber)
          .toList();

  group('which batches appear (EXP-1)', () {
    test(
      'window edge: day 90 in, day 91 out; expired stock always in',
      () async {
        final m = await env.medicine();
        await add(m, 'EXPIRED', -20);
        await add(m, 'TODAY', 0);
        await add(m, 'D90', 90);
        await add(m, 'D91', 91);
        expect(await numbers(query()), ['EXPIRED', 'TODAY', 'D90']);
      },
    );

    test('per-medicine window overrides the global one (MED-3 data)', () async {
      final wide = await env.medicine(brand: 'Wide', alertWindowDays: 200);
      final narrow = await env.medicine(brand: 'Narrow', alertWindowDays: 30);
      final plain = await env.medicine(brand: 'Plain');
      await add(wide, 'W', 150);
      await add(narrow, 'N31', 31);
      await add(narrow, 'N30', 30);
      await add(plain, 'P91', 91);
      await add(plain, 'P60', 60);
      expect(await numbers(query()), ['N30', 'P60', 'W']);
      // A bigger global window pulls in P91 but not N31 (own window of 30).
      expect(await numbers(query(window: 120)), ['N30', 'P60', 'P91', 'W']);
    });

    test(
      'excludes empty, discarded, returned and archived-medicine batches',
      () async {
        final m = await env.medicine();
        final gone = await env.medicine(brand: 'Gone');
        final sold = await add(m, 'SOLD', 10, qty: 2);
        final dumped = await add(m, 'DUMPED', 11, qty: 2);
        await add(m, 'KEEP', 12);
        await add(gone, 'ARCH', 10);
        await env.adjustStock(
          batchId: sold.id,
          delta: -2,
          reason: AdjustmentReason.sold,
        );
        await env.adjustStock(
          batchId: dumped.id,
          delta: -2,
          reason: AdjustmentReason.discardedExpired,
        );
        await env.setArchived(gone, archived: true);
        expect(await numbers(query()), ['KEEP']);
      },
    );

    test('returns medicine, days left and bucket for each row', () async {
      final m = await env.medicine();
      await add(m, 'A', -3);
      await add(m, 'B', 45);
      final items = (await env.expiry.fetchPage(query())).items;
      expect(items[0].daysLeft, -3);
      expect(items[0].bucket, ExpiryBucket.expired);
      expect(items[0].isExpired, isTrue);
      expect(items[1].daysLeft, 45);
      expect(
        items[1].bucket,
        ExpiryBucket.d90 == items[1].bucket
            ? ExpiryBucket.d90
            : ExpiryBucket.d60,
      );
      expect(items[1].bucket, ExpiryBucket.d60);
      expect(items[1].medicine.id, m);
    });

    test('value at risk per row, null without cost', () async {
      final m = await env.medicine();
      await add(m, 'PRICED', 5, qty: 4, cost: 250);
      await add(m, 'UNPRICED', 6);
      final items = (await env.expiry.fetchPage(query())).items;
      expect(items[0].valueAtRisk, const Money(1000));
      expect(items[1].valueAtRisk, isNull);
    });
  });

  group('sorting (EXP-4)', () {
    test('soonest, value at risk, name', () async {
      final a = await env.medicine(brand: 'Zeta');
      final b = await env.medicine(brand: 'Alpha');
      await add(a, 'Z1', 10, qty: 1, cost: 100); // value 100
      await add(b, 'A1', 40, qty: 10, cost: 1000); // value 10 000
      await add(b, 'A2', 20, qty: 5); // no cost -> 0
      expect(await numbers(query()), ['Z1', 'A2', 'A1']);
      expect(await numbers(query(sort: ExpirySort.valueAtRisk)), [
        'A1',
        'Z1',
        'A2',
      ]);
      expect(
        await numbers(query(sort: ExpirySort.name)),
        ['A2', 'A1', 'Z1'], // Alpha (by expiry) then Zeta
      );
    });
  });

  group('filters (EXP-4)', () {
    late String amox;
    late String para;
    setUp(() async {
      amox = await env.medicine(
        brand: 'Amoxil',
        category: 'Antibiotic',
        form: DosageForm.capsule,
      );
      para = await env.medicine(
        brand: 'Panadol',
        generic: 'Paracetamol',
        strength: '500 mg',
        category: 'Analgesic',
        form: DosageForm.tablet,
      );
      await add(amox, 'LOT-AMX', -5);
      await add(amox, 'AMX2', 20);
      await add(para, 'LOT-PAN', 45);
      await add(para, 'PAN2', 75);
    });

    test('bucket', () async {
      Future<List<String>> by(ExpiryBucket b) =>
          numbers(query(filter: ExpiryFilter(bucket: b)));
      expect(await by(ExpiryBucket.expired), ['LOT-AMX']);
      expect(await by(ExpiryBucket.d30), ['AMX2']);
      expect(await by(ExpiryBucket.d60), ['LOT-PAN']);
      expect(await by(ExpiryBucket.d90), ['PAN2']);
      expect(await by(ExpiryBucket.ok), isEmpty);
    });

    test('category and form', () async {
      expect(
        await numbers(query(filter: const ExpiryFilter(category: 'Analgesic'))),
        ['LOT-PAN', 'PAN2'],
      );
      expect(
        await numbers(
          query(filter: const ExpiryFilter(form: DosageForm.capsule)),
        ),
        ['LOT-AMX', 'AMX2'],
      );
    });

    test(
      'free text matches medicine name, generic, and batch number',
      () async {
        expect(
          await numbers(query(filter: const ExpiryFilter(query: 'paracet'))),
          ['LOT-PAN', 'PAN2'],
        );
        expect(
          await numbers(query(filter: const ExpiryFilter(query: 'lot-'))),
          ['LOT-AMX', 'LOT-PAN'],
        );
        expect(
          await numbers(query(filter: const ExpiryFilter(query: 'amox 250'))),
          isEmpty,
          reason: 'all words must match',
        );
        expect(
          await numbers(query(filter: const ExpiryFilter(query: '%'))),
          isEmpty,
          reason: 'wildcards are literal',
        );
      },
    );

    test('supplier filter matches the batch supplier', () async {
      expect(
        await numbers(query(filter: const ExpiryFilter(supplierId: 'nobody'))),
        isEmpty,
      );
    });

    test(
      'hideHandled hides handled near-expiry batches but not expired ones',
      () async {
        final all = (await env.expiry.fetchPage(query())).items;
        Batch find(String n) =>
            all.firstWhere((i) => i.batch.batchNumber == n).batch;
        await env.alertState.markHandled(find('LOT-AMX').id);
        await env.alertState.markHandled(find('AMX2').id);
        expect(
          await numbers(query(filter: const ExpiryFilter(hideHandled: true))),
          ['LOT-AMX', 'LOT-PAN', 'PAN2'],
        );
        expect(await numbers(query()), hasLength(4));
      },
    );

    test('categories lists distinct non-archived categories', () async {
      final dup = await env.medicine(brand: 'Other', category: 'Analgesic');
      await env.medicine(brand: 'Uncat');
      final arch = await env.medicine(brand: 'Old', category: 'Retired');
      await env.setArchived(arch, archived: true);
      expect(dup, isNotEmpty);
      expect(await env.expiry.categories(), ['Analgesic', 'Antibiotic']);
    });
  });

  group('keyset pagination (S2-02)', () {
    Future<void> seed() async {
      // Quotes and ties on purpose: same expiry day, awkward names.
      final names = ["O'Brien", 'Alpha', 'Beta"x', 'Gamma'];
      for (var i = 0; i < names.length; i++) {
        final m = await env.medicine(brand: names[i], strength: null);
        await add(m, 'B${i}A', 10 + i, qty: 1 + i, cost: 100 * (i + 1));
        await add(m, 'B${i}B', 10 + i, qty: 2, cost: 100);
      }
    }

    for (final sort in ExpirySort.values) {
      test('pages cover every row once, in order — ${sort.name}', () async {
        await seed();
        final q = query(sort: sort);
        final whole = (await env.expiry.fetchPage(q, limit: 100)).items;
        expect(whole, hasLength(8));

        final paged = <ExpiryItem>[];
        ExpiryCursor? cursor;
        var pages = 0;
        do {
          final page = await env.expiry.fetchPage(q, after: cursor, limit: 3);
          paged.addAll(page.items);
          cursor = page.next;
          pages++;
        } while (cursor != null);

        expect(pages, 3, reason: '3 + 3 + 2');
        expect(
          paged.map((i) => i.batch.id).toList(),
          whole.map((i) => i.batch.id).toList(),
        );
        expect(paged.map((i) => i.batch.id).toSet(), hasLength(8));
      });
    }

    test('the last page has no cursor; exact multiples end cleanly', () async {
      final m = await env.medicine();
      for (var i = 0; i < 4; i++) {
        await add(m, 'N$i', i + 1);
      }
      final p1 = await env.expiry.fetchPage(query(), limit: 2);
      final p2 = await env.expiry.fetchPage(query(), after: p1.next, limit: 2);
      expect(p2.items, hasLength(2));
      // A full page may still have a cursor; the following page is empty.
      final p3 = await env.expiry.fetchPage(query(), after: p2.next, limit: 2);
      expect(p3.items, isEmpty);
      expect(p3.next, isNull);
    });

    test(
      'value-at-risk order puts the biggest loss first, ties by expiry',
      () async {
        final m = await env.medicine();
        await add(m, 'SMALL', 5, qty: 1, cost: 100);
        await add(m, 'BIG', 50, qty: 10, cost: 1000);
        await add(m, 'TIE-LATE', 30, qty: 1, cost: 100);
        final items = (await env.expiry.fetchPage(
          query(sort: ExpirySort.valueAtRisk),
        )).items;
        expect(items.map((i) => i.batch.batchNumber), [
          'BIG',
          'SMALL',
          'TIE-LATE',
        ]);
      },
    );
  });

  group('summary (S2-04, S2-09)', () {
    test('counts every bucket and totals the value', () async {
      final m = await env.medicine();
      await add(m, 'E1', -10, qty: 2, cost: 100);
      await add(m, 'E2', -1, qty: 1, cost: 300);
      await add(m, 'A', 0, qty: 1, cost: 50);
      await add(m, 'B', 30, qty: 1); // no cost
      await add(m, 'C', 31, qty: 3, cost: 100);
      await add(m, 'D', 90, qty: 1, cost: 100);
      final s = await env.expiry.watchSummary(query()).first;
      expect(s.counts, {
        ExpiryBucket.expired: 2,
        ExpiryBucket.d30: 2,
        ExpiryBucket.d60: 1,
        ExpiryBucket.d90: 1,
        ExpiryBucket.ok: 0,
      });
      expect(s.total, 6);
      expect(s.value.total, const Money(200 + 300 + 50 + 300 + 100));
      expect(s.value.missingCost, 1);
      expect(s.value.isPartial, isTrue);
    });

    test('ignores the bucket filter but respects the other filters', () async {
      final a = await env.medicine(brand: 'A', category: 'X');
      final b = await env.medicine(brand: 'B', category: 'Y');
      await add(a, 'A1', 5);
      await add(b, 'B1', 5);
      final s = await env.expiry
          .watchSummary(
            query(
              filter: const ExpiryFilter(
                bucket: ExpiryBucket.expired,
                category: 'X',
              ),
            ),
          )
          .first;
      expect(s.count(ExpiryBucket.d30), 1);
      expect(s.total, 1);
    });

    test('empty database yields zeros', () async {
      final s = await env.expiry.watchSummary(query()).first;
      expect(s.total, 0);
      expect(s.value.total, Money.zero);
    });

    test('re-emits when stock changes', () async {
      final m = await env.medicine();
      final b = await add(m, 'A', 5);
      final emitted = <int>[];
      final sub = env.expiry
          .watchSummary(query())
          .listen((s) => emitted.add(s.total));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await env.adjustStock(
        batchId: b.id,
        delta: -10,
        reason: AdjustmentReason.sold,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await sub.cancel();
      expect(emitted, [1, 0]);
    });

    test('watchChanges fires on writes', () async {
      var n = 0;
      final sub = env.expiry.watchChanges().listen((_) => n++);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      final m = await env.medicine();
      await add(m, 'A', 5);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await sub.cancel();
      expect(n, greaterThan(0));
    });
  });

  group('snooze / handled (EXP-5, S2-07)', () {
    late String batchId;
    setUp(() async {
      final m = await env.medicine();
      batchId = (await add(m, 'A', 20)).id;
    });

    Future<Batch> reload() async => (await env.batches.getById(batchId))!;

    test(
      'snooze stores a calendar date and returns the previous state',
      () async {
        final prev = await env.alertState.snooze(
          batchId,
          DateTime(2026, 10, 24, 15),
        );
        expect(prev.snoozedUntil, isNull);
        expect(prev.handledAt, isNull);
        expect((await reload()).snoozedUntil, DateTime(2026, 10, 24));
      },
    );

    test('undo restores exactly the previous state', () async {
      await env.alertState.snooze(batchId, DateTime(2026, 10, 20));
      final prev = await env.alertState.markHandled(batchId);
      expect(prev.snoozedUntil, DateTime(2026, 10, 20));
      expect(prev.handledAt, isNull);
      expect((await reload()).handledAt, isNotNull);

      await env.alertState.restore(batchId, prev);
      final b = await reload();
      expect(b.handledAt, isNull);
      expect(b.snoozedUntil, DateTime(2026, 10, 20));
    });

    test(
      'markHandled keeps the snooze; unmark and clear are independent',
      () async {
        await env.alertState.snooze(batchId, DateTime(2026, 10, 20));
        await env.alertState.markHandled(batchId);
        var b = await reload();
        expect(b.snoozedUntil, DateTime(2026, 10, 20));
        expect(b.handledAt, env.clock.current);

        await env.alertState.clearSnooze(batchId);
        b = await reload();
        expect(b.snoozedUntil, isNull);
        expect(b.handledAt, isNotNull);

        await env.alertState.unmarkHandled(batchId);
        expect((await reload()).handledAt, isNull);
      },
    );

    test(
      'snoozing into the past is rejected; unknown batch is NotFound',
      () async {
        await expectLater(
          env.alertState.snooze(batchId, DateTime(2026, 10, 16)),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          env.alertState.markHandled('nope'),
          throwsA(isA<NotFoundException>()),
        );
      },
    );

    test('changes are announced to the alert engine', () async {
      final events = <DataChange>[];
      final sub = env.bus.changes.listen(events.add);
      await env.alertState.markHandled(batchId);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(events.single.kind, DataChangeKind.alertStateChanged);
      expect(events.single.batchId, batchId);
    });
  });

  group('discard (EXP-7)', () {
    test('writes off the remaining stock as expired with its value', () async {
      final m = await env.medicine();
      final b = await add(m, 'A', -2, qty: 7, cost: 150);
      final n = await env.discardBatches([b.id], note: 'shelf clear-out');
      expect(n, 1);
      final after = (await env.batches.getById(b.id))!;
      expect(after.quantityOnHand, 0);
      expect(after.status, BatchStatus.discarded);
      final h = await env.batches.watchAdjustments(b.id).first;
      expect(h.first.deltaQty, -7);
      expect(h.first.reason, AdjustmentReason.discardedExpired);
      expect(h.first.valueImpact, const Money(1050));
      expect(h.first.note, 'shelf clear-out');
      expect(await numbers(query()), isEmpty);
    });

    test('a bad id rolls back the whole bulk discard', () async {
      final m = await env.medicine();
      final a = await add(m, 'A', -2);
      final b = await add(m, 'B', -1);
      await expectLater(
        env.discardBatches([a.id, b.id, 'nope']),
        throwsA(isA<NotFoundException>()),
      );
      expect((await env.batches.getById(a.id))!.quantityOnHand, 10);
      expect((await env.batches.getById(b.id))!.quantityOnHand, 10);
    });

    test('empty batches are skipped', () async {
      final m = await env.medicine();
      final a = await add(m, 'A', -2, qty: 1);
      await env.adjustStock(
        batchId: a.id,
        delta: -1,
        reason: AdjustmentReason.sold,
      );
      expect(await env.discardBatches([a.id]), 0);
    });
  });

  group('performance on 50k batches (S2-02)', () {
    test('first page and summary stay fast', () async {
      final m = await env.medicine();
      // Bulk insert: 5 000 medicines x 10 batches, expiries spread over about
      // -100 .. +300 days from the fixed "today".
      await env.db.customStatement('''
        INSERT INTO medicines (id, brand_name, dosage_form, unit, reorder_level,
          is_archived, search_text, created_at, updated_at)
        WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 5000)
        SELECT 'med-' || i, 'Brand ' || i, 'tablet', 'strip', 0, 0,
               'brand ' || i, 0, 0 FROM n
      ''');
      await env.db.customStatement('''
        INSERT INTO batches (id, medicine_id, batch_number, expiry_date,
          expiry_precision, quantity_received, quantity_on_hand, cost_price_minor,
          received_date, status, created_at, updated_at)
        WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 50000)
        SELECT 'b-' || i, 'med-' || (1 + i % 5000), 'L' || i,
               date('2026-10-17', ((i * 7919) % 400 - 100) || ' days'),
               'DAY', 10, 10, 100 + i % 900, '2026-10-17', 'ACTIVE', 0, 0 FROM n
      ''');
      expect(m, isNotEmpty);
      final count = await env.db
          .customSelect('SELECT count(*) AS c FROM batches')
          .getSingle();
      expect(count.read<int>('c'), 50000);

      Future<int> time(Future<Object?> Function() f) async {
        final sw = Stopwatch()..start();
        await f();
        return sw.elapsedMilliseconds;
      }

      // Warm up SQLite page cache and query planning.
      await env.expiry.fetchPage(query());

      final soonest = await time(() => env.expiry.fetchPage(query()));
      final byValue = await time(
        () => env.expiry.fetchPage(query(sort: ExpirySort.valueAtRisk)),
      );
      final byName = await time(
        () => env.expiry.fetchPage(query(sort: ExpirySort.name)),
      );
      final summary = await time(() => env.expiry.watchSummary(query()).first);
      final firstPage = await env.expiry.fetchPage(query());
      final deep = await time(
        () => env.expiry.fetchPage(
          query(),
          after: const ExpiryCursor('2027-01-01', 'b-0'),
        ),
      );
      // Timings are the point of this test; print them for the log.
      // ignore: avoid_print
      print(
        '50k rows: soonest ${soonest}ms, value ${byValue}ms, '
        'name ${byName}ms, summary ${summary}ms, keyset ${deep}ms',
      );

      expect(firstPage.items, hasLength(50));
      expect(soonest, lessThan(100), reason: 'soonest ${soonest}ms');
      expect(deep, lessThan(100), reason: 'keyset page ${deep}ms');
      // Aggregates and unindexed sorts are timing-sensitive when the whole
      // suite runs in parallel (about 70 ms alone, 150 ms under load), so they
      // get headroom here; the printed numbers are the real record.
      expect(summary, lessThan(500), reason: 'summary ${summary}ms');
      // Sorts without a matching index scan the window; keep them bounded.
      expect(byValue, lessThan(500), reason: 'value sort ${byValue}ms');
      expect(byName, lessThan(500), reason: 'name sort ${byName}ms');
    });
  });
}
