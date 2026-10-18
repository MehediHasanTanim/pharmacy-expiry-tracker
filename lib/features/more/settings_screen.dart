import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/lock/lock_settings.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Pharmacy, expiry and display settings in one place (SET-1, 2, 8, 9, 11).
/// Alert timing lives under Alert settings.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _windows = [30, 60, 90, 120, 180, 365];

  final _name = TextEditingController();
  final _currency = TextEditingController();
  final _a = TextEditingController();
  final _b = TextEditingController();
  final _c = TextEditingController();
  String? _bucketError;
  bool _filled = false;

  Future<void> _update(AppSettings Function(AppSettings s) change) =>
      ref.read(settingsRepositoryProvider).update(change);

  @override
  void dispose() {
    for (final c in [_name, _currency, _a, _b, _c]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Fills the text fields once, from the saved settings.
  void _fill(AppSettings s) {
    if (_filled) return;
    _filled = true;
    _name.text = s.pharmacyName;
    _currency.text = s.currencySymbol;
    _a.text = '${s.bucketThresholds[0]}';
    _b.text = '${s.bucketThresholds[1]}';
    _c.text = '${s.bucketThresholds[2]}';
  }

  Future<void> _saveBuckets() async {
    final l10n = AppLocalizations.of(context);
    final a = int.tryParse(_a.text.trim());
    final b = int.tryParse(_b.text.trim());
    final c = int.tryParse(_c.text.trim());
    if (a == null || b == null || c == null || a < 1 || !(a < b && b < c)) {
      setState(() => _bucketError = l10n.errBucketsOrder);
      return;
    }
    setState(() => _bucketError = null);
    await _update((s) => s.copyWith(bucketThresholds: [a, b, c]));
  }

  String _dateLabel(AppLocalizations l10n, String pattern) {
    if (pattern.isEmpty) return l10n.dateFormatDevice;
    final sample = DateFormat(pattern).format(DateTime(2026, 11, 5));
    return '$pattern  ·  $sample';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final loaded = ref.watch(settingsProvider);
    final s = loaded.value ?? const AppSettings();
    if (loaded.hasValue) _fill(s);

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Semantics(
        header: true,
        child: Text(text, style: theme.textTheme.titleMedium),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          header(l10n.settingsPharmacy),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              key: const Key('settings-name'),
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.fieldPharmacyName,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  unawaited(_update((s) => s.copyWith(pharmacyName: v.trim()))),
            ),
          ),
          header(l10n.settingsExpiry),
          ListTile(
            title: Text(l10n.settingsWindow),
            subtitle: Text(l10n.settingsWindowHelp),
            trailing: DropdownButton<int>(
              key: const Key('settings-window'),
              value: _windows.contains(s.nearExpiryWindowDays)
                  ? s.nearExpiryWindowDays
                  : 90,
              items: [
                for (final w in _windows)
                  DropdownMenuItem(
                    value: w,
                    child: Text(l10n.settingsWindowDays(w)),
                  ),
              ],
              onChanged: (v) {
                if (v != null) {
                  unawaited(
                    _update((s) => s.copyWith(nearExpiryWindowDays: v)),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l10n.settingsBucketsHelp,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                for (final (key, controller, label) in [
                  ('settings-bucket-a', _a, l10n.settingsBucketA),
                  ('settings-bucket-b', _b, l10n.settingsBucketB),
                  ('settings-bucket-c', _c, l10n.settingsBucketC),
                ])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextField(
                        key: Key(key),
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: label,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => unawaited(_saveBuckets()),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_bucketError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                _bucketError!,
                key: const Key('settings-bucket-error'),
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          header(l10n.settingsDisplay),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              key: const Key('settings-currency'),
              controller: _currency,
              decoration: InputDecoration(
                labelText: l10n.settingsCurrency,
                helperText: l10n.settingsCurrencyHelp,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => unawaited(
                _update((s) => s.copyWith(currencySymbol: v.trim())),
              ),
            ),
          ),
          ListTile(
            title: Text(l10n.settingsDateFormat),
            trailing: DropdownButton<String>(
              key: const Key('settings-date-format'),
              value: dateFormatChoices.contains(s.dateFormat)
                  ? s.dateFormat
                  : '',
              items: [
                for (final p in dateFormatChoices)
                  DropdownMenuItem(value: p, child: Text(_dateLabel(l10n, p))),
              ],
              onChanged: (v) {
                if (v != null) {
                  unawaited(_update((s) => s.copyWith(dateFormat: v)));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.settingsTheme),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  key: const Key('settings-theme'),
                  segments: [
                    ButtonSegment(
                      value: 'system',
                      label: Text(l10n.themeSystem),
                      icon: const Icon(Icons.brightness_auto),
                    ),
                    ButtonSegment(
                      value: 'light',
                      label: Text(l10n.themeLight),
                      icon: const Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: 'dark',
                      label: Text(l10n.themeDark),
                      icon: const Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                  selected: {s.themeMode},
                  onSelectionChanged: (v) =>
                      unawaited(_update((s) => s.copyWith(themeMode: v.first))),
                ),
              ],
            ),
          ),
          header(l10n.settingsLockSection),
          const LockSettings(),
        ],
      ),
    );
  }
}
