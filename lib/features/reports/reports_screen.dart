import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/report.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/reports/report_export.dart';
import 'package:pharmacy_expiry_tracker/features/reports/report_tables.dart';
import 'package:pharmacy_expiry_tracker/features/reports/reports_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Expiry loss, stock value and dues aging (RPT-1…4): a total, a simple bar
/// chart, the lines behind it, and a way to share it as a spreadsheet or PDF.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context);
    final today = ref.read(todayDateProvider);
    final madeOn = formatDate(context, today);
    String date(DateTime d) => formatDate(context, d);
    switch (_tabs.index) {
      case 0:
        final report = await ref.read(lossReportProvider.future);
        final group = ref.read(lossGroupProvider);
        final range = ref.read(reportRangeProvider);
        if (!mounted) return;
        await shareReport(
          context,
          ref,
          fileName: 'expiry-loss-${_stamp(today)}',
          build: (money) => lossTable(
            l10n,
            report,
            group,
            period: l10n.reportsPeriod(date(range.from), date(range.to)),
            madeOn: madeOn,
            money: money,
          ),
        );
      case 1:
        final report = await ref.read(stockReportProvider.future);
        final group = ref.read(valuationGroupProvider);
        if (!mounted) return;
        await shareReport(
          context,
          ref,
          fileName: 'stock-value-${_stamp(today)}',
          build: (money) =>
              stockTable(l10n, report, group, asOf: madeOn, money: money),
        );
      default:
        final report = await ref.read(duesReportProvider.future);
        if (!mounted) return;
        await shareReport(
          context,
          ref,
          fileName: 'dues-aging-${_stamp(today)}',
          build: (money) =>
              agingTable(l10n, report, asOf: madeOn, money: money),
        );
    }
  }

  String _stamp(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportsTitle),
        actions: [
          IconButton(
            key: const Key('reports-share'),
            tooltip: l10n.reportsShare,
            icon: const Icon(Icons.ios_share),
            onPressed: () => unawaited(_share()),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(key: const Key('tab-loss'), text: l10n.reportsLoss),
            Tab(key: const Key('tab-stock'), text: l10n.reportsStock),
            Tab(key: const Key('tab-dues'), text: l10n.reportsDues),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [_LossTab(), _StockTab(), _DuesTab()],
      ),
    );
  }
}

String _labelFor(AppLocalizations l10n, ReportRow r, {String? fallback}) =>
    r.label.isNotEmpty ? r.label : (fallback ?? '—');

/// A bar chart with the label under each bar.
class ReportBars extends StatelessWidget {
  const ReportBars({
    required this.labels,
    required this.values,
    required this.semanticLabel,
    super.key,
  });

  final List<String> labels;
  final List<int> values;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxV = values.fold<int>(1, math.max);
    return Semantics(
      label: semanticLabel,
      container: true,
      child: ExcludeSemantics(
        child: SizedBox(
          key: const Key('report-chart'),
          height: 180,
          child: BarChart(
            BarChartData(
              maxY: maxV * 1.15,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: const BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      final t = labels[i];
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          t.length > 9 ? '${t.substring(0, 8)}…' : t,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < values.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i].toDouble(),
                        width: 18,
                        color: scheme.primary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Total at the top of a tab.
class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.valueKey,
  });

  final String label;
  final String value;
  final String detail;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            Text(value, key: valueKey, style: theme.textTheme.headlineSmall),
            if (detail.isNotEmpty)
              Text(detail, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Center(
      child: Text(
        AppLocalizations.of(context).reportsNothing,
        key: const Key('report-empty'),
      ),
    ),
  );
}

class _LossTab extends ConsumerWidget {
  const _LossTab();

  Future<void> _pickRange(BuildContext context, WidgetRef ref) async {
    final today = ref.read(todayDateProvider);
    final current = ref.read(reportRangeProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 5),
      lastDate: today,
      initialDateRange: DateTimeRange(start: current.from, end: current.to),
    );
    if (picked != null) {
      ref
          .read(reportRangeProvider.notifier)
          .set(DateRange(picked.start, picked.end));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currency = ref.watch(currencySymbolProvider);
    final group = ref.watch(lossGroupProvider);
    final range = ref.watch(reportRangeProvider);
    final today = ref.watch(todayDateProvider);
    final report = ref.watch(lossReportProvider);

    bool isPreset(RangePreset p) => presetRange(p, today) == range;
    final custom = !RangePreset.values.any(isPreset);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final (p, label) in [
              (RangePreset.month, l10n.reportsRangeMonth),
              (RangePreset.days90, l10n.reportsRange90),
              (RangePreset.year, l10n.reportsRangeYear),
            ])
              ChoiceChip(
                key: Key('range-${p.name}'),
                label: Text(label),
                selected: isPreset(p),
                onSelected: (_) => ref
                    .read(reportRangeProvider.notifier)
                    .set(presetRange(p, today)),
              ),
            ChoiceChip(
              key: const Key('range-custom'),
              label: Text(l10n.reportsRangeCustom),
              selected: custom,
              onSelected: (_) => unawaited(_pickRange(context, ref)),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            l10n.reportsPeriod(
              formatDate(context, range.from),
              formatDate(context, range.to),
            ),
            key: const Key('report-period'),
          ),
        ),
        SegmentedButton<LossGroup>(
          key: const Key('loss-group'),
          segments: [
            ButtonSegment(
              value: LossGroup.month,
              label: Text(l10n.reportsByMonth),
            ),
            ButtonSegment(
              value: LossGroup.supplier,
              label: Text(l10n.reportsBySupplier),
            ),
            ButtonSegment(
              value: LossGroup.medicine,
              label: Text(l10n.reportsByMedicine),
            ),
          ],
          selected: {group},
          onSelectionChanged: (s) =>
              ref.read(lossGroupProvider.notifier).set(s.first),
        ),
        SwitchListTile(
          key: const Key('loss-damaged'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.reportsIncludeDamaged),
          value: ref.watch(includeDamagedProvider),
          onChanged: (v) =>
              ref.read(includeDamagedProvider.notifier).set(value: v),
        ),
        report.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(l10n.errorGeneric),
          data: (r) {
            if (r.rows.isEmpty) return const _Empty();
            // Months read left to right, oldest first; others, biggest first.
            final shown = group == LossGroup.month
                ? r.rows.take(12).toList().reversed.toList()
                : r.rows.take(8).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TotalCard(
                  label: l10n.reportsTotalLoss,
                  value: r.value.format(symbol: currency),
                  valueKey: const Key('loss-total'),
                  detail: '${r.quantity} · ${l10n.colBatches}: ${r.batches}',
                ),
                if (r.unpriced > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      l10n.reportsUnpriced(r.unpriced),
                      key: const Key('loss-unpriced'),
                    ),
                  ),
                ReportBars(
                  labels: [for (final x in shown) _labelFor(l10n, x)],
                  values: [for (final x in shown) x.value.minor],
                  semanticLabel:
                      '${l10n.reportsTotalLoss}: ${r.value.format(symbol: currency)}',
                ),
                const SizedBox(height: 8),
                for (final row in r.rows)
                  ListTile(
                    key: Key('loss-row-${row.key}'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _labelFor(l10n, row, fallback: l10n.colNoSupplier),
                    ),
                    subtitle: Text(
                      '${row.quantity} · ${l10n.colBatches}: ${row.batches}',
                    ),
                    trailing: Text(
                      row.value.format(symbol: currency),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    onTap: () => unawaited(
                      _showDetails(context, ref, row, group, range),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _showDetails(
    BuildContext context,
    WidgetRef ref,
    ReportRow row,
    LossGroup group,
    DateRange range,
  ) async {
    final details = await ref
        .read(reportRepositoryProvider)
        .expiryLossDetails(
          range,
          group,
          row.key,
          includeDamaged: ref.read(includeDamagedProvider),
        );
    if (!context.mounted) return;
    final currency = ref.read(currencySymbolProvider);
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (ctx, controller) => ListView(
          key: const Key('loss-details'),
          controller: controller,
          children: [
            ListTile(
              title: Text(
                _labelFor(l10n, row),
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              subtitle: Text(l10n.reportsDetails),
            ),
            for (final d in details)
              ListTile(
                title: Text('${d.medicineName} · ${d.batchNumber}'),
                subtitle: Text(
                  [
                    formatDate(ctx, d.on),
                    if (d.supplierName != null) d.supplierName!,
                  ].join(' · '),
                ),
                trailing: Text(
                  '${d.quantity}'
                  '${d.value == null ? '' : ' · ${d.value!.format(symbol: currency)}'}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StockTab extends ConsumerWidget {
  const _StockTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currency = ref.watch(currencySymbolProvider);
    final group = ref.watch(valuationGroupProvider);
    final report = ref.watch(stockReportProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SegmentedButton<ValuationGroup>(
          key: const Key('stock-group'),
          segments: [
            ButtonSegment(
              value: ValuationGroup.medicine,
              label: Text(l10n.reportsByMedicine),
            ),
            ButtonSegment(
              value: ValuationGroup.supplier,
              label: Text(l10n.reportsBySupplier),
            ),
            ButtonSegment(
              value: ValuationGroup.category,
              label: Text(l10n.reportsByCategory),
            ),
          ],
          selected: {group},
          onSelectionChanged: (s) =>
              ref.read(valuationGroupProvider.notifier).set(s.first),
        ),
        const SizedBox(height: 8),
        report.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(l10n.errorGeneric),
          data: (r) {
            if (r.rows.isEmpty) return const _Empty();
            final shown = r.rows.take(8).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TotalCard(
                  label: l10n.reportsTotalValue,
                  value: r.value.format(symbol: currency),
                  valueKey: const Key('stock-total'),
                  detail: '${r.quantity} · ${l10n.colBatches}: ${r.batches}',
                ),
                if (r.unpriced > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      l10n.reportsUnpriced(r.unpriced),
                      key: const Key('stock-unpriced'),
                    ),
                  ),
                ReportBars(
                  labels: [for (final x in shown) _labelFor(l10n, x)],
                  values: [for (final x in shown) x.value.minor],
                  semanticLabel:
                      '${l10n.reportsTotalValue}: ${r.value.format(symbol: currency)}',
                ),
                const SizedBox(height: 8),
                for (final row in r.rows)
                  ListTile(
                    key: Key('stock-row-${row.key}'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      row.label.isNotEmpty
                          ? row.label
                          : (group == ValuationGroup.supplier
                                ? l10n.colNoSupplier
                                : l10n.colNoCategory),
                    ),
                    subtitle: Text(
                      '${row.quantity} · ${l10n.colBatches}: ${row.batches}',
                    ),
                    trailing: Text(
                      row.value.format(symbol: currency),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    onTap: () => unawaited(_details(context, ref, row, group)),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _details(
    BuildContext context,
    WidgetRef ref,
    ReportRow row,
    ValuationGroup group,
  ) async {
    final details = await ref
        .read(reportRepositoryProvider)
        .stockDetails(group, row.key);
    if (!context.mounted) return;
    final currency = ref.read(currencySymbolProvider);
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (ctx, controller) => ListView(
          key: const Key('stock-details'),
          controller: controller,
          children: [
            ListTile(
              title: Text(
                row.label.isNotEmpty ? row.label : l10n.colNoSupplier,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              subtitle: Text(l10n.reportsDetails),
            ),
            for (final d in details)
              ListTile(
                title: Text('${d.medicineName} · ${d.batchNumber}'),
                subtitle: Text(
                  '${l10n.colExpiry}: ${formatDate(ctx, d.expiry)}',
                ),
                trailing: Text(
                  '${d.quantity}'
                  '${d.value == null ? '' : ' · ${d.value!.format(symbol: currency)}'}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DuesTab extends ConsumerWidget {
  const _DuesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currency = ref.watch(currencySymbolProvider);
    final report = ref.watch(duesReportProvider);

    String bucketName(AgingBucket b) => switch (b) {
      AgingBucket.current => l10n.agingCurrent,
      AgingBucket.d1to30 => l10n.aging1to30,
      AgingBucket.d31to60 => l10n.aging31to60,
      AgingBucket.d61to90 => l10n.aging61to90,
      AgingBucket.over90 => l10n.agingOver90,
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        report.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(l10n.errorGeneric),
          data: (r) {
            if (r.rows.isEmpty) return const _Empty();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TotalCard(
                  label: l10n.reportsTotalOwed,
                  value: r.total.format(symbol: currency),
                  valueKey: const Key('dues-total'),
                  detail: '',
                ),
                ReportBars(
                  labels: [for (final b in AgingBucket.values) bucketName(b)],
                  values: [for (final b in AgingBucket.values) r.of(b).minor],
                  semanticLabel:
                      '${l10n.reportsTotalOwed}: ${r.total.format(symbol: currency)}',
                ),
                const SizedBox(height: 8),
                for (final row in r.rows)
                  ExpansionTile(
                    key: Key('dues-row-${row.supplierId}'),
                    tilePadding: EdgeInsets.zero,
                    title: Text(row.supplierName),
                    trailing: Text(
                      row.total.format(symbol: currency),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    children: [
                      for (final b in AgingBucket.values)
                        if (row.of(b) != Money.zero)
                          ListTile(
                            dense: true,
                            title: Text(bucketName(b)),
                            trailing: Text(row.of(b).format(symbol: currency)),
                          ),
                      TextButton(
                        key: Key('dues-open-${row.supplierId}'),
                        onPressed: () => context.push(
                          '${Routes.suppliers}/${row.supplierId}',
                        ),
                        child: Text(l10n.reportsOpenSupplier),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
