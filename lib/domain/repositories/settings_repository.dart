import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';

abstract interface class SettingsRepository {
  /// Emits the current settings, and again after every change.
  Stream<AppSettings> watch();

  Future<AppSettings> load();

  Future<void> save(AppSettings settings);

  /// Reads, applies [change], and saves in one step.
  Future<AppSettings> update(AppSettings Function(AppSettings current) change);
}
