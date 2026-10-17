import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// An amount of money in integer minor units (e.g. cents), never a double.
/// Currency is a global app setting, so it is not carried on the value.
@immutable
class Money implements Comparable<Money> {
  const Money(this.minor);

  static const zero = Money(0);

  /// Parses a decimal string such as `12`, `12.5` or `12.50` ("," or "." as
  /// separator) into minor units. Returns null if it is not a valid amount.
  static Money? tryParse(String input, {int decimalDigits = 2}) {
    final s = input.trim().replaceAll(',', '.');
    final match = RegExp(r'^(-)?(\d+)(?:\.(\d*))?$').firstMatch(s);
    if (match == null) return null;
    final fraction = match.group(3) ?? '';
    if (fraction.length > decimalDigits) return null;
    final whole = int.parse(match.group(2)!);
    final frac = fraction.padRight(decimalDigits, '0');
    final scale = _pow10(decimalDigits);
    final value = whole * scale + (frac.isEmpty ? 0 : int.parse(frac));
    return Money(match.group(1) != null ? -value : value);
  }

  final int minor;

  Money operator +(Money o) => Money(minor + o.minor);
  Money operator -(Money o) => Money(minor - o.minor);
  Money operator -() => Money(-minor);
  Money times(int quantity) => Money(minor * quantity);

  bool get isNegative => minor < 0;

  /// Formats with grouping per [locale]. [symbol] defaults to none so callers
  /// pass the user's configured currency symbol.
  String format({String? locale, String symbol = '', int decimalDigits = 2}) {
    final f = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return f.format(minor / _pow10(decimalDigits)).trim();
  }

  static int _pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }

  @override
  int compareTo(Money other) => minor.compareTo(other.minor);

  @override
  bool operator ==(Object other) => other is Money && other.minor == minor;

  @override
  int get hashCode => minor.hashCode;

  @override
  String toString() => 'Money($minor)';
}
