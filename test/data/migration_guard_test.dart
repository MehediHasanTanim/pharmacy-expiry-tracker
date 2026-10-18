import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pharmacy_expiry_tracker/data/db/migration_guard.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('guard_test');
    file = File(p.join(dir.path, 'app.sqlite'));
  });
  tearDown(() => dir.deleteSync(recursive: true));

  void seed({required int version}) {
    sql.sqlite3.open(file.path)
      ..execute('PRAGMA journal_mode = WAL')
      ..execute('CREATE TABLE medicines (id TEXT, name TEXT)')
      ..execute("INSERT INTO medicines VALUES ('1', 'Napa'), ('2', 'Amoxil')")
      ..execute('PRAGMA user_version = $version')
      ..close();
  }

  List<String> names() {
    final db = sql.sqlite3.open(file.path);
    try {
      return [
        for (final r in db.select('SELECT name FROM medicines ORDER BY id'))
          r['name']! as String,
      ];
    } finally {
      db.close();
    }
  }

  test('a failing upgrade restores the data exactly as it was', () async {
    seed(version: 1);
    await expectLater(
      guardedMigrate(
        file: file,
        targetVersion: 2,
        migrate: () async {
          // A half-finished migration: damage the data, then fail.
          sql.sqlite3.open(file.path)
            ..execute("DELETE FROM medicines WHERE id = '1'")
            ..execute('ALTER TABLE medicines RENAME TO old_medicines')
            ..close();
          throw StateError('step 2 failed');
        },
      ),
      throwsA(isA<MigrationFailedException>()),
    );
    expect(names(), ['Napa', 'Amoxil']);
    final db = sql.sqlite3.open(file.path);
    expect(db.select('PRAGMA user_version').first.values.first, 1);
    db.close();
    expect(File('${file.path}.premigrate').existsSync(), isFalse);
  });

  test('a successful upgrade removes the safety copy', () async {
    seed(version: 1);
    var ran = false;
    final copied = await guardedMigrate(
      file: file,
      targetVersion: 2,
      migrate: () async {
        ran = true;
        // The copy exists while the migration runs.
        expect(File('${file.path}.premigrate').existsSync(), isTrue);
      },
    );
    expect(ran, isTrue);
    expect(copied, isTrue);
    expect(File('${file.path}.premigrate').existsSync(), isFalse);
  });

  test('no copy for a fresh install or an up-to-date file', () async {
    var made = false;
    expect(
      await guardedMigrate(
        file: file,
        targetVersion: 2,
        migrate: () async =>
            made = File('${file.path}.premigrate').existsSync(),
      ),
      isFalse,
    );
    expect(made, isFalse);

    seed(version: 2);
    expect(
      await guardedMigrate(file: file, targetVersion: 2, migrate: () async {}),
      isFalse,
    );
  });
}
