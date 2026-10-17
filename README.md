# Pharmacy Expiry Tracker

Offline-first mobile app (Flutter) for tracking medicine batch expiry dates,
near-expiry lists, supplier dues and reorder reminders. Expiry alerts are the
core feature and run entirely on-device.

Docs: [feature spec](docs/feature-spec.md) ·
[technical design](docs/technical-design.md) ·
[sprint plan](docs/sprint-plan.md)

## Setup

```bash
flutter pub get
dart run build_runner build     # Drift code
flutter gen-l10n                # localizations
```

## Run

Android has `dev` and `prod` flavors (`dev` installs side by side as
`com.pharmacytracker.pharmacy_expiry_tracker.dev`).

```bash
flutter run --flavor dev
```

Flavor is available in code as `appFlavor` (`package:flutter/services.dart`).
iOS flavor schemes are not set up yet; use the default `Runner` scheme.

## Checks

```bash
flutter analyze
flutter test
tool/check_manifest.sh          # no INTERNET permission in release
```

## Database changes

Generated Drift code and schema snapshots are committed. After editing tables
or bumping `schemaVersion`:

```bash
dart run build_runner build
dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/
dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
```

Never edit a shipped schema version; add a stepwise migration and test.

## Layout

See technical design §3. `lib/domain` is pure Dart logic (alert planner, rules),
`lib/data` holds Drift and platform services, `lib/features` the screens.
