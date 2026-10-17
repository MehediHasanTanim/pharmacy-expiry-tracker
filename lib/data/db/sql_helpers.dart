import 'package:drift/drift.dart';

/// True when [column] contains [needle] literally.
///
/// Drift's `contains` builds a `LIKE '%needle%'`, so `%` and `_` typed by the
/// user act as wildcards. `instr` has no special characters. It is
/// case-sensitive, which is fine because searchable columns are stored
/// normalised (lower-case search text, upper-case batch numbers).
Expression<bool> containsLiteral(Expression<String> column, String needle) {
  return FunctionCallExpression<int>('instr', [
    column,
    Variable<String>(needle),
  ]).isBiggerThanValue(0);
}
