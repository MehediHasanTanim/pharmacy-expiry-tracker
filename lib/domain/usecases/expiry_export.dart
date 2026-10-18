import 'package:pharmacy_expiry_tracker/domain/entities/expiry.dart';

/// Column titles, in the user's language.
class ExportHeaders {
  const ExportHeaders({
    required this.medicine,
    required this.batch,
    required this.expiry,
    required this.daysLeft,
    required this.status,
    required this.quantity,
    required this.unitCost,
    required this.value,
  });

  final String medicine;
  final String batch;
  final String expiry;
  final String daysLeft;
  final String status;
  final String quantity;
  final String unitCost;
  final String value;

  List<String> get row => [
    medicine,
    batch,
    expiry,
    daysLeft,
    status,
    quantity,
    unitCost,
    value,
  ];
}

/// Rows of an exported expiry list (EXP-11, RPT-4): header first, then one
/// row per batch. Amounts are plain decimals (no currency symbol or grouping)
/// so spreadsheets read them as numbers.
List<List<String>> expiryExportRows(
  List<ExpiryItem> items, {
  required ExportHeaders headers,
  required String Function(DateTime) formatDate,
  required String Function(ExpiryItem) status,
}) {
  String money(int minor) => (minor / 100).toStringAsFixed(2);
  return [
    headers.row,
    for (final i in items)
      [
        i.medicine.displayName,
        i.batch.batchNumber,
        formatDate(i.expiry.date),
        '${i.daysLeft}',
        status(i),
        '${i.batch.quantityOnHand}',
        // Empty cells, not zeros, when no cost price is known. Fixed columns,
        // so these cannot be collection-if elements.
        // ignore: prefer_if_elements_to_conditional_expressions
        i.batch.costPrice == null ? '' : money(i.batch.costPrice!.minor),
        // Same as above.
        // ignore: prefer_if_elements_to_conditional_expressions
        i.valueAtRisk == null ? '' : money(i.valueAtRisk!.minor),
      ],
  ];
}

/// RFC 4180 CSV with a byte-order mark so Excel reads it as UTF-8. Cells that
/// begin with a character spreadsheets treat as a formula are neutralised, so
/// a medicine named "=HYPERLINK(...)" cannot run anything when opened.
String encodeCsv(List<List<String>> rows) {
  String cell(String v) {
    var s = v;
    if (s.isNotEmpty &&
        '=+-@\t\r'.contains(s[0]) &&
        double.tryParse(s) == null) {
      s = "'$s";
    }
    if (s.contains(',') ||
        s.contains('"') ||
        s.contains('\n') ||
        s.contains('\r')) {
      s = '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  final out = StringBuffer('\u{FEFF}');
  for (final r in rows) {
    out
      ..writeAll(r.map(cell), ',')
      ..write('\r\n');
  }
  return out.toString();
}

/// A plain-text version, one batch per line, for pasting into a chat or mail.
String encodeText(String title, List<List<String>> rows) {
  final out = StringBuffer()..writeln(title);
  for (final r in rows.skip(1)) {
    // medicine, batch, expiry, days, status, quantity
    out.writeln('${r[0]} · ${r[1]} · ${r[2]} · ${r[4]} · ×${r[5]}');
  }
  return out.toString();
}
