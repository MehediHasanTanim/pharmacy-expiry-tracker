import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/expiry.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/expiry_bucket.dart';

/// Bucket chip currently selected on the Expiry tab (null = all).
class ExpiryBucketSelection extends Notifier<ExpiryBucket?> {
  @override
  ExpiryBucket? build() => null;

  void select(ExpiryBucket? bucket) => state = bucket;
}

final expiryBucketProvider =
    NotifierProvider<ExpiryBucketSelection, ExpiryBucket?>(
      ExpiryBucketSelection.new,
    );

/// Free-text search on the Expiry tab.
class ExpirySearchText extends Notifier<String> {
  @override
  String build() => '';

  void set(String text) => state = text.trim();
}

final expirySearchProvider = NotifierProvider<ExpirySearchText, String>(
  ExpirySearchText.new,
);

/// Batches ticked in selection mode; null when not selecting (S2-08).
class ExpirySelection extends Notifier<Set<String>?> {
  @override
  Set<String>? build() => null;

  void start() => state = <String>{};

  void cancel() => state = null;

  void toggle(String id) {
    final current = state;
    if (current == null) return;
    state = current.contains(id)
        ? ({...current}..remove(id))
        : {...current, id};
  }
}

final expirySelectionProvider = NotifierProvider<ExpirySelection, Set<String>?>(
  ExpirySelection.new,
);

/// Everything the expiry queries depend on, assembled from settings, today's
/// date (so it refreshes at midnight) and the tab's own state.
final expiryQueryProvider = Provider<ExpiryQuery>((ref) {
  final today = ref.watch(todayDateProvider);
  final s = ref.watch(settingsProvider).value ?? const AppSettings();
  final bucket = ref.watch(expiryBucketProvider);
  final text = ref.watch(expirySearchProvider);
  return ExpiryQuery(
    today: today,
    globalWindowDays: s.nearExpiryWindowDays,
    thresholds: s.bucketThresholds,
    sort: ExpirySort.fromStored(s.expirySort),
    filter: ExpiryFilter(
      bucket: bucket,
      query: text,
      category: s.expiryCategory.isEmpty ? null : s.expiryCategory,
      form: s.expiryForm.isEmpty ? null : DosageForm.fromDb(s.expiryForm),
      hideHandled: s.expiryHideHandled,
    ),
  );
});

final expirySummaryProvider = StreamProvider.autoDispose<ExpirySummary>((ref) {
  final repo = ref.watch(expiryRepositoryProvider);
  return repo.watchSummary(ref.watch(expiryQueryProvider));
});

final expiryCategoriesProvider = FutureProvider.autoDispose<List<String>>(
  (ref) => ref.watch(expiryRepositoryProvider).categories(),
);

@immutable
class ExpiryList {
  const ExpiryList(this.items, this.next, {this.loadingMore = false});

  final List<ExpiryItem> items;

  /// Cursor for the next page; null when everything is loaded.
  final ExpiryCursor? next;
  final bool loadingMore;

  bool get hasMore => next != null;

  ExpiryList copyWith({
    List<ExpiryItem>? items,
    ExpiryCursor? next,
    bool? loadingMore,
    bool clearNext = false,
  }) {
    return ExpiryList(
      items ?? this.items,
      clearNext ? null : next ?? this.next,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

/// The paged Expiry list. Reloads from the first page whenever the query or
/// the underlying data changes; further pages load on demand.
class ExpiryListController extends AsyncNotifier<ExpiryList> {
  static const pageSize = 50;

  @override
  Future<ExpiryList> build() async {
    final query = ref.watch(expiryQueryProvider);
    final repo = ref.watch(expiryRepositoryProvider);
    final changes = repo.watchChanges().listen((_) => ref.invalidateSelf());
    ref.onDispose(() => unawaited(changes.cancel()));
    final page = await repo.fetchPage(query);
    return ExpiryList(page.items, page.next);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    final loading = current.copyWith(loadingMore: true);
    state = AsyncData(loading);
    final query = ref.read(expiryQueryProvider);
    final page = await ref
        .read(expiryRepositoryProvider)
        .fetchPage(query, after: current.next);
    // If the list was reloaded meanwhile (query or data changed), this page
    // belongs to a stale list: drop it.
    if (!identical(state.value, loading)) return;
    state = AsyncData(ExpiryList([...current.items, ...page.items], page.next));
  }
}

final expiryListProvider =
    AsyncNotifierProvider.autoDispose<ExpiryListController, ExpiryList>(
      ExpiryListController.new,
    );
