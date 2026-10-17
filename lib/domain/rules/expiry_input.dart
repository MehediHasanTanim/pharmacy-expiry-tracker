import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';

enum ExpiryWarning { inPast, farFuture }

/// Result of parsing the text a user typed into the expiry field.
sealed class ExpiryParse {
  const ExpiryParse();
}

/// Nothing (or not enough) typed yet.
class ExpiryIncomplete extends ExpiryParse {
  const ExpiryIncomplete();
}

class ExpiryInvalid extends ExpiryParse {
  const ExpiryInvalid();
}

class ExpiryParsed extends ExpiryParse {
  const ExpiryParsed(this.value);

  final ExpiryDate value;
}

/// Parses `MM / YYYY` (or `DD / MM / YYYY` when [exact]). Two-digit years mean
/// 20YY. Month-only input resolves to the last day of the month.
ExpiryParse parseExpiryInput({
  required String month,
  required String year,
  String day = '',
  bool exact = false,
}) {
  final m = month.trim();
  final y = year.trim();
  final d = day.trim();
  if (m.isEmpty || y.isEmpty || (exact && d.isEmpty)) {
    return const ExpiryIncomplete();
  }
  final mi = int.tryParse(m);
  var yi = int.tryParse(y);
  final di = exact ? int.tryParse(d) : null;
  if (mi == null || yi == null || (exact && di == null)) {
    return const ExpiryInvalid();
  }
  if (y.length == 2) {
    yi += 2000;
  } else if (y.length != 4) {
    return const ExpiryIncomplete();
  }
  if (mi < 1 || mi > 12 || yi < 2000 || yi > 2100) {
    return const ExpiryInvalid();
  }
  final value = exact
      ? ExpiryDate.tryDay(yi, mi, di!)
      : ExpiryDate.monthYear(yi, mi);
  return value == null ? const ExpiryInvalid() : ExpiryParsed(value);
}

/// Non-blocking warning for a plausible-but-unusual expiry.
ExpiryWarning? expiryWarning(ExpiryDate expiry, DateTime today) {
  final days = expiry.daysUntil(today);
  if (days < 0) return ExpiryWarning.inPast;
  if (days > 365 * 10) return ExpiryWarning.farFuture;
  return null;
}
