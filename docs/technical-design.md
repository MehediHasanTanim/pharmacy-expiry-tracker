# Pharmacy Expiry Tracker — Technical Design

**Version:** 0.1 (draft) · **Date:** 2026-10-17 · **Companion to:** [feature-spec.md](feature-spec.md)

This document turns the feature spec into an implementable design. Requirement IDs (e.g. `ALR-5`) refer to the spec.

---

## 1. Decisions & Assumptions

The spec left framework and market open. These defaults are chosen so work can start; each is reversible and noted in the decision log (§17).

| Decision | Choice | Why |
|---|---|---|
| Framework | **Flutter 3.x (Dart)** | One codebase; mature local-notification, SQLite and scanner packages; predictable background behavior. |
| Local DB | **SQLite via Drift** (+ SQLCipher in v1.1) | Typed queries, migrations, reactive streams, easy to unit test with in-memory DB. |
| State / DI | **Riverpod** | Compile-safe DI, testable, works well with Drift streams. |
| Navigation | **go_router** | Declarative, supports deep links from notifications. |
| Notifications | **flutter_local_notifications** + **timezone** | OS-native scheduled notifications (survive app kill). |
| Architecture | Feature-first, layered (presentation → domain → data) | Keeps alert logic pure and testable. |
| Min OS | Android 8.0 (API 26), iOS 15 | Matches spec §8. |
| Network | None in v1 | Offline-first (SEC-1). |
| Locale | Device locale; English strings, ARB-based i18n | Bangla/other added later. |

**Assumptions:** single user per device; no backend; prices optional; selling not tracked (only stock adjustments).

---

## 2. Architecture Overview

```
┌────────────────────────────── Presentation ──────────────────────────────┐
│  Screens / Widgets  ←→  Riverpod Notifiers (ViewModels)                  │
└───────────────┬──────────────────────────────────────────────────────────┘
                │ calls use cases / repositories (interfaces)
┌───────────────▼────────────────── Domain ────────────────────────────────┐
│  Entities · Value objects · Use cases · AlertPlanner (pure) · Rules       │
└───────────────┬──────────────────────────────────────────────────────────┘
                │ implemented by
┌───────────────▼────────────────── Data ──────────────────────────────────┐
│  Repositories · Drift DAOs · Mappers                                      │
│  Platform services: NotificationScheduler · BackupService · Scanner       │
└───────────────┬──────────────────────────────────────────────────────────┘
                │
        SQLite file  ·  OS notification scheduler  ·  Camera  ·  Share sheet
```

**Principles**
1. **Database is the source of truth.** Notifications are a nudge derived from it; the UI never depends on a notification having fired.
2. **Pure core.** `AlertPlanner`, bucket calculation, reorder rules and due-status are pure Dart functions taking `now` as an argument — fully unit-testable with no platform code.
3. **Idempotent reconciliation.** The scheduler diffs *desired* vs *scheduled* alerts; running it twice is harmless, so it can be triggered liberally.
4. **Transactions around every multi-table write.**

---

## 3. Project Structure

```
lib/
  main.dart
  app/
    app.dart                  # MaterialApp.router, theme, l10n
    router.dart               # go_router config, notification deep links
    providers.dart            # root Riverpod providers
  core/
    clock/clock.dart          # injectable Clock (now())
    date/expiry_date.dart     # month-only → end-of-month logic
    money/money.dart          # integer minor units
    result/result.dart
    utils/
  data/
    db/
      app_database.dart       # Drift database
      tables/*.dart
      daos/*.dart
      migrations/
    repositories/*_impl.dart
    services/
      notification_scheduler.dart
      backup_service.dart
      barcode_service.dart
      export_service.dart
  domain/
    entities/                 # Medicine, Batch, Supplier, Invoice, ...
    repositories/             # abstract interfaces
    usecases/
    alerts/
      alert_planner.dart      # pure
      planned_alert.dart
      alert_reconciler.dart
    rules/
      expiry_bucket.dart
      reorder_rules.dart
      invoice_status.dart
  features/
    home/ stock/ expiry/ suppliers/ reorder/ reports/ settings/ onboarding/
      (each: presentation/, providers/)
  l10n/                       # app_en.arb
test/
  unit/ domain/ data/ widget/
integration_test/
docs/
```

---

## 4. Data Layer

### 4.1 Conventions
- **IDs:** UUIDv4 text. Keeps door open for sync/merge later.
- **Money:** stored as **integer minor units** (e.g. cents/paisa) plus a global currency setting; never floats.
- **Dates:** expiry/invoice/payment dates stored as ISO `YYYY-MM-DD` text (calendar dates, no timezone). Timestamps (`created_at`, `fire_at`) stored as UTC epoch milliseconds.
- **Audit columns:** `created_at`, `updated_at`; soft delete via `deleted_at` (nullable). All reads filter `deleted_at IS NULL`.
- **Foreign keys ON**, `PRAGMA journal_mode=WAL`.

### 4.2 Schema (DDL sketch)

```sql
CREATE TABLE medicines (
  id TEXT PRIMARY KEY,
  brand_name TEXT NOT NULL,
  generic_name TEXT,
  strength TEXT,
  dosage_form TEXT NOT NULL DEFAULT 'other',
  unit TEXT NOT NULL DEFAULT 'piece',
  pack_size INTEGER,
  manufacturer TEXT,
  category TEXT,
  reorder_level INTEGER NOT NULL DEFAULT 0,
  preferred_supplier_id TEXT REFERENCES suppliers(id),
  alert_window_days INTEGER,            -- null = use global
  storage_condition TEXT,
  notes TEXT,
  is_archived INTEGER NOT NULL DEFAULT 0,
  search_text TEXT NOT NULL,            -- normalized brand+generic for search
  created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER
);
CREATE INDEX idx_med_search ON medicines(search_text);

CREATE TABLE medicine_barcodes (
  id TEXT PRIMARY KEY,
  medicine_id TEXT NOT NULL REFERENCES medicines(id),
  value TEXT NOT NULL UNIQUE,
  symbology TEXT
);

CREATE TABLE batches (
  id TEXT PRIMARY KEY,
  medicine_id TEXT NOT NULL REFERENCES medicines(id),
  batch_number TEXT NOT NULL,
  expiry_date TEXT NOT NULL,            -- YYYY-MM-DD (last day if month-only)
  expiry_precision TEXT NOT NULL,       -- 'MONTH' | 'DAY'
  quantity_received INTEGER NOT NULL,
  quantity_on_hand INTEGER NOT NULL,
  cost_price_minor INTEGER,
  selling_price_minor INTEGER,
  received_date TEXT NOT NULL,
  supplier_id TEXT REFERENCES suppliers(id),
  invoice_id TEXT REFERENCES supplier_invoices(id),
  status TEXT NOT NULL,                 -- ACTIVE|DEPLETED|RETURNED|DISCARDED
  snoozed_until TEXT,                   -- YYYY-MM-DD
  handled_at INTEGER,
  notes TEXT,
  created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER,
  UNIQUE (medicine_id, batch_number, expiry_date)
);
CREATE INDEX idx_batch_expiry ON batches(expiry_date) WHERE quantity_on_hand > 0;
CREATE INDEX idx_batch_med ON batches(medicine_id);
CREATE INDEX idx_batch_supplier ON batches(supplier_id);

CREATE TABLE stock_adjustments (
  id TEXT PRIMARY KEY,
  batch_id TEXT NOT NULL REFERENCES batches(id),
  delta_qty INTEGER NOT NULL,
  reason TEXT NOT NULL,
  note TEXT,
  value_impact_minor INTEGER,           -- cost × |delta| for losses
  return_id TEXT REFERENCES supplier_returns(id),
  created_at INTEGER NOT NULL
);

CREATE TABLE suppliers (
  id TEXT PRIMARY KEY, name TEXT NOT NULL, contact_person TEXT, phone TEXT,
  email TEXT, address TEXT, tax_id TEXT, payment_terms_days INTEGER,
  notes TEXT, is_archived INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER
);

CREATE TABLE supplier_invoices (
  id TEXT PRIMARY KEY,
  supplier_id TEXT NOT NULL REFERENCES suppliers(id),
  invoice_number TEXT,
  invoice_date TEXT NOT NULL,
  due_date TEXT,
  total_minor INTEGER NOT NULL,
  notes TEXT,
  reminders_snoozed_until TEXT,
  created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER
);
CREATE INDEX idx_inv_due ON supplier_invoices(due_date);

CREATE TABLE supplier_payments (
  id TEXT PRIMARY KEY,
  supplier_id TEXT NOT NULL REFERENCES suppliers(id),
  invoice_id TEXT REFERENCES supplier_invoices(id),
  amount_minor INTEGER NOT NULL,
  paid_on TEXT NOT NULL,
  method TEXT, reference TEXT,
  created_at INTEGER NOT NULL, deleted_at INTEGER
);

CREATE TABLE supplier_credits (
  id TEXT PRIMARY KEY,
  supplier_id TEXT NOT NULL REFERENCES suppliers(id),
  invoice_id TEXT REFERENCES supplier_invoices(id),
  return_id TEXT REFERENCES supplier_returns(id),
  amount_minor INTEGER NOT NULL, issued_on TEXT NOT NULL, note TEXT,
  created_at INTEGER NOT NULL, deleted_at INTEGER
);

CREATE TABLE supplier_returns (
  id TEXT PRIMARY KEY, supplier_id TEXT NOT NULL REFERENCES suppliers(id),
  returned_on TEXT NOT NULL, note TEXT, created_at INTEGER NOT NULL
);
CREATE TABLE supplier_return_lines (
  id TEXT PRIMARY KEY, return_id TEXT NOT NULL REFERENCES supplier_returns(id),
  batch_id TEXT NOT NULL REFERENCES batches(id),
  quantity INTEGER NOT NULL, value_minor INTEGER
);

CREATE TABLE reorder_orders (
  id TEXT PRIMARY KEY, medicine_id TEXT NOT NULL REFERENCES medicines(id),
  supplier_id TEXT REFERENCES suppliers(id),
  quantity INTEGER NOT NULL, ordered_on TEXT NOT NULL, expected_on TEXT,
  status TEXT NOT NULL,                 -- ORDERED|RECEIVED|CANCELLED
  created_at INTEGER NOT NULL
);

CREATE TABLE reorder_reminder_state (
  medicine_id TEXT PRIMARY KEY REFERENCES medicines(id),
  last_notified_on TEXT, snoozed_until TEXT
);

CREATE TABLE scheduled_alerts (
  id TEXT PRIMARY KEY,                  -- deterministic key, see §6.4
  kind TEXT NOT NULL,                   -- EXPIRY_LEAD|EXPIRY_DAY|DIGEST|PAYMENT|REORDER|BACKUP
  fire_at INTEGER NOT NULL,             -- UTC ms
  os_id INTEGER NOT NULL UNIQUE,        -- 31-bit int passed to the OS
  payload TEXT NOT NULL,                -- JSON (route + summary)
  content_hash TEXT NOT NULL,           -- detect changed title/body
  state TEXT NOT NULL                   -- PENDING|FIRED|CANCELLED
);
CREATE INDEX idx_alert_fire ON scheduled_alerts(fire_at);

CREATE TABLE alert_log (
  id TEXT PRIMARY KEY, kind TEXT NOT NULL, title TEXT NOT NULL, body TEXT NOT NULL,
  route TEXT, fired_at INTEGER NOT NULL, opened_at INTEGER
);

CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL);
```

### 4.3 Key derived queries
- **Near-expiry:** `batches JOIN medicines WHERE quantity_on_hand > 0 AND status='ACTIVE' AND expiry_date <= date(today, '+' || COALESCE(m.alert_window_days, :global) || ' days')` ordered by `expiry_date`.
- **Usable stock per medicine (reorder):** `SUM(quantity_on_hand) WHERE expiry_date >= today AND status='ACTIVE'`.
- **Invoice outstanding:** `total − SUM(payments) − SUM(credits)` via a view `v_invoice_balance`.
- **Value at risk:** `SUM(quantity_on_hand × cost_price_minor)` over near-expiry rows.

All exposed as Drift `watch()` streams so UI auto-refreshes.

### 4.4 Migrations
Drift `schemaVersion` with stepwise `onUpgrade`; migration tests via Drift's `SchemaVerifier` snapshots stored in `drift_schemas/`. Never edit a shipped schema version.

### 4.5 Search
Normalized `search_text` (lowercase, diacritics stripped) with `LIKE`/prefix matching for v1 (adequate for ≤5k medicines). If needed, upgrade to an FTS5 virtual table (Drift supports it) — noted as v1.1 option for typo tolerance.

---

## 5. Domain Rules (pure logic)

### 5.1 Expiry date handling (`core/date/expiry_date.dart`)
```dart
class ExpiryDate {
  final DateTime date;            // calendar date, no time
  final ExpiryPrecision precision; // month | day
  factory ExpiryDate.fromMonthYear(int month, int year) =>
      ExpiryDate(DateTime(year, month + 1, 0), ExpiryPrecision.month); // last day
  int daysUntil(DateTime today) => date.difference(dateOnly(today)).inDays;
  bool isExpired(DateTime today) => daysUntil(today) < 0; // valid through end of day
}
```
Rules: valid *through* expiry day; expired starting next day (spec §6).

### 5.2 Buckets (`expiry_bucket.dart`)
`enum Bucket { expired, d30, d60, d90, ok }`, thresholds from settings (default 30/60/90). Function `bucketFor(daysLeft, thresholds)`.

### 5.3 Reorder (`reorder_rules.dart`)
- `usable(medicine) = Σ qty of batches not expired`.
- `needsReorder = usable < reorder_level`.
- `projectedShortfallDate`: walk batches ordered by expiry, subtract each batch's qty as it expires; first date where remaining < level (ROR-3).
- `suggestedQty = max(level*2 − usable, 1)`.

### 5.4 Invoice status (`invoice_status.dart`)
`unpaid | partial | paid | overdue` from balance, payments, `due_date`, `today`.

---

## 6. Alert Engine (core feature)

### 6.1 Components

| Component | Layer | Responsibility |
|---|---|---|
| `AlertPlanner` | domain, pure | Given a snapshot + settings + `now`, return desired `List<PlannedAlert>`. |
| `AlertReconciler` | domain | Diff desired vs `scheduled_alerts`; produce `toCancel`, `toSchedule`. |
| `NotificationScheduler` | data, platform | Executes diff against `flutter_local_notifications`; updates table in a transaction. |
| `AlertCoordinator` | app | Subscribes to triggers and invokes plan→reconcile→apply, debounced. |

### 6.2 `PlannedAlert`
```dart
class PlannedAlert {
  final String key;        // deterministic, e.g. "lead:2026-11-17" or "digest:2026-10-18"
  final AlertKind kind;
  final DateTime fireAt;   // local wall-clock converted to tz-aware time
  final String title, body;
  final String route;      // deep link, e.g. /expiry?bucket=d30&date=2026-11-17
  final String contentHash;
}
```

### 6.3 Planning algorithm
```
plan(snapshot, settings, now):
  alerts = []
  # 1. Expiry lead-time alerts, grouped per fire date
  for batch in snapshot.activeBatches where !handled && qty>0:
    for lead in settings.leadDays (incl. 0):
      day = batch.expiry - lead
      if day < today: continue
      if batch.snoozedUntil && day <= snoozedUntil: continue
      groups[day].add(batch, lead)
  for (day, items) in groups:
      fireAt = applyQuietHours(day @ settings.alertTime)
      alerts += grouped notification (title: "Expiry in N days — K batches")
  # 2. Daily digest for next D days (skip empty days per setting)
  #    Digest content depends on state at fire time (see 6.6).
  # 3. Payment reminders: for each unpaid invoice with due_date: lead offsets + overdue repeats
  # 4. Reorder reminders: for medicines below level and not suppressed
  # 5. Backup reminder
  sort by fireAt; take first MAX_PENDING (60)
```
- **Grouping** (ALR-3): one notification per fire-date per kind; body lists the top 3 items + "and N more".
- **Cap** (ALR-5): keep earliest 60 across all kinds; `MAX_PENDING` is a constant, below iOS's 64 limit. On Android the same cap is used for uniformity (OS supports far more).
- **Digest horizon:** schedule digests for the next ~14 days only; further days are added at re-plan.
- **Quiet hours** (ALR-10): if `fireAt` falls in quiet window, move to window end.

### 6.4 Keys & OS IDs
`key` is stable per logical alert (`kind:date[:ref]`). `os_id = stableHash31(key)` with collision check against the table (linear probe). This makes reconciliation deterministic and lets us cancel by key without scanning OS state.

### 6.5 Reconcile & apply
```
desired  = plan(...)
existing = SELECT * FROM scheduled_alerts WHERE state='PENDING'
cancel   = existing − desired (by key)  ∪  existing where contentHash changed
schedule = desired − existing           ∪  changed
BEGIN TX
  for c in cancel:   plugin.cancel(c.os_id); mark CANCELLED
  for s in schedule: plugin.zonedSchedule(s.os_id, ..., payload); upsert PENDING
COMMIT
```
- Past-due PENDING rows (fire_at < now) are marked FIRED and inserted into `alert_log` on next launch (missed-alert recovery, spec §9.6).
- Plugin failures roll the row state back to be retried on the next plan.

### 6.6 Stale content problem
A scheduled notification's text is fixed at schedule time, but data may change before it fires (e.g. user discards the batch → count wrong). Mitigations:
1. Every data mutation triggers re-plan → texts refreshed/cancelled immediately (primary defense).
2. Digest wording is **generic** when scheduled ("Open to review today's expiry actions") unless the app has re-planned within the last 24 h, in which case it includes counts. Counts are never claimed as exact for alerts > 24 h out ("Expiry in 30 days — review batches").
3. Tapping always opens a live query-driven screen, so the UI is correct regardless of notification text.

### 6.7 Triggers (`AlertCoordinator`)
| Trigger | Mechanism |
|---|---|
| Batch / invoice / payment / settings / reorder change | Repository emits change → coordinator (debounced 500 ms) |
| App launch & resume | `WidgetsBindingObserver` |
| Device reboot (Android) | Plugin's `ScheduledNotificationBootReceiver` restores OS schedules; app re-plans on next launch; a lightweight `workmanager` task also re-plans after boot |
| Timezone/clock change | Android `TIMEZONE_CHANGED`/`TIME_SET` broadcasts → workmanager; iOS: `significantTimeChange` on resume + re-plan |
| Daily maintenance | `workmanager` periodic (~24 h, Android) / `BGAppRefreshTask` (iOS), best effort |
| Notification received (foreground) | Mark FIRED, log, re-plan |

### 6.8 Platform specifics

**Android**
- Channels: `expiry_critical` (high importance), `expiry_digest` (default), `payments`, `reorder`, `backup`.
- Permissions: `POST_NOTIFICATIONS` (API 33+), `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`. Use `AndroidScheduleMode.exactAllowWhileIdle` when allowed; otherwise `inexactAllowWhileIdle` (alerts may drift a few minutes — acceptable, as alerts are date-level).
- Battery: alert health screen deep-links to `ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS`, and shows OEM-specific tips (Xiaomi autostart, etc.).
- Notification-tap routing via `onDidReceiveNotificationResponse` + `getNotificationAppLaunchDetails` for cold starts.

**iOS**
- Calendar-based triggers via `zonedSchedule` (`UNCalendarNotificationTrigger`) at local time.
- 64 pending limit → capped plan; re-plan on foreground/background refresh.
- Request authorization with `alert, badge, sound`; consider provisional authorization is *not* used (we want banners).
- Badge: set to count of needs-action batches on each plan and on resume.

### 6.9 Permission & health model
`AlertHealth` aggregate (provider):
`notificationsGranted` · `exactAlarmsGranted` · `batteryOptimized` (Android) · `lastReconcileAt` · `nextAlertAt` · `pendingCount`.
Home banner shows if `!notificationsGranted` or (`Android && batteryOptimized && OEM known-aggressive`).
**Test alert** schedules a notification 5 s out through the real path and records whether it was received while in foreground/background.

### 6.10 Edge cases
- Expiry day lead `0`: fires at alert time that day.
- Batch added with expiry already inside lead windows: skip past leads, but schedule the next future one; and show a snackbar "Already within 30 days".
- Leap day / month-end: handled by `DateTime(year, month + 1, 0)`.
- DST: scheduling uses `tz.TZDateTime` in the device's local zone, so 09:00 stays 09:00; ambiguous/nonexistent local times resolved forward.
- Snoozed batch: lead alerts suppressed until snooze end; first alert after snooze fires next alert-time.
- Handled/discarded/returned/depleted batches: excluded from plan → cancelled via diff.
- Clock manually set back: re-plan on time-change trigger; duplicates avoided because keys are deterministic.

---

## 7. Feature Modules — Implementation Notes

### 7.1 Stock & batch entry
- `AddBatchController` (Riverpod `Notifier`) holds form state; validates (BAT-3); checks duplicate (BAT-4) via `batchRepo.findByMedicineAndNumber`.
- **Expiry input:** custom month/year picker (wheel or 2 text fields `MM / YYYY`) with a toggle to "full date". Shows the interpreted date beneath ("Expires 31 Aug 2027").
- **Quick add:** last supplier/received date kept in a `lastUsedProvider` (in-memory + persisted in settings).
- **Saving** runs in a single transaction: insert batch → insert initial adjustment (`+qty`, reason RECEIVED) → optionally create invoice → coordinator notified.

### 7.2 Adjustments
`AdjustStockUseCase(batchId, delta, reason, note)`:
1. Transaction; reject if result < 0.
2. Insert `stock_adjustments`; update `quantity_on_hand`; set status `DEPLETED` at 0 (or `DISCARDED`/`RETURNED` by reason).
3. Compute `value_impact` for loss reasons using batch cost.
4. Emit change → re-plan alerts.

### 7.3 Returns & credits
`ReturnToSupplierUseCase`: creates `supplier_returns` + lines, adjustments (reason RETURNED), and optionally a `supplier_credits` row; all in one transaction.

### 7.4 Dues
- Payments with `invoice_id = null` are auto-allocated oldest-due-first at write time by splitting into per-invoice payment rows (keeps the balance query simple).
- Overpayment is rejected with a prompt to record as supplier credit.

### 7.5 Reorder
`ReorderService.evaluate()` runs on stock changes and daily; updates `reorder_reminder_state`, and the planner reads that state to emit reminders honoring the re-fire interval.

### 7.6 Scanning
`mobile_scanner` wrapped by `BarcodeService`. Lookup order: `medicine_barcodes.value` exact → prompt to link. GS1 parser (v1.2) is a pure function `Gs1.parse(String) -> {gtin, lot, expiry}` handling FNC1/GS separators and AI table.

### 7.7 Backup / restore
- **Export:** `VACUUM INTO` a temp file → zip with metadata (`app_version`, `schema_version`, `created_at`, checksum) → optionally AES-256-GCM encrypt with a key derived via PBKDF2/Argon2 from the user passphrase → share sheet.
- **Restore:** validate checksum & schema version (reject newer-than-app; migrate older), show summary (counts), require confirmation, close DB, swap file atomically, reopen, then **force a full re-plan** of alerts and clear `scheduled_alerts` (cancelling all OS notifications first).
- Settings (including alert preferences) are included in the backup.

### 7.8 Reports & export
SQL aggregates → view models. CSV via `csv` package; PDF via `pdf`/`printing`. Large exports are generated in an isolate to keep the UI responsive.

### 7.9 App lock
`local_auth` + PIN fallback (hash stored in secure storage). Lock on background after configurable timeout. Alerts and background re-plans work while locked (planner uses DB directly; with SQLCipher the key is in the keychain/keystore, not behind the app PIN).

---

## 8. State Management

- **Repositories** return `Stream<T>` for lists/aggregates and `Future<T>` for commands.
- **Providers:** `StreamProvider` per list/query; `Notifier`/`AsyncNotifier` for commands/forms; `Provider` for use cases (constructor-injected repos).
- **Clock** injected everywhere (`clockProvider`) so "today" is controllable in tests; a midnight timer invalidates date-dependent providers at day rollover.
- Errors surface via `AsyncValue.error` and a central `ErrorReporter` (local log only).

---

## 9. UI Implementation Notes

- Material 3, light/dark, `ColorScheme.fromSeed`. Urgency uses a semantic palette + **icon + text label** (never color alone).
- Lists use `SliverList` with item extents for performance; paging via Drift `limit/offset` with keyset on `(expiry_date, id)` for the Expiry tab.
- Swipe actions via `flutter_slidable`.
- All text via ARB; plural-aware (`{count, plural, ...}`).
- Minimum 48dp touch targets; semantic labels on icons; supports `textScaler` up to 200%.

**Navigation map**
```
/home
/stock  /stock/medicine/:id  /stock/batch/:id  /stock/add
/expiry?bucket=&supplier=&date=
/suppliers  /suppliers/:id  /suppliers/:id/invoice/new  /suppliers/:id/pay
/reorder
/more  /more/reports  /more/settings  /more/alert-health  /more/backup
/onboarding
```
Notification payload `route` is one of these; the router handles cold-start deep-link after unlock/onboarding.

---

## 10. Security & Privacy

- No network permission requested in release builds (INTERNET omitted on Android; ATS irrelevant on iOS) — enforced as a CI check on the merged manifest.
- DB encryption at rest (SQLCipher) in v1.1; key generated at first run, stored in Keychain / Android Keystore via `flutter_secure_storage`.
- Backup files optionally passphrase-encrypted; passphrase is never stored.
- Android: `allowBackup="false"` for DB to avoid unencrypted cloud copies, **unless** user opts into OS backup (setting); iOS: mark DB file `isExcludedFromBackup` per same setting.
- Logs contain no medicine/supplier names in release builds.
- Notification text may show on the lock screen: setting "Hide details on lock screen" (uses `visibility: private` on Android / generic body on iOS).

---

## 11. Performance Plan

| Concern | Approach |
|---|---|
| Large lists | Indexed queries, keyset pagination, `const` widgets, `ListView.builder`. |
| Startup | Lazy init; DB opened in a background isolate (`NativeDatabase.createInBackground`); defer alert reconcile until after first frame. |
| Re-plan cost | Planner reads only active batches within the largest lead window (+ unpaid invoices); target < 1 s for 50k batches (benchmark in CI). |
| Rebuild storms | `select`-scoped providers, debounced coordinator. |
| Export | Isolate-based generation. |

---

## 12. Testing Strategy

| Level | Scope | Tooling |
|---|---|---|
| **Unit (heaviest)** | `ExpiryDate`, bucket, reorder rules, invoice status, **AlertPlanner** (grouping, cap, quiet hours, snooze, DST, leap day, month-end, past dates), reconciler diffs, GS1 parser | `flutter_test`, fake `Clock` |
| **Data** | DAOs, queries, transactions (return+credit atomicity), migrations | Drift in-memory DB, `SchemaVerifier` |
| **Widget** | Add batch form validation, Expiry list buckets/actions, permission banner | `flutter_test`, golden tests for key screens (light/dark/large text) |
| **Integration** | Add batch → alert scheduled; discard → alert cancelled; restore → re-plan | `integration_test` with a **fake `NotificationPlugin`** recording calls |
| **Device/manual** | Real delivery with airplane mode, reboot, force-stop, Doze, timezone change, DST; matrix: Pixel, Samsung, Xiaomi, iPhone (iOS 15 & latest) | Checklist in `docs/qa-alert-matrix.md` |
| **Perf** | Seed 5k medicines / 50k batches; assert query and plan timings | Custom benchmark test |

**Key design-for-test seams:** `Clock`, `NotificationPlugin` interface (wrapping the Flutter plugin), `AppDatabase.forTesting(memory)`.

CI (GitHub Actions): `flutter analyze` (strict lints) → unit/widget tests with coverage gate (domain ≥ 90%) → debug builds for both platforms → manifest check (no INTERNET).

---

## 13. Build, Release & Environments

- **Flavors:** `dev` (separate app id, verbose logs, seed-data button) and `prod`.
- **Versioning:** semver; DB `schemaVersion` independent and documented per release.
- **Distribution:** Play Console (internal → closed → production); TestFlight → App Store.
- **Seed/demo data:** generator producing batches at varied expiry offsets for QA and screenshots (dev flavor only).
- **Crash reporting:** none by default (offline/privacy); optional opt-in local "export diagnostic log" for support.

---

## 14. Implementation Roadmap

| Milestone | Deliverables | Exit criteria |
|---|---|---|
| **M0 – Foundations** (wk 1) | Project scaffold, CI, theme, l10n, Drift schema v1, Clock, router | App boots; DB migration test green |
| **M1 – Catalog & batches** (wk 2–3) | Medicine + batch CRUD, adjustments, validation, search | Add/edit/adjust works offline; unit + data tests pass |
| **M2 – Expiry lists** (wk 3–4) | Near-expiry/expired screens, buckets, filters, actions (discard/snooze) | Spec EXP-1…5, 7, 8 met |
| **M3 – Alert engine** (wk 4–6) | Planner, reconciler, scheduler, coordinator, permissions, health screen, deep links | Alerts verified on device matrix incl. reboot & airplane mode |
| **M4 – Suppliers & dues** (wk 6–7) | Suppliers, invoices, payments, due reminders | SUP P0 items met |
| **M5 – Reorder & Home** (wk 7–8) | Reorder list/reminders, dashboard, onboarding | HOM-1/2/5, ROR P0 met |
| **M6 – Backup & hardening** (wk 8–9) | Backup/restore, a11y pass, perf benchmarks, beta release | MVP scope complete; beta to pilot pharmacy |
| **M7+ (v1.1)** | Scanner, returns/credits, reports, SQLCipher, app lock | Per spec §11 |

*Alerts (M3) are scheduled early on purpose: they are the highest-risk and highest-value piece.*

---

## 15. Risks (technical)

| Risk | Mitigation |
|---|---|
| OEM kills background tasks / ignores alarms | OS-native scheduled notifications; health screen; re-plan on every open; digest redundancy; device matrix testing early (M3) |
| iOS 64 cap | Grouping + rolling 60-window + re-plan on foreground/BG refresh |
| Plugin limitations (exact alarms, boot restore, tz handling) | Isolate behind `NotificationPlugin` interface; spike on real devices at start of M3; fallback to a small native Kotlin/Swift channel if needed |
| Stale notification text | Re-plan on every mutation; generic wording for far-future alerts (§6.6) |
| Migration bugs corrupting data | `SchemaVerifier` tests; automatic pre-migration DB copy kept until next successful launch |
| Restore replaces data wrongly | Checksum + schema validation, summary + confirmation, atomic swap, keep previous DB as `.bak` for 24 h |
| Month-only expiry misinterpreted | Single `ExpiryDate` abstraction; UI always displays resolved date |

---

## 16. Open Technical Questions

1. Confirm **Flutter** (vs React Native) before M0.
2. Is `SCHEDULE_EXACT_ALARM` justified for Play review? Fallback inexact path is designed in; decide whether to request exact at all (date-level alerts may not need it).
3. Should the DB be **encrypted from MVP** rather than v1.1? (Adds ~0.5 week; recommended if the pharmacy device is shared or unlocked.)
4. Do we need **tablet/landscape** layouts at MVP?
5. Required **backup destination** beyond share sheet (e.g. direct Google Drive/iCloud Drive)?

---

## 17. Decision Log

| # | Decision | Alternatives considered | Rationale |
|---|---|---|---|
| D1 | Flutter | React Native/Expo | Stronger local-notification + SQLite story, single rendering stack |
| D2 | Drift/SQLite | Isar, Hive, ObjectBox | Relational data (batches↔suppliers↔dues), migrations, transactions |
| D3 | Money as integer minor units | `double`, `Decimal` | Avoids rounding errors, trivial to store/sum in SQL |
| D4 | Expiry as calendar date text | UTC timestamp | No timezone drift; matches how expiry is printed |
| D5 | Grouped notifications + rolling window | One notification per batch/lead | Respects iOS cap, reduces spam |
| D6 | Deterministic alert keys + diff reconcile | Cancel-all-and-reschedule | Idempotent, cheap, fewer OS calls, no flicker |
| D7 | DB is source of truth, notifications advisory | Notification-driven state | Resilient to OS suppressing/killing alerts |
| D8 | Feature-first layered architecture | MVC/flat | Keeps pure alert/rules logic isolated and testable |
