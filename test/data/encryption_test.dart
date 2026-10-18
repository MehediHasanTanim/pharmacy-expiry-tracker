import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pharmacy_expiry_tracker/data/backup/backup_service.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/db/database_bootstrap.dart';
import 'package:pharmacy_expiry_tracker/data/db/db_encryption.dart';
import 'package:pharmacy_expiry_tracker/data/security/db_key_store.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import '../support/fake_clock.dart';

class _FailingStore implements DatabaseKeyStore {
  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String hexKey) async => throw StateError('no keystore');
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Directory dir;
  late File file;
  final key = 'ab' * 32;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('enc_test');
    file = File(p.join(dir.path, 'app.sqlite'));
  });
  tearDown(() => dir.deleteSync(recursive: true));

  /// A plaintext database as an earlier version of the app left it.
  Future<void> plainDb({int medicines = 3}) async {
    final db = AppDatabase.forFile(file, background: false);
    for (var i = 0; i < medicines; i++) {
      await db
          .into(db.medicines)
          .insert(
            MedicinesCompanion.insert(
              id: 'm$i',
              brandName: 'Brand $i',
              searchText: 'brand $i',
              createdAt: 0,
              updatedAt: 0,
            ),
          );
    }
    await db.close();
  }

  Future<List<String>> names({String? withKey}) async {
    final db = AppDatabase.forFile(file, hexKey: withKey, background: false);
    try {
      return [for (final m in await db.select(db.medicines).get()) m.brandName]
        ..sort();
    } finally {
      await db.close();
    }
  }

  test('keys are 64 hex characters and always different', () {
    final a = generateDatabaseKey();
    final b = generateDatabaseKey();
    expect(a, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(a, isNot(b));
    expect(() => keyPragma('short'), throwsArgumentError);
    expect(
      () => keyPragma("ab'; DROP TABLE x; --${'a' * 50}"),
      throwsArgumentError,
    );
  });

  test('a plaintext database is encrypted with all its data', () async {
    await plainDb();
    expect(isPlainSqlite(file), isTrue);
    expect(encryptInPlace(file, key), isTrue);

    expect(isPlainSqlite(file), isFalse);
    expect(isEncryptedFile(file), isTrue);
    expect(
      String.fromCharCodes(file.readAsBytesSync().sublist(0, 15)),
      isNot('SQLite format 3'),
    );
    expect(await names(withKey: key), ['Brand 0', 'Brand 1', 'Brand 2']);
    // No leftovers.
    expect(dir.listSync().map((e) => p.basename(e.path)), ['app.sqlite']);
  });

  test('the schema version and tables survive the conversion', () async {
    await plainDb();
    encryptInPlace(file, key);
    final db = openEncrypted(file.path, key, readOnly: true);
    expect(
      db.select('PRAGMA user_version').first.values.first,
      AppDatabase.currentSchemaVersion,
    );
    final tables = db
        .select("SELECT name FROM sqlite_master WHERE type='table'")
        .map((r) => r['name']);
    expect(
      tables,
      containsAll(['medicines', 'batches', 'settings', 'scheduled_alerts']),
    );
    db.close();
  });

  test('without the key, or with a wrong key, nothing can be read', () async {
    await plainDb();
    encryptInPlace(file, key);
    expect(
      () => sql.sqlite3.open(file.path).select('SELECT * FROM medicines'),
      throwsA(isA<sql.SqliteException>()),
    );
    expect(
      () => openEncrypted(file.path, 'cd' * 32),
      throwsA(isA<sql.SqliteException>()),
    );
    // The text of the data is not in the file.
    expect(
      String.fromCharCodes(file.readAsBytesSync()).contains('Brand 1'),
      isFalse,
    );
  });

  test('a failure before the swap leaves the plaintext untouched', () async {
    await plainDb();
    final before = file.readAsBytesSync();
    expect(
      () =>
          encryptInPlace(file, key, beforeSwap: () => throw StateError('boom')),
      throwsStateError,
    );
    expect(isPlainSqlite(file), isTrue);
    expect(file.readAsBytesSync(), before);
    expect(dir.listSync().map((e) => p.basename(e.path)), ['app.sqlite']);
    expect(await names(), ['Brand 0', 'Brand 1', 'Brand 2']);
  });

  test('already encrypted, or missing: nothing to do', () async {
    expect(encryptInPlace(file, key), isFalse);
    await plainDb();
    expect(encryptInPlace(file, key), isTrue);
    expect(encryptInPlace(file, key), isFalse);
  });

  test('an interrupted earlier attempt is cleaned up and retried', () async {
    await plainDb();
    File('${file.path}.enc').writeAsStringSync('half written');
    File('${file.path}.plain').writeAsStringSync('stale');
    expect(encryptInPlace(file, key), isTrue);
    expect(await names(withKey: key), hasLength(3));
    expect(dir.listSync().map((e) => p.basename(e.path)), ['app.sqlite']);
  });

  group('prepareDatabase', () {
    test('a new install gets an encrypted database', () async {
      final keys = MemoryDatabaseKeyStore();
      final k = await prepareDatabase(keys: keys, file: file);
      expect(k, keys.value);
      expect(isEncryptedFile(file), isTrue);
      expect(await names(withKey: k), isEmpty);
    });

    test('an upgrade from the plaintext beta keeps every record', () async {
      await plainDb(medicines: 5);
      final keys = MemoryDatabaseKeyStore();
      final k = await prepareDatabase(keys: keys, file: file);
      expect(k, isNotNull);
      expect(isPlainSqlite(file), isFalse);
      expect(await names(withKey: k), hasLength(5));
      // Starting again is a no-op and uses the same key.
      expect(await prepareDatabase(keys: keys, file: file), k);
    });

    test('if encrypting fails the plaintext stays usable', () async {
      await plainDb();
      final k = await prepareDatabase(keys: _FailingStore(), file: file);
      expect(k, isNull);
      expect(isPlainSqlite(file), isTrue);
      expect(await names(), hasLength(3));
    });

    test(
      'an encrypted file with no key is reported, not overwritten',
      () async {
        await plainDb();
        encryptInPlace(file, key);
        final before = file.readAsBytesSync();
        await expectLater(
          prepareDatabase(keys: MemoryDatabaseKeyStore(), file: file),
          throwsA(isA<DatabaseKeyMissingException>()),
        );
        expect(file.readAsBytesSync(), before);
      },
    );

    test('the key is only ever saved once', () async {
      final keys = MemoryDatabaseKeyStore();
      final a = await getOrCreateDatabaseKey(keys);
      final b = await getOrCreateDatabaseKey(keys);
      expect(a, b);
    });
  });

  group('backups of an encrypted database', () {
    test('the backup is readable anywhere; restore re-encrypts it', () async {
      await plainDb(medicines: 4);
      encryptInPlace(file, key);
      final live = AppDatabase.forFile(file, hexKey: key, background: false);
      final service = BackupService(
        workDir: Directory(p.join(dir.path, 'work')),
        clock: FakeClock(DateTime(2026, 10, 17, 9)),
        appVersion: '1.1.0',
        iterations: 1000,
      );
      final backup = await service.create(live);
      expect(backup.metadata.medicines, 4);
      await live.close();

      // The backup holds a plain database (any phone can restore it).
      final preview = await service.inspect(backup.file);
      expect(isPlainSqlite(preview.databaseFile), isTrue);
      expect(preview.metadata.schemaVersion, AppDatabase.currentSchemaVersion);

      // Restoring onto an encrypted phone leaves it encrypted.
      await service.swapIn(
        live: file,
        preview: preview,
        closeDb: () async {},
        hexKey: key,
      );
      expect(isEncryptedFile(file), isTrue);
      expect(await names(withKey: key), hasLength(4));
    });

    test(
      'restoring onto a phone still running unencrypted keeps it so',
      () async {
        await plainDb(medicines: 2);
        final db = AppDatabase.forFile(file, background: false);
        final service = BackupService(
          workDir: Directory(p.join(dir.path, 'work')),
          clock: FakeClock(DateTime(2026, 10, 17, 9)),
          appVersion: '1.1.0',
          iterations: 1000,
        );
        final backup = await service.create(db);
        await db.close();
        final preview = await service.inspect(backup.file);
        await service.swapIn(
          live: file,
          preview: preview,
          closeDb: () async {},
        );
        expect(isPlainSqlite(file), isTrue);
        expect(await names(), hasLength(2));
      },
    );

    test(
      'an old plaintext backup from the beta restores onto an encrypted phone',
      () async {
        // Made by the previous version: plain database inside the container.
        await plainDb(medicines: 3);
        final seed = AppDatabase.forFile(file, background: false);
        final service = BackupService(
          workDir: Directory(p.join(dir.path, 'work')),
          clock: FakeClock(DateTime(2026, 10, 17, 9)),
          appVersion: '1.0.0',
          iterations: 1000,
        );
        final old = await service.create(seed);
        await seed.close();
        file.deleteSync();
        // A different phone, already encrypted, with other data.
        await plainDb(medicines: 1);
        encryptInPlace(file, key);
        final preview = await service.inspect(old.file);
        await service.swapIn(
          live: file,
          preview: preview,
          closeDb: () async {},
          hexKey: key,
        );
        expect(await names(withKey: key), hasLength(3));
      },
    );
  });
}
