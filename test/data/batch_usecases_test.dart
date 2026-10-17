import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart'
    show BatchesCompanion;
import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/batch_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/batch_usecases.dart';

import '../support/test_env.dart';

/// Delegates to the real repository but fails on demand, to prove that a
/// failure part-way through a use case rolls everything back.
class FlakyBatchRepository implements BatchRepository {
  FlakyBatchRepository(this._real);

  final BatchRepository _real;
  bool failOnAdjustment = false;

  @override
  Future<void> insertAdjustment(StockAdjustment adjustment) {
    if (failOnAdjustment) return Future.error(StateError('disk full'));
    return _real.insertAdjustment(adjustment);
  }

  @override
  Future<Batch?> getById(String id) => _real.getById(id);
  @override
  Stream<Batch?> watchById(String id) => _real.watchById(id);
  @override
  Future<List<Batch>> findByMedicineAndNumber(String m, String n) =>
      _real.findByMedicineAndNumber(m, n);
  @override
  Future<Batch?> findExact(
    String m,
    String n,
    ExpiryDate e, {
    String? excludeId,
  }) => _real.findExact(m, n, e, excludeId: excludeId);
  @override
  Stream<List<Batch>> watchByMedicine(String id) => _real.watchByMedicine(id);
  @override
  Stream<List<BatchWithMedicine>> watchAllActive() => _real.watchAllActive();
  @override
  Future<void> insert(Batch batch) => _real.insert(batch);
  @override
  Future<void> update(Batch batch) => _real.update(batch);
  @override
  Future<void> updateQuantity(
    String id, {
    required int onHand,
    required int received,
    required BatchStatus status,
    required DateTime at,
  }) => _real.updateQuantity(
    id,
    onHand: onHand,
    received: received,
    status: status,
    at: at,
  );
  @override
  Stream<List<StockAdjustment>> watchAdjustments(String id) =>
      _real.watchAdjustments(id);
}

void main() {
  late FlakyBatchRepository flaky;
  late TestEnv env;
  late String med;

  setUp(() async {
    env = TestEnv(wrapBatches: (real) => flaky = FlakyBatchRepository(real));
    med = await env.medicine();
  });
  tearDown(() => env.dispose());

  Future<List<StockAdjustment>> history(String batchId) =>
      env.batches.watchAdjustments(batchId).first;

  group('AddBatch', () {
    test(
      'creates batch with normalised number and RECEIVED adjustment',
      () async {
        final r = await env.addBatch(env.batchInput(med, number: ' a-123 '));
        expect(r.merged, isFalse);
        final b = (await env.batches.getById(r.batch.id))!;
        expect(b.batchNumber, 'A-123');
        expect(b.quantityOnHand, 10);
        expect(b.quantityReceived, 10);
        expect(b.status, BatchStatus.active);
        expect(b.expiry.toIso(), '2027-08-31');
        expect(b.expiry.precision, ExpiryPrecision.month);
        expect(b.receivedDate, DateTime(2026, 10, 17));
        final h = await history(b.id);
        expect(h.single.deltaQty, 10);
        expect(h.single.reason, AdjustmentReason.received);
      },
    );

    test('stores prices and exact-day precision', () async {
      final r = await env.addBatch(
        BatchInput(
          medicineId: med,
          batchNumber: 'P1',
          expiry: ExpiryDate.day(2027, 1, 15),
          quantity: 3,
          receivedDate: DateTime(2026, 10, 1, 14, 30),
          costPrice: const Money(1250),
          sellingPrice: const Money(1800),
        ),
      );
      final b = (await env.batches.getById(r.batch.id))!;
      expect(b.costPrice, const Money(1250));
      expect(b.sellingPrice, const Money(1800));
      expect(b.expiry.precision, ExpiryPrecision.day);
      expect(b.receivedDate, DateTime(2026, 10, 1));
    });

    test(
      'rejects blank number, non-positive quantity, negative price',
      () async {
        await expectLater(
          env.addBatch(env.batchInput(med, number: '  ')),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          env.addBatch(env.batchInput(med, quantity: 0)),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          env.addBatch(
            BatchInput(
              medicineId: med,
              batchNumber: 'X',
              expiry: ExpiryDate.monthYear(2027, 1),
              quantity: 1,
              receivedDate: DateTime(2026, 10, 17),
              costPrice: const Money(-1),
            ),
          ),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test('rejects unknown and archived medicines', () async {
      await expectLater(
        env.addBatch(env.batchInput('nope')),
        throwsA(isA<NotFoundException>()),
      );
      await env.setArchived(med, archived: true);
      await expectLater(
        env.addBatch(env.batchInput(med)),
        throwsA(isA<ValidationException>()),
      );
    });

    group('duplicate policy (BAT-4)', () {
      test('ask: same number and expiry is an exact-match duplicate', () async {
        await env.addBatch(env.batchInput(med, number: 'A1'));
        final e = await env
            .addBatch(env.batchInput(med, number: 'a1'))
            .then<Object>((_) => 'no error')
            .catchError((Object e) => e);
        expect(e, isA<DuplicateBatchException>());
        e as DuplicateBatchException;
        expect(e.exactMatch, isTrue);
        expect(e.existing, hasLength(1));
        expect(await env.db.select(env.db.batches).get(), hasLength(1));
      });

      test(
        'ask: same number, different expiry is a non-exact duplicate',
        () async {
          await env.addBatch(env.batchInput(med, number: 'A1'));
          final e = await env
              .addBatch(
                env.batchInput(
                  med,
                  number: 'A1',
                  expiry: ExpiryDate.monthYear(2028, 1),
                ),
              )
              .then<Object>((_) => 'no error')
              .catchError((Object e) => e);
          expect((e as DuplicateBatchException).exactMatch, isFalse);
        },
      );

      test(
        'mergeInto adds to existing quantity and logs an adjustment',
        () async {
          final first = await env.addBatch(env.batchInput(med, number: 'A1'));
          final r = await env.addBatch(
            env.batchInput(med, number: 'A1', quantity: 4),
            onDuplicate: DuplicateResolution.mergeInto(first.batch.id),
          );
          expect(r.merged, isTrue);
          expect(r.batch.id, first.batch.id);
          expect(r.batch.quantityOnHand, 14);
          expect(r.batch.quantityReceived, 14);
          expect(await history(first.batch.id), hasLength(2));
          expect(await env.db.select(env.db.batches).get(), hasLength(1));
        },
      );

      test('merging into a depleted batch reactivates it', () async {
        final first = await env.addBatch(env.batchInput(med, number: 'A1'));
        await env.adjustStock(
          batchId: first.batch.id,
          delta: -10,
          reason: AdjustmentReason.sold,
        );
        final r = await env.addBatch(
          env.batchInput(med, number: 'A1', quantity: 2),
          onDuplicate: DuplicateResolution.mergeInto(first.batch.id),
        );
        expect(r.batch.status, BatchStatus.active);
        expect(r.batch.quantityOnHand, 2);
      });

      test('separate creates a second batch when expiry differs', () async {
        await env.addBatch(env.batchInput(med, number: 'A1'));
        final r = await env.addBatch(
          env.batchInput(
            med,
            number: 'A1',
            expiry: ExpiryDate.monthYear(2028, 1),
          ),
          onDuplicate: DuplicateResolution.separate,
        );
        expect(r.merged, isFalse);
        expect(await env.db.select(env.db.batches).get(), hasLength(2));
      });

      test('separate is refused when number and expiry both match', () async {
        await env.addBatch(env.batchInput(med, number: 'A1'));
        await expectLater(
          env.addBatch(
            env.batchInput(med, number: 'A1'),
            onDuplicate: DuplicateResolution.separate,
          ),
          throwsA(isA<DuplicateBatchException>()),
        );
      });

      test('same number on a different medicine is not a duplicate', () async {
        final other = await env.medicine(brand: 'Other');
        await env.addBatch(env.batchInput(med, number: 'A1'));
        await env.addBatch(env.batchInput(other, number: 'A1'));
        expect(await env.db.select(env.db.batches).get(), hasLength(2));
      });
    });

    test('rolls back the batch when the adjustment write fails', () async {
      flaky.failOnAdjustment = true;
      await expectLater(
        env.addBatch(env.batchInput(med)),
        throwsA(isA<StateError>()),
      );
      expect(await env.db.select(env.db.batches).get(), isEmpty);
      expect(await env.db.select(env.db.stockAdjustments).get(), isEmpty);
    });

    test('emits a change event after commit only', () async {
      final events = <DataChange>[];
      final sub = env.bus.changes.listen(events.add);
      flaky.failOnAdjustment = true;
      await expectLater(
        env.addBatch(env.batchInput(med)),
        throwsA(isA<StateError>()),
      );
      flaky.failOnAdjustment = false;
      final r = await env.addBatch(env.batchInput(med));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      // Only the committed add emits; the rolled-back attempt does not.
      expect(events.single.kind, DataChangeKind.batchAdded);
      expect(events.single.batchId, r.batch.id);
    });
  });

  group('AdjustStock', () {
    late String batchId;
    setUp(() async {
      final r = await env.addBatch(
        BatchInput(
          medicineId: med,
          batchNumber: 'A1',
          expiry: ExpiryDate.monthYear(2027, 8),
          quantity: 10,
          receivedDate: DateTime(2026, 10, 17),
          costPrice: const Money(250),
        ),
      );
      batchId = r.batch.id;
    });

    test('sold reduces stock and logs the delta', () async {
      final b = await env.adjustStock(
        batchId: batchId,
        delta: -3,
        reason: AdjustmentReason.sold,
        note: 'counter sale',
      );
      expect(b.quantityOnHand, 7);
      expect(b.status, BatchStatus.active);
      final h = await history(batchId);
      expect(h.first.deltaQty, -3);
      expect(h.first.note, 'counter sale');
      expect(h.first.valueImpact, isNull);
    });

    test('loss reasons record cost x quantity as value impact', () async {
      await env.adjustStock(
        batchId: batchId,
        delta: -4,
        reason: AdjustmentReason.damaged,
      );
      expect((await history(batchId)).first.valueImpact, const Money(1000));
    });

    test('loss without a cost price records no value', () async {
      final r = await env.addBatch(env.batchInput(med, number: 'NOCOST'));
      await env.adjustStock(
        batchId: r.batch.id,
        delta: -1,
        reason: AdjustmentReason.discardedExpired,
      );
      expect((await history(r.batch.id)).first.valueImpact, isNull);
    });

    test('status follows quantity and reason when reaching zero', () async {
      Future<BatchStatus> zeroWith(AdjustmentReason reason) async {
        final r = await env.addBatch(
          env.batchInput(med, number: 'Z${reason.name}', quantity: 2),
        );
        final b = await env.adjustStock(
          batchId: r.batch.id,
          delta: -2,
          reason: reason,
        );
        return b.status;
      }

      expect(await zeroWith(AdjustmentReason.sold), BatchStatus.depleted);
      expect(await zeroWith(AdjustmentReason.other), BatchStatus.depleted);
      expect(
        await zeroWith(AdjustmentReason.discardedExpired),
        BatchStatus.discarded,
      );
      expect(await zeroWith(AdjustmentReason.damaged), BatchStatus.discarded);
      expect(await zeroWith(AdjustmentReason.returned), BatchStatus.returned);
    });

    test('received and positive correction add stock and reactivate', () async {
      await env.adjustStock(
        batchId: batchId,
        delta: -10,
        reason: AdjustmentReason.sold,
      );
      var b = (await env.batches.getById(batchId))!;
      expect(b.status, BatchStatus.depleted);
      b = await env.adjustStock(
        batchId: batchId,
        delta: 2,
        reason: AdjustmentReason.correction,
      );
      expect(b.status, BatchStatus.active);
      expect(b.quantityOnHand, 2);
      b = await env.adjustStock(
        batchId: batchId,
        delta: 5,
        reason: AdjustmentReason.received,
      );
      expect(b.quantityOnHand, 7);
      expect(b.quantityReceived, 15);
    });

    test('rejects going below zero and leaves the batch unchanged', () async {
      await expectLater(
        env.adjustStock(
          batchId: batchId,
          delta: -11,
          reason: AdjustmentReason.sold,
        ),
        throwsA(
          isA<InsufficientStockException>()
              .having((e) => e.available, 'available', 10)
              .having((e) => e.requested, 'requested', 11),
        ),
      );
      expect((await env.batches.getById(batchId))!.quantityOnHand, 10);
      expect(await history(batchId), hasLength(1));
    });

    test('rejects zero delta and wrong-sign deltas', () async {
      for (final (reason, delta) in [
        (AdjustmentReason.sold, 0),
        (AdjustmentReason.sold, 2),
        (AdjustmentReason.received, -1),
        (AdjustmentReason.damaged, 1),
      ]) {
        await expectLater(
          env.adjustStock(batchId: batchId, delta: delta, reason: reason),
          throwsA(isA<ValidationException>()),
          reason: '$reason $delta',
        );
      }
    });

    test('unknown batch throws NotFound', () async {
      await expectLater(
        env.adjustStock(
          batchId: 'nope',
          delta: -1,
          reason: AdjustmentReason.sold,
        ),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('rolls back the quantity change when the audit write fails', () async {
      flaky.failOnAdjustment = true;
      await expectLater(
        env.adjustStock(
          batchId: batchId,
          delta: -5,
          reason: AdjustmentReason.sold,
        ),
        throwsA(isA<StateError>()),
      );
      final b = (await env.batches.getById(batchId))!;
      expect(b.quantityOnHand, 10);
      expect(b.status, BatchStatus.active);
      flaky.failOnAdjustment = false;
      expect(await history(batchId), hasLength(1));
    });

    test('history lists newest first', () async {
      env.clock.advance(const Duration(minutes: 1));
      await env.adjustStock(
        batchId: batchId,
        delta: -1,
        reason: AdjustmentReason.sold,
      );
      env.clock.advance(const Duration(minutes: 1));
      await env.adjustStock(
        batchId: batchId,
        delta: -2,
        reason: AdjustmentReason.damaged,
      );
      expect((await history(batchId)).map((a) => a.deltaQty), [-2, -1, 10]);
    });
  });

  group('EditBatch (BAT-9)', () {
    late Batch batch;
    setUp(() async {
      batch = (await env.addBatch(env.batchInput(med, number: 'A1'))).batch;
    });

    BatchEdit edit({String number = 'A1', ExpiryDate? expiry, Money? cost}) =>
        BatchEdit(
          batchNumber: number,
          expiry: expiry ?? ExpiryDate.monthYear(2027, 8),
          receivedDate: DateTime(2026, 10, 17),
          costPrice: cost,
        );

    test('changes number, expiry and cost without touching quantity', () async {
      final b = await env.editBatch(
        batch.id,
        edit(
          number: 'b2',
          expiry: ExpiryDate.day(2027, 9, 30),
          cost: const Money(99),
        ),
      );
      expect(b.batchNumber, 'B2');
      expect(b.expiry.toIso(), '2027-09-30');
      expect(b.costPrice, const Money(99));
      expect(b.quantityOnHand, 10);
      expect(await history(batch.id), hasLength(1));
    });

    test(
      'changing expiry clears snooze and handled; other edits keep them',
      () async {
        await env.db
            .update(env.db.batches)
            .write(
              const BatchesCompanion(
                snoozedUntil: Value('2026-12-01'),
                handledAt: Value(123),
              ),
            );
        var b = await env.editBatch(batch.id, edit(cost: const Money(5)));
        expect(b.snoozedUntil, DateTime(2026, 12));
        expect(b.handledAt, isNotNull);
        b = await env.editBatch(
          batch.id,
          edit(expiry: ExpiryDate.monthYear(2027, 9)),
        );
        expect(b.snoozedUntil, isNull);
        expect(b.handledAt, isNull);
      },
    );

    test('rejects a number+expiry that another batch already has', () async {
      await env.addBatch(
        env.batchInput(
          med,
          number: 'B2',
          expiry: ExpiryDate.monthYear(2028, 1),
        ),
      );
      await expectLater(
        env.editBatch(
          batch.id,
          edit(number: 'B2', expiry: ExpiryDate.monthYear(2028, 1)),
        ),
        throwsA(isA<DuplicateBatchException>()),
      );
    });

    test(
      'saving unchanged number and expiry is not a clash with itself',
      () async {
        await env.editBatch(batch.id, edit(cost: const Money(1)));
      },
    );

    test('emits batchEdited', () async {
      final events = <DataChange>[];
      final sub = env.bus.changes.listen(events.add);
      await env.editBatch(batch.id, edit());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(events.single.kind, DataChangeKind.batchEdited);
      expect(events.single.batchId, batch.id);
    });

    test('unknown batch throws NotFound', () async {
      await expectLater(
        env.editBatch('nope', edit()),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('batch queries', () {
    test('watchByMedicine: soonest expiry first, depleted last', () async {
      final late = await env.addBatch(
        env.batchInput(
          med,
          number: 'LATE',
          expiry: ExpiryDate.monthYear(2028, 1),
        ),
      );
      final soon = await env.addBatch(
        env.batchInput(
          med,
          number: 'SOON',
          expiry: ExpiryDate.monthYear(2026, 12),
        ),
      );
      final empty = await env.addBatch(
        env.batchInput(
          med,
          number: 'EMPTY',
          quantity: 1,
          expiry: ExpiryDate.monthYear(2026, 11),
        ),
      );
      await env.adjustStock(
        batchId: empty.batch.id,
        delta: -1,
        reason: AdjustmentReason.sold,
      );
      final list = await env.batches.watchByMedicine(med).first;
      expect(list.map((b) => b.batchNumber), ['SOON', 'LATE', 'EMPTY']);
      expect(soon.batch.id, list.first.id);
      expect(late.batch.id, list[1].id);
    });

    test(
      'watchAllActive excludes empty, non-active and archived-less rows',
      () async {
        final a = await env.addBatch(env.batchInput(med, number: 'A'));
        final b = await env.addBatch(
          env.batchInput(
            med,
            number: 'B',
            quantity: 1,
            expiry: ExpiryDate.monthYear(2026, 12),
          ),
        );
        await env.adjustStock(
          batchId: b.batch.id,
          delta: -1,
          reason: AdjustmentReason.sold,
        );
        final active = await env.batches.watchAllActive().first;
        expect(active.map((x) => x.batch.id), [a.batch.id]);
        expect(active.single.medicine.id, med);
      },
    );

    test('findByMedicineAndNumber is scoped to the medicine', () async {
      final other = await env.medicine(brand: 'Other');
      await env.addBatch(env.batchInput(med, number: 'A1'));
      await env.addBatch(env.batchInput(other, number: 'A1'));
      expect(
        await env.batches.findByMedicineAndNumber(med, 'A1'),
        hasLength(1),
      );
      expect(await env.batches.findByMedicineAndNumber(med, 'ZZ'), isEmpty);
    });
  });
}
