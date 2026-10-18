import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/data/export/pdf_report.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/report_table.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/expiry_export.dart';
import 'package:pharmacy_expiry_tracker/features/expiry/expiry_share.dart';
import 'package:pharmacy_expiry_tracker/features/reports/report_tables.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

enum ReportFormat { csv, pdf }

/// Asks which format to share; null if dismissed.
Future<ReportFormat?> askReportFormat(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<ReportFormat>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            key: const Key('report-format-csv'),
            leading: const Icon(Icons.table_chart_outlined),
            title: Text(l10n.reportsShareCsv),
            onTap: () => Navigator.pop(ctx, ReportFormat.csv),
          ),
          ListTile(
            key: const Key('report-format-pdf'),
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(l10n.reportsSharePdf),
            subtitle: Text(l10n.reportsPdfNote),
            onTap: () => Navigator.pop(ctx, ReportFormat.pdf),
          ),
        ],
      ),
    ),
  );
}

/// Builds the report as a spreadsheet or PDF in a background isolate and hands
/// it to the share sheet (RPT-4, SUP-11). [build] is called with the amount
/// style that suits the format.
Future<void> shareReport(
  BuildContext context,
  WidgetRef ref, {
  required ReportTable Function(MoneyStyle money) build,
  required String fileName,
  ReportFormat? format,
}) async {
  final chosen = format ?? await askReportFormat(context);
  if (chosen == null || !context.mounted) return;
  final symbol = ref.read(currencySymbolProvider);
  final table = build(
    chosen == ReportFormat.csv
        ? const MoneyStyle(plain: true)
        : MoneyStyle(symbol: symbol),
  );
  final dir = ref.read(exportDirProvider)..createSync(recursive: true);
  final file = File(
    p.join(dir.path, '$fileName.${chosen == ReportFormat.csv ? 'csv' : 'pdf'}'),
  );
  if (chosen == ReportFormat.csv) {
    final text = await _csvInBackground(table.grid);
    await file.writeAsString(text, flush: true);
  } else {
    await file.writeAsBytes(
      await buildReportPdfInBackground(table),
      flush: true,
    );
  }
  await ref.read(fileExchangeProvider).share(file, subject: table.title);
}

/// Separate function so the isolate closure carries only the rows.
Future<String> _csvInBackground(List<List<String>> grid) =>
    Isolate.run(() => encodeCsv(grid));
