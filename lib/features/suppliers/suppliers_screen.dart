import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/suppliers_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Suppliers tab: who is owed what, with overdue flagged (SUP-7, SUP-8).
class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  String _query = '';
  bool _includeArchived = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sort = ref.watch(supplierSortProvider);
    final list = ref.watch(
      supplierListProvider((
        query: _query,
        includeArchived: _includeArchived,
        sort: sort,
      )),
    );

    String sortLabel(SupplierSort s) => switch (s) {
      SupplierSort.name => l10n.supplierSortName,
      SupplierSort.balance => l10n.supplierSortBalance,
      SupplierSort.nextDue => l10n.supplierSortDue,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabSuppliers)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-supplier'),
        onPressed: () => context.push('${Routes.suppliers}/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.supplierAdd),
      ),
      body: Column(
        children: [
          const _DuesBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SearchBar(
              key: const Key('supplier-search'),
              hintText: l10n.supplierSearchHint,
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                for (final s in SupplierSort.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: Key('supplier-sort-${s.name}'),
                      label: Text(sortLabel(s)),
                      selected: sort == s,
                      onSelected: (_) =>
                          ref.read(supplierSortProvider.notifier).set(s),
                    ),
                  ),
                FilterChip(
                  key: const Key('supplier-archived'),
                  label: Text(l10n.supplierShowArchived),
                  selected: _includeArchived,
                  onSelected: (v) => setState(() => _includeArchived = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: list.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.errorGeneric)),
              data: (items) {
                if (items.isEmpty) {
                  return _query.isEmpty
                      ? const _EmptyState()
                      : Center(child: Text(l10n.stockNoResults));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: items.length,
                  itemBuilder: (context, i) => _SupplierTile(summary: items[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DuesBar extends ConsumerWidget {
  const _DuesBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dues = ref.watch(duesSummaryProvider).value;
    final currency = ref.watch(currencySymbolProvider);
    if (dues == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    Widget stat(String label, String value, {Color? color, Key? key}) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelMedium),
            Text(
              value,
              key: key,
              style: theme.textTheme.titleMedium?.copyWith(color: color),
            ),
          ],
        ),
      );
    }

    return Card(
      key: const Key('dues-bar'),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            stat(
              l10n.duesOwed,
              dues.outstanding.format(symbol: currency),
              key: const Key('dues-owed'),
            ),
            stat(
              l10n.duesOverdue,
              dues.overdue.format(symbol: currency),
              key: const Key('dues-overdue'),
              color: dues.overdueCount > 0 ? theme.colorScheme.error : null,
            ),
            stat(
              l10n.duesNextDue,
              dues.nextDue == null
                  ? l10n.duesNone
                  : formatDate(context, dues.nextDue!),
              key: const Key('dues-next'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupplierTile extends ConsumerWidget {
  const _SupplierTile({required this.summary});

  final SupplierSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currency = ref.watch(currencySymbolProvider);
    final s = summary.supplier;
    final subtitle = [
      if (s.contactPerson != null) s.contactPerson!,
      if (s.phone != null) s.phone!,
    ].join(' · ');

    return Opacity(
      opacity: s.isArchived ? 0.6 : 1,
      child: ListTile(
        key: Key('supplier-${s.id}'),
        title: Text(s.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitle.isNotEmpty) Text(subtitle),
            if (s.isArchived) Text(l10n.archivedBadge),
            if (summary.nextDue != null)
              Text(
                l10n.supplierNextDueLine(formatDate(context, summary.nextDue!)),
              ),
          ],
        ),
        isThreeLine: subtitle.isNotEmpty && summary.nextDue != null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              summary.outstanding.minor == 0
                  ? l10n.duesAllClear
                  : l10n.supplierOwedLine(
                      summary.outstanding.format(symbol: currency),
                    ),
              key: Key('owed-${s.id}'),
              style: theme.textTheme.labelLarge,
            ),
            if (summary.hasOverdue)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  key: Key('overdue-${s.id}'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 14,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.supplierOverdueLine(
                          summary.overdue.format(symbol: currency),
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        onTap: () => context.push('${Routes.suppliers}/${s.id}'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
              Icons.local_shipping_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.emptySuppliers,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(l10n.supplierEmptyBody, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('empty-add-supplier'),
              onPressed: () => context.push('${Routes.suppliers}/new'),
              child: Text(l10n.supplierEmptyCta),
            ),
          ],
        ),
      ),
    );
  }
}
