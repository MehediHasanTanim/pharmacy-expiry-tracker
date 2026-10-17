# Pharmacy Expiry Tracker — Feature Specification

**Version:** 0.1 (draft) · **Date:** 2026-10-17 · **Platforms:** Android + iOS (mobile)

---

## 1. Overview

A mobile app for small and mid-size pharmacies to track medicine batches and their expiry dates, surface near-expiry stock before it becomes a loss, manage supplier dues, and get reminders to reorder.

**The core value is expiry alerts, and they must work entirely on-device** — no internet, no server, no account required. Everything else supports that loop: record batches → get warned → act (sell first, return to supplier, discard) → reorder.

### 1.1 Goals
- Never let a batch expire unnoticed.
- Make stock entry fast enough to do at the shelf or while receiving a delivery.
- Show, in one glance, what needs attention today.
- Keep a clear picture of what is owed to each supplier.
- Work fully offline; data stays on the device by default.

### 1.2 Non-goals (v1)
- Point-of-sale / billing / customer-facing sales.
- Prescription management or patient records.
- Multi-branch real-time sync and multi-user roles (see §12 Future).
- Regulatory reporting (e.g. controlled-substance registers).
- Automatic supplier ordering (reminders only; no order transmission).

### 1.3 Target users
| Persona | Needs |
|---|---|
| **Owner-pharmacist** (primary) | Overview, loss prevention, supplier dues, reorder decisions |
| **Shop assistant / stock keeper** | Fast batch entry, scanning, shelf checks, marking items sold/discarded |

v1 is single-user per device; both personas share the same app experience.

---

## 2. Key Concepts & Terminology

| Term | Definition |
|---|---|
| **Medicine (Product)** | A catalog entry: brand name, generic name, strength, form, unit, etc. |
| **Batch** | A specific received lot of a medicine: batch/lot number, expiry date, quantity, cost. One medicine has many batches. |
| **Near-expiry** | A batch expiring within the configured alert window (default 90 days). |
| **Expired** | Expiry date has passed; stock must be quarantined/discarded/returned. |
| **Supplier** | A distributor/wholesaler/rep from whom batches are purchased. |
| **Due** | An amount owed to a supplier for received stock, with optional due date. |
| **Reorder level** | Minimum total on-hand quantity of a medicine before a reminder fires. |
| **FEFO** | First-Expired-First-Out: sell the soonest-expiring batch first. |

---

## 3. Information Architecture

Bottom navigation with five tabs:

1. **Home** — today's dashboard (alerts, counts, dues, reorder)
2. **Stock** — medicines and their batches (search, filter, scan)
3. **Expiry** — near-expiry and expired lists (the primary workflow screen)
4. **Suppliers** — supplier list, dues, payments
5. **More** — reorder list, reports/export, settings, backup

A persistent floating **"+ Add stock"** action is available on Home, Stock and Expiry.

---

## 4. Functional Requirements

Priority legend: **P0** = MVP-critical · **P1** = MVP-desirable · **P2** = post-MVP.

### 4.1 Medicine Catalog

| ID | Requirement | Priority |
|---|---|---|
| MED-1 | Create/edit/archive a medicine with: brand name (required), generic name, strength (e.g. 500 mg), dosage form (tablet, capsule, syrup, injection, ointment, drops, other), unit of measure (strip, box, bottle, vial, piece), pack size, manufacturer, category/tags, barcode(s), notes. | P0 |
| MED-2 | Per-medicine **reorder level** (min quantity) and optional **preferred supplier**. | P0 |
| MED-3 | Per-medicine **override of alert window** (e.g. 180 days for slow movers, 30 days for fast movers). Falls back to global default. | P1 |
| MED-4 | Optional **storage condition** flag (room temp / refrigerated / controlled) shown on batch detail. | P2 |
| MED-5 | Duplicate detection: warn if brand + strength + form already exists. | P1 |
| MED-6 | Archiving hides a medicine from lists and stops its alerts but retains history. | P0 |
| MED-7 | Bulk import of the catalog from CSV. | P2 |

### 4.2 Batch Management

| ID | Requirement | Priority |
|---|---|---|
| BAT-1 | Add a batch to a medicine: **batch/lot number**, **expiry date** (required), **quantity** (required), purchase (cost) price, selling price (MRP), received date (default today), supplier, notes. | P0 |
| BAT-2 | **Expiry date entry** supports month/year only (common on packaging, e.g. `08/2027`) — interpreted as the **last day of that month** — as well as full dates. | P0 |
| BAT-3 | Validation: expiry must be present; warn (do not block) if expiry is already past or more than 10 years out; quantity must be a positive number. | P0 |
| BAT-4 | Warn when the same medicine + batch number already exists, offering "add to existing batch" (increase quantity) or "create separate". | P0 |
| BAT-5 | **Adjust quantity** on a batch with a reason: *sold/used*, *damaged*, *expired–discarded*, *returned to supplier*, *correction*, *transferred*. Every adjustment is logged (who/when/why/delta). | P0 |
| BAT-6 | Batch status derived automatically: **Active**, **Near-expiry**, **Expired**, **Depleted** (qty 0), **Returned**, **Discarded**. | P0 |
| BAT-7 | **Quick add** mode: pick/scan medicine → enter expiry + qty → save (≤ 3 taps of required fields beyond typing). Remembers last supplier and received date between consecutive adds. | P0 |
| BAT-8 | **Bulk receive**: add several batches under one supplier delivery in one session and optionally create a single supplier due from the total. | P1 |
| BAT-9 | Edit a batch (correct expiry, number, cost). Editing expiry re-evaluates alerts immediately. | P0 |
| BAT-10 | Batch detail shows full adjustment history and linked supplier/due. | P1 |
| BAT-11 | Photo attachment on a batch (pack/expiry print) stored locally. | P2 |

### 4.3 Near-Expiry & Expired Lists (main workflow)

| ID | Requirement | Priority |
|---|---|---|
| EXP-1 | **Near-expiry list**: all batches with remaining qty > 0 expiring within the alert window, sorted by soonest expiry first. | P0 |
| EXP-2 | Items are grouped into **urgency buckets** with color + icon (never color alone, for accessibility): **Expired** (red), **≤ 30 days** (orange), **31–60 days** (amber), **61–90 days** (yellow), **> 90 days** (none). Bucket thresholds are configurable. | P0 |
| EXP-3 | Each row shows: medicine name + strength, batch no., expiry date, **days remaining** (or "expired N days ago"), quantity, **value at risk** (qty × cost), supplier. | P0 |
| EXP-4 | **Filters**: bucket, supplier, category/form, search by name/batch/barcode. **Sort**: soonest expiry, highest value at risk, name. | P0 |
| EXP-5 | **Row actions** (swipe or tap-through): *Mark sold down / adjust qty*, *Return to supplier*, *Discard*, *Snooze alert*, *Mark as handled*. | P0 |
| EXP-6 | **Return to supplier** records a return (qty, date, optional credit note amount). If a credit amount is entered, it can reduce that supplier's outstanding due. | P1 |
| EXP-7 | **Discard** requires confirmation and logs a write-off with value lost; contributes to the loss report. | P0 |
| EXP-8 | **Expired tab** lists expired batches still holding stock, prominently flagged "Remove from shelf". Unresolved expired stock is surfaced on Home until handled. | P0 |
| EXP-9 | Multi-select to bulk-discard or bulk-return. | P1 |
| EXP-10 | **Shelf check mode**: step through near-expiry items one by one ("Is it still on the shelf? Qty?") to reconcile and act. | P2 |
| EXP-11 | Share/print the near-expiry list (PDF / text) to send to a supplier or staff. | P1 |

### 4.4 Local Expiry Alerts (core feature)

All alerts are **scheduled on-device using the OS local-notification APIs**. No server, push service, or network is involved.

| ID | Requirement | Priority |
|---|---|---|
| ALR-1 | For each active batch, schedule local notifications at configurable **lead times before expiry**. Defaults: **90, 60, 30, 14, 7, 1 days** before, and **on expiry day**. User can add/remove lead times globally. | P0 |
| ALR-2 | **Daily digest** notification at a user-set time (default 09:00): "N batches expire within 30 days · M expired · ₹X at risk". Tapping opens the Expiry tab. Digest is skipped on days with nothing to report (configurable). | P0 |
| ALR-3 | Per-batch individual alerts are **coalesced**: if many batches hit the same lead-time on the same day, send one grouped notification rather than N (avoids spam and OS scheduled-notification limits). | P0 |
| ALR-4 | Alerts are **recomputed and rescheduled** whenever a batch is added, edited, depleted, discarded, returned, or snoozed; and whenever alert settings change. Cancelled for depleted/discarded/returned batches. | P0 |
| ALR-5 | **Reliability against OS limits**: iOS caps pending local notifications at 64. Strategy: keep a rolling schedule of the next ≤ 60 *grouped* notifications (by date), and **re-plan on every app launch / foreground / background refresh**. Android uses exact/inexact alarms per OS rules. | P0 |
| ALR-6 | **Survive reboot / app update / time change**: re-register schedules on device boot (Android `BOOT_COMPLETED`), app update, timezone or clock change. | P0 |
| ALR-7 | **Permission flow**: request notification permission with a pre-prompt explaining why; handle denial with a persistent in-app banner ("Alerts are off — expiry warnings won't reach you") linking to system settings. On Android 13+ request `POST_NOTIFICATIONS`; on Android 12+ handle exact-alarm permission and fall back gracefully to inexact. | P0 |
| ALR-8 | **Alert health check** screen: shows permission status, battery-optimization status (Android OEM kill risk), next scheduled alert, and a **"Send test alert"** button. | P1 |
| ALR-9 | **Snooze** a batch alert (1 day / 3 days / 1 week / until next lead time). **Dismiss/handled** stops further lead-time alerts for that batch (digest still shows if unresolved expired). | P0 |
| ALR-10 | **Quiet hours** setting (no alerts between X and Y). Alerts due in quiet hours deliver at the end of it. | P1 |
| ALR-11 | Notification **actions** (where OS supports): *View*, *Snooze 1 day*. | P2 |
| ALR-12 | In-app **alert center / history**: log of fired alerts so a dismissed notification can be revisited. | P1 |
| ALR-13 | Home screen **badge count** = batches needing action (expired + ≤ critical bucket). | P1 |
| ALR-14 | Reorder and supplier-due reminders (§4.6, §4.5) use the same local scheduling engine and quiet-hours rules. | P0 |
| ALR-15 | Alerts fire correctly with **no network** and **no account**; this must be verified by testing in airplane mode. | P0 |

**Notification copy examples**
- Lead time: *"Expiry in 30 days — 4 batches (₹3,200 at risk). Tap to review."*
- Expiry day: *"Expires today: Amoxicillin 500 mg (Batch A123), 24 strips."*
- Digest: *"Good morning. 6 near expiry · 2 expired on shelf."*

### 4.5 Supplier Management & Dues

| ID | Requirement | Priority |
|---|---|---|
| SUP-1 | Create/edit/archive suppliers: name (required), contact person, phone, email, address, notes, payment terms (e.g. net 30), optional license/GST/tax ID. | P0 |
| SUP-2 | **One-tap contact**: call, SMS, WhatsApp (via deep link), email from supplier profile. | P1 |
| SUP-3 | **Dues ledger** per supplier: list of *charges* (purchase invoices / deliveries) and *payments*. Outstanding = charges − payments − credits. | P0 |
| SUP-4 | Add a **due (invoice)**: amount, invoice number, invoice date, **due date**, linked batches (optional), notes. | P0 |
| SUP-5 | Record a **payment** (full or partial): amount, date, method (cash/bank/mobile wallet/cheque), reference. Payments apply to a chosen invoice or oldest-first. | P0 |
| SUP-6 | Due status per invoice: **Unpaid**, **Partially paid**, **Paid**, **Overdue** (past due date, unpaid). | P0 |
| SUP-7 | **Suppliers list** shows outstanding balance and overdue badge; sort by balance, due date, name. | P0 |
| SUP-8 | **Dues summary** card on Home: total outstanding, total overdue, next due date. | P0 |
| SUP-9 | **Payment reminders** (local): at configurable lead times (default 3 days before and on due date), plus an overdue reminder every N days (default 3) until paid or snoozed. | P0 |
| SUP-10 | **Credit notes / returns** reduce the balance (links with EXP-6). | P1 |
| SUP-11 | Supplier statement export (PDF/CSV) for reconciliation. | P1 |
| SUP-12 | Attach invoice photo (local). | P2 |

### 4.6 Reorder Reminders

| ID | Requirement | Priority |
|---|---|---|
| ROR-1 | A medicine is **below reorder level** when total *usable* quantity (active + near-expiry, **excluding expired**) < its reorder level. | P0 |
| ROR-2 | **Reorder list**: medicines at/below level, showing on-hand, level, suggested order qty (= level×2 − on-hand by default, editable), preferred supplier. Grouped by supplier. | P0 |
| ROR-3 | **Expiry-aware**: if stock will fall below level *because* batches are about to expire within the alert window, flag "Will fall below level by <date>". | P1 |
| ROR-4 | **Local reorder reminder**: when stock crosses below level (checked on every quantity change and daily), fire a notification; at most once per medicine per N days (default 3) until restocked or snoozed. | P0 |
| ROR-5 | Mark as **"Ordered"** with expected delivery date; suppresses reminders until that date, then reminds if not received. | P1 |
| ROR-6 | **Share order list** per supplier as text/PDF/WhatsApp message ("Please supply: …"). Sent by the user via the OS share sheet — the app does not transmit orders itself. | P1 |
| ROR-7 | Quick "Received" action converts an ordered line into a new batch entry (pre-filled medicine & supplier). | P1 |

### 4.7 Search & Barcode Scanning

| ID | Requirement | Priority |
|---|---|---|
| SCN-1 | Global search by brand, generic name, batch number, supplier. Tolerant of minor typos and case. | P0 |
| SCN-2 | **Barcode scan** (EAN-13 / UPC / Code128 / GS1 DataMatrix / QR) via camera to find or create a medicine. First scan of an unknown barcode prompts to link it to a medicine. | P1 |
| SCN-3 | **GS1 DataMatrix parsing**: where present, auto-fill batch number and expiry date from application identifiers (AI 10 = lot, AI 17 = expiry, AI 01 = GTIN). | P2 |
| SCN-4 | **OCR of expiry date** from camera frame, with user confirmation. | P2 |

### 4.8 Home Dashboard

| ID | Requirement | Priority |
|---|---|---|
| HOM-1 | **Needs attention** cards: Expired on shelf (count, value), Expiring ≤ 30 days (count, value), Reorder needed (count), Overdue dues (count, amount). Each taps through to the filtered list. | P0 |
| HOM-2 | **Alert status** banner if notifications are disabled or exact-alarm/battery restrictions threaten reliability. | P0 |
| HOM-3 | "**Expiring this week**" mini-list (top 5). | P1 |
| HOM-4 | Value-at-risk figure: total cost of stock expiring in the alert window. | P1 |
| HOM-5 | Empty-state onboarding for new users (add first medicine, enable alerts). | P0 |

### 4.9 Reports & Export

| ID | Requirement | Priority |
|---|---|---|
| RPT-1 | **Expiry loss report**: value of stock discarded/expired by month, by supplier, by medicine. | P1 |
| RPT-2 | **Stock valuation**: on-hand qty × cost, total and by category. | P1 |
| RPT-3 | **Supplier dues aging**: 0–30 / 31–60 / 61–90 / 90+ days. | P1 |
| RPT-4 | Export any list/report to **CSV** and **PDF** via the share sheet. | P1 |
| RPT-5 | Returns-to-supplier summary. | P2 |

### 4.10 Settings

| ID | Setting | Default |
|---|---|---|
| SET-1 | Global near-expiry window | 90 days |
| SET-2 | Urgency bucket thresholds | 30 / 60 / 90 days |
| SET-3 | Alert lead times | 90, 60, 30, 14, 7, 1, 0 days |
| SET-4 | Daily digest on/off + time | On, 09:00 |
| SET-5 | Quiet hours | Off (22:00–07:00 suggested) |
| SET-6 | Payment reminder lead times / overdue interval | 3 d, 0 d / every 3 d |
| SET-7 | Reorder reminder re-fire interval | 3 days |
| SET-8 | Currency symbol & number format | Device locale |
| SET-9 | Date format; week start | Device locale |
| SET-10 | Language (EN at launch; structure for i18n e.g. Bangla) | English |
| SET-11 | Theme: light / dark / system | System |
| SET-12 | App lock (PIN / biometric) | Off |
| SET-13 | Backup & restore (see §7) | — |

---

## 5. Key User Flows

### 5.1 First launch
1. Brief 3-screen intro (track expiry → get alerts → manage dues).
2. Set pharmacy name, currency, alert window (accept defaults).
3. **Notification permission pre-prompt** → system prompt. Android: also guide through exact-alarm and battery settings if needed.
4. Prompt to add first medicine / import / start scanning.

### 5.2 Receive stock (the most frequent flow)
1. Tap **+ Add stock** → scan barcode or search medicine (or create inline).
2. Enter batch no., expiry (month/year picker), quantity, cost.
3. Supplier pre-filled from last add / preferred supplier.
4. Save → batch created → alerts scheduled → toast "Alerts set for 7 dates".
5. Option: "Add another batch of this medicine" / "Add due for this delivery".

### 5.3 Daily review
1. Morning digest arrives → tap → Expiry tab at the urgent bucket.
2. For each batch: remove from shelf → **Discard** / **Return to supplier** / **Adjust qty** (sold) / **Snooze**.
3. Home counters update; stale notifications for handled batches are cancelled.

### 5.4 Supplier return
1. Expiry tab → select batches → **Return to supplier**.
2. Confirm quantities, optionally enter credit-note amount.
3. Stock reduced, return logged, supplier balance reduced if credit entered; share a return list to the supplier.

### 5.5 Pay supplier
1. Reminder "Payment due tomorrow: ABC Pharma ₹18,500" → tap.
2. Supplier ledger → **Record payment** → amount/method → invoice marked paid or partial.

### 5.6 Reorder
1. Reorder reminder fires → Reorder list grouped by supplier.
2. Edit suggested qty → **Share** to supplier via WhatsApp/SMS → mark **Ordered** with expected date.
3. On delivery → **Received** → pre-filled batch entry.

---

## 6. Data Model

Relational model stored in an on-device SQLite database. IDs are UUIDs; all tables carry `created_at`, `updated_at`, and a soft-delete `deleted_at` (supports future sync).

```
Medicine
  id, brand_name, generic_name, strength, dosage_form, unit, pack_size,
  manufacturer, category, barcode(s) [separate table], reorder_level,
  preferred_supplier_id?, alert_window_days?, storage_condition?,
  notes, is_archived

MedicineBarcode
  id, medicine_id, barcode_value, symbology

Batch
  id, medicine_id, batch_number, expiry_date (date; month-only -> last day),
  expiry_precision (MONTH | DAY), quantity_received, quantity_on_hand,
  cost_price, selling_price, received_date, supplier_id?, purchase_id?,
  status (ACTIVE | DEPLETED | RETURNED | DISCARDED), snoozed_until?, handled_at?,
  notes

StockAdjustment
  id, batch_id, delta_qty, reason (SOLD | DAMAGED | DISCARDED_EXPIRED | RETURNED |
  CORRECTION | OTHER), note, value_impact, created_at

Supplier
  id, name, contact_person, phone, email, address, tax_id,
  payment_terms_days, notes, is_archived

SupplierInvoice          -- a "due"
  id, supplier_id, invoice_number, invoice_date, due_date,
  total_amount, notes

SupplierPayment
  id, supplier_id, invoice_id?, amount, paid_on, method, reference

SupplierCredit           -- credit notes / returns
  id, supplier_id, amount, issued_on, linked_return_id?, note

SupplierReturn
  id, supplier_id, returned_on, note
SupplierReturnLine
  id, return_id, batch_id, quantity, value

ReorderOrder             -- "ordered" state
  id, medicine_id, supplier_id?, quantity, ordered_on, expected_on, status

ScheduledAlert           -- local bookkeeping of planned notifications
  id, kind (EXPIRY_LEAD | EXPIRY_DAY | DIGEST | PAYMENT | REORDER),
  target_ref, fire_at, os_notification_id, state (PENDING | FIRED | CANCELLED)

AlertLog
  id, kind, title, body, fired_at, opened_at?

Settings (key-value)
```

**Derived values (not stored):** days to expiry, urgency bucket, invoice status/outstanding, medicine total usable stock, value at risk.

**Rules**
- `quantity_on_hand` is changed only through `StockAdjustment` rows (audit trail); batch status follows quantity.
- Invoice outstanding = `total_amount − Σ payments(invoice) − Σ credits(linked)`.
- Dates stored as local calendar dates (ISO `YYYY-MM-DD`), not timestamps, to avoid timezone drift in expiry comparison.
- Expiry is treated as valid **through the end of the expiry day**; a batch becomes "Expired" the day after.

---

## 7. Offline, Privacy, Backup & Security

| ID | Requirement | Priority |
|---|---|---|
| SEC-1 | **Offline-first**: every feature in v1 works with no network. No analytics or network calls required for core functionality. | P0 |
| SEC-2 | No account/sign-in in v1. Data lives on-device. | P0 |
| SEC-3 | **Local backup**: export full database to a file (encrypted with a user passphrase, optional) saved via the OS share/files sheet. **Restore** from file with a preview and "replace vs. merge" warning. | P0 |
| SEC-4 | **Auto-backup reminder** (local notification) if no backup in N days (default 14). Optional OS-level cloud backup (iCloud / Google Auto Backup) documented in settings. | P1 |
| SEC-5 | **App lock** with PIN/biometrics. | P1 |
| SEC-6 | Database encrypted at rest (e.g. SQLCipher) with key in the OS keystore/keychain. | P1 |
| SEC-7 | Store no patient/personal health data. Supplier contact info is the only personal data; disclosed in privacy policy. | P0 |
| SEC-8 | Request only needed permissions: notifications, camera (scanning, on demand), exact alarms (Android, with fallback). | P0 |
| SEC-9 | Optional opt-in cloud sync / multi-device — **out of scope for v1** (§12). | — |

> **Data-loss risk:** with no server, uninstalling or losing the phone loses all data unless a backup exists. The app must make backup prominent (onboarding nudge, periodic reminder, Home banner when stale).

---

## 8. Non-Functional Requirements

| Category | Requirement |
|---|---|
| **Reliability** | Expiry alerts fire within ±5 minutes of scheduled time on supported devices, including after reboot and in Doze mode (best effort on aggressive OEM battery managers; guided mitigations in alert health check). |
| **Performance** | Cold start < 2 s on a mid-range device. Lists remain smooth (60 fps) with 10,000 batches. Near-expiry query < 100 ms. Reschedule of all alerts < 1 s. |
| **Scale** | Supports ≥ 5,000 medicines, ≥ 50,000 batch records, ≥ 200 suppliers on-device. |
| **Usability** | One-handed use; core entry in ≤ 30 s per batch; large touch targets (≥ 48dp); works in bright shop lighting (high-contrast). |
| **Accessibility** | WCAG AA contrast, dynamic type, screen-reader labels, urgency never conveyed by color alone. |
| **Localization** | Locale-aware dates/currency; externalized strings; RTL-ready layout; Bangla translation as first additional language (candidate). |
| **Platforms** | Android 8.0+ (API 26+), iOS 15+. Phones primary; tablets supported with a responsive layout. |
| **Data integrity** | All multi-step writes (e.g. payment + invoice status, return + stock + credit) are transactional. Migrations versioned and tested. |
| **Battery** | No continuous background work; alerts via OS schedulers only. |
| **Testing** | Unit tests on date/bucket/alert-planning logic (incl. leap years, month-end, DST/timezone changes); integration tests for scheduling; manual device matrix incl. at least Samsung, Xiaomi, and a stock-Android device for background-kill behavior. |

---

## 9. Alert Scheduling Design (reference)

A pure, testable **AlertPlanner** produces the desired set of notifications; a thin **Scheduler** reconciles it with the OS.

1. **Inputs:** active batches (qty > 0, not handled), settings (lead times, quiet hours, digest time), unpaid invoices, reorder state, "now".
2. **Plan:** for each batch × lead time compute `fire_at = expiry_date − lead_days @ digest_time` (skip past dates). Group by `fire_at` date → one notification per date with a summary and deep link. Add daily digest entries. Add payment/reorder entries. Apply quiet hours shift.
3. **Window:** keep the soonest ≤ 60 entries (iOS limit 64). The remainder are generated on later re-plans.
4. **Reconcile:** diff planned vs. `ScheduledAlert` rows; cancel stale OS notifications, schedule new ones, update table. Idempotent.
5. **Triggers to re-plan:** app launch, foreground, batch/invoice/settings change, boot completed, timezone/clock change, background refresh (daily best-effort), notification fired.
6. **Missed alerts:** on launch, compare last-planned vs. now; any lead-time alert that should have fired while the app was unreachable is surfaced in the in-app alert center and Home "Needs attention".

Because the UI also reads state directly from the database, correctness never depends on a notification having been delivered — notifications are a *nudge*, the app is the source of truth.

---

## 10. Suggested Technical Approach (non-binding)

| Concern | Suggestion |
|---|---|
| Framework | **Flutter** (single codebase, mature local-notification + SQLite ecosystem) or React Native with Expo (bare/dev-build for exact alarms). |
| Storage | SQLite (Drift / sqflite+SQLCipher, or WatermelonDB / op-sqlite). |
| Notifications | `flutter_local_notifications` + `timezone`, `workmanager`/`android_alarm_manager_plus` for re-plan; or `expo-notifications` equivalents. |
| Scanner | `mobile_scanner` (ML Kit / AVFoundation). |
| State | Riverpod / Bloc (Flutter) or Zustand (RN). |
| Export | `pdf` + `share_plus`; CSV generated in-app. |
| CI | Unit tests on planner; build per-platform; release via Play/TestFlight. |

---

## 11. Release Plan

### MVP (v1.0) — "Never miss an expiry"
- Medicine catalog (MED-1,2,6) · Batch CRUD + adjustments (BAT-1…7, 9)
- Near-expiry & expired lists with actions (EXP-1…5, 7, 8)
- **Full local alert engine** (ALR-1…7, 9, 14, 15)
- Suppliers, invoices, payments, due reminders (SUP-1,3…9)
- Reorder level, reorder list, reminder (ROR-1,2,4)
- Home dashboard (HOM-1,2,5) · Search (SCN-1)
- Core settings · Backup/restore (SEC-3)

### v1.1 — Speed & polish
- Barcode scanning (SCN-2) · bulk receive (BAT-8) · returns/credits (EXP-6, SUP-10)
- Alert health check, quiet hours, alert center (ALR-8, 10, 12, 13)
- Per-medicine alert window (MED-3) · reorder "Ordered" tracking & share (ROR-3,5,6,7)
- Reports & CSV/PDF export (RPT-1…4) · app lock + DB encryption (SEC-5,6)

### v1.2+ — Advanced
- GS1 DataMatrix parsing, OCR expiry (SCN-3,4) · shelf-check mode (EXP-10)
- Photos on batches/invoices · catalog CSV import · storage conditions

---

## 12. Future / Out of Scope for v1

- Multi-user roles and multi-branch with cloud sync (optional, opt-in).
- POS / sales integration to auto-decrement stock (FEFO suggestions).
- Public medicine database lookup (name, generic, strength by barcode).
- Supplier portal / electronic ordering.
- Controlled-substance register and regulatory compliance exports.
- Wear OS / widgets showing "expiring today".

---

## 13. Success Metrics

(Collected locally; any telemetry is strictly opt-in.)

- ≥ 95% of scheduled alerts delivered on test devices across the device matrix.
- Median time to add a batch ≤ 30 s.
- Reduction in value of expired-on-shelf stock (user-reported / report-based) within 3 months of use.
- ≥ 80% of users complete notification permission setup at onboarding.
- ≥ 60% of users take a backup within the first 30 days.

---

## 14. Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| OEM battery managers kill background scheduling (Xiaomi, Oppo, Samsung, etc.) | Missed alerts — the core value | OS-native scheduled notifications (not app-process timers), alert health check, in-app guidance for battery whitelist, re-plan on every open, daily digest redundancy |
| iOS 64 pending-notification cap | Alerts beyond the window not scheduled | Grouped notifications + rolling window + re-plan on launch/background refresh |
| User denies notification permission | No alerts | Pre-prompt education, persistent in-app banner, in-app dashboard as fallback |
| Data loss (no cloud) | Loss of all records | Prominent backup UX, reminders, optional OS cloud backup |
| Slow data entry → users abandon | Stale data, useless alerts | Quick-add, remembered defaults, barcode, month/year expiry entry, bulk receive |
| Wrong expiry interpretation (month-only) | Premature/late alerts | Clear rule: expires end of printed month; show interpreted date in UI |
| Timezone / DST / clock changes | Shifted alerts | Date-based (not timestamp) expiry; re-plan on timezone change |

---

## 15. Open Questions

1. **Target market & currency/locale** (e.g. Bangladesh/India/other)? Affects language (Bangla), tax IDs (VAT/GST), default currency, and regulatory notes.
2. **Framework preference** — Flutter vs. React Native?
3. Should the app track **selling** (even simply, a "sold N units" decrement), or stay purely receiving/adjusting stock?
4. Is **single-device/single-user** acceptable for v1, or is a second device (e.g. owner + staff) required early?
5. Are **cost/selling prices** mandatory, or should "value at risk" be optional for users who don't want to enter prices?
6. Any **regulatory requirements** for disposal records of expired medicines (e.g. witnessed destruction logs)?
7. Preferred default **alert lead times** — confirm 90/60/30/14/7/1/0 with real pharmacist input.
