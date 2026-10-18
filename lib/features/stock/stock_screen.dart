import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/features/common/expiry_chip.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/common/search_field.dart';
import 'package:pharmacy_expiry_tracker/features/stock/medicine_tile.dart';
import 'package:pharmacy_expiry_tracker/features/stock/stock_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Stock tab: searchable medicine list. Typing switches to grouped search
/// results (medicines and batch numbers); focusing the empty search field
/// shows recent searches.
class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  String _query = '';
  bool _includeArchived = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _query = value.trim());
    });
    // Clearing the field returns to the list without waiting.
    if (value.trim().isEmpty) setState(() => _query = '');
  }

  Future<void> _remember(String term) async {
    await ref.read(recentSearchesRepositoryProvider).add(term);
    ref.invalidate(recentSearchesProvider);
  }

  void _applyRecent(String term) {
    _controller.text = term;
    _controller.selection = TextSelection.collapsed(offset: term.length);
    setState(() => _query = term);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showRecent = _query.isEmpty && _focus.hasFocus;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabStock)),
      floatingActionButton: FloatingActionButton.extended(
        // Tabs stay alive side by side; a shared default hero tag would clash.
        heroTag: null,
        key: const Key('add-stock'),
        onPressed: () => context.push('${Routes.stock}/pick'),
        icon: const Icon(Icons.add),
        label: Text(l10n.stockAddStock),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SearchField(
              key: const Key('stock-search'),
              controller: _controller,
              focusNode: _focus,
              hintText: l10n.stockSearchHint,
              onChanged: _onChanged,
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) unawaited(_remember(v));
              },
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilterChip(
                key: const Key('filter-archived'),
                label: Text(l10n.stockShowArchived),
                selected: _includeArchived,
                onSelected: (v) => setState(() => _includeArchived = v),
              ),
            ),
          ),
          Expanded(
            child: showRecent
                ? _RecentSearches(onPick: _applyRecent)
                : _query.isEmpty
                ? _MedicineList(includeArchived: _includeArchived)
                : _SearchResults(
                    query: _query,
                    onOpened: () => unawaited(_remember(_query)),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MedicineList extends ConsumerWidget {
  const _MedicineList({required this.includeArchived});

  final bool includeArchived;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final list = ref.watch(
      medicineListProvider((query: '', includeArchived: includeArchived)),
    );
    return list.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.errorGeneric)),
      data: (items) {
        if (items.isEmpty) {
          return _EmptyState(
            onAdd: () => context.push('${Routes.stock}/medicine/new'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 96),
          itemCount: items.length,
          itemBuilder: (context, i) => MedicineTile(
            summary: items[i],
            onTap: () => context.push(
              '${Routes.stock}/medicine/${items[i].medicine.id}',
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.emptyStock,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(l10n.stockEmptyBody, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('empty-add-medicine'),
              onPressed: onAdd,
              child: Text(l10n.stockEmptyCta),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query, required this.onOpened});

  final String query;
  final VoidCallback onOpened;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final results = ref.watch(searchResultsProvider(query));
    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.errorGeneric)),
      data: (r) {
        if (r.isEmpty) return Center(child: Text(l10n.stockNoResults));
        return ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            if (r.medicines.isNotEmpty) _SectionHeader(l10n.sectionMedicines),
            for (final s in r.medicines)
              MedicineTile(
                summary: s,
                onTap: () {
                  onOpened();
                  unawaited(
                    context.push('${Routes.stock}/medicine/${s.medicine.id}'),
                  );
                },
              ),
            if (r.batches.isNotEmpty) _SectionHeader(l10n.sectionBatches),
            for (final b in r.batches)
              ListTile(
                key: Key('batch-hit-${b.batch.id}'),
                title: Text(l10n.batchBy(b.batch.batchNumber)),
                subtitle: Text(
                  '${b.medicine.displayName} · ${l10n.batchTileSubtitle(b.batch.quantityOnHand, formatDate(context, b.batch.expiry.date))}',
                ),
                trailing: b.batch.quantityOnHand > 0
                    ? ExpiryChip(expiry: b.batch.expiry)
                    : null,
                onTap: () {
                  onOpened();
                  unawaited(
                    context.push('${Routes.stock}/batch/${b.batch.id}'),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

class _RecentSearches extends ConsumerWidget {
  const _RecentSearches({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recent = ref.watch(recentSearchesProvider).value ?? const <String>[];
    if (recent.isEmpty) return const SizedBox.shrink();
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.searchRecent,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton(
                key: const Key('clear-recent'),
                onPressed: () async {
                  await ref.read(recentSearchesRepositoryProvider).clear();
                  ref.invalidate(recentSearchesProvider);
                },
                child: Text(l10n.searchClearRecent),
              ),
            ],
          ),
        ),
        for (final term in recent)
          ListTile(
            key: Key('recent-$term'),
            leading: const Icon(Icons.history),
            title: Text(term),
            onTap: () => onPick(term),
          ),
      ],
    );
  }
}
