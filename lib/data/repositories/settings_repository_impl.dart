import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._db);

  final AppDatabase _db;

  static AppSettings _fromRows(List<Setting> rows) =>
      AppSettings.fromMap({for (final r in rows) r.key: r.value});

  @override
  Stream<AppSettings> watch() =>
      _db.select(_db.settings).watch().map(_fromRows).distinct();

  @override
  Future<AppSettings> load() async =>
      _fromRows(await _db.select(_db.settings).get());

  @override
  Future<void> save(AppSettings settings) async {
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(_db.settings, [
        for (final e in settings.toMap().entries)
          SettingsCompanion.insert(key: e.key, value: e.value),
      ]);
    });
  }

  @override
  Future<AppSettings> update(AppSettings Function(AppSettings current) change) {
    return _db.transaction(() async {
      final next = change(await load());
      await save(next);
      return next;
    });
  }
}
