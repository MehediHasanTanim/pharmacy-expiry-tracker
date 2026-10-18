import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/draft_store.dart';

/// Keeps drafts in the settings table under a `draft:` prefix, so they are
/// part of backups and need no extra table.
class DraftStoreImpl implements DraftStore {
  DraftStoreImpl(this._db);

  final AppDatabase _db;

  String _k(String key) => 'draft:$key';

  @override
  Future<String?> load(String key) async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(_k(key)))).getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> save(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(key: _k(key), value: value),
      );

  @override
  Future<void> clear(String key) =>
      (_db.delete(_db.settings)..where((s) => s.key.equals(_k(key)))).go();
}
