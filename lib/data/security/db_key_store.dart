import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pharmacy_expiry_tracker/data/db/db_encryption.dart';

/// Where the database key lives: the Android Keystore / iOS Keychain through
/// secure storage, never in the app's own files or in backups.
abstract interface class DatabaseKeyStore {
  /// The saved key, or null if there is none yet.
  Future<String?> read();

  Future<void> write(String hexKey);
}

class SecureDatabaseKeyStore implements DatabaseKeyStore {
  const SecureDatabaseKeyStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const _name = 'database_key_v1';

  @override
  Future<String?> read() => _storage.read(key: _name);

  @override
  Future<void> write(String hexKey) =>
      _storage.write(key: _name, value: hexKey);
}

/// In memory, for tests.
class MemoryDatabaseKeyStore implements DatabaseKeyStore {
  MemoryDatabaseKeyStore([this.value]);

  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String hexKey) async => value = hexKey;
}

/// The key to use, creating and saving a new one on first use.
Future<String> getOrCreateDatabaseKey(DatabaseKeyStore store) async {
  final existing = await store.read();
  if (existing != null && RegExp(r'^[0-9a-f]{64}$').hasMatch(existing)) {
    return existing;
  }
  final created = generateDatabaseKey();
  await store.write(created);
  // Read it back: never encrypt data with a key that was not really saved.
  if (await store.read() != created) {
    throw StateError('The database key could not be saved');
  }
  return created;
}
