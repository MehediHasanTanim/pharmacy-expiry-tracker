import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/data/background/alert_background.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/alert_store_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/batch_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/expiry_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/medicine_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/search_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/settings_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/services/alert_engine_factory.dart';
import 'package:pharmacy_expiry_tracker/data/services/local_notification_plugin.dart';
import 'package:pharmacy_expiry_tracker/data/services/platform_alert_settings_impl.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_engine.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_records.dart';
import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/notification_plugin.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/platform_alert_settings.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/alert_store.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/batch_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/expiry_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/medicine_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/search_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/settings_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/transaction_runner.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/batch_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/expiry_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/medicine_usecases.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(databaseProvider)),
);

final settingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

/// Currency symbol from settings; empty means "show the bare amount".
final currencySymbolProvider = Provider<String>(
  (ref) =>
      ref.watch(settingsProvider.select((s) => s.value?.currencySymbol ?? '')),
);

/// Committed data changes, for components that react to them (search refresh
/// now, the alert engine from Sprint 3).
final dataChangeBusProvider = Provider<DataChangeBus>((ref) {
  final bus = DataChangeBus();
  ref.onDispose(bus.dispose);
  return bus;
});

final dataChangesProvider = StreamProvider<DataChange>(
  (ref) => ref.watch(dataChangeBusProvider).changes,
);

final medicineRepositoryProvider = Provider<MedicineRepository>(
  (ref) => MedicineRepositoryImpl(
    ref.watch(databaseProvider),
    ref.watch(clockProvider),
  ),
);

final batchRepositoryProvider = Provider<BatchRepository>(
  (ref) => BatchRepositoryImpl(ref.watch(databaseProvider)),
);

final transactionRunnerProvider = Provider<TransactionRunner>(
  (ref) => DriftTransactionRunner(ref.watch(databaseProvider)),
);

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepositoryImpl(ref.watch(databaseProvider)),
);

final recentSearchesRepositoryProvider = Provider<RecentSearchesRepository>(
  (ref) => RecentSearchesRepositoryImpl(ref.watch(databaseProvider)),
);

final saveMedicineProvider = Provider<SaveMedicine>(
  (ref) => SaveMedicine(
    ref.watch(medicineRepositoryProvider),
    ref.watch(dataChangeBusProvider),
  ),
);

final setMedicineArchivedProvider = Provider<SetMedicineArchived>(
  (ref) => SetMedicineArchived(
    ref.watch(medicineRepositoryProvider),
    ref.watch(dataChangeBusProvider),
  ),
);

final addBatchProvider = Provider<AddBatch>(
  (ref) => AddBatch(
    batches: ref.watch(batchRepositoryProvider),
    medicines: ref.watch(medicineRepositoryProvider),
    transaction: ref.watch(transactionRunnerProvider),
    clock: ref.watch(clockProvider),
    bus: ref.watch(dataChangeBusProvider),
  ),
);

final editBatchProvider = Provider<EditBatch>(
  (ref) => EditBatch(
    batches: ref.watch(batchRepositoryProvider),
    transaction: ref.watch(transactionRunnerProvider),
    clock: ref.watch(clockProvider),
    bus: ref.watch(dataChangeBusProvider),
  ),
);

final adjustStockProvider = Provider<AdjustStock>(
  (ref) => AdjustStock(
    batches: ref.watch(batchRepositoryProvider),
    transaction: ref.watch(transactionRunnerProvider),
    clock: ref.watch(clockProvider),
    bus: ref.watch(dataChangeBusProvider),
  ),
);

final expiryRepositoryProvider = Provider<ExpiryRepository>(
  (ref) => ExpiryRepositoryImpl(ref.watch(databaseProvider)),
);

final updateAlertStateProvider = Provider<UpdateAlertState>(
  (ref) => UpdateAlertState(
    batches: ref.watch(batchRepositoryProvider),
    clock: ref.watch(clockProvider),
    bus: ref.watch(dataChangeBusProvider),
  ),
);

final discardBatchesProvider = Provider<DiscardBatches>(
  (ref) => DiscardBatches(
    batches: ref.watch(batchRepositoryProvider),
    adjustStock: ref.watch(adjustStockProvider),
    transaction: ref.watch(transactionRunnerProvider),
  ),
);

/// The OS notification scheduler. Overridden with a fake in tests.
final notificationPluginProvider = Provider<NotificationPlugin>(
  (ref) => LocalNotificationPlugin(),
);

final platformAlertSettingsProvider = Provider<PlatformAlertSettings>(
  (ref) => MethodChannelPlatformAlertSettings(),
);

final alertStoreProvider = Provider<AlertStore>(
  (ref) => AlertStoreImpl(ref.watch(databaseProvider)),
);

final alertSourceProvider = Provider<AlertSource>(
  (ref) => AlertSourceImpl(ref.watch(databaseProvider)),
);

/// Whether the alert engine runs at all. Tests that exercise screens, not
/// alerts, switch it off.
final alertEngineEnabledProvider = Provider<bool>((ref) => true);

final alertEngineProvider = Provider<AlertEngine>(
  (ref) => createAlertEngine(
    db: ref.watch(databaseProvider),
    plugin: ref.watch(notificationPluginProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Registers the periodic background re-plan. Replaced in tests.
final backgroundReplanRegistrarProvider = Provider<Future<void> Function()>(
  (ref) => AlertBackground.register,
);

/// Re-plans alerts when data or settings change. Reading this provider starts
/// listening.
final alertCoordinatorProvider = Provider<AlertCoordinator>((ref) {
  final coordinator = AlertCoordinator(ref.watch(alertEngineProvider))
    ..listenTo(ref.watch(dataChangeBusProvider).changes)
    ..listenTo(ref.watch(settingsRepositoryProvider).watch());
  ref.onDispose(() => unawaited(coordinator.dispose()));
  return coordinator;
});

/// Result of each completed alert pass, newest last.
final replanResultsProvider = StreamProvider<ReplanSummary>(
  (ref) => ref.watch(alertCoordinatorProvider).results,
);

/// Current notification / exact-alarm permission. Invalidate to re-check
/// (the app does when it returns to the foreground).
final notificationPermissionsProvider =
    FutureProvider.autoDispose<NotificationPermissions>(
      (ref) => ref.watch(notificationPluginProvider).permissions(),
    );

final deviceAlertConditionsProvider =
    FutureProvider.autoDispose<DeviceAlertConditions>(
      (ref) => ref.watch(platformAlertSettingsProvider).conditions(),
    );

final alertLogProvider = StreamProvider.autoDispose<List<AlertLogEntry>>(
  (ref) => ref.watch(alertStoreProvider).watchLog(),
);

final pendingAlertCountProvider = StreamProvider.autoDispose<int>(
  (ref) => ref.watch(alertStoreProvider).watchPendingCount(),
);
