import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/data/backup/backup_codec.dart';
import 'package:pharmacy_expiry_tracker/data/backup/backup_failure.dart';
import 'package:pharmacy_expiry_tracker/data/backup/backup_service.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';

import '../support/test_env.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late TestEnv env;
  late Directory dir;
  late BackupService service;

  setUp(() async {
    env = TestEnv();
    dir = await Directory.systemTemp.createTemp('backup_test');
    service = BackupService(
      workDir: Directory(p.join(dir.path, 'work')),
      clock: env.clock,
      appVersion: '1.0.0+1',
      // Key derivation is deliberately slow; keep tests quick.
      iterations: 1000,
    );
    final med = await env.medicine(brand: 'Napa', strength: '500 mg');
    await env.addBatch(
      env.batchInput(
        med,
        number: 'A1',
        quantity: 12,
        expiry: ExpiryDate.day(2027, 3, 31),
      ),
    );
    final s = await env.supplier(name: 'ABC Pharma');
    await env.invoice(s, due: DateTime(2026, 11, 1));
  });
  tearDown(() async {
    await env.dispose();
    await dir.delete(recursive: true);
  });

  Future<List<String>> medicinesIn(File f) async {
    final db = AppDatabase(NativeDatabase(f));
    try {
      return [for (final m in await db.select(db.medicines).get()) m.brandName];
    } finally {
      await db.close();
    }
  }

  test('plain backup round-trips with its summary', () async {
    final result = await service.create(env.db);
    expect(result.file.path, endsWith('pharmacy-expiry-backup-2026-10-17.zip'));
    expect(result.metadata.medicines, 1);
    expect(result.metadata.batches, 1);
    expect(result.metadata.suppliers, 1);
    expect(result.metadata.invoices, 1);
    expect(result.metadata.encrypted, isFalse);

    final preview = await service.inspect(result.file);
    expect(preview.metadata.schemaVersion, AppDatabase.currentSchemaVersion);
    expect(preview.metadata.batches, 1);
    expect(await medicinesIn(preview.databaseFile), ['Napa']);
  });

  test('the backup records its own time in the settings', () async {
    final result = await service.create(env.db);
    final preview = await service.inspect(result.file);
    final db = AppDatabase(NativeDatabase(preview.databaseFile));
    final rows = await db.select(db.settings).get();
    await db.close();
    final stamp = rows.firstWhere((r) => r.key == SettingKey.lastBackupAt);
    expect(DateTime.parse(stamp.value), env.clock.now());
  });

  test('an encrypted backup needs the right passphrase', () async {
    final result = await service.create(env.db, passphrase: 'correct horse');
    expect(result.file.path, endsWith('.pxenc'));
    final raw = await result.file.readAsBytes();
    expect(isEncryptedBackup(raw), isTrue);
    // Nothing readable leaks into the file.
    expect(String.fromCharCodes(raw).contains('Napa'), isFalse);
    expect(String.fromCharCodes(raw).contains('SQLite'), isFalse);

    await expectLater(
      service.inspect(result.file),
      throwsA(
        isA<BackupException>().having(
          (e) => e.kind,
          'kind',
          BackupFailureKind.needsPassphrase,
        ),
      ),
    );
    await expectLater(
      service.inspect(result.file, passphrase: 'wrong'),
      throwsA(
        isA<BackupException>().having(
          (e) => e.kind,
          'kind',
          BackupFailureKind.wrongPassphrase,
        ),
      ),
    );
    final preview = await service.inspect(
      result.file,
      passphrase: 'correct horse',
    );
    expect(preview.metadata.encrypted, isTrue);
    expect(await medicinesIn(preview.databaseFile), ['Napa']);
  });

  test('two encrypted backups differ (fresh salt and nonce)', () async {
    final a = await (await service.create(
      env.db,
      passphrase: 'x',
    )).file.readAsBytes();
    final b = await (await service.create(
      env.db,
      passphrase: 'x',
    )).file.readAsBytes();
    expect(a, isNot(b));
  });

  Future<void> expectKind(Future<Object?> f, BackupFailureKind kind) =>
      expectLater(
        f,
        throwsA(isA<BackupException>().having((e) => e.kind, 'kind', kind)),
      );

  test('files that are not backups are rejected', () async {
    final junk = File(p.join(dir.path, 'notes.txt'))
      ..writeAsStringSync('shopping list');
    await expectKind(service.inspect(junk), BackupFailureKind.notABackup);

    final empty = File(p.join(dir.path, 'empty.zip'))..writeAsBytesSync([]);
    await expectKind(service.inspect(empty), BackupFailureKind.notABackup);

    await expectKind(
      service.inspect(File(p.join(dir.path, 'missing.zip'))),
      BackupFailureKind.notABackup,
    );
  });

  test('a damaged backup is reported as corrupt', () async {
    final result = await service.create(env.db);
    final bytes = await result.file.readAsBytes();
    // Flip bytes in the middle of the archive.
    for (var i = bytes.length ~/ 2; i < bytes.length ~/ 2 + 40; i++) {
      bytes[i] ^= 0xff;
    }
    final damaged = File(p.join(dir.path, 'damaged.zip'))
      ..writeAsBytesSync(bytes);
    await expectKind(service.inspect(damaged), BackupFailureKind.corrupt);

    final cut = File(p.join(dir.path, 'cut.zip'))
      ..writeAsBytesSync(bytes.sublist(0, bytes.length ~/ 3));
    await expectKind(service.inspect(cut), BackupFailureKind.corrupt);
  });

  test('a tampered encrypted backup does not open', () async {
    final result = await service.create(env.db, passphrase: 'pw');
    final bytes = await result.file.readAsBytes();
    bytes[bytes.length ~/ 2] ^= 1;
    final f = File(p.join(dir.path, 'tampered.pxenc'))..writeAsBytesSync(bytes);
    await expectLater(
      service.inspect(f, passphrase: 'pw'),
      throwsA(isA<BackupException>()),
    );
  });

  test('a backup from a newer version is refused', () async {
    final snapshot = p.join(dir.path, 'snap.sqlite');
    await env.db.customStatement('VACUUM INTO ?', [snapshot]);
    final out = p.join(dir.path, 'newer.zip');
    await buildBackup(
      dbPath: snapshot,
      outPath: out,
      appVersion: '9.9.9',
      schemaVersion: AppDatabase.currentSchemaVersion + 1,
      createdAt: env.clock.now(),
    );
    await expectKind(
      service.inspect(File(out)),
      BackupFailureKind.newerVersion,
    );
  });

  group('swapping the database in', () {
    late File live;

    Future<File> makeLive(String brand) async {
      final f = File(p.join(dir.path, 'live.sqlite'));
      final db = AppDatabase(NativeDatabase(f));
      await db
          .into(db.medicines)
          .insert(
            MedicinesCompanion.insert(
              id: 'live-1',
              brandName: brand,
              searchText: brand.toLowerCase(),
              createdAt: 0,
              updatedAt: 0,
            ),
          );
      await db.close();
      return f;
    }

    setUp(() async {
      live = await makeLive('Existing');
    });

    test('replaces the data and keeps the old copy', () async {
      final preview = await service.inspect(
        await service.create(env.db).then((r) => r.file),
      );
      var closed = false;
      final bak = await service.swapIn(
        live: live,
        preview: preview,
        closeDb: () async => closed = true,
      );
      expect(closed, isTrue);
      expect(await medicinesIn(live), ['Napa']);
      expect(await medicinesIn(bak), ['Existing']);
    });

    test('puts the old data back when the swap fails', () async {
      final preview = BackupPreview(
        metadata: (await service.inspect((await service.create(env.db)).file))
            .metadata,
        databaseFile: File(p.join(dir.path, 'does-not-exist.sqlite')),
      );
      await expectKind(
        service.swapIn(live: live, preview: preview, closeDb: () async {}),
        BackupFailureKind.swapFailed,
      );
      expect(await medicinesIn(live), ['Existing']);
      final stray = dir.listSync().where(
        (e) => p.basename(e.path).contains('.bak-'),
      );
      expect(stray, isEmpty);
    });

    test('safety copies are purged after 24 hours', () async {
      final preview = await service.inspect(
        (await service.create(env.db)).file,
      );
      final bak = await service.swapIn(
        live: live,
        preview: preview,
        closeDb: () async {},
      );
      final now = env.clock.now();
      expect(
        await BackupService.purgeSafetyCopies(
          live,
          now.add(const Duration(hours: 23)),
        ),
        0,
      );
      expect(bak.existsSync(), isTrue);
      expect(
        await BackupService.purgeSafetyCopies(
          live,
          now.add(const Duration(hours: 25)),
        ),
        1,
      );
      expect(bak.existsSync(), isFalse);
      expect(live.existsSync(), isTrue);
    });
  });
}
