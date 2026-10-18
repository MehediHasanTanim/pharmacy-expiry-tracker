import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/expiry_export.dart';

void main() {
  const headers = ExportHeaders(
    medicine: 'Medicine',
    batch: 'Batch',
    expiry: 'Expiry date',
    daysLeft: 'Days left',
    status: 'Status',
    quantity: 'Quantity',
    unitCost: 'Unit cost',
    value: 'Value at risk',
  );

  test('CSV starts with a byte-order mark and uses CRLF rows', () {
    final csv = encodeCsv([
      ['a', 'b'],
      ['1', '2'],
    ]);
    expect(csv, '\u{FEFF}a,b\r\n1,2\r\n');
  });

  test('commas, quotes and line breaks are quoted', () {
    final csv = encodeCsv([
      ['Napa, 500 mg', 'say "hi"', 'two\nlines'],
    ]);
    expect(csv, '\u{FEFF}"Napa, 500 mg","say ""hi""","two\nlines"\r\n');
  });

  test('cells that a spreadsheet would run as formulas are neutralised', () {
    final csv = encodeCsv([
      ['=HYPERLINK("http://x")', '+1+1', '@SUM(A1)', '-cmd', '-3', '12.50'],
    ]);
    final cells = csv.substring(1).trim();
    expect(cells, startsWith('"\'=HYPERLINK(""http://x"")",'));
    expect(cells, contains(",'+1+1,"));
    expect(cells, contains(",'@SUM(A1),"));
    expect(cells, contains(",'-cmd,"));
    // Genuine negative numbers stay numbers.
    expect(cells, endsWith(',-3,12.50'));
  });

  test('text export is one line per batch under the title', () {
    final text = encodeText('Expiry list', [
      headers.row,
      ['Napa 500 mg', 'A1', '31/03/2027', '165', '165 days left', '12', '', ''],
    ]);
    expect(
      text,
      'Expiry list\nNapa 500 mg · A1 · 31/03/2027 · 165 days left · ×12\n',
    );
  });
}
