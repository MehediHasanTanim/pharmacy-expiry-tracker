import 'package:flutter/foundation.dart';

/// A report ready to print or save: plain text cells, so it can be handed to
/// a background isolate and turned into CSV or PDF without touching the
/// database or the UI.
@immutable
class ReportTable {
  const ReportTable({
    required this.title,
    required this.headers,
    required this.rows,
    this.subtitle = '',
    this.footer = const [],
    this.numericColumns = const {},
  });

  final String title;

  /// A line under the title: the period, the supplier, the date made.
  final String subtitle;
  final List<String> headers;
  final List<List<String>> rows;

  /// A totals line, one cell per column (or empty for none).
  final List<String> footer;

  /// Columns to right-align (amounts, quantities).
  final Set<int> numericColumns;

  /// Header, rows and totals as one grid, for CSV.
  List<List<String>> get grid => [
    headers,
    ...rows,
    if (footer.isNotEmpty) footer,
  ];
}
