import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/db/database_bootstrap.dart';
import 'package:pharmacy_expiry_tracker/data/db/migration_guard.dart';
import 'package:pharmacy_expiry_tracker/data/services/alert_engine_factory.dart';
import 'package:pharmacy_expiry_tracker/data/services/local_notification_plugin.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/notification_plugin.dart';
import 'package:workmanager/workmanager.dart';

/// Name of the periodic background re-plan.
const alertReplanTask = 'com.pharmacytracker.alert_replan';

/// Runs one alert pass without the UI: opens its own database and scheduler,
/// plans, and closes. Returns whether the pass succeeded (so the OS can retry
/// a failure). Pass [database]/[plugin] only from tests.
Future<bool> runBackgroundReplan({
  AppDatabase? database,
  NotificationPlugin? plugin,
  Clock clock = const SystemClock(),
}) async {
  if (database == null) {
    // An upgrade may be pending if the app was updated but not yet opened.
    try {
      await prepareDatabase();
    } on MigrationFailedException {
      return false;
    }
  }
  final db = database ?? AppDatabase.open();
  try {
    final scheduler = plugin ?? LocalNotificationPlugin();
    await scheduler.initialize(onSelected: (_) {});
    final summary = await createAlertEngine(
      db: db,
      plugin: scheduler,
      clock: clock,
    ).replan();
    return summary.ok;
  } on Object catch (e, st) {
    debugPrint('Background alert pass failed: $e\n$st');
    return false;
  } finally {
    if (database == null) await db.close();
  }
}

/// Entry point the OS invokes in a headless isolate (S3-09).
@pragma('vm:entry-point')
void alertBackgroundDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != alertReplanTask) return true;
    return runBackgroundReplan();
  });
}

/// Registers the periodic re-plan. It keeps alerts fresh when the app has not
/// been opened for a while: it picks up the passing of time (new days come
/// into range, the rolling window refills) and survives a reboot, since
/// WorkManager re-registers its jobs itself.
///
/// Android only. It cannot notice a time-zone or clock change the moment it
/// happens (that would need a native receiver); the next run or app launch
/// does. iOS background refresh is not set up.
abstract final class AlertBackground {
  static const period = Duration(hours: 12);

  static Future<void> register() async {
    if (!Platform.isAndroid) return;
    try {
      await Workmanager().initialize(alertBackgroundDispatcher);
      await Workmanager().registerPeriodicTask(
        alertReplanTask,
        alertReplanTask,
        frequency: period,
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
        constraints: Constraints(networkType: NetworkType.notRequired),
      );
    } on Object catch (e) {
      // Not fatal: alerts are still re-planned whenever the app opens.
      debugPrint('Could not register the background re-plan: $e');
    }
  }
}
