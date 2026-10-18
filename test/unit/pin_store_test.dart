import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/data/security/secure_pin_store.dart';
import 'package:pharmacy_expiry_tracker/domain/security/app_lock.dart';

void main() {
  late MemorySecretStore box;
  late SecurePinStore store;
  final now = DateTime(2026, 10, 17, 9);

  setUp(() {
    box = MemorySecretStore();
    store = SecurePinStore(box, iterations: 100, random: Random(1));
  });

  test('PINs are 4 to 8 digits', () {
    expect(isValidPin('1234'), isTrue);
    expect(isValidPin('12345678'), isTrue);
    for (final bad in ['', '123', '123456789', '12a4', '12 34', '１２３４']) {
      expect(isValidPin(bad), isFalse, reason: bad);
    }
  });

  test('the PIN itself is never stored', () async {
    await store.setPin('4821');
    expect(await store.hasPin(), isTrue);
    expect(box.values.values.any((v) => v.contains('4821')), isFalse);
  });

  test('the right PIN opens, a wrong one does not', () async {
    await store.setPin('4821');
    expect((await store.verify('4821', now)).ok, isTrue);
    final wrong = await store.verify('1111', now);
    expect(wrong.ok, isFalse);
    expect(wrong.attemptsLeft, 4);
  });

  test('two stores with the same PIN have different hashes (salted)', () async {
    final other = MemorySecretStore();
    await store.setPin('4821');
    await SecurePinStore(
      other,
      iterations: 100,
      random: Random(2),
    ).setPin('4821');
    expect(
      box.values['app_lock_pin_v1'],
      isNot(other.values['app_lock_pin_v1']),
    );
  });

  test('five wrong tries start a waiting period that grows', () async {
    await store.setPin('4821');
    for (var i = 1; i <= 4; i++) {
      expect((await store.verify('0000', now)).attemptsLeft, 5 - i);
    }
    final fifth = await store.verify('0000', now);
    expect(fifth.lockedFor, const Duration(seconds: 30));

    // Even the right PIN is refused during the wait.
    final during = await store.verify(
      '4821',
      now.add(const Duration(seconds: 10)),
    );
    expect(during.ok, isFalse);
    expect(during.lockedFor, const Duration(seconds: 20));

    // After it, one wrong try doubles the wait.
    final later = now.add(const Duration(seconds: 31));
    expect(
      (await store.verify('0000', later)).lockedFor,
      const Duration(seconds: 60),
    );
  });

  test('a right PIN clears the failures; they survive a restart', () async {
    await store.setPin('4821');
    await store.verify('0000', now);
    await store.verify('0000', now);
    // "Restart": a new store over the same storage still counts.
    final again = SecurePinStore(box, iterations: 100);
    expect((await again.verify('0000', now)).attemptsLeft, 2);
    expect((await again.verify('4821', now)).ok, isTrue);
    expect((await again.verify('0000', now)).attemptsLeft, 4);
  });

  test('clearing removes the PIN and the failures', () async {
    await store.setPin('4821');
    await store.verify('0000', now);
    await store.clear();
    expect(await store.hasPin(), isFalse);
    expect(box.values, isEmpty);
  });

  test('setting an invalid PIN is refused', () async {
    expect(() => store.setPin('12'), throwsArgumentError);
  });

  test('the waiting schedule', () {
    expect(
      [for (var f = 0; f <= 9; f++) lockoutFor(f).inSeconds],
      [0, 0, 0, 0, 0, 30, 60, 120, 240, 480],
    );
    expect(lockoutFor(100), const Duration(seconds: 30 * 64));
  });
}
