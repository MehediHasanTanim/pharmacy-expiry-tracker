import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/batch_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/expiry_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/medicine_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/search_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/settings_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/services/local_notification_plugin.dart';
import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/notification_plugin.dart';
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
