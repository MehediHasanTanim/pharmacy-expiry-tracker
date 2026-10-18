import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/app/theme.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/expiry.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/expiry_bucket.dart';
import 'package:pharmacy_expiry_tracker/features/alerts/alert_status_banner.dart';
import 'package:pharmacy_expiry_tracker/features/common/expiry_chip.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/home/home_providers.dart';
import 'package:pharmacy_expiry_tracker/features/stock/stock_providers.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/suppliers_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// One-glance dashboard: what needs attention today (HOM-1), what expires this
/// week (HOM-3), and whether alerts are working (HOM-2).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final medicines = ref.watch(
      medicineListProvider((query: '', includeArchived: false)),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabHome)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const AlertStatusBanner(),
          if (medicines.value?.isEmpty ?? false)
            const _FirstMedicineCard()
          else ...const [_AttentionGrid(), _AtRiskLine(), _ThisWeek()],
        ],
      ),
    );
  }
}

class _FirstMedicineCard extends StatelessWidget {
  const _FirstMedicineCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      key: const Key('home-first-medicine'),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.medication_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.homeFirstTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(l10n.homeFirstBody, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('home-add-medicine'),
              onPressed: () => context.push('${Routes.stock}/medicine/new'),
              child: Text(l10n.homeAddMedicine),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttentionGrid extends ConsumerWidget {
  const _AttentionGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currency = ref.watch(currencySymbolProvider);
    final summary = ref.watch(homeExpirySummaryProvider).value;
    final reorder = ref.watch(reorderItemsProvider).value;
    final dues = ref.watch(duesSummaryProvider).value;
    final urgency = Theme.of(context).extension<UrgencyColors>()!;

    String batches(int n) => l10n.homeBatchCount(n);

    final expiredCount = summary?.count(ExpiryBucket.expired) ?? 0;
    final soonCount = summary?.count(ExpiryBucket.d30) ?? 0;
    final reorderCount = reorder?.length ?? 0;
    final overdueCount = dues?.overdueCount ?? 0;

    final cards = [
      _AttentionCard(
        cardKey: const Key('card-expired'),
        icon: urgency.of(ExpiryBucket.expired).icon,
        color: urgency.of(ExpiryBucket.expired).color,
        label: l10n.homeExpired,
        value: '$expiredCount',
        detail: expiredCount == 0
            ? l10n.homeAllGood
            : '${batches(expiredCount)} · '
                  '${summary!.valueOf(ExpiryBucket.expired).total.format(symbol: currency)}',
        urgent: expiredCount > 0,
        onTap: () => context.go(Routes.expiryFiltered(bucket: 'expired')),
      ),
      _AttentionCard(
        cardKey: const Key('card-soon'),
        icon: urgency.of(ExpiryBucket.d30).icon,
        color: urgency.of(ExpiryBucket.d30).color,
        label: l10n.homeExpiring30,
        value: '$soonCount',
        detail: soonCount == 0
            ? l10n.homeAllGood
            : '${batches(soonCount)} · '
                  '${summary!.valueOf(ExpiryBucket.d30).total.format(symbol: currency)}',
        urgent: soonCount > 0,
        onTap: () => context.go(Routes.expiryFiltered(bucket: 'd30')),
      ),
      _AttentionCard(
        cardKey: const Key('card-reorder'),
        icon: Icons.shopping_cart_outlined,
        color: Theme.of(context).colorScheme.primary,
        label: l10n.homeReorder,
        value: '$reorderCount',
        detail: reorderCount == 0
            ? l10n.homeNoReorder
            : l10n.homeMedicineCount(reorderCount),
        urgent: reorderCount > 0,
        onTap: () => context.push(Routes.reorder),
      ),
      _AttentionCard(
        cardKey: const Key('card-dues'),
        icon: Icons.payments_outlined,
        color: Theme.of(context).colorScheme.error,
        label: l10n.homeOverdueDues,
        value: dues == null ? '0' : dues.overdue.format(symbol: currency),
        detail: overdueCount == 0
            ? l10n.homeAllGood
            : l10n.homeInvoiceCount(overdueCount),
        urgent: overdueCount > 0,
        onTap: () => context.go(Routes.suppliers),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: LayoutBuilder(
        builder: (context, box) {
          // Two columns normally, one when the text is very large or narrow.
          final columns =
              box.maxWidth < 360 ||
                  MediaQuery.textScalerOf(context).scale(16) > 24
              ? 1
              : 2;
          final width = (box.maxWidth - (columns - 1) * 8) / columns;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final c in cards) SizedBox(width: width, child: c)],
          );
        },
      ),
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({
    required this.cardKey,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.detail,
    required this.urgent,
    required this.onTap,
  });

  final Key cardKey;
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String detail;
  final bool urgent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: l10n.homeCardSemantics(label, '$value, $detail'),
      excludeSemantics: true,
      child: Card(
        key: cardKey,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: urgent
              ? BorderSide(color: color.withValues(alpha: 0.7), width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(label, style: theme.textTheme.labelLarge),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: urgent ? color : null,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(detail, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AtRiskLine extends ConsumerWidget {
  const _AtRiskLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currency = ref.watch(currencySymbolProvider);
    final summary = ref.watch(homeExpirySummaryProvider).value;
    if (summary == null || summary.total == 0) return const SizedBox.shrink();
    final v = summary.value;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Text(
            l10n.expiryValueAtRisk(v.total.format(symbol: currency)),
            key: const Key('home-at-risk'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (v.isPartial) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.expiryValuePartial(v.missingCost),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThisWeek extends ConsumerWidget {
  const _ThisWeek();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(expiringThisWeekProvider).value;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.homeWeekTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              TextButton(
                key: const Key('home-see-all'),
                onPressed: () =>
                    context.go(Routes.expiryFiltered(bucket: 'd30')),
                child: Text(l10n.homeSeeAll),
              ),
            ],
          ),
        ),
        if (items != null && items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(l10n.homeWeekEmpty, key: const Key('home-week-empty')),
          )
        else
          for (final item in items ?? const <ExpiryItem>[])
            ListTile(
              key: Key('week-${item.batch.id}'),
              title: Text(item.medicine.displayName),
              subtitle: Text(
                '${l10n.batchBy(item.batch.batchNumber)} · '
                '${l10n.stockOnHand(item.batch.quantityOnHand)} · '
                '${formatDate(context, item.batch.expiry.date)}',
              ),
              trailing: ExpiryChip(expiry: item.expiry),
              onTap: () =>
                  context.push('${Routes.stock}/batch/${item.batch.id}'),
            ),
      ],
    );
  }
}
