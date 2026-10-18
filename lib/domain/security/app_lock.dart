import 'package:flutter/foundation.dart';

/// PINs are 4 to 8 digits.
const minPinLength = 4;
const maxPinLength = 8;

bool isValidPin(String pin) =>
    pin.length >= minPinLength &&
    pin.length <= maxPinLength &&
    RegExp(r'^\d+$').hasMatch(pin);

/// Outcome of checking a PIN.
@immutable
class PinCheck {
  const PinCheck.ok() : ok = true, lockedFor = null, attemptsLeft = null;

  const PinCheck.wrong(this.attemptsLeft) : ok = false, lockedFor = null;

  const PinCheck.lockedOut(this.lockedFor) : ok = false, attemptsLeft = null;

  final bool ok;

  /// Tries left before a waiting period starts.
  final int? attemptsLeft;

  /// Set while further tries are refused.
  final Duration? lockedFor;
}

/// Where the PIN is kept (a salted hash in secure storage, never the PIN, and
/// not in the database, so backups do not carry it).
abstract interface class PinStore {
  Future<bool> hasPin();

  Future<void> setPin(String pin);

  /// Checks [pin]. Repeated mistakes are slowed down: after
  /// [freeAttempts] wrong tries every further one adds a growing wait.
  Future<PinCheck> verify(String pin, DateTime now);

  Future<void> clear();
}

/// Tries allowed before waiting periods start.
const freeAttempts = 5;

/// The wait after the [failures]-th wrong PIN in a row (0 = none yet).
Duration lockoutFor(int failures) {
  if (failures < freeAttempts) return Duration.zero;
  final steps = failures - freeAttempts; // 0, 1, 2 ...
  final seconds = 30 * (1 << (steps > 6 ? 6 : steps)); // 30 s up to ~32 min
  return Duration(seconds: seconds);
}

/// Fingerprint, face or the phone's own screen lock.
abstract interface class BiometricAuth {
  /// Whether the phone can authenticate this way right now.
  Future<bool> isAvailable();

  /// Asks the system to authenticate; false when cancelled or failed.
  Future<bool> authenticate(String reason);
}
