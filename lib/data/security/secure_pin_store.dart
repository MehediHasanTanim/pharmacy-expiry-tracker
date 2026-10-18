import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pharmacy_expiry_tracker/domain/security/app_lock.dart';

/// Key/value storage for the PIN record. Secure storage in the app; a map in
/// tests.
abstract interface class SecretValueStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

class PlatformSecretStore implements SecretValueStore {
  const PlatformSecretStore([this._s = const FlutterSecureStorage()]);

  final FlutterSecureStorage _s;

  @override
  Future<String?> read(String key) => _s.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _s.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _s.delete(key: key);
}

class MemorySecretStore implements SecretValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// Salted PBKDF2-HMAC-SHA256 hash of the PIN, with a failure counter that
/// slows guessing down. A short PIN can always be brute-forced if someone can
/// copy the stored hash off the phone; the secure storage and the lockout are
/// what stand in the way, which is why [iterations] is modest (the check runs
/// in pure Dart on the UI isolate's time).
class SecurePinStore implements PinStore {
  SecurePinStore(this._box, {this.iterations = 20000, Random? random})
    : _random = random ?? Random.secure();

  final SecretValueStore _box;
  final int iterations;
  final Random _random;

  static const _pinKey = 'app_lock_pin_v1';
  static const _failKey = 'app_lock_fail_v1';

  Future<String> _hash(String pin, List<int> salt, int rounds) async {
    final key = await Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: rounds,
      bits: 256,
    ).deriveKeyFromPassword(password: pin, nonce: salt);
    return base64.encode(await key.extractBytes());
  }

  @override
  Future<bool> hasPin() async => await _box.read(_pinKey) != null;

  @override
  Future<void> setPin(String pin) async {
    if (!isValidPin(pin)) throw ArgumentError('Invalid PIN');
    final salt = List<int>.generate(16, (_) => _random.nextInt(256));
    final h = await _hash(pin, salt, iterations);
    await _box.write(_pinKey, '$iterations:${base64.encode(salt)}:$h');
    await _box.delete(_failKey);
  }

  @override
  Future<PinCheck> verify(String pin, DateTime now) async {
    final fail = await _box.read(_failKey);
    var failures = 0;
    if (fail != null) {
      final parts = fail.split(':');
      failures = int.tryParse(parts.first) ?? 0;
      final until = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      final left = DateTime.fromMillisecondsSinceEpoch(until).difference(now);
      if (left > Duration.zero) return PinCheck.lockedOut(left);
    }
    final stored = await _box.read(_pinKey);
    if (stored == null) return const PinCheck.wrong(0);
    final parts = stored.split(':');
    final rounds = int.parse(parts[0]);
    final salt = base64.decode(parts[1]);
    final candidate = await _hash(pin, salt, rounds);
    if (_constantTimeEquals(candidate, parts[2])) {
      await _box.delete(_failKey);
      return const PinCheck.ok();
    }
    failures++;
    final wait = lockoutFor(failures);
    final until = now.add(wait).millisecondsSinceEpoch;
    await _box.write(_failKey, '$failures:$until');
    if (wait > Duration.zero) return PinCheck.lockedOut(wait);
    return PinCheck.wrong(freeAttempts - failures);
  }

  @override
  Future<void> clear() async {
    await _box.delete(_pinKey);
    await _box.delete(_failKey);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
