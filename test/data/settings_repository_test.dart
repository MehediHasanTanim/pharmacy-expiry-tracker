import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/settings_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';

void main() {
  late AppDatabase db;
  late SettingsRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = SettingsRepositoryImpl(db);
  });
  tearDown(() => db.close());

  test('empty database yields spec defaults', () async {
    final s = await repo.load();
    expect(s.nearExpiryWindowDays, 90);
    expect(s.bucketThresholds, [30, 60, 90]);
    expect(s.alertLeadDays, [90, 60, 30, 14, 7, 1, 0]);
    expect(s.digestEnabled, isTrue);
    expect(s.digestMinutes, 540);
    expect(s.quietHoursEnabled, isFalse);
    expect(s.paymentLeadDays, [3, 0]);
    expect(s.overdueRepeatDays, 3);
    expect(s.reorderRefireDays, 3);
    expect(s.backupReminderDays, 14);
    expect(s.themeMode, 'system');
    expect(s.appLockEnabled, isFalse);
  });

  test('save then load round trips every field', () async {
    const custom = AppSettings(
      pharmacyName: 'City Pharma',
      nearExpiryWindowDays: 120,
      bucketThresholds: [15, 45, 120],
      alertLeadDays: [60, 0],
      digestEnabled: false,
      digestMinutes: 480,
      skipEmptyDigest: false,
      quietHoursEnabled: true,
      quietStartMinutes: 1260,
      quietEndMinutes: 360,
      paymentLeadDays: [],
      overdueRepeatDays: 5,
      reorderRefireDays: 7,
      backupReminderDays: 30,
      currencySymbol: '৳',
      dateFormat: 'dd/MM/yyyy',
      languageCode: 'bn',
      themeMode: 'dark',
      appLockEnabled: true,
      hideDetailsOnLockScreen: true,
    );
    await repo.save(custom);
    expect(await repo.load(), custom);
  });

  test('malformed stored values fall back to defaults', () {
    final s = AppSettings.fromMap(const {
      SettingKey.nearExpiryWindowDays: 'abc',
      SettingKey.alertLeadDays: '30,x',
      SettingKey.digestEnabled: 'maybe',
    });
    expect(s.nearExpiryWindowDays, 90);
    expect(s.alertLeadDays, [90, 60, 30, 14, 7, 1, 0]);
    expect(s.digestEnabled, isTrue);
  });

  test('update applies a change atomically', () async {
    final next = await repo.update((s) => s.copyWith(themeMode: 'light'));
    expect(next.themeMode, 'light');
    expect((await repo.load()).themeMode, 'light');
  });

  test('watch emits on change and skips identical values', () async {
    final emitted = <String>[];
    final sub = repo.watch().listen((s) => emitted.add(s.themeMode));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await repo.update((s) => s.copyWith(themeMode: 'dark'));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await repo.update((s) => s.copyWith(themeMode: 'dark'));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();
    expect(emitted, ['system', 'dark']);
  });
}
