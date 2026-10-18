# Privacy and security notes (draft)

*Draft for the store listing and the pilot. Not legal advice; have it reviewed
before publishing.* Review date: Sprint 6 (S6-10). Everything below describes
what the code does today and how it was checked.

## What the app does with data

| Question | Answer | How it is enforced |
|---|---|---|
| Does the app need the internet? | No. | `INTERNET` is not declared in the main or release manifest. `tool/check_manifest.sh` fails the build if it appears, and checks the merged release manifests. |
| Where is data stored? | In one SQLite file in the app's private storage on the phone. | Drift/SQLite via `path_provider` documents directory. |
| Is data sent to a server, analytics or crash service? | No. There is no analytics or crash SDK. | No such dependency in `pubspec.yaml`; no network permission. |
| Is data copied to the cloud automatically? | No. | Android `allowBackup="false"`. The user can make a backup file themselves and choose where it goes. |
| Who can read a backup file? | Whoever has the file, unless it is passphrase-protected. | Optional AES-256-GCM encryption (key from PBKDF2-HMAC-SHA256, random salt and nonce per file). A wrong passphrase or a modified file fails the authentication check. |
| What is in notifications? | Medicine and supplier names, by default. | Settings → Alert settings → *Hide details on the lock screen* replaces the text with "Open the app to see details." |
| What is in the error log and the diagnostics file? | Error types, scrubbed messages, code locations, version numbers, row counts and on/off settings. | `ErrorLog.scrub` removes quoted text, file paths and any word containing a digit; the diagnostics report has no names, amounts or dates of records. Tests assert this. The log never leaves the phone unless the user exports it. |
| What does a shared expiry list contain? | The medicines, batches, dates, quantities and costs on the screen. | Only when the user taps *Share*. The CSV neutralises cells that start with `=`, `+`, `-` or `@` so a medicine name cannot run as a spreadsheet formula. |

## Permissions (Android)

| Permission | Why | Notes |
|---|---|---|
| `CAMERA` | Scan medicine barcodes (Sprint 7). | Asked the first time the scanner opens; typing the number works without it. Nothing is recorded or sent; frames are read on the phone and discarded. Declared with `required="false"` so the app installs on devices without a camera. |
| `POST_NOTIFICATIONS` | Show expiry, payment, reorder and backup reminders. | Asked in context during onboarding or from the Alerts banner. |
| `SCHEDULE_EXACT_ALARM` | Deliver alerts at the chosen time. | The user can revoke it; alerts then arrive inexactly. |
| `RECEIVE_BOOT_COMPLETED` | Re-register scheduled alerts after a reboot or update. | Used by the notification plugin's receiver only. |

Added by libraries (found by reading the merged release manifest in Sprint 6;
none is requested at run time, all are "normal" permissions granted at
install):

| Permission | From | Why it is there |
|---|---|---|
| `WAKE_LOCK`, `VIBRATE` | notifications | Waking the device to deliver an alert; vibration. |
| `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_SHORT_SERVICE` | background tasks | The 12-hourly re-plan runs briefly as a service. |
| Launcher badge permissions (`com.sec…`, `com.huawei…`, `com.htc…`, `com.sonymobile…`, `com.vivo…`, `com.hihonor…`, `com.anddoes…`, `com.majeur…`) | icon badge library | Showing the "needs action" count on those launchers' icons. They only talk to the launcher. If you would rather not carry them, drop `app_badge_plus` and the badge feature (S5-10). |
| `ACCESS_NETWORK_STATE` | background tasks | **Removed** in our manifest (`tools:node="remove"`): the app sets no network constraints. |

No location, contacts, microphone, storage or phone-state permission is
requested. Choosing a file to restore and sharing a backup go through the
system picker and share sheet, which need no permission.

## Checks done in Sprint 6

* **SEC-1 (offline):** manifest check passes on the prod release build.
* **SEC-2 (no data leaves the device unprompted):** no network permission, no
  network-capable dependency used by the app code; sharing is user-initiated.
* **SEC-3 (backup):** round trip proven by automated tests, including alerts
  after restore (`test/data/restore_flow_test.dart`).
* **SEC-4 (backup reminder):** reminder notification and Home banner; default
  every 14 days, changeable or off.
* **SEC-7 (log hygiene):** scrubbing tests in `test/unit/error_log_test.dart`
  and `test/widget/diagnostics_and_errors_test.dart`.
* **SEC-8 (lock-screen privacy):** setting implemented and tested at the
  planner level; behaviour on real lock screens is in the device matrix.

## Known limits (state these honestly in the listing)

* **No app lock yet.** Anyone who can unlock the phone can open the app. The
  `appLockEnabled` setting exists but is not wired to a screen lock.
* **Backups are only as private as where you keep them.** Without a
  passphrase, the file is readable by anyone who gets it. A forgotten
  passphrase cannot be recovered.
* **Key derivation is in pure Dart** (150 000 PBKDF2 rounds, stored in each
  file so it can be raised later). It takes a few seconds on a mid-range phone
  and is weaker than a native Argon2id; revisit if backups need to withstand
  determined offline attacks.
* **Notification text** that includes names can be read on the lock screen
  unless the privacy option is on.
* **Device storage** is protected by the phone's own encryption and lock; the
  database file itself is not encrypted separately.
* **iOS** (which now also has an `NSCameraUsageDescription`) has not been built or reviewed; its Info.plist, background modes and
  sharing entitlements need the same review on a Mac with Xcode.

## Merged manifest check

Run after a release build:

```bash
bash tool/check_manifest.sh
```

and list the permissions it contains:

```bash
grep -o 'uses-permission[^/]*' build/app/intermediates/merged_manifest/prodRelease/processProdReleaseManifest/AndroidManifest.xml | sort -u
```
