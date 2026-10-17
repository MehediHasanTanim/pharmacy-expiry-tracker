import 'package:flutter/material.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/expiry_bucket.dart';

/// Colour + icon per urgency level. Urgency is never conveyed by colour alone.
@immutable
class UrgencyStyle {
  const UrgencyStyle(this.color, this.icon);
  final Color color;
  final IconData icon;
}

class UrgencyColors extends ThemeExtension<UrgencyColors> {
  const UrgencyColors({required this.styles});

  factory UrgencyColors.forBrightness(Brightness b) {
    final dark = b == Brightness.dark;
    return UrgencyColors(
      styles: {
        ExpiryBucket.expired: UrgencyStyle(
          dark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
          Icons.dangerous_outlined,
        ),
        ExpiryBucket.d30: UrgencyStyle(
          dark ? const Color(0xFFFFB74D) : const Color(0xFFB85C00),
          Icons.warning_amber_rounded,
        ),
        ExpiryBucket.d60: UrgencyStyle(
          dark ? const Color(0xFFFFD54F) : const Color(0xFF8A6D00),
          Icons.schedule,
        ),
        ExpiryBucket.d90: UrgencyStyle(
          dark ? const Color(0xFFE6EE9C) : const Color(0xFF5F6B00),
          Icons.hourglass_bottom,
        ),
        ExpiryBucket.ok: UrgencyStyle(
          dark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
          Icons.check_circle_outline,
        ),
      },
    );
  }

  final Map<ExpiryBucket, UrgencyStyle> styles;

  UrgencyStyle of(ExpiryBucket bucket) => styles[bucket]!;

  @override
  UrgencyColors copyWith({Map<ExpiryBucket, UrgencyStyle>? styles}) =>
      UrgencyColors(styles: styles ?? this.styles);

  @override
  UrgencyColors lerp(ThemeExtension<UrgencyColors>? other, double t) =>
      t < 0.5 || other is! UrgencyColors ? this : other;
}

abstract final class AppTheme {
  static const _seed = Color(0xFF00796B);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: brightness,
      ),
      extensions: [UrgencyColors.forBrightness(brightness)],
      visualDensity: VisualDensity.standard,
    );
  }
}
