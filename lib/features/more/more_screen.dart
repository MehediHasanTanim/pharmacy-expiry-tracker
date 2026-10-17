import 'package:flutter/material.dart';
import 'package:pharmacy_expiry_tracker/features/placeholder_screen.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderScreen(title: l10n.tabMore, message: l10n.emptyMore);
  }
}
