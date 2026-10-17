import 'package:drift/drift.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/text/search_text.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/db/sql_helpers.dart';
import 'package:pharmacy_expiry_tracker/data/mappers/mappers.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/summary_query.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/medicine_repository.dart';
import 'package:uuid/uuid.dart';

String medicineSearchText(MedicineInput i) => normalizeSearchText(
  '${i.brandName} ${i.genericName ?? ''} ${i.strength ?? ''}',
);

class MedicineRepositoryImpl implements MedicineRepository {
  MedicineRepositoryImpl(this._db, this._clock, {String Function()? newId})
    : _newId = newId ?? (() => const Uuid().v4());

  final AppDatabase _db;
  final Clock _clock;
  final String Function() _newId;

  @override
  Stream<List<MedicineSummary>> watchAll({
    String query = '',
    bool includeArchived = false,
  }) {
    final q = MedicineSummaryQuery(_db);
    final m = _db.medicines;
    final terms = normalizeSearchText(query)
        .split(' ')
        .where((t) => t.isNotEmpty)
        .toList();
    q.statement
      ..where(
        m.deletedAt.isNull() &
            (includeArchived
                ? const Constant(true)
                : m.isArchived.equals(false)) &
            terms.fold<Expression<bool>>(
              const Constant(true),
              (acc, t) => acc & containsLiteral(m.searchText, t),
            ),
      )
      ..orderBy([OrderingTerm.asc(m.searchText)]);
    return q.statement.watch().map((rows) => rows.map(q.map).toList());
  }

  @override
  Stream<Medicine?> watchById(String id) {
    return (_db.select(_db.medicines)
          ..where((m) => m.id.equals(id) & m.deletedAt.isNull()))
        .watchSingleOrNull()
        .map((r) => r?.toEntity());
  }

  @override
  Future<Medicine?> getById(String id) async {
    final row = await (_db.select(
      _db.medicines,
    )..where((m) => m.id.equals(id) & m.deletedAt.isNull())).getSingleOrNull();
    return row?.toEntity();
  }

  @override
  Future<String> create(MedicineInput input) async {
    final id = _newId();
    final now = _clock.now();
    final companion =
        medicineCompanion(
          input,
          searchText: medicineSearchText(input),
          now: now,
          id: id,
        ).copyWith(
          createdAt: Value(now.millisecondsSinceEpoch),
          isArchived: const Value(false),
        );
    await _db.into(_db.medicines).insert(companion);
    return id;
  }

  @override
  Future<void> update(String id, MedicineInput input) async {
    final updated =
        await (_db.update(
          _db.medicines,
        )..where((m) => m.id.equals(id) & m.deletedAt.isNull())).write(
          medicineCompanion(
            input,
            searchText: medicineSearchText(input),
            now: _clock.now(),
          ),
        );
    if (updated == 0) throw NotFoundException('medicine', id);
  }

  @override
  Future<void> setArchived(String id, {required bool archived}) async {
    final updated =
        await (_db.update(
          _db.medicines,
        )..where((m) => m.id.equals(id) & m.deletedAt.isNull())).write(
          MedicinesCompanion(
            isArchived: Value(archived),
            updatedAt: Value(_clock.now().millisecondsSinceEpoch),
          ),
        );
    if (updated == 0) throw NotFoundException('medicine', id);
  }

  @override
  Future<Medicine?> findDuplicate({
    required String brandName,
    required DosageForm dosageForm,
    String? strength,
    String? excludeId,
  }) async {
    final brand = brandName.trim().toLowerCase();
    final str = (strength ?? '').trim().toLowerCase();
    final rows =
        await (_db.select(_db.medicines)..where(
              (m) =>
                  m.brandName.lower().equals(brand) &
                  m.dosageForm.equals(dosageForm.name) &
                  m.deletedAt.isNull(),
            ))
            .get();
    for (final r in rows) {
      if (r.id == excludeId) continue;
      if ((r.strength ?? '').trim().toLowerCase() == str) return r.toEntity();
    }
    return null;
  }
}
