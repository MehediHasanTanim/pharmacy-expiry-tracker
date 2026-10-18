import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/report.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/report_table.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/statement.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// How amounts are written: [plain] for spreadsheets (`1250.00`, so they read
/// as numbers), otherwise grouped with the currency symbol for print.
class MoneyStyle {
  const MoneyStyle({this.plain = false, this.symbol = ''});

  final bool plain;
  final String symbol;

  String call(Money m) {
    if (plain) return (m.minor / 100).toStringAsFixed(2);
    return m.format(symbol: symbol);
  }
}

String _groupName(AppLocalizations l10n, LossGroup g) => switch (g) {
  LossGroup.month => l10n.reportsByMonth,
  LossGroup.supplier => l10n.reportsBySupplier,
  LossGroup.medicine => l10n.reportsByMedicine,
};

String _groupColumn(AppLocalizations l10n, LossGroup g) => switch (g) {
  LossGroup.month => l10n.colMonth,
  LossGroup.supplier => l10n.colSupplier,
  LossGroup.medicine => l10n.colMedicine,
};

String _label(AppLocalizations l10n, ReportRow r, {required bool supplier}) =>
    r.label.isNotEmpty
    ? r.label
    : supplier
    ? l10n.colNoSupplier
    : l10n.colNoCategory;

ReportTable lossTable(
  AppLocalizations l10n,
  GroupedReport report,
  LossGroup group, {
  required String period,
  required String madeOn,
  required MoneyStyle money,
}) => ReportTable(
  title: l10n.reportsLossTitle(_groupName(l10n, group)),
  subtitle: '$period · ${l10n.reportsGeneratedOn(madeOn)}',
  headers: [
    _groupColumn(l10n, group),
    l10n.colQuantity,
    l10n.colBatches,
    l10n.colValue,
  ],
  rows: [
    for (final r in report.rows)
      [
        _label(l10n, r, supplier: group == LossGroup.supplier),
        '${r.quantity}',
        '${r.batches}',
        money(r.value),
      ],
  ],
  footer: report.rows.isEmpty
      ? const []
      : [
          l10n.colTotal,
          '${report.quantity}',
          '${report.batches}',
          money(report.value),
        ],
  numericColumns: const {1, 2, 3},
);

ReportTable stockTable(
  AppLocalizations l10n,
  GroupedReport report,
  ValuationGroup group, {
  required String asOf,
  required MoneyStyle money,
}) {
  final name = switch (group) {
    ValuationGroup.medicine => l10n.reportsByMedicine,
    ValuationGroup.supplier => l10n.reportsBySupplier,
    ValuationGroup.category => l10n.reportsByCategory,
  };
  final column = switch (group) {
    ValuationGroup.medicine => l10n.colMedicine,
    ValuationGroup.supplier => l10n.colSupplier,
    ValuationGroup.category => l10n.colCategory,
  };
  return ReportTable(
    title: l10n.reportsStockTitle(name),
    subtitle: l10n.reportsStockAsOf(asOf),
    headers: [column, l10n.colQuantity, l10n.colBatches, l10n.colValue],
    rows: [
      for (final r in report.rows)
        [
          _label(l10n, r, supplier: group == ValuationGroup.supplier),
          '${r.quantity}',
          '${r.batches}',
          money(r.value),
        ],
    ],
    footer: report.rows.isEmpty
        ? const []
        : [
            l10n.colTotal,
            '${report.quantity}',
            '${report.batches}',
            money(report.value),
          ],
    numericColumns: const {1, 2, 3},
  );
}

ReportTable agingTable(
  AppLocalizations l10n,
  AgingReport report, {
  required String asOf,
  required MoneyStyle money,
}) {
  const buckets = AgingBucket.values;
  String name(AgingBucket b) => switch (b) {
    AgingBucket.current => l10n.agingCurrent,
    AgingBucket.d1to30 => l10n.aging1to30,
    AgingBucket.d31to60 => l10n.aging31to60,
    AgingBucket.d61to90 => l10n.aging61to90,
    AgingBucket.over90 => l10n.agingOver90,
  };
  return ReportTable(
    title: l10n.reportsDuesTitle,
    subtitle: l10n.reportsDuesAsOf(asOf),
    headers: [
      l10n.colSupplier,
      for (final b in buckets) name(b),
      l10n.colTotal,
    ],
    rows: [
      for (final r in report.rows)
        [
          r.supplierName,
          for (final b in buckets) money(r.of(b)),
          money(r.total),
        ],
    ],
    footer: report.rows.isEmpty
        ? const []
        : [
            l10n.colTotal,
            for (final b in buckets) money(report.of(b)),
            money(report.total),
          ],
    numericColumns: {for (var i = 1; i <= buckets.length + 1; i++) i},
  );
}

ReportTable statementTable(
  AppLocalizations l10n,
  SupplierStatement s, {
  required String Function(DateTime) date,
  required String madeOn,
  required MoneyStyle money,
}) {
  String kind(StatementKind k) => switch (k) {
    StatementKind.invoice => l10n.statementInvoice,
    StatementKind.payment => l10n.statementPayment,
    StatementKind.credit => l10n.statementCredit,
  };
  return ReportTable(
    title: l10n.statementTitle(s.supplierName),
    subtitle:
        '${l10n.reportsPeriod(date(s.from), date(s.to))} · '
        '${l10n.reportsGeneratedOn(madeOn)}',
    headers: [
      l10n.colDate,
      l10n.colType,
      l10n.colReference,
      l10n.colInvoiced,
      l10n.colPaidCredited,
      l10n.colBalance,
    ],
    rows: [
      [date(s.from), l10n.statementOpening, '', '', '', money(s.opening)],
      for (final e in s.entries)
        _statementRow(e, kind(e.kind), date(e.on), money),
    ],
    footer: [
      '',
      l10n.statementClosing,
      '',
      money(s.totalInvoiced),
      money(s.totalPaid + s.totalCredited),
      money(s.closing),
    ],
    numericColumns: const {3, 4, 5},
  );
}

/// Rows behind a loss line.
ReportTable lossDetailTable(
  AppLocalizations l10n,
  List<LossDetail> rows, {
  required String title,
  required String Function(DateTime) date,
  required MoneyStyle money,
}) => ReportTable(
  title: title,
  headers: [
    l10n.colDate,
    l10n.colMedicine,
    l10n.colBatch,
    l10n.colSupplier,
    l10n.colQuantity,
    l10n.colValue,
  ],
  rows: [
    for (final r in rows)
      [
        date(r.on),
        r.medicineName,
        r.batchNumber,
        r.supplierName ?? '',
        '${r.quantity}',
        _valueOrBlank(r.value, money),
      ],
  ],
  numericColumns: const {4, 5},
);

String _valueOrBlank(Money? m, MoneyStyle money) => m == null ? '' : money(m);

List<String> _statementRow(
  StatementEntry e,
  String kind,
  String date,
  MoneyStyle money,
) {
  final isInvoice = e.kind == StatementKind.invoice;
  final charge = isInvoice ? money(e.amount) : '';
  final settled = isInvoice ? '' : money(Money(-e.amount.minor));
  return [date, kind, e.reference ?? '', charge, settled, money(e.balance)];
}
