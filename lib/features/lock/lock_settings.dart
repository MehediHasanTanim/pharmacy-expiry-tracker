import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/security/app_lock.dart';
import 'package:pharmacy_expiry_tracker/features/lock/app_lock_controller.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

const _timeouts = [0, 30, 60, 300];

/// The "App lock" block of the Settings screen (S8-06): switch, change PIN,
/// phone-lock unlocking, and the time in the background before it locks.
class LockSettings extends ConsumerWidget {
  const LockSettings({super.key});

  Future<void> _enable(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final pin = await showDialog<String>(
      context: context,
      builder: (_) => const _NewPinDialog(),
    );
    if (pin == null) return;
    await ref.read(pinStoreProvider).setPin(pin);
    ref.read(pinVersionProvider.notifier).bump();
    await ref
        .read(settingsRepositoryProvider)
        .update((s) => s.copyWith(appLockEnabled: true));
    messenger.showSnackBar(SnackBar(content: Text(l10n.lockEnabledSnack)));
  }

  /// Asks for the current PIN; true when it was right.
  Future<bool> _confirm(BuildContext context, WidgetRef ref) async {
    final pin = await showDialog<String>(
      context: context,
      builder: (_) => const _CurrentPinDialog(),
    );
    if (pin == null) return false;
    final r = await ref
        .read(pinStoreProvider)
        .verify(pin, ref.read(clockProvider).now());
    if (!r.ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).lockWrongPin)),
      );
    }
    return r.ok;
  }

  Future<void> _disable(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await _confirm(context, ref)) return;
    await ref.read(pinStoreProvider).clear();
    ref.read(pinVersionProvider.notifier).bump();
    await ref
        .read(settingsRepositoryProvider)
        .update((s) => s.copyWith(appLockEnabled: false));
    messenger.showSnackBar(SnackBar(content: Text(l10n.lockDisabledSnack)));
  }

  Future<void> _change(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await _confirm(context, ref)) return;
    if (!context.mounted) return;
    final pin = await showDialog<String>(
      context: context,
      builder: (_) => const _NewPinDialog(),
    );
    if (pin == null) return;
    await ref.read(pinStoreProvider).setPin(pin);
    messenger.showSnackBar(SnackBar(content: Text(l10n.lockChangedSnack)));
  }

  String _timeoutLabel(AppLocalizations l10n, int seconds) {
    if (seconds == 0) return l10n.settingsLockTimeoutNow;
    if (seconds < 60) return l10n.settingsLockTimeoutSeconds(seconds);
    return l10n.settingsLockTimeoutMinutes(seconds ~/ 60);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider).value;
    final active = ref.watch(appLockActiveProvider) ?? false;
    final device = ref.watch(biometricAvailableProvider).value ?? false;
    if (s == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          key: const Key('applock-switch'),
          title: Text(l10n.settingsLockSwitch),
          subtitle: Text(l10n.settingsLockHelp),
          value: active,
          onChanged: (on) =>
              unawaited(on ? _enable(context, ref) : _disable(context, ref)),
        ),
        if (active) ...[
          ListTile(
            key: const Key('applock-change'),
            title: Text(l10n.settingsLockChange),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => unawaited(_change(context, ref)),
          ),
          if (device)
            SwitchListTile(
              key: const Key('applock-device'),
              title: Text(l10n.settingsLockBiometrics),
              value: s.appLockBiometrics,
              onChanged: (v) => unawaited(
                ref
                    .read(settingsRepositoryProvider)
                    .update((x) => x.copyWith(appLockBiometrics: v)),
              ),
            ),
          ListTile(
            title: Text(l10n.settingsLockTimeout),
            trailing: DropdownButton<int>(
              key: const Key('applock-timeout'),
              value: _timeouts.contains(s.appLockTimeoutSeconds)
                  ? s.appLockTimeoutSeconds
                  : 30,
              items: [
                for (final t in _timeouts)
                  DropdownMenuItem(
                    value: t,
                    child: Text(_timeoutLabel(l10n, t)),
                  ),
              ],
              onChanged: (v) {
                if (v != null) {
                  unawaited(
                    ref
                        .read(settingsRepositoryProvider)
                        .update((x) => x.copyWith(appLockTimeoutSeconds: v)),
                  );
                }
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _NewPinDialog extends StatefulWidget {
  const _NewPinDialog();

  @override
  State<_NewPinDialog> createState() => _NewPinDialogState();
}

class _NewPinDialogState extends State<_NewPinDialog> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.lockSetTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.lockSetHint),
          TextField(
            key: const Key('pin-new'),
            controller: _a,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: maxPinLength,
            decoration: InputDecoration(labelText: l10n.lockPin),
          ),
          TextField(
            key: const Key('pin-confirm'),
            controller: _b,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: maxPinLength,
            decoration: InputDecoration(
              labelText: l10n.lockPinConfirm,
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const Key('pin-save'),
          onPressed: () {
            if (!isValidPin(_a.text)) {
              setState(() => _error = l10n.lockPinInvalid);
            } else if (_a.text != _b.text) {
              setState(() => _error = l10n.lockPinMismatch);
            } else {
              Navigator.pop(context, _a.text);
            }
          },
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}

class _CurrentPinDialog extends StatefulWidget {
  const _CurrentPinDialog();

  @override
  State<_CurrentPinDialog> createState() => _CurrentPinDialogState();
}

class _CurrentPinDialogState extends State<_CurrentPinDialog> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.lockCurrentTitle),
      content: TextField(
        key: const Key('pin-current'),
        controller: _c,
        autofocus: true,
        obscureText: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: maxPinLength,
        decoration: InputDecoration(labelText: l10n.lockPin),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const Key('pin-current-ok'),
          onPressed: () => Navigator.pop(context, _c.text),
          child: Text(l10n.actionConfirm),
        ),
      ],
    );
  }
}
