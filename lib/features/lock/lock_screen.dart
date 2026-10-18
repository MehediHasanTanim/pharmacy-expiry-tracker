import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/domain/security/app_lock.dart';
import 'package:pharmacy_expiry_tracker/features/lock/app_lock_controller.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Full-screen PIN pad shown over the app while it is locked. The phone's own
/// lock (fingerprint, face, screen lock) is offered beside it and is also the
/// way back in after a forgotten PIN.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _pin = '';
  String? _message;
  Timer? _countdown;
  int _waitSeconds = 0;
  bool _busy = false;
  bool _prompted = false;

  @override
  void initState() {
    super.initState();
    // Offer the system prompt once as the screen appears, like other apps.
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoPrompt());
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  Future<void> _autoPrompt() async {
    if (_prompted || !mounted) return;
    _prompted = true;
    final available = await ref.read(biometricAvailableProvider.future);
    if (!mounted) return;
    final wanted = ref.read(settingsProvider).value?.appLockBiometrics ?? true;
    if (available && wanted) await _device();
  }

  Future<void> _device() async {
    final l10n = AppLocalizations.of(context);
    await ref
        .read(appLockProvider.notifier)
        .unlockWithDevice(l10n.lockBiometricReason);
  }

  void _digit(String d) {
    if (_busy || _waitSeconds > 0 || _pin.length >= maxPinLength) return;
    setState(() {
      _pin += d;
      _message = null;
    });
  }

  void _back() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    if (_pin.length < minPinLength || _busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    final result = await ref.read(appLockProvider.notifier).unlockWithPin(_pin);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _pin = '';
      if (result.ok) return;
      if (result.lockedFor != null) {
        _startWait(result.lockedFor!.inSeconds + 1);
      } else {
        _message = result.attemptsLeft != null && result.attemptsLeft! > 0
            ? l10n.lockAttemptsLeft(result.attemptsLeft!)
            : l10n.lockWrongPin;
      }
    });
  }

  void _startWait(int seconds) {
    _waitSeconds = seconds;
    _countdown?.cancel();
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() {
        _waitSeconds--;
        if (_waitSeconds <= 0) {
          _waitSeconds = 0;
          t.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final device = ref.watch(settingsProvider).value?.appLockBiometrics ?? true;
    final available = ref.watch(biometricAvailableProvider).value ?? false;
    return Scaffold(
      key: const Key('lock-screen'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.lockEnterPin, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: true,
                    label: '${_pin.length}',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < maxPinLength; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(
                              i < _pin.length
                                  ? Icons.circle
                                  : Icons.circle_outlined,
                              size: 14,
                              color: i < minPinLength || i < _pin.length
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: Center(
                      child: Text(
                        _waitSeconds > 0
                            ? l10n.lockWait(_waitSeconds)
                            : (_message ?? ''),
                        key: const Key('lock-message'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ),
                  for (final row in const [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                  ])
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [for (final d in row) _key(d, l10n)],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _IconKey(
                        keyName: 'lock-back',
                        tooltip: l10n.lockDelete,
                        icon: Icons.backspace_outlined,
                        onPressed: _back,
                      ),
                      _key('0', l10n),
                      _IconKey(
                        keyName: 'lock-ok',
                        tooltip: l10n.actionConfirm,
                        icon: Icons.check_circle_outline,
                        onPressed: _pin.length >= minPinLength ? _submit : null,
                      ),
                    ],
                  ),
                  if (device && available) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      key: const Key('lock-device'),
                      onPressed: _device,
                      icon: const Icon(Icons.fingerprint),
                      label: Text(l10n.lockUseDevice),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    l10n.lockForgot,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _key(String d, AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.all(4),
    child: SizedBox(
      width: 80,
      height: 56,
      child: Semantics(
        label: l10n.lockDigit(d),
        button: true,
        excludeSemantics: true,
        child: FilledButton.tonal(
          key: Key('lock-$d'),
          onPressed: () => _digit(d),
          child: Text(d, style: const TextStyle(fontSize: 22)),
        ),
      ),
    ),
  );
}

class _IconKey extends StatelessWidget {
  const _IconKey({
    required this.keyName,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String keyName;
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(4),
    child: SizedBox(
      width: 80,
      height: 56,
      child: IconButton(
        key: Key(keyName),
        tooltip: tooltip,
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    ),
  );
}

/// Wraps the app: covers it with the [LockScreen] while locked, and locks it
/// when it has been in the background too long (S8-06).
class LockGate extends ConsumerStatefulWidget {
  const LockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual<bool?>(appLockActiveProvider, (_, active) {
      if (active != null) {
        ref.read(appLockProvider.notifier).sync(active: active);
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lock = ref.read(appLockProvider.notifier);
    switch (state) {
      case AppLifecycleState.paused || AppLifecycleState.hidden:
        lock.left();
      case AppLifecycleState.resumed:
        lock.returned();
      case AppLifecycleState.inactive || AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(appLockActiveProvider);
    final lock = ref.watch(appLockProvider);
    // Until we know whether a lock applies, show nothing rather than flash
    // the app and then cover it.
    if (active == null || !lock.initialized) {
      return const ColoredBox(color: Colors.transparent);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        // The app keeps running underneath (alerts, background work) but is
        // hidden from the user and from screen readers while locked.
        Offstage(
          offstage: lock.locked,
          child: ExcludeSemantics(
            excluding: lock.locked,
            child: TickerMode(enabled: !lock.locked, child: widget.child),
          ),
        ),
        // The gate sits above the app's Navigator, so give the lock screen
        // an Overlay of its own (tooltips need one).
        if (lock.locked)
          Overlay(
            initialEntries: [OverlayEntry(builder: (_) => const LockScreen())],
          ),
      ],
    );
  }
}
