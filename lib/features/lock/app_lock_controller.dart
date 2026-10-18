import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/data/security/local_biometric_auth.dart';
import 'package:pharmacy_expiry_tracker/data/security/secure_pin_store.dart';
import 'package:pharmacy_expiry_tracker/domain/security/app_lock.dart';

final pinStoreProvider = Provider<PinStore>(
  (ref) => SecurePinStore(const PlatformSecretStore()),
);

final biometricAuthProvider = Provider<BiometricAuth>(
  (ref) => LocalBiometricAuth(),
);

/// Bumped whenever the PIN is set or cleared, so providers that look at it
/// refresh.
final pinVersionProvider = NotifierProvider<_Counter, int>(_Counter.new);

class _Counter extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

/// Whether this phone has a PIN.
final hasPinProvider = FutureProvider<bool>((ref) async {
  ref.watch(pinVersionProvider);
  try {
    return await ref.watch(pinStoreProvider).hasPin();
  } on Object catch (e, st) {
    // If secure storage cannot be read, do not lock the user out of their own
    // data; the failure is logged.
    ref.read(errorLogProvider).record('pin-store', e, st);
    return false;
  }
});

/// The lock is really on: switched on in settings **and** a PIN exists here.
/// (A backup restored from another phone can say "on" without a PIN; that must
/// not lock the user out.) Null while still loading.
final appLockActiveProvider = Provider<bool?>((ref) {
  final enabled = ref.watch(
    settingsProvider.select((s) => s.value?.appLockEnabled),
  );
  final pin = ref.watch(hasPinProvider).value;
  if (enabled == null || pin == null) return null;
  return enabled && pin;
});

final biometricAvailableProvider = FutureProvider<bool>(
  (ref) => ref.watch(biometricAuthProvider).isAvailable(),
);

/// Whether the screen is locked (S8-06). The notifications and the alert
/// engine do not depend on this; only what the user can see is covered.
class AppLockState {
  const AppLockState({this.initialized = false, this.locked = false});

  final bool initialized;
  final bool locked;
}

class AppLockController extends Notifier<AppLockState> {
  DateTime? _leftAt;

  /// True while a system prompt (fingerprint, face) is up: the app is
  /// "inactive" then, and that must not count as leaving it.
  bool authenticating = false;

  @override
  AppLockState build() => const AppLockState();

  /// Called as the lock setting becomes known or changes.
  void sync({required bool active}) {
    if (!state.initialized) {
      state = AppLockState(initialized: true, locked: active);
    } else if (!active && state.locked) {
      state = const AppLockState(initialized: true);
    }
  }

  void lockNow() {
    if (ref.read(appLockActiveProvider) ?? false) {
      state = const AppLockState(initialized: true, locked: true);
    }
  }

  /// The app went to the background.
  void left() {
    if (authenticating) return;
    // Keep the first time: the way back passes through "hidden" again.
    _leftAt ??= ref.read(clockProvider).now();
  }

  /// The app came back; locks if it was away for the configured time.
  void returned() {
    final away = _leftAt;
    _leftAt = null;
    if (away == null || state.locked) return;
    if (!(ref.read(appLockActiveProvider) ?? false)) return;
    final timeout = Duration(
      seconds: ref.read(settingsProvider).value?.appLockTimeoutSeconds ?? 30,
    );
    if (ref.read(clockProvider).now().difference(away) >= timeout) {
      state = const AppLockState(initialized: true, locked: true);
    }
  }

  Future<PinCheck> unlockWithPin(String pin) async {
    final r = await ref
        .read(pinStoreProvider)
        .verify(pin, ref.read(clockProvider).now());
    if (r.ok) state = const AppLockState(initialized: true);
    return r;
  }

  Future<bool> unlockWithDevice(String reason) async {
    authenticating = true;
    try {
      final ok = await ref.read(biometricAuthProvider).authenticate(reason);
      if (ok) state = const AppLockState(initialized: true);
      return ok;
    } finally {
      authenticating = false;
      // Returning from the system prompt is not "coming back to the app".
      _leftAt = null;
    }
  }
}

final appLockProvider = NotifierProvider<AppLockController, AppLockState>(
  AppLockController.new,
);
