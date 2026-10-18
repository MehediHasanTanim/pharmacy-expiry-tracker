import 'package:flutter/material.dart';
import 'package:pharmacy_expiry_tracker/features/alerts/alert_permission.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabHome)),
      body: ListView(
        children: [
          const AlertPermissionBanner(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                l10n.emptyHome,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
