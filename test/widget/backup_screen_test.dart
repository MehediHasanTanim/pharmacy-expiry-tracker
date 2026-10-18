import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/router.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/data/backup/backup_service.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/features/backup/backup_controller.dart';

import '../support/fake_file_exchange.dart';
import '../support/pump_app.dart';
import '../support/test_env.dart';

/// A controller whose restore only records the call; swapping real files is
/// covered by the data tests.
class _RecordingController extends BackupController {
  _RecordingController(super.ref);

  static final restored = <BackupPreview>[];

  @override
  Future<void> restore(BackupPreview preview) async => restored.add(preview);
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late TestEnv env;
  late Directory dir;
  late FakeFileExchange files;

  setUp(() async {
    env = TestEnv();
    dir = await Directory.systemTemp.createTemp('backup_screen');
    files = FakeFileExchange();
    _RecordingController.restored.clear();
    EditableText.debugDeterministicCursor = true;
    final m = await env.medicine(brand: 'Napa', strength: '500 mg');
    expect(m, isNotEmpty);
  });
  tearDown(() async {
    EditableText.debugDeterministicCursor = false;
    await env.dispose();
    await dir.delete(recursive: true);
  });

  List<Override> overrides() => [
    fileExchangeProvider.overrideWithValue(files),
    backupWorkDirProvider.overrideWithValue(Directory(p.join(dir.path, 'w'))),
    backupIterationsProvider.overrideWithValue(1000),
    backupControllerProvider.overrideWith(_RecordingController.new),
  ];

  Future<void> open(WidgetTester t) async {
    t.view
      ..physicalSize = const Size(900, 2400)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await pumpApp(t, env, overrides: overrides());
    final c = ProviderScope.containerOf(t.element(find.byType(Scaffold).first));
    c.read(routerProvider).go(Routes.backup);
    await settle(t);
  }

  /// Lets isolate work and file I/O finish in real time, then redraws.
  Future<void> real(WidgetTester t) async {
    // Alternate real time (isolates, file I/O) with fake time (Drift's timers).
    for (var i = 0; i < 12; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> tapKey(WidgetTester t, String key) async {
    await t.tap(find.byKey(Key(key)));
    await settle(t);
  }

  Future<File> makeBackup({String? passphrase}) async {
    final service = BackupService(
      workDir: Directory(p.join(dir.path, 'seed')),
      clock: env.clock,
      appVersion: '1.0.0+1',
      iterations: 1000,
    );
    final r = await service.create(env.db, passphrase: passphrase);
    return r.file;
  }

  testWidgets('backing up shares a file and records the time', (t) async {
    await open(t);
    expect(find.text('No backup yet'), findsOneWidget);
    await tapKey(t, 'backup-now');
    await tapKey(t, 'backup-go');
    await real(t);
    expect(files.shared, hasLength(1));
    expect(files.shared.single.path, endsWith('.zip'));
    expect(find.text('Backup saved'), findsOneWidget);
    final s = await t.runAsync(() => env.settings.load());
    expect(DateTime.parse(s!.lastBackupAt), env.clock.now());
    await settle(t);
    expect(find.text('Last backup: today'), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('dismissing the share sheet does not count as a backup', (
    t,
  ) async {
    files.accepts = false;
    await open(t);
    await tapKey(t, 'backup-now');
    await tapKey(t, 'backup-go');
    await real(t);
    expect(find.textContaining('Nothing was saved'), findsOneWidget);
    final s = await t.runAsync(() => env.settings.load());
    expect(s!.lastBackupAt, isEmpty);
    await disposeApp(t);
  });

  testWidgets('a passphrase is checked, then encrypts the file', (t) async {
    await open(t);
    await tapKey(t, 'backup-now');
    await tapKey(t, 'backup-protect');
    await t.enterText(find.byKey(const Key('backup-pass')), 'short');
    await t.enterText(find.byKey(const Key('backup-pass2')), 'short');
    await tapKey(t, 'backup-go');
    expect(find.text('Use at least 8 characters'), findsOneWidget);
    await t.enterText(find.byKey(const Key('backup-pass')), 'long enough pw');
    await t.enterText(find.byKey(const Key('backup-pass2')), 'different one');
    await tapKey(t, 'backup-go');
    expect(find.text('The passphrases do not match'), findsOneWidget);
    await t.enterText(find.byKey(const Key('backup-pass2')), 'long enough pw');
    await tapKey(t, 'backup-go');
    await real(t);
    expect(files.shared.single.path, endsWith('.pxenc'));
    expect(
      String.fromCharCodes(files.sharedBytes.single).contains('Napa'),
      isFalse,
    );
    await disposeApp(t);
  });

  testWidgets('restore shows what is in the backup and asks first', (t) async {
    files.toPick = await t.runAsync(makeBackup);
    await open(t);
    await tapKey(t, 'backup-restore');
    await real(t);
    expect(find.text('Restore this backup?'), findsOneWidget);
    expect(
      find.text('1 medicines, 0 batches, 0 suppliers, 0 invoices'),
      findsOneWidget,
    );

    await tapKey(t, 'restore-cancel');
    expect(_RecordingController.restored, isEmpty);

    await tapKey(t, 'backup-restore');
    await real(t);
    await tapKey(t, 'restore-confirm');
    expect(_RecordingController.restored, hasLength(1));
    expect(find.text('Backup restored'), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('a protected backup asks for its passphrase', (t) async {
    files.toPick = await t.runAsync(
      () => makeBackup(passphrase: 'open sesame'),
    );
    await open(t);
    await tapKey(t, 'backup-restore');
    await real(t);
    expect(find.text('This backup is protected'), findsOneWidget);

    await t.enterText(find.byKey(const Key('restore-pass')), 'nope');
    await tapKey(t, 'restore-pass-ok');
    await real(t);
    expect(find.text('That passphrase did not work.'), findsOneWidget);

    await t.enterText(find.byKey(const Key('restore-pass')), 'open sesame');
    await tapKey(t, 'restore-pass-ok');
    await real(t);
    expect(find.text('Restore this backup?'), findsOneWidget);
    await tapKey(t, 'restore-cancel');
    await disposeApp(t);
  });

  testWidgets('other files are refused with a clear message', (t) async {
    final junk = File(p.join(dir.path, 'notes.txt'))
      ..writeAsStringSync('hello');
    files.toPick = junk;
    await open(t);
    await tapKey(t, 'backup-restore');
    await real(t);
    expect(
      find.text('That file is not a backup from this app.'),
      findsOneWidget,
    );
    expect(_RecordingController.restored, isEmpty);
    await disposeApp(t);
  });

  testWidgets('cancelling the picker does nothing', (t) async {
    files.toPick = null;
    await open(t);
    await tapKey(t, 'backup-restore');
    await real(t);
    expect(find.text('Restore this backup?'), findsNothing);
    await disposeApp(t);
  });

  testWidgets('the reminder interval can be changed', (t) async {
    await open(t);
    await tapKey(t, 'backup-reminder');
    await t.tap(find.text('Every 30 days').last);
    await settle(t);
    final s = await t.runAsync(() => env.settings.load());
    expect(s!.backupReminderDays, 30);
    await disposeApp(t);
  });

  group('Home banner', () {
    Future<void> home(
      WidgetTester t,
      AppSettings Function(AppSettings s) change,
    ) async {
      await t.runAsync(() => env.settings.update(change));
      t.view
        ..physicalSize = const Size(900, 2400)
        ..devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await pumpApp(t, env, overrides: overrides());
    }

    testWidgets('appears when the backup is old, and leads to the screen', (
      t,
    ) async {
      await home(
        t,
        (s) => s.copyWith(
          lastBackupAt: DateTime(2026, 9, 1, 10).toIso8601String(),
        ),
      );
      expect(find.byKey(const Key('backup-banner')), findsOneWidget);
      expect(
        find.text('Your data has not been backed up for 46 days.'),
        findsOneWidget,
      );
      await tapKey(t, 'backup-banner-action');
      expect(find.text('Back up now'), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('says so when there never was a backup', (t) async {
      await home(t, (s) => s.copyWith(firstRunOn: '2026-09-01'));
      expect(find.text('Your data has never been backed up.'), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('is hidden after a recent backup', (t) async {
      await home(
        t,
        (s) =>
            s.copyWith(lastBackupAt: DateTime(2026, 10, 10).toIso8601String()),
      );
      expect(find.byKey(const Key('backup-banner')), findsNothing);
      await disposeApp(t);
    });

    testWidgets('is hidden when reminders are off', (t) async {
      await home(
        t,
        (s) => s.copyWith(
          backupReminderDays: 0,
          lastBackupAt: DateTime(2026, 1, 1).toIso8601String(),
        ),
      );
      expect(find.byKey(const Key('backup-banner')), findsNothing);
      await disposeApp(t);
    });
  });
}
