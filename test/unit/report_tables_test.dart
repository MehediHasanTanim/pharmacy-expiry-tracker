import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/report.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/expiry_export.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/statement.dart';
import 'package:pharmacy_expiry_tracker/features/reports/report_tables.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  const csv = MoneyStyle(plain: true);
  const print = MoneyStyle(symbol: '৳');
  String d(DateTime x) => '${x.day}/${x.month}/${x.year}';

  const report = GroupedReport([
    ReportRow(
      key: '2026-09',
      label: '2026-09',
      quantity: 12,
      value: Money(123456),
      batches: 3,
    ),
    ReportRow(
      key: '2026-08',
      label: '2026-08',
      quantity: 4,
      value: Money(50),
      batches: 1,
      unpriced: 1,
    ),
  ]);

  test(
    'loss table: spreadsheet amounts are plain numbers, with a total line',
    () {
      final t = lossTable(
        l10n,
        report,
        LossGroup.month,
        period: 'a to b',
        madeOn: 'today',
        money: csv,
      );
      expect(t.title, 'Expiry loss, By month');
      expect(t.headers, ['Month', 'Quantity', 'Batches', 'Value']);
      expect(t.rows.first, ['2026-09', '12', '3', '1234.56']);
      expect(t.rows.last.last, '0.50');
      expect(t.footer, ['Total', '16', '4', '1235.06']);
      expect(t.subtitle, contains('a to b'));
      expect(t.grid.length, 4);
    },
  );

  test('printed amounts are grouped with the currency symbol', () {
    final t = lossTable(
      l10n,
      report,
      LossGroup.supplier,
      period: 'p',
      madeOn: 'm',
      money: print,
    );
    expect(t.rows.first.last, '৳1,234.56');
    expect(t.headers.first, 'Supplier');
  });

  test('an empty report has no total line', () {
    final t = lossTable(
      l10n,
      const GroupedReport([]),
      LossGroup.month,
      period: 'p',
      madeOn: 'm',
      money: csv,
    );
    expect(t.rows, isEmpty);
    expect(t.footer, isEmpty);
  });

  test('rows with no supplier or category get a readable name', () {
    const r = GroupedReport([
      ReportRow(key: '', label: '', quantity: 1, value: Money(100), batches: 1),
    ]);
    expect(
      stockTable(
        l10n,
        r,
        ValuationGroup.supplier,
        asOf: 'x',
        money: csv,
      ).rows.single.first,
      'No supplier',
    );
    expect(
      stockTable(
        l10n,
        r,
        ValuationGroup.category,
        asOf: 'x',
        money: csv,
      ).rows.single.first,
      'No category',
    );
  });

  test('aging table: one column per bucket and a total', () {
    final t = agingTable(
      l10n,
      const AgingReport([
        AgingRow(
          supplierId: 's',
          supplierName: 'ABC',
          buckets: {
            AgingBucket.current: Money(100),
            AgingBucket.over90: Money(900),
          },
        ),
      ]),
      asOf: 'today',
      money: csv,
    );
    expect(t.headers, [
      'Supplier',
      'Not yet due',
      '1-30 days late',
      '31-60 days late',
      '61-90 days late',
      'Over 90 days late',
      'Total',
    ]);
    expect(t.rows.single, [
      'ABC',
      '1.00',
      '0.00',
      '0.00',
      '0.00',
      '9.00',
      '10.00',
    ]);
    expect(t.footer.last, '10.00');
    expect(t.numericColumns, {1, 2, 3, 4, 5, 6});
  });

  test('statement table: opening, lines, closing; invoices vs settlements', () {
    final s = SupplierStatement(
      supplierName: 'ABC',
      from: DateTime(2026, 9),
      to: DateTime(2026, 9, 30),
      opening: const Money(6000),
      entries: [
        StatementEntry(
          on: DateTime(2026, 9, 5),
          kind: StatementKind.invoice,
          amount: const Money(5000),
          balance: const Money(11000),
          reference: 'INV-2',
        ),
        StatementEntry(
          on: DateTime(2026, 9, 25),
          kind: StatementKind.payment,
          amount: const Money(-6000),
          balance: const Money(5000),
        ),
      ],
      closing: const Money(5000),
      totalInvoiced: const Money(5000),
      totalPaid: const Money(6000),
      totalCredited: Money.zero,
    );
    final t = statementTable(l10n, s, date: d, madeOn: 'today', money: csv);
    expect(t.title, 'Statement: ABC');
    expect(t.rows[0], ['1/9/2026', 'Opening balance', '', '', '', '60.00']);
    expect(t.rows[1], ['5/9/2026', 'Invoice', 'INV-2', '50.00', '', '110.00']);
    expect(t.rows[2], ['25/9/2026', 'Payment', '', '', '60.00', '50.00']);
    expect(t.footer, ['', 'Closing balance', '', '50.00', '60.00', '50.00']);
  });

  test('a table exports as safe CSV', () {
    final t = lossTable(
      l10n,
      const GroupedReport([
        ReportRow(
          key: 'k',
          label: '=cmd|"x"',
          quantity: 1,
          value: Money(100),
          batches: 1,
        ),
      ]),
      LossGroup.medicine,
      period: 'p',
      madeOn: 'm',
      money: csv,
    );
    final text = encodeCsv(t.grid);
    expect(text, contains("\"'=cmd|\"\"x\"\"\""));
    expect(text.startsWith('\u{FEFF}Medicine,Quantity'), isTrue);
  });
}
