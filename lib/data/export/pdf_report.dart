import 'dart:isolate';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pharmacy_expiry_tracker/domain/entities/report_table.dart';

/// The PDF uses the built-in Helvetica, which covers Latin-1 only. Text in
/// other scripts (for example Bengali medicine names) would draw as blanks, so
/// it is replaced by "?" rather than silently lost; the CSV export keeps the
/// original text. A few currency signs get their usual ASCII spelling.
String pdfSafe(String s) {
  final b = StringBuffer();
  for (final r in s.runes) {
    if (r == 0x09B3 || r == 0x09F3) {
      b.write('Tk'); // Bengali taka sign
    } else if (r == 0x20B9) {
      b.write('Rs');
    } else if (r == 0x20AC) {
      b.write('EUR');
    } else if (r == 0x2013 || r == 0x2014) {
      b.write('-');
    } else if (r == 0x2018 || r == 0x2019) {
      b.write("'");
    } else if (r == 0x201C || r == 0x201D) {
      b.write('"');
    } else if (r == 0x2022 || r == 0x00B7) {
      b.write('-');
    } else if (r == 0x00D7) {
      b.write('x');
    } else if (r == 0x0A || r == 0x0D || r == 0x09) {
      b.write(' ');
    } else if (r < 0x20 || (r > 0x7E && r < 0xA0)) {
      b.write('?');
    } else if (r <= 0xFF) {
      b.writeCharCode(r);
    } else {
      b.write('?');
    }
  }
  return b.toString();
}

/// Draws [table] as a PDF. Runs on whatever isolate calls it; use
/// [buildReportPdfInBackground] from the UI.
Future<Uint8List> buildReportPdf(ReportTable table) async {
  final wide = table.headers.length > 6;
  final doc = pw.Document(
    title: pdfSafe(table.title),
    creator: 'Expiry Tracker',
  );
  const headerStyle = pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold);
  const cellStyle = pw.TextStyle(fontSize: 9);
  final align = {
    for (final c in table.numericColumns) c: pw.Alignment.centerRight,
  };

  List<List<String>> safe(List<List<String>> rows) => [
    for (final r in rows) [for (final c in r) pdfSafe(c)],
  ];

  doc.addPage(
    pw.MultiPage(
      pageFormat: wide ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      // The default stops at 20 pages; a big stock list can run to hundreds.
      maxPages: 5000,
      header: (context) => context.pageNumber == 1
          ? pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  pdfSafe(table.title),
                  style: const pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (table.subtitle.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 4),
                    child: pw.Text(
                      pdfSafe(table.subtitle),
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                pw.SizedBox(height: 12),
              ],
            )
          : pw.SizedBox(height: 8),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          '${context.pageNumber} / ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 8),
        ),
      ),
      build: (context) => [
        pw.TableHelper.fromTextArray(
          headers: [for (final h in table.headers) pdfSafe(h)],
          data: safe(
            table.footer.isEmpty ? table.rows : [...table.rows, table.footer],
          ),
          headerStyle: headerStyle,
          cellStyle: cellStyle,
          cellAlignments: align,
          headerAlignments: align,
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 3,
          ),
          border: const pw.TableBorder(
            horizontalInside: pw.BorderSide(
              color: PdfColors.grey400,
              width: 0.3,
            ),
            bottom: pw.BorderSide(color: PdfColors.grey600, width: 0.5),
          ),
        ),
      ],
    ),
  );
  return doc.save();
}

/// [buildReportPdf] on a background isolate, so a long report does not
/// freeze the screen.
Future<Uint8List> buildReportPdfInBackground(ReportTable table) =>
    Isolate.run(() => buildReportPdf(table));
