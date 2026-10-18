import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/reorder_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/reorder_usecases.dart';

import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late ReorderRepositoryImpl reorder;
  late UpdateReorderSnooze snooze;
  final today = DateTime(2026, 10, 17);

  setUp(() {
    env = TestEnv();
    reorder = ReorderRepositoryImpl(env.db);
    snooze = UpdateReorderSnooze(
      reorder: reorder,
      clock: env.clock,
      bus: env.bus,
    );
  });
  tearDown(() => env.dispose());

  Future<List<String>> names() async => [
    for (final i in await reorder.watchBelowLevel(today: today).first) i.name,
  ];

  ExpiryDate in_(int days) {
    final d = DateTime(2026, 10, 17 + days);
    return ExpiryDate.day(d.year, d.month, d.day);
  }

  test('only medicines below their level are listed (ROR-1)', () async {
    final low = await env.medicine(
      brand: 'Low',
      reorderLevel: 20,
      strength: null,
    );
    final fine = await env.medicine(
      brand: 'Fine',
      reorderLevel: 20,
      strength: null,
    );
    await env.medicine(brand: 'Untracked', strength: null); // level 0
    await env.addBatch(env.batchInput(low, quantity: 5, expiry: in_(100)));
    await env.addBatch(env.batchInput(fine, quantity: 25, expiry: in_(100)));
    expect(await names(), ['Low']);
  });

  test('a medicine with no stock at all is below its level', () async {
    await env.medicine(brand: 'Empty', reorderLevel: 10, strength: null);
    final item = (await reorder.watchBelowLevel(today: today).first).single;
    expect(item.usable, 0);
    expect(item.suggested, 20);
  });

  test('expired and inactive stock does not count', () async {
    final m = await env.medicine(brand: 'M', reorderLevel: 10, strength: null);
    await env.addBatch(
      env.batchInput(m, number: 'OLD', quantity: 50, expiry: in_(-1)),
    );
    final gone = (await env.addBatch(
      env.batchInput(m, number: 'GONE', quantity: 50, expiry: in_(60)),
    )).batch;
    await env.adjustStock(
      batchId: gone.id,
      delta: -50,
      reason: AdjustmentReason.sold,
    );
    await env.addBatch(
      env.batchInput(m, number: 'OK', quantity: 4, expiry: in_(60)),
    );
    final item = (await reorder.watchBelowLevel(today: today).first).single;
    expect(item.usable, 4);
    expect(item.suggested, 16);
  });

  test('stock expiring today still counts, tomorrow it does not', () async {
    final m = await env.medicine(brand: 'M', reorderLevel: 10, strength: null);
    await env.addBatch(env.batchInput(m, quantity: 10, expiry: in_(0)));
    expect(await names(), isEmpty);
    expect(
      [
        for (final i
            in await reorder
                .watchBelowLevel(today: DateTime(2026, 10, 18))
                .first)
          i.name,
      ],
      ['M'],
    );
  });

  test('archived medicines are left out', () async {
    final m = await env.medicine(
      brand: 'Old',
      reorderLevel: 10,
      strength: null,
    );
    await env.setArchived(m, archived: true);
    expect(await names(), isEmpty);
  });

  test('ordered by how far below the level, then name', () async {
    final a = await env.medicine(brand: 'A', reorderLevel: 10, strength: null);
    final b = await env.medicine(brand: 'B', reorderLevel: 50, strength: null);
    final c = await env.medicine(brand: 'C', reorderLevel: 10, strength: null);
    await env.addBatch(env.batchInput(a, quantity: 5, expiry: in_(90)));
    await env.addBatch(env.batchInput(b, quantity: 5, expiry: in_(90)));
    await env.addBatch(env.batchInput(c, quantity: 5, expiry: in_(90)));
    expect(await names(), ['B', 'A', 'C']);
  });

  test('carries the preferred supplier and unit', () async {
    final s = await env.supplier(name: 'ABC');
    await env.saveMedicine(
      MedicineInput(
        brandName: 'Napa',
        reorderLevel: 10,
        preferredSupplierId: s,
        unit: StockUnit.box,
      ),
    );
    final item = (await reorder.watchBelowLevel(today: today).first).single;
    expect(item.supplierId, s);
    expect(item.unit, StockUnit.box);
  });

  test('the list updates as stock changes', () async {
    final m = await env.medicine(brand: 'M', reorderLevel: 10, strength: null);
    final seen = <int>[];
    final sub = reorder
        .watchBelowLevel(today: today)
        .listen((l) => seen.add(l.length));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    final b = (await env.addBatch(
      env.batchInput(m, quantity: 30, expiry: in_(90)),
    )).batch;
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await env.adjustStock(
      batchId: b.id,
      delta: -25,
      reason: AdjustmentReason.sold,
    );
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await sub.cancel();
    expect(seen, [1, 0, 1]);
  });

  group('snooze (ROR-4)', () {
    test('stored, reported, cleared, and announced', () async {
      final m = await env.medicine(
        brand: 'M',
        reorderLevel: 10,
        strength: null,
      );
      final events = <DataChange>[];
      final sub = env.bus.changes.listen(events.add);
      await snooze.snooze(m, DateTime(2026, 10, 24, 15));
      var item = (await reorder.watchBelowLevel(today: today).first).single;
      expect(item.snoozedUntil, DateTime(2026, 10, 24));
      await snooze.clear(m);
      item = (await reorder.watchBelowLevel(today: today).first).single;
      expect(item.snoozedUntil, isNull);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(
        events.map((e) => e.kind),
        everyElement(DataChangeKind.reorderChanged),
      );
      expect(events, hasLength(2));
    });

    test('cannot snooze into the past', () async {
      final m = await env.medicine(
        brand: 'M',
        reorderLevel: 10,
        strength: null,
      );
      await expectLater(
        snooze.snooze(m, DateTime(2026, 10, 16)),
        throwsA(isA<Object>()),
      );
    });

    test('restore puts back the earlier value', () async {
      final m = await env.medicine(
        brand: 'M',
        reorderLevel: 10,
        strength: null,
      );
      await snooze.snooze(m, DateTime(2026, 10, 20));
      await snooze.restore(m, null);
      final item = (await reorder.watchBelowLevel(today: today).first).single;
      expect(item.snoozedUntil, isNull);
    });
  });
}
