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
