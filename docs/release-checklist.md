# Release checklist (S6-11)

What is done in the repository, and what needs a person, an account or a
device. Items marked **needs you** cannot be completed from the code alone.

## Build and signing

- [x] Flavors `dev` and `prod` (`com.pharmacytracker.pharmacy_expiry_tracker[.dev]`).
- [x] Release signing reads `android/key.properties`; without it the release
      build is debug-signed and **must not be published**.
- [ ] **needs you:** create the upload key and `android/key.properties`:

  ```bash
  keytool -genkey -v -keystore ~/pharmacy-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```

  ```properties
  storeFile=/Users/you/pharmacy-upload.jks
  storePassword=...
  keyAlias=upload
  keyPassword=...
  ```

  Keep the keystore and passwords somewhere safe and backed up; losing the
  key means losing the ability to update the app.
- [ ] **needs you:** bump `version:` in `pubspec.yaml` for each upload
      (`1.0.0+1` → build number must increase every time).
- [ ] Build the bundle: `flutter build appbundle --release --flavor prod`
      and run `bash tool/check_manifest.sh`.

## Store listing

- [ ] **needs you:** app icon (adaptive, 512×512 for Play) replacing the
      Flutter default in `android/app/src/main/res/mipmap-*`.
- [ ] **needs you:** screenshots from the `dev` flavor with seed data
      (More → *Seed sample data*), at least 4 phone screenshots: Home,
      Expiry list, Medicine/batch, Suppliers/dues.
- [ ] Short description (80 chars): *Never sell expired medicine. Offline expiry
      alerts, stock and supplier dues for pharmacies.*
- [ ] Full description: lead with alerts working offline, then expiry list,
      supplier dues, reorder reminders, backup/restore.
- [ ] **needs you:** privacy policy URL (publish `docs/privacy.md` after review).
- [ ] **needs you:** Play Console data-safety form: *no data collected, no data
      shared*; app does not use the network. Content rating questionnaire.
- [ ] **needs you:** Play internal testing track upload; add the pilot
      pharmacy's Google account as a tester.
- [ ] **needs you (iOS):** Apple developer account, bundle ids per flavor,
      TestFlight build from a Mac. iOS has never been built in this project.

## Before every upload

- [ ] `flutter test`, `flutter analyze`, `dart format --set-exit-if-changed lib test`
- [ ] Device matrix (`docs/qa-alert-matrix.md`) re-run on the lowest-end and
      the most aggressive-battery devices available.
- [ ] Backup → restore round trip on a real phone with real-sized data.
- [ ] Install over the previous build (upgrade path) and confirm data and
      alerts survive.

## Release 1.1 (S8-09)

Version is `1.1.0+2`. Changelog: `CHANGELOG.md`.

### Upgrade verification from 1.0 (do this on a real phone before submitting)

The database is encrypted in place on the first launch of 1.1. This is the
riskiest step of the release; the automated tests cover it with generated
plaintext databases, but it needs a real 1.0 install.

1. Install the **1.0 beta** build and enter real-sized data (or seed 5 000
   medicines / 10 000 batches from the dev flavor). Make a backup file as well.
2. Note: number of medicines, batches, suppliers, invoices and the *Scheduled
   alerts* count on *Alert health*.
3. Install 1.1 **over** it (do not uninstall).
4. First launch: it should open normally (a few seconds longer with big data).
5. Check the same numbers match, a test alert arrives, and the *next alert* time
   is unchanged.
6. *More → Export diagnostics* shows no errors from `database` or `migration`.
7. Force-stop, reopen, and swipe the app away; the background re-plan must still
   work (wait for the next alert or use *Alert health → Check again*).
8. Restore the 1.0 backup file made in step 1 onto this phone; data returns and
   the database stays encrypted (the app still opens after a restart).
9. Uninstall/reinstall and restore the backup on the same phone.

If step 4 or 5 fails: the original data is kept beside the new file until the
conversion is verified, and the app falls back to the unencrypted file. Collect
*Export diagnostics* before reinstalling anything.

### Store submission

- [ ] **needs you:** upload the `1.1.0+2` bundle to the internal track and
      promote after the upgrade check above.
- [ ] **needs you:** update the Play data-safety form: camera is used on-device
      only; no data collected or shared (unchanged).
- [ ] Update screenshots (Reports, Receive delivery).
- [ ] Publish the reviewed `docs/privacy.md`.
