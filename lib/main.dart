import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pharmacy_expiry_tracker/app/app.dart';
import 'package:pharmacy_expiry_tracker/app/error_ui.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/logging/error_log.dart';
import 'package:pharmacy_expiry_tracker/data/backup/backup_service.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/db/database_bootstrap.dart';
import 'package:pharmacy_expiry_tracker/data/db/db_encryption.dart';
import 'package:pharmacy_expiry_tracker/data/db/migration_guard.dart';
import 'package:pharmacy_expiry_tracker/data/security/db_key_store.dart';

/// Flavor is chosen with `--flavor dev|prod` and read from `appFlavor`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final support = await getApplicationSupportDirectory();
  final log = ErrorLog(File(p.join(support.path, 'logs', 'errors.log')));
  FlutterError.onError = (details) {
    log.record('flutter', details.exception, details.stack);
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    log.record('platform', error, stack);
    return true;
  };
  if (kReleaseMode) {
    ErrorWidget.builder = (_) => const FriendlyError();
  }

  final file = await AppDatabase.defaultFile();
  await _housekeeping(file);
  String? dbKey;
  try {
    dbKey = await prepareDatabase(
      keys: const SecureDatabaseKeyStore(),
      file: file,
    );
  } on DatabaseKeyMissingException catch (e) {
    log.record('database-key', e);
    runApp(const StartupFailedApp(keyMissing: true));
    return;
  } on MigrationFailedException catch (e) {
    // The old data is back in place; do not open it with a half-working app.
    log.record('migration', e.cause);
    runApp(const StartupFailedApp());
    return;
  }

  final info = await PackageInfo.fromPlatform();
  runApp(
    ProviderScope(
      overrides: [
        appVersionProvider.overrideWithValue(
          '${info.version}+${info.buildNumber}',
        ),
        databaseFileProvider.overrideWithValue(file),
        databaseKeyProvider.overrideWithValue(dbKey),
        errorLogProvider.overrideWithValue(log),
      ],
      child: const App(),
    ),
  );
}

/// Removes what earlier runs left behind: old safety copies of the database
/// (kept 24 hours after a restore) and staged backup and export files.
Future<void> _housekeeping(File databaseFile) async {
  try {
    await BackupService.purgeSafetyCopies(databaseFile, DateTime.now());
    for (final name in const ['pharmacy_backup', 'pharmacy_export']) {
      final dir = Directory(p.join(Directory.systemTemp.path, name));
      if (dir.existsSync()) await dir.delete(recursive: true);
    }
  } on Object catch (e) {
    debugPrint('Housekeeping skipped: $e');
  }
}
