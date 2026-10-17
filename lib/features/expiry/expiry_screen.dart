import 'package:flutter/material.dart';
import 'package:pharmacy_expiry_tracker/features/placeholder_screen.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

class ExpiryScreen extends StatelessWidget {
  const ExpiryScreen({this.bucket, this.date, super.key});

  /// Deep-link filters (`?bucket=` / `?date=`); applied in Sprint 2.
  final String? bucket;
  final String? date;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderScreen(title: l10n.tabExpiry, message: l10n.emptyExpiry);
  }
}
