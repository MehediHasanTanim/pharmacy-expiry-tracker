import 'dart:ui' show Locale;

import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/alert_store_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/batch_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/settings_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_engine.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_scheduler.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/notification_plugin.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Loads the strings alerts are written in, with no `BuildContext` — the
/// background task has none.
Future<AppLocalizations> loadAlertStrings(AppSettings settings) =>
    AppLocalizations.delegate.load(Locale(settings.languageCode));

/// Builds the alert engine from the bare pieces. Used by the running app and,
/// identically, by the background task, so both plan the same way.
AlertEngine createAlertEngine({
  required AppDatabase db,
  required NotificationPlugin plugin,
  required Clock clock,
}) {
  final store = AlertStoreImpl(db);
  return AlertEngine(
    settings: SettingsRepositoryImpl(db),
    source: AlertSourceImpl(db),
    store: store,
    scheduler: AlertScheduler(
      plugin: plugin,
      store: store,
      transaction: DriftTransactionRunner(db),
    ),
    plugin: plugin,
    clock: clock,
    loadL10n: loadAlertStrings,
  );
}
