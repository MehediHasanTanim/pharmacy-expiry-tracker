import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/app/theme.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/expiry.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/expiry_bucket.dart';
import 'package:pharmacy_expiry_tracker/features/common/search_field.dart';
import 'package:pharmacy_expiry_tracker/features/expiry/expiry_actions.dart';
import 'package:pharmacy_expiry_tracker/features/expiry/expiry_filter_sheet.dart';
import 'package:pharmacy_expiry_tracker/features/expiry/expiry_providers.dart';
import 'package:pharmacy_expiry_tracker/features/expiry/expiry_row.dart';
import 'package:pharmacy_expiry_tracker/features/expiry/expiry_share.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/return_screen.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// The main workflow screen: batches that are near expiry or already expired,
/// grouped by urgency, with filters, sorting and per-row actions.
class ExpiryScreen extends ConsumerStatefulWidget {
  const ExpiryScreen({this.bucket, this.date, super.key});

  /// Deep-link filters (`?bucket=d30`), e.g. from a notification.
  final String? bucket;
  final String? date;

  @override
  ConsumerState<ExpiryScreen> createState() => _ExpiryScreenState();
}

class _ExpiryScreenState extends ConsumerState<ExpiryScreen> {
  final _scroll = ScrollController();
  final _search = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _applyDeepLink();
  }

  @override
  void didUpdateWidget(ExpiryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bucket != widget.bucket) _applyDeepLink();
  }

  /// Preselects the bucket from a `?bucket=` link, e.g. a tapped alert.
  void _applyDeepLink() {
    final wanted = ExpiryBucket.values
        .where((b) => b.name == widget.bucket)
        .firstOrNull;
    // Providers may not be modified while the tree is building.
    unawaited(
      Future.microtask(
        () => ref.read(expiryBucketProvider.notifier).select(wanted),
      ),
    );
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 600) {
      unawaited(ref.read(expiryListProvider.notifier).loadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selection = ref.watch(expirySelectionProvider);
    final selecting = selection != null;
    final settings = ref.watch(settingsProvider).value ?? const AppSettings();
    final filterActive =
        settings.expiryCategory.isNotEmpty ||
        settings.expiryForm.isNotEmpty ||
        settings.expiryHideHandled ||
        settings.expirySort != 'soonest';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selecting ? l10n.selectedCount(selection.length) : l10n.tabExpiry,
        ),
        leading: selecting
            ? IconButton(
                key: const Key('select-cancel'),
                tooltip: l10n.selectCancel,
                icon: const Icon(Icons.close),
                onPressed: ref.read(expirySelectionProvider.notifier).cancel,
              )
            : null,
        actions: selecting
            ? null
            : [
                IconButton(
                  key: const Key('expiry-search-toggle'),
                  tooltip: l10n.tooltipSearch,
                  icon: Icon(_searching ? Icons.search_off : Icons.search),
                  onPressed: () {
                    setState(() => _searching = !_searching);
                    if (!_searching) {
                      _search.clear();
                      ref.read(expirySearchProvider.notifier).set('');
                    }
                  },
                ),
                PopupMenuButton<ExpiryShareFormat>(
                  key: const Key('expiry-share'),
                  tooltip: l10n.shareListAction,
                  icon: const Icon(Icons.ios_share),
                  onSelected: (f) =>
                      unawaited(shareExpiryList(context, ref, f)),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      key: const Key('expiry-share-csv'),
                      value: ExpiryShareFormat.csv,
                      child: Text(l10n.shareListCsv),
                    ),
                    PopupMenuItem(
                      key: const Key('expiry-share-text'),
                      value: ExpiryShareFormat.text,
                      child: Text(l10n.shareListText),
                    ),
                  ],
                ),
                IconButton(
                  key: const Key('expiry-select'),
                  tooltip: l10n.tooltipSelect,
                  icon: const Icon(Icons.checklist),
                  onPressed: ref.read(expirySelectionProvider.notifier).start,
                ),
                IconButton(
                  key: const Key('expiry-filter'),
                  tooltip: l10n.tooltipFilter,
                  icon: Badge(
                    isLabelVisible: filterActive,
                    smallSize: 8,
                    child: const Icon(Icons.filter_list),
                  ),
                  onPressed: () => showExpiryFilterSheet(context),
                ),
              ],
      ),
      bottomNavigationBar: selecting
          ? _SelectionBar(selection: selection)
          : null,
      body: Column(
        children: [
          if (_searching)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SearchField(
                key: const Key('expiry-search'),
                controller: _search,
                autofocus: true,
                hintText: l10n.expirySearchHint,
                onChanged: (v) =>
                    ref.read(expirySearchProvider.notifier).set(v),
              ),
            ),
          const _BucketChips(),
          const _ValueBanner(),
          Expanded(child: _ExpiryList(controller: _scroll)),
        ],
      ),
    );
  }
}

class _BucketChips extends ConsumerWidget {
  const _BucketChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(expirySummaryProvider).value;
    final selected = ref.watch(expiryBucketProvider);
    final urgency = Theme.of(context).extension<UrgencyColors>()!;

    String label(ExpiryBucket b) => switch (b) {
      ExpiryBucket.expired => l10n.chipExpired,
      ExpiryBucket.d30 => l10n.chip30,
      ExpiryBucket.d60 => l10n.chip60,
      ExpiryBucket.d90 => l10n.chip90,
      ExpiryBucket.ok => l10n.chipLater,
    };

    Widget chip(ExpiryBucket? bucket) {
      final count = bucket == null ? summary?.total : summary?.count(bucket);
      final style = bucket == null ? null : urgency.of(bucket);
      final text = bucket == null ? l10n.chipAll : label(bucket);
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          key: Key('chip-${bucket?.name ?? 'all'}'),
          selected: selected == bucket,
          avatar: style == null
              ? null
              : Icon(style.icon, size: 18, color: style.color),
          label: Text('$text${count == null ? '' : ' · $count'}'),
          onSelected: (_) =>
              ref.read(expiryBucketProvider.notifier).select(bucket),
        ),
      );
    }

    // The ">90 days" chip only matters if some medicine has a longer window.
    final showLater = (summary?.count(ExpiryBucket.ok) ?? 0) > 0;
    return SizedBox(
      // Room for chips at the full 48 dp touch height.
      height: 64,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          chip(null),
          chip(ExpiryBucket.expired),
          chip(ExpiryBucket.d30),
          chip(ExpiryBucket.d60),
          chip(ExpiryBucket.d90),
          if (showLater || selected == ExpiryBucket.ok) chip(ExpiryBucket.ok),
        ],
      ),
    );
  }
}

class _ValueBanner extends ConsumerWidget {
  const _ValueBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(expirySummaryProvider).value;
    if (summary == null || summary.total == 0) return const SizedBox.shrink();
    final currency = ref.watch(currencySymbolProvider);
    final v = summary.value;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Text(
            l10n.expiryValueAtRisk(v.total.format(symbol: currency)),
            key: const Key('value-at-risk'),
            style: theme.textTheme.titleSmall,
          ),
          if (v.isPartial) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.info_outline,
              size: 16,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                l10n.expiryValuePartial(v.missingCost),
                key: const Key('value-partial'),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

sealed class _Entry {
  const _Entry();
}

class _HeaderEntry extends _Entry {
  const _HeaderEntry(this.bucket);
  final ExpiryBucket bucket;
}

class _ItemEntry extends _Entry {
  const _ItemEntry(this.item);
  final ExpiryItem item;
}

class _ExpiryList extends ConsumerWidget {
  const _ExpiryList({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final list = ref.watch(expiryListProvider);
    final query = ref.watch(expiryQueryProvider);
    final summary = ref.watch(expirySummaryProvider).value;
    final selection = ref.watch(expirySelectionProvider);
    final actions = ExpiryActions(context, ref);

    return list.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.errorGeneric)),
      data: (data) {
        if (data.items.isEmpty) {
          return _EmptyState(
            filtered: query.filter.isActive || query.sort != ExpirySort.soonest,
            windowDays: query.globalWindowDays,
          );
        }
        // Section headers only make sense when rows run in expiry order.
        final grouped = query.sort == ExpirySort.soonest;
        final entries = <_Entry>[];
        ExpiryBucket? last;
        for (final item in data.items) {
          if (grouped && item.bucket != last) {
            entries.add(_HeaderEntry(item.bucket));
            last = item.bucket;
          }
          entries.add(_ItemEntry(item));
        }
        return ListView.builder(
          key: const Key('expiry-list'),
          controller: controller,
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: entries.length + (data.loadingMore ? 1 : 0),
          itemBuilder: (context, i) {
            if (i >= entries.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return switch (entries[i]) {
              _HeaderEntry(:final bucket) => _SectionHeader(
                bucket: bucket,
                count: summary?.count(bucket),
              ),
              _ItemEntry(:final item) => ExpiryRow(
                item: item,
                actions: actions,
                selecting: selection != null,
                selected: selection?.contains(item.batch.id) ?? false,
                onToggleSelected: () => ref
                    .read(expirySelectionProvider.notifier)
                    .toggle(item.batch.id),
              ),
            };
          },
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.bucket, required this.count});

  final ExpiryBucket bucket;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final style = theme.extension<UrgencyColors>()!.of(bucket);
    final expired = bucket == ExpiryBucket.expired;
    final label = switch (bucket) {
      ExpiryBucket.expired => l10n.expirySectionExpired,
      ExpiryBucket.d30 => l10n.bucketD30,
      ExpiryBucket.d60 => l10n.bucketD60,
      ExpiryBucket.d90 => l10n.bucketD90,
      ExpiryBucket.ok => l10n.bucketOk,
    };
    final text = count == null ? label : l10n.rowSection(label, count!);
    return Semantics(
      header: true,
      child: Container(
        key: Key('section-${bucket.name}'),
        width: double.infinity,
        margin: expired
            ? const EdgeInsets.fromLTRB(12, 8, 12, 4)
            : EdgeInsets.zero,
        padding: EdgeInsets.symmetric(
          horizontal: expired ? 12 : 16,
          vertical: expired ? 10 : 8,
        ),
        decoration: expired
            ? BoxDecoration(
                color: style.color.withValues(alpha: 0.12),
                border: Border.all(color: style.color),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Row(
          children: [
            Icon(style.icon, size: 20, color: style.color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: style.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState({required this.filtered, required this.windowDays});

  final bool filtered;
  final int windowDays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filtered
                  ? Icons.filter_alt_off_outlined
                  : Icons.verified_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              filtered ? l10n.expiryNoMatches : l10n.emptyExpiry,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              filtered ? '' : l10n.expiryEmptyDays(windowDays),
              textAlign: TextAlign.center,
            ),
            if (filtered) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                key: const Key('expiry-clear-filters'),
                onPressed: () async {
                  ref.read(expiryBucketProvider.notifier).select(null);
                  ref.read(expirySearchProvider.notifier).set('');
                  await ref
                      .read(settingsRepositoryProvider)
                      .update(
                        (s) => s.copyWith(
                          expirySort: 'soonest',
                          expiryCategory: '',
                          expiryForm: '',
                          expiryHideHandled: false,
                        ),
                      );
                },
                child: Text(l10n.expiryClearFilters),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SelectionBar extends ConsumerWidget {
  const _SelectionBar({required this.selection});

  final Set<String> selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('return-selected'),
                onPressed: selection.isEmpty
                    ? null
                    : () async {
                        final ids = selection.toList();
                        final done = await context.push<bool>(
                          Routes.supplierReturn,
                          extra: ReturnArgs(batchIds: ids),
                        );
                        if (done ?? false) {
                          ref.read(expirySelectionProvider.notifier).cancel();
                        }
                      },
                icon: const Icon(Icons.assignment_return_outlined),
                label: Text(l10n.expiryReturnAction),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                key: const Key('discard-selected'),
                onPressed: selection.isEmpty
                    ? null
                    : () async {
                        final actions = ExpiryActions(context, ref);
                        await actions.discardMany(selection.toList());
                        ref.read(expirySelectionProvider.notifier).cancel();
                      },
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.discardSelected),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
