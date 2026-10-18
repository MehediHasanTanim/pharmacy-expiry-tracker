import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// First-run flow: three intro cards, a short setup (pharmacy name, currency,
/// near-expiry window), the notification permission, and a prompt to add the
/// first medicine (HOM-5). Every step can be skipped; the defaults work.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _lastPage = 5;
  static const _setupPage = 3;
  static const _currencies = ['', '৳', '₹', 'Rs', r'$', '€', '£'];
  static const _windows = [30, 60, 90, 120, 180];

  final _name = TextEditingController();
  int _page = 0;
  String _currency = '';
  int _window = 90;
  bool _alertsAllowed = false;
  bool _busy = false;
  bool _currencyChosen = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// A sensible starting currency from the device's region, if it has one.
  String _deviceCurrency(BuildContext context) {
    try {
      final locale = Localizations.localeOf(context).toString();
      final symbol = NumberFormat.simpleCurrency(locale: locale).currencySymbol;
      return _currencies.contains(symbol) ? symbol : '';
    } on Object {
      return '';
    }
  }

  void _go(int page) => setState(() => _page = page.clamp(0, _lastPage));

  Future<void> _turnOnAlerts() async {
    setState(() => _busy = true);
    try {
      final plugin = ref.read(notificationPluginProvider);
      await plugin.initialize(onSelected: (_) {});
      final result = await plugin.requestPermissions();
      if (mounted) setState(() => _alertsAllowed = result.notifications);
      await ref
          .read(settingsRepositoryProvider)
          .update((s) => s.copyWith(alertPermissionAsked: true));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Saves the choices and leaves onboarding for good.
  Future<void> _finish({required bool addFirst}) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(settingsRepositoryProvider)
          .update(
            (s) => s.copyWith(
              pharmacyName: _name.text.trim(),
              currencySymbol: _currency,
              nearExpiryWindowDays: _window,
              onboardingDone: true,
            ),
          );
      if (!mounted) return;
      // The router sends the user Home once the setting is saved.
      context.go(Routes.home);
      if (addFirst) unawaited(context.push('${Routes.stock}/medicine/new'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (!_currencyChosen) {
      _currency = _deviceCurrency(context);
      _currencyChosen = true;
    }

    Widget intro(IconData icon, String title, String body, {required Key key}) {
      return Padding(
        key: key,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 96, color: theme.colorScheme.primary),
            const SizedBox(height: 32),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final pages = <Widget>[
      intro(
        Icons.event_available_outlined,
        l10n.onb1Title,
        l10n.onb1Body,
        key: const Key('onb-page-0'),
      ),
      intro(
        Icons.notifications_active_outlined,
        l10n.onb2Title,
        l10n.onb2Body,
        key: const Key('onb-page-1'),
      ),
      intro(
        Icons.local_shipping_outlined,
        l10n.onb3Title,
        l10n.onb3Body,
        key: const Key('onb-page-2'),
      ),
      // Setup
      ListView(
        key: const Key('onb-page-3'),
        padding: const EdgeInsets.all(24),
        children: [
          Text(l10n.onbSetupTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(l10n.onbSetupBody),
          const SizedBox(height: 24),
          TextField(
            key: const Key('onb-name'),
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.fieldPharmacyName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: const Key('onb-currency'),
            initialValue: _currency,
            decoration: InputDecoration(
              labelText: l10n.settingsCurrency,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final c in _currencies)
                DropdownMenuItem(
                  value: c,
                  child: Text(c.isEmpty ? l10n.supplierNone : c),
                ),
            ],
            onChanged: (v) => setState(() => _currency = v ?? ''),
          ),
          const SizedBox(height: 16),
          Text(l10n.settingsWindow, style: theme.textTheme.titleSmall),
          Text(l10n.settingsWindowHelp, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final w in _windows)
                ChoiceChip(
                  key: Key('onb-window-$w'),
                  label: Text(l10n.settingsWindowDays(w)),
                  selected: _window == w,
                  onSelected: (_) => setState(() => _window = w),
                ),
            ],
          ),
        ],
      ),
      // Alerts
      Padding(
        key: const Key('onb-page-4'),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _alertsAllowed
                  ? Icons.notifications_active
                  : Icons.notifications_outlined,
              size: 96,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.onbAlertsTitle,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(l10n.onbAlertsBody, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (_alertsAllowed)
              Row(
                key: const Key('onb-alerts-on'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(l10n.healthAllowed),
                ],
              )
            else
              FilledButton(
                key: const Key('onb-allow-alerts'),
                onPressed: _busy ? null : _turnOnAlerts,
                child: Text(l10n.permissionAllow),
              ),
          ],
        ),
      ),
      // Done
      Padding(
        key: const Key('onb-page-5'),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 96, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              l10n.onbDoneTitle,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(l10n.onbDoneBody, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              l10n.onboardingBackupNote,
              key: const Key('onb-backup-note'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('onb-add-first'),
                onPressed: _busy ? null : () => _finish(addFirst: true),
                child: Text(l10n.onbAddFirst),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                key: const Key('onb-explore'),
                onPressed: _busy ? null : () => _finish(addFirst: false),
                child: Text(l10n.onbExplore),
              ),
            ),
          ],
        ),
      ),
    ];

    final onIntro = _page < _setupPage;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: onIntro
                  ? TextButton(
                      key: const Key('onb-skip'),
                      onPressed: _busy ? null : () => _finish(addFirst: false),
                      child: Text(l10n.onbSkip),
                    )
                  : const SizedBox(height: 48),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: KeyedSubtree(key: ValueKey(_page), child: pages[_page]),
              ),
            ),
            Semantics(
              label: l10n.onbStep(_page + 1, _lastPage + 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i <= _lastPage; i++)
                    Container(
                      margin: const EdgeInsets.all(4),
                      width: i == _page ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_page > 0)
                    TextButton(
                      key: const Key('onb-back'),
                      onPressed: _busy ? null : () => _go(_page - 1),
                      child: Text(l10n.onbBack),
                    ),
                  const Spacer(),
                  if (_page < _lastPage)
                    FilledButton(
                      key: const Key('onb-next'),
                      onPressed: _busy ? null : () => _go(_page + 1),
                      child: Text(
                        _page == _setupPage - 1 ? l10n.onbStart : l10n.onbNext,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
