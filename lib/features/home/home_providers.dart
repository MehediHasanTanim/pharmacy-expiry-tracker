import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/expiry.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/reorder.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/expiry_bucket.dart';

/// The expiry query behind the dashboard: the user's window and urgency
/// thresholds, with no filters (the Expiry tab's own filters do not apply).
final homeExpiryQueryProvider = Provider<ExpiryQuery>((ref) {
  final today = ref.watch(todayDateProvider);
  final s = ref.watch(settingsProvider).value ?? const AppSettings();
  return ExpiryQuery(
    today: today,
    globalWindowDays: s.nearExpiryWindowDays,
    thresholds: s.bucketThresholds,
  );
});

/// Counts and values per urgency bucket for the dashboard cards and the app
/// badge.
final homeExpirySummaryProvider = StreamProvider.autoDispose<ExpirySummary>(
  (ref) => ref
      .watch(expiryRepositoryProvider)
      .watchSummary(ref.watch(homeExpiryQueryProvider)),
);

/// Batches expiring in the next seven days, soonest first (HOM-3).
final expiringThisWeekProvider = StreamProvider.autoDispose<List<ExpiryItem>>((
  ref,
) async* {
  final repo = ref.watch(expiryRepositoryProvider);
  final base = ref.watch(homeExpiryQueryProvider);
  final query = ExpiryQuery(
    today: base.today,
    globalWindowDays: base.globalWindowDays,
    thresholds: base.thresholds,
    filter: const ExpiryFilter(fromDays: 0, toDays: 7),
  );
  Future<List<ExpiryItem>> load() async =>
      (await repo.fetchPage(query, limit: 5)).items;
  yield await load();
  await for (final _ in repo.watchChanges()) {
    yield await load();
  }
});

/// Medicines below their reorder level.
final reorderItemsProvider = StreamProvider.autoDispose<List<ReorderItem>>(
  (ref) => ref
      .watch(reorderRepositoryProvider)
      .watchBelowLevel(today: ref.watch(todayDateProvider)),
);

/// What needs doing now: expired stock plus the most urgent group. Drives the
/// app icon badge (HOM / S5-10).
int needsActionCount(ExpirySummary s) =>
    s.count(ExpiryBucket.expired) + s.count(ExpiryBucket.d30);
