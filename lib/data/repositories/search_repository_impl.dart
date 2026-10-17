import 'package:drift/drift.dart' hide Batch;
import 'package:pharmacy_expiry_tracker/core/text/search_text.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/db/sql_helpers.dart';
import 'package:pharmacy_expiry_tracker/data/mappers/mappers.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/summary_query.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<SearchResults> search(String query, {int limit = 30}) async {
    final normalized = normalizeSearchText(query);
    if (normalized.isEmpty) return SearchResults.empty;
    final medicines = await _searchMedicines(normalized, limit);
    final batches = await _searchBatches(normalizeBatchNumber(query), limit);
    return SearchResults(medicines: medicines, batches: batches);
  }

  /// Ranked: prefix of the first word > word-prefix > anywhere. All words
  /// must appear.
  Future<List<MedicineSummary>> _searchMedicines(
    String normalized,
    int limit,
  ) async {
    final terms = normalized.split(' ');
    final first = terms.first;
    final m = _db.medicines;

    Expression<bool> base() => terms
        .skip(1)
        .fold<Expression<bool>>(
          m.deletedAt.isNull() &
              m.isArchived.equals(false) &
              containsLiteral(m.searchText, first),
          (acc, t) => acc & containsLiteral(m.searchText, t),
        );

    final prefix = m.searchText.substr(1, first.length).equals(first);
    final wordPrefix = containsLiteral(m.searchText, ' $first');

    final ids = <String>[];
    Future<void> tier(Expression<bool> extra) async {
      if (ids.length >= limit) return;
      final rows =
          await (_db.selectOnly(m)
                ..addColumns([m.id])
                ..where(base() & extra)
                ..orderBy([OrderingTerm.asc(m.searchText)])
                ..limit(limit))
              .map((r) => r.read(m.id)!)
              .get();
      for (final id in rows) {
        if (ids.length < limit && !ids.contains(id)) ids.add(id);
      }
    }

    await tier(prefix);
    await tier(wordPrefix);
    await tier(const Constant(true));
    if (ids.isEmpty) return const [];

    final q = MedicineSummaryQuery(_db);
    q.statement.where(m.id.isIn(ids));
    final byId = {
      for (final s in (await q.statement.get()).map(q.map)) s.medicine.id: s,
    };
    return [for (final id in ids) byId[id]!];
  }

  Future<List<BatchWithMedicine>> _searchBatches(
    String batchNumber,
    int limit,
  ) async {
    if (batchNumber.isEmpty) return const [];
    final b = _db.batches;
    final m = _db.medicines;

    final ids = <String>[];
    Future<void> tier(Expression<bool> extra) async {
      if (ids.length >= limit) return;
      final rows =
          await (_db.selectOnly(b)
                ..addColumns([b.id])
                ..where(
                  b.deletedAt.isNull() &
                      containsLiteral(b.batchNumber, batchNumber) &
                      extra,
                )
                ..orderBy([
                  OrderingTerm.asc(b.batchNumber),
                  OrderingTerm.asc(b.expiryDate),
                ])
                ..limit(limit))
              .map((r) => r.read(b.id)!)
              .get();
      for (final id in rows) {
        if (ids.length < limit && !ids.contains(id)) ids.add(id);
      }
    }

    await tier(b.batchNumber.substr(1, batchNumber.length).equals(batchNumber));
    await tier(const Constant(true));
    if (ids.isEmpty) return const [];

    final rows = await (_db.select(b).join([
      innerJoin(m, m.id.equalsExp(b.medicineId)),
    ])..where(b.id.isIn(ids) & m.deletedAt.isNull())).get();
    final byId = {
      for (final r in rows)
        r.readTable(b).id: BatchWithMedicine(
          batch: r.readTable(b).toEntity(),
          medicine: r.readTable(m).toEntity(),
        ),
    };
    return [
      for (final id in ids)
        if (byId[id] != null) byId[id]!,
    ];
  }
}

class RecentSearchesRepositoryImpl implements RecentSearchesRepository {
  RecentSearchesRepositoryImpl(this._db, {this.max = 8});

  static const _key = 'recent_searches';
  final AppDatabase _db;
  final int max;

  @override
  Future<List<String>> load() async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(_key))).getSingleOrNull();
    if (row == null || row.value.isEmpty) return const [];
    return row.value.split('\n');
  }

  @override
  Future<void> add(String term) async {
    final t = term.trim().replaceAll('\n', ' ');
    if (t.isEmpty) return;
    final current = await load();
    final next = [
      t,
      ...current.where((e) => e.toLowerCase() != t.toLowerCase()),
    ].take(max).toList();
    await _write(next.join('\n'));
  }

  @override
  Future<void> clear() => _write('');

  Future<void> _write(String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(key: _key, value: value),
      );
}
