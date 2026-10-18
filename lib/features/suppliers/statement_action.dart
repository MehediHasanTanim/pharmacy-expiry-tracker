import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/report.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/statement.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/reports/report_export.dart';
import 'package:pharmacy_expiry_tracker/features/reports/report_tables.dart';
import 'package:pharmacy_expiry_tracker/features/reports/reports_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Offers a period, builds the supplier's statement for it and shares it as a
/// spreadsheet or PDF, for reconciling with the supplier (SUP-11).
Future<void> shareSupplierStatement(
  BuildContext context,
  WidgetRef ref, {
  required String supplierId,
}) async {
  final l10n = AppLocalizations.of(context);
  final today = ref.read(todayDateProvider);
  final range = await showModalBottomSheet<DateRange>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: Text(l10n.statementPickRange)),
          for (final (key, label, range) in [
            (
              'month',
              l10n.reportsRangeMonth,
              presetRange(RangePreset.month, today),
            ),
            (
              'days90',
              l10n.reportsRange90,
              presetRange(RangePreset.days90, today),
            ),
            (
              'year',
              l10n.reportsRangeYear,
              presetRange(RangePreset.year, today),
            ),
          ])
            ListTile(
              key: Key('statement-$key'),
              title: Text(label),
              onTap: () => Navigator.pop(ctx, range),
            ),
          ListTile(
            key: const Key('statement-custom'),
            title: Text(l10n.reportsRangeCustom),
            onTap: () async {
              final picked = await showDateRangePicker(
                context: ctx,
                firstDate: DateTime(today.year - 10),
                lastDate: today,
              );
              if (picked != null && ctx.mounted) {
                Navigator.pop(ctx, DateRange(picked.start, picked.end));
              }
            },
          ),
        ],
      ),
    ),
  );
  if (range == null || !context.mounted) return;

  final suppliers = ref.read(supplierRepositoryProvider);
  final ledger = ref.read(ledgerRepositoryProvider);
  final supplier = await suppliers.getById(supplierId);
  if (supplier == null) return;
  final invoices = [
    for (final b in await ledger.watchInvoices(supplierId, today: today).first)
      b.invoice,
  ];
  final payments = await ledger.watchPayments(supplierId).first;
  final credits = await ledger.watchCredits(supplierId).first;
  final statement = buildStatement(
    supplierName: supplier.name,
    from: range.from,
    to: range.to,
    invoices: invoices,
    payments: payments,
    credits: credits,
  );
  if (!context.mounted) return;
  final madeOn = formatDate(context, today);
  String date(DateTime d) => formatDate(context, d);
  final safeName = supplier.name
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  await shareReport(
    context,
    ref,
    fileName: 'statement-${safeName.isEmpty ? 'supplier' : safeName}',
    build: (money) => statementTable(
      l10n,
      statement,
      date: date,
      madeOn: madeOn,
      money: money,
    ),
  );
}
