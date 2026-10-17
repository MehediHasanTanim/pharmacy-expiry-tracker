import 'package:drift/drift.dart' hide Batch;
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/mappers/mappers.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/batch_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/transaction_runner.dart';

class BatchRepositoryImpl implements BatchRepository {
  BatchRepositoryImpl(this._db);

  final AppDatabase _db;

  $BatchesTable get _b => _db.batches;

  @override
  Future<Batch?> getById(String id) async {
    final row = await (_db.select(
      _b,
    )..where((b) => b.id.equals(id) & b.deletedAt.isNull())).getSingleOrNull();
    return row?.toEntity();
  }

  @override
  Stream<Batch?> watchById(String id) {
    return (_db.select(_b)
          ..where((b) => b.id.equals(id) & b.deletedAt.isNull()))
        .watchSingleOrNull()
        .map((r) => r?.toEntity());
  }

  @override
  Future<List<Batch>> findByMedicineAndNumber(
    String medicineId,
    String batchNumber,
  ) async {
    final rows =
        await (_db.select(_b)
              ..where(
                (b) =>
                    b.medicineId.equals(medicineId) &
                    b.batchNumber.equals(batchNumber) &
                    b.deletedAt.isNull(),
              )
              ..orderBy([(b) => OrderingTerm.asc(b.expiryDate)]))
            .get();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<Batch?> findExact(
    String medicineId,
    String batchNumber,
    ExpiryDate expiry, {
    String? excludeId,
  }) async {
    final row =
        await (_db.select(_b)..where(
              (b) =>
                  b.medicineId.equals(medicineId) &
                  b.batchNumber.equals(batchNumber) &
                  b.expiryDate.equals(expiry.toIso()) &
                  b.deletedAt.isNull() &
                  (excludeId == null
                      ? const Constant(true)
                      : b.id.equals(excludeId).not()),
            ))
            .getSingleOrNull();
    return row?.toEntity();
  }

  @override
  Stream<List<Batch>> watchByMedicine(String medicineId) {
    final stmt = _db.select(_b)
      ..where((b) => b.medicineId.equals(medicineId) & b.deletedAt.isNull())
      ..orderBy([(b) => OrderingTerm.asc(b.expiryDate)]);
    return stmt.watch().map((rows) {
      final batches = rows.map((r) => r.toEntity()).toList();
      // In-stock batches first (already by expiry), depleted ones last.
      return [
        ...batches.where((b) => b.quantityOnHand > 0),
        ...batches.where((b) => b.quantityOnHand == 0),
      ];
    });
  }

  @override
  Stream<List<BatchWithMedicine>> watchAllActive() {
    final stmt =
        _db.select(_b).join([
            innerJoin(_db.medicines, _db.medicines.id.equalsExp(_b.medicineId)),
          ])
          ..where(
            _b.deletedAt.isNull() &
                _b.quantityOnHand.isBiggerThanValue(0) &
                _b.status.equals(BatchStatus.active.db) &
                _db.medicines.deletedAt.isNull(),
          )
          ..orderBy([OrderingTerm.asc(_b.expiryDate)]);
    return stmt.watch().map(
      (rows) => [
        for (final r in rows)
          BatchWithMedicine(
            batch: r.readTable(_b).toEntity(),
            medicine: r.readTable(_db.medicines).toEntity(),
          ),
      ],
    );
  }

  @override
  Future<void> insert(Batch batch) =>
      _db.into(_b).insert(batchCompanion(batch));

  @override
  Future<void> update(Batch batch) async {
    final updated =
        await (_db.update(_b)
              ..where((b) => b.id.equals(batch.id) & b.deletedAt.isNull()))
            .write(batchCompanion(batch));
    if (updated == 0) throw NotFoundException('batch', batch.id);
  }

  @override
  Future<void> updateQuantity(
    String id, {
    required int onHand,
    required int received,
    required BatchStatus status,
    required DateTime at,
  }) async {
    final updated =
        await (_db.update(
          _b,
        )..where((b) => b.id.equals(id) & b.deletedAt.isNull())).write(
          BatchesCompanion(
            quantityOnHand: Value(onHand),
            quantityReceived: Value(received),
            status: Value(status.db),
            updatedAt: Value(at.millisecondsSinceEpoch),
          ),
        );
    if (updated == 0) throw NotFoundException('batch', id);
  }

  @override
  Future<void> setAlertState(
    String id, {
    required DateTime? snoozedUntil,
    required DateTime? handledAt,
    required DateTime at,
  }) async {
    final updated =
        await (_db.update(
          _b,
        )..where((b) => b.id.equals(id) & b.deletedAt.isNull())).write(
          BatchesCompanion(
            snoozedUntil: Value(
              snoozedUntil == null ? null : dateToIso(snoozedUntil),
            ),
            handledAt: Value(handledAt?.millisecondsSinceEpoch),
            updatedAt: Value(at.millisecondsSinceEpoch),
          ),
        );
    if (updated == 0) throw NotFoundException('batch', id);
  }

  @override
  Future<void> insertAdjustment(StockAdjustment adjustment) =>
      _db.into(_db.stockAdjustments).insert(adjustmentCompanion(adjustment));

  @override
  Stream<List<StockAdjustment>> watchAdjustments(String batchId) {
    return (_db.select(_db.stockAdjustments)
          ..where((a) => a.batchId.equals(batchId))
          ..orderBy([
            (a) => OrderingTerm.desc(a.createdAt),
            // Same-millisecond entries keep insertion order.
            (a) => OrderingTerm.desc(const CustomExpression<int>('rowid')),
          ]))
        .watch()
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }
}

class DriftTransactionRunner implements TransactionRunner {
  DriftTransactionRunner(this._db);

  final AppDatabase _db;

  @override
  Future<T> run<T>(Future<T> Function() action) => _db.transaction(action);
}
