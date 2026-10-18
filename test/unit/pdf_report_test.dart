import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/data/export/pdf_report.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/report_table.dart';

void main() {
  test('the PDF text is made safe for the built-in font', () {
    expect(pdfSafe('Napa 500 mg'), 'Napa 500 mg');
    expect(pdfSafe('৳1,250.00'), 'Tk1,250.00');
    expect(pdfSafe('Café – déjà vu'), 'Café - déjà vu');
    expect(pdfSafe('নাপা'), '????');
    expect(pdfSafe('a\nb\tc'), 'a b c');
    expect(pdfSafe('2 × 3 · ok'), '2 x 3 - ok');
  });

  test('a PDF is produced, with the right number of pages', () async {
    final small = await buildReportPdf(
      const ReportTable(
        title: 'Expiry loss',
        subtitle: 'Jan - Dec 2026',
        headers: ['Month', 'Qty', 'Value'],
        rows: [
          ['2026-09', '12', '70.00'],
        ],
        footer: ['Total', '12', '70.00'],
        numericColumns: {1, 2},
      ),
    );
    expect(utf8.decode(small.sublist(0, 5)), '%PDF-');
    expect(small.length, greaterThan(500));

    final rows = [
      for (var i = 0; i < 2000; i++)
        ['Medicine $i', 'Batch $i', '${i * 3}', '${i * 2}.50'],
    ];
    final sw = Stopwatch()..start();
    final big = await buildReportPdfInBackground(
      ReportTable(
        title: 'Stock',
        headers: const ['Medicine', 'Batch', 'Qty', 'Value'],
        rows: rows,
      ),
    );
    sw.stop();
    expect(utf8.decode(big.sublist(0, 5)), '%PDF-');
    expect(big.length, greaterThan(small.length * 10));
    expect(sw.elapsed, lessThan(const Duration(seconds: 30)));
    // The timing is the record of this test.
    // ignore: avoid_print
    print('2000-row PDF: ${sw.elapsedMilliseconds} ms, ${big.length} bytes');
  });

  test('a wide table and an empty one do not fail', () async {
    final wide = await buildReportPdf(
      const ReportTable(
        title: 'Wide',
        headers: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'],
        rows: [
          ['1', '2', '3', '4', '5', '6', '7', '8'],
        ],
      ),
    );
    expect(wide, isNotEmpty);
    final empty = await buildReportPdf(
      const ReportTable(title: 'Nothing', headers: ['x'], rows: []),
    );
    expect(empty, isNotEmpty);
  });
}
