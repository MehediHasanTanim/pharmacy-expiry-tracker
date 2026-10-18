import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/expiry.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/expiry_export.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/expiry/expiry_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

enum ExpiryShareFormat { csv, text }

/// Where exported lists are staged; cleared at the next launch.
final exportDirProvider = Provider<Directory>(
  (ref) => Directory(p.join(Directory.systemTemp.path, 'pharmacy_export')),
);

/// Most rows an export will hold (guards memory on very large stores).
const maxExportRows = 20000;

/// Shares what the Expiry tab is showing, as a spreadsheet or plain text
/// (EXP-11, RPT-4). The current search, bucket and filters all apply.
Future<void> shareExpiryList(
  BuildContext context,
  WidgetRef ref,
  ExpiryShareFormat format,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final query = ref.read(expiryQueryProvider);
  final repo = ref.read(expiryRepositoryProvider);
  final symbol = ref.read(currencySymbolProvider);

  final items = <ExpiryItem>[];
  ExpiryCursor? cursor;
  do {
    final page = await repo.fetchPage(query, after: cursor, limit: 500);
    items.addAll(page.items);
    cursor = page.next;
  } while (cursor != null && items.length < maxExportRows);

  if (items.isEmpty) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.shareListEmpty)));
    return;
  }
  if (!context.mounted) return;

  final headers = ExportHeaders(
    medicine: l10n.exportColMedicine,
    batch: l10n.exportColBatch,
    expiry: l10n.exportColExpiry,
    daysLeft: l10n.exportColDaysLeft,
    status: l10n.exportColStatus,
    quantity: l10n.exportColQuantity,
    unitCost: symbol.isEmpty
        ? l10n.exportColUnitCost
        : '${l10n.exportColUnitCost} ($symbol)',
    value: symbol.isEmpty
        ? l10n.exportColValue
        : '${l10n.exportColValue} ($symbol)',
  );
  final rows = expiryExportRows(
    items,
    headers: headers,
    formatDate: (d) => formatDate(context, d),
    status: (i) => i.daysLeft < 0
        ? l10n.expiredAgo(-i.daysLeft)
        : l10n.daysLeft(i.daysLeft),
  );
  final today = dateOnly(ref.read(clockProvider).now());
  final day =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-'
      '${today.day.toString().padLeft(2, '0')}';
  final title = l10n.exportTextTitle(formatDate(context, today));

  // Encoding a big list is CPU work; keep it off the UI thread.
  final isCsv = format == ExpiryShareFormat.csv;
  final text = await _encodeInBackground(isCsv, title, rows);

  final dir = ref.read(exportDirProvider)..createSync(recursive: true);
  final file = File(
    p.join(dir.path, 'expiry-list-$day.${isCsv ? 'csv' : 'txt'}'),
  );
  await file.writeAsString(text, flush: true);
  await ref
      .read(fileExchangeProvider)
      .share(file, subject: l10n.shareListSubject(day));
}

/// A separate function so the isolate closure captures only plain data (a
/// closure created beside a `BuildContext` would drag it along and fail to
/// send).
Future<String> _encodeInBackground(
  bool csv,
  String title,
  List<List<String>> rows,
) => Isolate.run(() => csv ? encodeCsv(rows) : encodeText(title, rows));
