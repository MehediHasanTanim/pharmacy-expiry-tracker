import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/search_repository.dart';

typedef MedicineListArgs = ({String query, bool includeArchived});

final medicineListProvider = StreamProvider.autoDispose
    .family<List<MedicineSummary>, MedicineListArgs>(
      (ref, args) => ref
          .watch(medicineRepositoryProvider)
          .watchAll(query: args.query, includeArchived: args.includeArchived),
    );

final medicineProvider = StreamProvider.autoDispose.family<Medicine?, String>(
  (ref, id) => ref.watch(medicineRepositoryProvider).watchById(id),
);

final batchesByMedicineProvider = StreamProvider.autoDispose
    .family<List<Batch>, String>(
      (ref, id) => ref.watch(batchRepositoryProvider).watchByMedicine(id),
    );

final batchProvider = StreamProvider.autoDispose.family<Batch?, String>(
  (ref, id) => ref.watch(batchRepositoryProvider).watchById(id),
);

final adjustmentsProvider = StreamProvider.autoDispose
    .family<List<StockAdjustment>, String>(
      (ref, batchId) =>
          ref.watch(batchRepositoryProvider).watchAdjustments(batchId),
    );

/// Search results; re-run whenever committed data changes.
final searchResultsProvider = FutureProvider.autoDispose
    .family<SearchResults, String>((ref, query) {
      ref.watch(dataChangesProvider);
      return ref.watch(searchRepositoryProvider).search(query);
    });

final recentSearchesProvider = FutureProvider.autoDispose<List<String>>(
  (ref) => ref.watch(recentSearchesRepositoryProvider).load(),
);

/// Remembers the last "received on" date between consecutive batch entries
/// (BAT-7).
class LastReceivedDate extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void remember(DateTime date) => state = date;
}

final lastReceivedDateProvider = NotifierProvider<LastReceivedDate, DateTime?>(
  LastReceivedDate.new,
);
