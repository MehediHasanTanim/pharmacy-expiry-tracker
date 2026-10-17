# Pharmacy Expiry Tracker — Sprint-wise Implementation Plan

**Version:** 0.1 (draft) · **Date:** 2026-10-17
**Companions:** [feature-spec.md](feature-spec.md) · [technical-design.md](technical-design.md)

Scope of this plan: the **MVP (v1.0)** plus the v1.1 follow-up sprints. Requirement IDs (`BAT-1`, `ALR-5`…) come from the spec; section references (§) point to the technical design.

---

## 1. Planning Assumptions

| Item | Assumption |
|---|---|
| Team | 1–2 developers (one full-stack Flutter dev is enough; a second can take UI/QA). Plan is sized for **1 dev ≈ 30 productive hours/week**. |
| Sprint length | **2 weeks** (≈ 60 dev-hours). Sprint 0 is 1 week. |
| Estimates | Hours per task (ideal, includes writing tests). Buffer: ~15% per sprint is left unallocated. |
| Stack | Flutter + Drift + Riverpod + go_router + `flutter_local_notifications` (technical-design §1). |
| Test devices | 1 Android (Pixel/stock), 1 Samsung or Xiaomi, 1 iPhone. Obtain by Sprint 3. |
| Definition of Ready | Task has requirement IDs, acceptance criteria, and no unresolved open question. |
| Definition of Done | Code merged via PR, `flutter analyze` clean, unit/widget tests added and green, strings in ARB, a11y labels added, demo-able on a device, docs updated. |

### Timeline

| Sprint | Weeks | Theme | Milestone |
|---|---|---|---|
| **S0** | 1 | Foundations | M0 |
| **S1** | 2–3 | Catalog, batches, search | M1 |
| **S2** | 4–5 | Expiry lists & actions + alert **spike** | M2 |
| **S3** | 6–7 | **Local alert engine** | M3 |
| **S4** | 8–9 | Suppliers & dues + due reminders | M4 |
| **S5** | 10–11 | Reorder, Home dashboard, onboarding | M5 |
| **S6** | 12–13 | Backup/restore, hardening, beta | M6 → **MVP beta** |
| **S7** | 14–15 | v1.1-A: scanner, returns/credits, bulk receive | |
| **S8** | 16–17 | v1.1-B: reports/export, encryption, app lock, polish | **v1.1 release** |

> The alert spike starts in S2 (not S3) on purpose: it is the riskiest, highest-value part. If the spike reveals plugin gaps, S3 absorbs a small native channel without slipping the plan.

### Task ID convention
`S<sprint>-<nn>` · Estimates `[h]` · Dependencies `→ S1-04`

---

## Sprint 0 — Foundations (1 week, ~30 h)

**Goal:** a running app skeleton with CI, database, theming, routing and testing seams so every later sprint is feature work only.
**Demo:** App launches on both platforms, shows bottom nav with 5 empty tabs, DB migration test green in CI.

| ID | Task | Details / acceptance | [h] |
|---|---|---|---|
| S0-01 | Repo & project scaffold | `flutter create`, org/app ids, `dev` and `prod` flavors (Android flavors + iOS schemes), `.gitignore`, README. | 3 |
| S0-02 | Lint & CI | `very_good_analysis` or strict `analysis_options.yaml`; GitHub Actions: analyze → test → debug build (Android); iOS build job (macOS runner). Coverage artifact. | 4 |
| S0-03 | Folder structure & DI | Create layout from §3; root `ProviderScope`; `providers.dart`. | 2 |
| S0-04 | `Clock` abstraction | `Clock` interface + `clockProvider`; fake clock for tests; midnight rollover provider. | 2 |
| S0-05 | Core value objects | `ExpiryDate` (month-only → last day, `daysUntil`, `isExpired`), `Money` (minor units, formatting by locale). Unit tests incl. leap year/Feb/month-end. | 4 |
| S0-06 | Drift setup + schema v1 | All tables from §4.2, indexes, `PRAGMA foreign_keys/WAL`, `AppDatabase.forTesting()`, background isolate open. | 6 |
| S0-07 | Migration test harness | `drift_schemas/` snapshot v1, `SchemaVerifier` test. | 2 |
| S0-08 | Theme & l10n | Material 3 light/dark, semantic urgency colors + icons, ARB (`app_en.arb`), `flutter_localizations`. | 3 |
| S0-09 | Router & shell | go_router with `StatefulShellRoute` for 5 tabs; placeholder screens; route constants for deep links. | 3 |
| S0-10 | Settings repository | Key-value settings with typed accessors + defaults (SET-1…SET-13 keys), stream API. Tests. | 3 |
| S0-11 | Android manifest/iOS plist baseline | Permissions placeholders (notifications, boot, no INTERNET in release), CI manifest check script. | 2 |

**Exit criteria:** CI green on main; `flutter test` passes; app runs on Android + iOS devices; manifest check rejects `INTERNET` in release.

---

## Sprint 1 — Medicine Catalog, Batches, Search (2 weeks, ~60 h)

**Goal:** a user can create medicines, add/edit batches with fast entry, adjust quantities with an audit trail, and find items by search. All offline.
**Reqs:** MED-1, MED-2, MED-5, MED-6, BAT-1…7, BAT-9, SCN-1.
**Demo:** Add a medicine, receive two batches (one month-only expiry), adjust stock, search by batch number.

### Data & domain
| ID | Task | Details / acceptance | [h] |
|---|---|---|---|
| S1-01 | Entities & mappers | `Medicine`, `Batch`, `StockAdjustment` domain entities; Drift ⇄ entity mappers. | 3 |
| S1-02 | `MedicineDao` + repository | CRUD, archive, `watchAll(query, includeArchived)`, normalized `search_text` builder, duplicate lookup (brand+strength+form). Tests. | 5 |
| S1-03 | `BatchDao` + repository | CRUD, `findByMedicineAndNumber`, `watchByMedicine`, `watchAllActive`. Tests. | 5 |
| S1-04 | `AdjustStockUseCase` | Transactional: insert adjustment, update qty, derive status (ACTIVE/DEPLETED/DISCARDED/RETURNED), reject negative, compute `value_impact`. Tests incl. rollback. | 5 |
| S1-05 | `AddBatchUseCase` | Transaction: batch + initial `+qty` adjustment (reason RECEIVED); duplicate batch policy (merge qty vs separate). Tests. | 4 |
| S1-06 | `EditBatchUseCase` | Edit expiry/number/cost; emits change event (consumed by alert engine in S3). | 2 |
| S1-07 | Global search repo | Unified search across medicines (brand/generic), batch numbers (and later suppliers); ranked prefix > contains. Tests on 5k seed rows. | 4 |
| S1-08 | Seed-data generator (dev flavor) | Generates N medicines/batches with spread of expiry offsets. Hidden dev menu button. | 3 |

### UI
| ID | Task | Details / acceptance | [h] |
|---|---|---|---|
| S1-09 | Stock tab list | Searchable medicine list: on-hand total, nearest expiry chip, archived filter. Empty state. | 4 |
| S1-10 | Medicine form | Create/edit, validation, dosage form + unit pickers, reorder level field, duplicate warning dialog (MED-5), archive action. | 5 |
| S1-11 | Medicine detail screen | Header info + batch list (status chips, qty, expiry, days left). | 3 |
| S1-12 | **Expiry input widget** | `MM/YYYY` quick input (numeric keypad, auto-advance) + "exact date" toggle; shows resolved date "Expires 31 Aug 2027"; validation (past → warning, >10y → warning). Widget tests. | 5 |
| S1-13 | Add/Edit batch form (+ quick add) | Fields per BAT-1; supplier field stubbed until S4; remembers last received date; "Save & add another". Duplicate dialog (BAT-4). | 6 |
| S1-14 | Adjust stock sheet | Bottom sheet: reason chips, qty stepper, note; confirm for destructive reasons; updates immediately. | 3 |
| S1-15 | Batch detail + history | Adjustment timeline; edit action. | 3 |
| S1-16 | Global search UI | Search bar on Stock tab with recent searches; results grouped (medicines / batches). | 3 |

**Exit criteria:** all listed reqs demoed; data tests on adjustments and duplicates green; adding a batch ≤ 30 s measured by stopwatch on device; 10k-batch seed scrolls smoothly.
**Risks:** form UX churn → timebox S1-12/13 and review with a pharmacist early in the sprint.

---

## Sprint 2 — Expiry Lists & Actions + Alert Spike (2 weeks, ~60 h)

**Goal:** the main workflow screens (near-expiry/expired) with actions, and a **proven technical path** for on-device scheduled notifications on real devices.
**Reqs:** EXP-1…5, EXP-7, EXP-8, BAT-6; spike toward ALR-1, ALR-5, ALR-6.
**Demo:** Expiry tab with buckets/filters/actions; a test notification scheduled for 2 minutes ahead fires in airplane mode with the app force-closed (Android + iOS).

### Expiry workflow
| ID | Task | Details / acceptance | [h] |
|---|---|---|---|
| S2-01 | `ExpiryBucket` rules | Bucket calculation from thresholds; per-medicine window override resolution. Unit tests (boundaries: 0, 30, 31, −1 days). | 3 |
| S2-02 | Near-expiry query | Drift query per §4.3 with join, window logic, keyset pagination on `(expiry_date, id)`; sort variants (soonest, value at risk, name). Tests + 50k-row perf test (<100 ms). | 6 |
| S2-03 | Expiry state providers | Filter state (bucket, supplier, category), sort, search; `StreamProvider`s; midnight invalidation. | 4 |
| S2-04 | Expiry tab UI | Bucket header chips with counts, sections, rows per EXP-3 (days left, value at risk), color + icon + text label. Empty & loading states. | 7 |
| S2-05 | Filters & sort sheet | Bottom sheet; persisted last selection in settings. | 3 |
| S2-06 | Row actions | Swipe/long-press: Adjust qty (sold), Discard (confirm, logs loss), Snooze (1d/3d/1w/until next lead), Mark handled. Undo snackbar for non-destructive. | 6 |
| S2-07 | Snooze/handled data model use | Wire `snoozed_until`/`handled_at` through repo; tests. | 2 |
| S2-08 | Expired section | "Remove from shelf" highlighted state; counts; bulk discard prep (multi-select, full in v1.1). | 3 |
| S2-09 | Value-at-risk calc | Sum of qty×cost respecting missing prices (show "—" and "partial" hint). Tests. | 2 |

### Alert spike (timeboxed 16 h, → feeds S3)
| ID | Task | Details / acceptance | [h] |
|---|---|---|---|
| S2-10 | `NotificationPlugin` interface + impl | Thin wrapper over `flutter_local_notifications` (init, request permission, schedule zoned, cancel, pending list, launch details). Fake impl for tests. | 4 |
| S2-11 | Android spike | Channels, `POST_NOTIFICATIONS`, exact vs inexact alarms, boot receiver, schedule +2 min, test with app force-stopped, airplane mode, reboot, Doze. Document results. | 5 |
| S2-12 | iOS spike | Authorization, calendar trigger, background/killed delivery, 64-cap observation. | 3 |
| S2-13 | OEM spike | Test on Samsung/Xiaomi with default battery settings; record failure modes → `docs/qa-alert-matrix.md`. | 3 |
| S2-14 | Spike report & go/no-go | Decide: plugin sufficient vs add native Kotlin/Swift channel for specific gaps (exact alarm, boot re-plan). Update technical-design §6.8 if needed. | 1 |

**Exit criteria:** Expiry tab reqs met; spike report committed; decision on native channel made before S3 starts.
**Risks:** OEM behaviors worse than expected → S3 gets a scoped native fallback task (already budgeted as buffer).

---

## Sprint 3 — Local Alert Engine (2 weeks, ~60 h)

**Goal:** production-grade, idempotent, tested alert scheduling for expiry (lead times, day-of, digest), with permission UX, health screen and deep links. **This is the core value.**
**Reqs:** ALR-1…10, ALR-12 (basic), ALR-15, SET-3/4/5.
**Demo:** Add/edit/discard batches and watch scheduled alerts update; airplane mode + force-close + reboot test passes on Android and iOS.

### Domain
| ID | Task | Details / acceptance | [h] |
|---|---|---|---|
| S3-01 | `PlannedAlert` + key scheme | Deterministic keys (`lead:YYYY-MM-DD`, `digest:…`), `contentHash`, `os_id` stable-hash with collision probe. Tests. | 3 |
| S3-02 | `AlertPlanner` – expiry leads | Per §6.3: leads × batches, skip past, grouped per fire date, snooze/handled exclusion, expiry-day lead 0. Copy builder (title/body with top-3 + "and N more"). | 7 |
| S3-03 | `AlertPlanner` – digest | Next ~14 days, skip-empty option, generic wording rule beyond 24 h (§6.6). | 4 |
| S3-04 | Quiet hours + cap | Shift into window end; keep earliest 60 across kinds; ordering stable. Tests. | 3 |
| S3-05 | Planner test suite | Table-driven: DST spring/fall, leap day, month-end, timezone change, 5k batches, snoozed, depleted, batch added inside window. Property test: plan idempotent. | 6 |
| S3-06 | `AlertReconciler` | Diff desired vs `scheduled_alerts` (by key + hash) → cancel/schedule lists. Tests. | 4 |

### Platform & orchestration
| ID | Task | Details / acceptance | [h] |
|---|---|---|---|
| S3-07 | `NotificationScheduler` | Execute diff in a DB transaction, rollback on plugin failure, retry next plan; mark past-due PENDING as FIRED + `alert_log` (missed recovery). | 5 |
| S3-08 | `AlertCoordinator` | Triggers (§6.7): repo change events (debounced 500 ms), app resume/launch, settings change. Single-flight (mutex) re-plan. | 4 |
| S3-09 | Background re-plan | `workmanager` periodic task (Android) + BGAppRefresh (iOS); boot/timezone/time-change handlers; headless entry point opens DB + runs plan. | 6 |
| S3-10 | Channels & permissions | Android channels per §6.8; `POST_NOTIFICATIONS`; exact-alarm check with graceful fallback; iOS auth. | 3 |
| S3-11 | Native fallback (if spike demanded) | Scoped Kotlin/Swift channel for gaps found in S2-14. Skip if not needed → time returns to buffer. | (6) |
| S3-12 | Deep-link routing | Payload → go_router route (`/expiry?bucket=&date=`); cold-start via launch details; handle locked/onboarding state. | 3 |

### UI
| ID | Task | Details / acceptance | [h] |
|---|---|---|---|
| S3-13 | Permission pre-prompt & denied banner | Education screen → system prompt; persistent banner with "Open settings" (ALR-7). | 3 |
| S3-14 | Alert settings screen | Lead-time chip editor, digest time/on-off, quiet hours, "skip empty digests" (SET-3/4/5). Changes trigger re-plan. | 4 |
| S3-15 | Alert health screen | `AlertHealth` provider; shows permission, exact alarms, battery optimization (Android), next alert, pending count; **Send test alert** (real path); deep link to battery settings. | 5 |
| S3-16 | Alert center (basic) | List `alert_log` entries with open-through-to-filter; mark opened. | 2 |
| S3-17 | Snooze integration | Snooze/handled actions in S2 now trigger re-plan; verify suppression. | 1 |

### Verification
| ID | Task | Details | [h] |
|---|---|---|---|
| S3-18 | Integration tests (fake plugin) | Add batch → N alerts scheduled; discard → cancelled; edit expiry → rescheduled; restore-like full replan. | 4 |
| S3-19 | Device test pass | Run `docs/qa-alert-matrix.md`: airplane mode, force-stop, reboot, Doze, timezone change, DST change, notification-denied path on all 3 devices. Fix defects. | 6 |

**Exit criteria:** ≥ 95% of test alerts delivered across matrix; plan for 50k batches < 1 s; no duplicate notifications after repeated re-plans; ALR-15 verified in airplane mode.
**Risks:** OEM kill → mitigated by health screen and digest redundancy; document remaining known-bad devices in-app.

---

## Sprint 4 — Suppliers & Dues (2 weeks, ~60 h)

**Goal:** manage suppliers, record purchase invoices (dues) and payments, see balances/overdue, and receive local payment reminders.
**Reqs:** SUP-1, 3…9, SET-6; link batches↔supplier (BAT-1 supplier field), ALR-14 (payments).
**Demo:** Create supplier, receive stock with a due, record partial payment, see overdue state, receive a due-date reminder.

| ID | Task | Details / acceptance | [h] |
|---|---|---|---|
| S4-01 | Supplier entity/DAO/repo | CRUD, archive, search, `watchWithBalances`. Tests. | 4 |
| S4-02 | Invoice/payment/credit DAOs | `v_invoice_balance` view (total − payments − credits), status derivation. Tests (partial, overpay reject, credit). | 6 |
| S4-03 | `InvoiceStatus` rules | unpaid/partial/paid/overdue pure function + tests across due dates. | 2 |
| S4-04 | `AddInvoiceUseCase` | Create invoice, optionally link received batches; default due date from supplier terms. | 3 |
| S4-05 | `RecordPaymentUseCase` | Explicit invoice or oldest-due-first auto-allocation into per-invoice rows; reject overpayment with prompt to record credit. Transactional tests. | 5 |
| S4-06 | Suppliers tab UI | List with outstanding balance, overdue badge, sort (balance/due/name), search. | 4 |
| S4-07 | Supplier form & detail | Contact fields, payment terms; detail with ledger (invoices + payments), totals; archive. | 6 |
| S4-08 | Contact actions | Call/SMS/WhatsApp/email via `url_launcher` with graceful fallbacks. | 2 |
| S4-09 | Invoice & payment forms | Validation, date pickers, method chips; edit/delete with ledger recompute. | 6 |
| S4-10 | Wire supplier into batch form | Supplier picker in Add Batch, preferred-supplier default, "Add due for this delivery" prompt after save (BAT-8 lite). | 4 |
| S4-11 | Planner: payment reminders | Extend `AlertPlanner`: lead offsets, due day, repeating overdue every N days until paid/snoozed; grouping per day; settings SET-6. Tests. | 6 |
| S4-12 | Dues summary provider | Total outstanding, total overdue, next due date (for Home, S5). | 2 |
| S4-13 | Snooze payment reminder | Per-invoice snooze; reconciler honors. | 2 |
| S4-14 | Integration + device test | Payment reminder fires on device; paying cancels remaining reminders. | 3 |

**Exit criteria:** SUP P0 items demoed; balance math verified by tests including edge cases (multi-invoice auto-allocation); reminders cancel on payment.

---

## Sprint 5 — Reorder, Home Dashboard, Onboarding (2 weeks, ~60 h)

**Goal:** close the loop (reorder), give the owner a one-glance Home, and make first run smooth.
**Reqs:** ROR-1, 2, 4; HOM-1, 2, 3, 5; SET-1/2/7/8/9/11; More tab.
**Demo:** Stock drops below level → reminder fires → reorder list grouped by supplier; Home shows needs-attention cards; fresh install onboarding to first batch.

| ID | Task | Details / acceptance | [h] |
|---|---|---|---|
| S5-01 | `ReorderRules` | usable stock (excl. expired), needsReorder, suggestedQty, projected shortfall date (ROR-3 logic ready even if UI in v1.1). Tests. | 4 |
| S5-02 | Reorder query & provider | Aggregate usable stock per medicine; grouped by preferred supplier (unassigned group). | 4 |
| S5-03 | Reorder list UI | Cards per supplier, editable suggested qty, empty state; entry from More + Home card. | 6 |
| S5-04 | Reorder reminder state | `reorder_reminder_state`; planner emits reminders honoring re-fire interval (SET-7) and suppression until restocked. Tests. | 5 |
| S5-05 | Reorder trigger wiring | Re-evaluate on each stock change and in daily maintenance task. | 2 |
| S5-06 | Home dashboard | Needs-attention cards (HOM-1) each deep-linking to filtered lists; "expiring this week" top-5 (HOM-3); value-at-risk. Streams. | 7 |
| S5-07 | Alert status banner | Reuse `AlertHealth` (HOM-2). | 2 |
| S5-08 | Onboarding flow | 3-screen intro, pharmacy name/currency/window defaults, notification pre-prompt, first-medicine CTA, empty states (HOM-5). | 7 |
| S5-09 | Settings screens | Thresholds, window, currency/date, theme, digest etc. consolidated; More tab navigation. | 5 |
| S5-10 | Badge count | iOS/Android app badge = needs-action count, updated on plan and resume. | 2 |
| S5-11 | Accessibility pass #1 | Semantics labels, 48dp targets, large text 200% layouts, contrast check, color+icon audit. | 5 |
| S5-12 | Performance pass #1 | Profile Expiry/Home with 50k batches; fix jank; startup time (<2 s). | 4 |
| S5-13 | Bug-bash & buffer | Fix issues from sprint demo and early pilot feedback. | 7 |

**Exit criteria:** Home + reorder P0 done; first-run completes in <2 min; cold start <2 s on mid-range device.

---

## Sprint 6 — Backup/Restore, Hardening, Beta (2 weeks, ~60 h)

**Goal:** protect users from data loss, harden everything, and ship a **beta to a pilot pharmacy**.
**Reqs:** SEC-3, SEC-4 (reminder), SEC-1/2/7/8 verification, ALR re-plan after restore, RPT-4 (CSV for near-expiry basic), EXP-11.

| ID | Task | Details / acceptance | [h] |
|---|---|---|---|
| S6-01 | Backup export | `VACUUM INTO` temp → zip with metadata (app/schema version, checksum) → optional AES-256-GCM with passphrase (PBKDF2/Argon2) → share sheet. Isolate for large DBs. Tests with round-trip. | 8 |
| S6-02 | Restore | File picker, checksum & schema validation (reject newer), summary preview, confirmation, close DB → atomic swap → keep `.bak` 24 h → reopen. Corrupt/wrong-passphrase handling. | 8 |
| S6-03 | Post-restore re-plan | Cancel all OS notifications, clear `scheduled_alerts`, full re-plan, re-request permissions if missing. Integration test. | 3 |
| S6-04 | Backup reminders & banner | Planner emits backup reminder (default 14 d); Home banner when stale; onboarding nudge. | 3 |
| S6-05 | Pre-migration safety copy | Auto-copy DB before migration; restore on failure; test with simulated failing migration. | 3 |
| S6-06 | Share near-expiry list | CSV + PDF/text of current Expiry view (EXP-11, RPT-4 subset); isolate generation. | 6 |
| S6-07 | Lock-screen privacy option | "Hide details on lock screen" (generic body / Android private visibility). | 2 |
| S6-08 | Error handling & logging | Central `ErrorReporter` (local log, no PII), user-friendly error states, "export diagnostics" file. | 4 |
| S6-09 | Full device matrix regression | Re-run alert matrix + backup/restore on all devices; fix defects. | 8 |
| S6-10 | Security/privacy review | Verify no INTERNET perm, `allowBackup` policy, no PII in logs, permission list minimal; write `docs/privacy.md` draft. | 3 |
| S6-11 | Store assets & release prep | Icons, screenshots (seed data), store listing, privacy policy, signing config, TestFlight/Play internal track. | 6 |
| S6-12 | Beta rollout & feedback loop | Install at pilot pharmacy; checklist for daily use; capture issues/metrics (stopwatch entry time, alert reliability). | 3 |
| S6-13 | Buffer / fixes | Pilot-found P0 bugs. | 3 |

**Exit criteria (MVP beta):** all MVP P0 requirements met; backup→restore round trip proven including alerts; no known data-loss or missed-alert defects on matrix; beta installed at ≥ 1 real pharmacy.

---

## Sprint 7 — v1.1-A: Speed & Returns (2 weeks, ~60 h)

**Reqs:** SCN-2, BAT-8, EXP-6, EXP-9, SUP-10, MED-3, ROR-5/6/7.

| ID | Task | Details | [h] |
|---|---|---|---|
| S7-01 | `BarcodeService` + scan screen | `mobile_scanner`, torch toggle, permission flow, debounce. | 6 |
| S7-02 | Barcode link/lookup flow | Exact lookup → medicine; unknown → "link to medicine" sheet; multiple barcodes per medicine. Scan from Add Stock, Stock search. | 6 |
| S7-03 | Bulk receive | Multi-batch session under one supplier delivery; single invoice from total; per-line validation; resume draft. | 10 |
| S7-04 | Return to supplier use case + UI | Transactional return + lines + adjustments + optional credit; share return list. | 9 |
| S7-05 | Supplier credits in ledger | Credits applied to balance/invoice; UI in supplier detail; tests. | 4 |
| S7-06 | Multi-select bulk discard/return | Selection mode on Expiry tab. | 5 |
| S7-07 | Per-medicine alert window | UI + resolver already in S2-01; wire to planner. | 3 |
| S7-08 | Reorder "Ordered" tracking | `reorder_orders`, expected date suppression + overdue reminder, "Received" → prefilled batch (ROR-5/7). | 8 |
| S7-09 | Share order list per supplier | Text/WhatsApp formatted message (ROR-6). | 3 |
| S7-10 | Tests & device checks | Scanner on 3 devices; return/credit math; bulk-receive atomicity. | 4 |

## Sprint 8 — v1.1-B: Reports, Security, Polish (2 weeks, ~60 h)

**Reqs:** RPT-1…4, SEC-5, SEC-6, ALR-8 (extend), ALR-10/13 polish, HOM-4, SUP-11.

| ID | Task | Details | [h] |
|---|---|---|---|
| S8-01 | Report queries | Expiry loss (month/supplier/medicine), stock valuation, dues aging; Drift aggregates + tests. | 8 |
| S8-02 | Reports UI | Charts (simple bars via `fl_chart`), date range, drill-down. | 10 |
| S8-03 | CSV/PDF export for reports | Isolate generation, share sheet. | 5 |
| S8-04 | Supplier statement export | PDF/CSV for reconciliation (SUP-11). | 4 |
| S8-05 | SQLCipher migration | Encrypted DB with key in Keychain/Keystore; migrate existing plaintext DB safely (backup copy first); headless background task must open encrypted DB. Tests. | 12 |
| S8-06 | App lock | PIN + biometrics (`local_auth`), timeout, lock on background; alerts unaffected while locked. | 7 |
| S8-07 | Alert health enhancements | OEM-specific tips, last-fired history, notification actions *Snooze 1 day* (ALR-11 if feasible). | 5 |
| S8-08 | Final a11y/perf/regression | Full matrix, golden tests refresh, 50k-row perf check. | 6 |
| S8-09 | Release v1.1 | Changelog, store submission, migration verification from v1.0 beta. | 3 |

---

## 2. Dependency Map (critical path)

```
S0 (DB, Clock, ExpiryDate)
  └─► S1 (batches/adjust) ─► S2 (expiry lists, snooze) ─► S3 (alert engine) ─┐
                                   └─► S2 spike ─────────────────────────────┤
S1 ─► S4 (suppliers/dues) ─► planner extension (S4-11) ──────────────────────┤
S1/S4 ─► S5 (reorder, home) ─► S6 (backup/hardening/beta) ─► S7 ─► S8
```
Critical path: **S0 → S1 → S2 → S3 → S6**. S4 and S5 can overlap with a second developer starting after S2.

---

## 3. Requirement → Sprint Traceability (MVP)

| Area | Requirements | Sprint |
|---|---|---|
| Catalog | MED-1, 2, 5, 6 | S1 |
| Batches | BAT-1…7, 9 | S1 |
| Search | SCN-1 | S1 |
| Expiry lists | EXP-1…5, 7, 8 | S2 |
| Alerts | ALR-1…10, 12, 15 | S3 (spike S2) |
| Suppliers/dues | SUP-1, 3…9 | S4 |
| Payment alerts | ALR-14 | S4 |
| Reorder | ROR-1, 2, 4 | S5 |
| Home / onboarding | HOM-1, 2, 3, 5; ALR-13 | S5 |
| Settings | SET-1…12 | S0 (store), S3/S4/S5 (UI) |
| Backup | SEC-3, 4 | S6 |
| Share list | EXP-11 | S6 |

Deferred to v1.1 (S7–S8): scanner, bulk receive, returns/credits, reports, encryption, app lock, "Ordered" tracking. P2 items (GS1, OCR, photos, shelf-check, catalog import) remain in backlog.

---

## 4. Quality Gates per Sprint

| Gate | Check |
|---|---|
| Code | PR review, `flutter analyze` clean, no TODOs without ticket |
| Tests | Domain coverage ≥ 90%; new use cases have transaction/rollback tests; planner changes need updated golden plan cases |
| Device | Each sprint demo performed on a real Android and iPhone, not only emulators |
| Alerts | From S3 onward, every PR touching planner/scheduler must pass the integration suite and a manual smoke ("add batch → alert pending → discard → cancelled") |
| Perf | Seed 50k batches in dev flavor; Expiry tab and plan time budgets checked at S2, S3, S5, S8 |
| Docs | Technical design / decision log updated when deviating |

---

## 5. Risk Register (delivery)

| Risk | Sprint hit | Likelihood | Mitigation / contingency |
|---|---|---|---|
| OEM background restrictions drop alerts | S2–S3, S6 | High | Early spike; native-channel contingency (+6 h reserved); health screen; digest redundancy |
| Plugin gaps for exact alarms / boot restore | S3 | Medium | S2-14 go/no-go; native fallback S3-11 |
| iOS 64-notification cap bugs | S3 | Medium | Cap + grouping built in S3-04; tested with 5k-batch scenario |
| Form UX slows data entry → adoption risk | S1, S5 | Medium | Early pharmacist review in S1; quick-add and defaults; measure entry time |
| Scope creep (POS, sync, etc.) | All | Medium | Spec §1.2 non-goals; changes via backlog triage at sprint planning |
| Encryption migration breaks background tasks | S8 | Medium | Moved after beta; backup before migrate; headless-open test |
| No test devices available | S2 on | Medium | Procure by S2; fallback: Firebase Test Lab/BrowserStack for Android only (iOS needs real device for notification behavior) |
| Underestimation | All | Medium | 15% buffer per sprint; S5-13/S6-13 explicit buffer tasks; cut candidates below |

**Scope-cut candidates if behind (in order):** HOM-3 "expiring this week" list → S5-12 perf pass depth → SEC-4 backup reminder polish → S6-06 PDF (keep CSV/text) → onboarding illustrations.

---

## 6. Ceremonies & Cadence

| Event | When | Output |
|---|---|---|
| Sprint planning | Day 1 | Confirm tasks meet DoR; assign; adjust estimates |
| Mid-sprint check | Day 5 | Risk review, scope trade-offs |
| Device test day | Day 9 (S2+) | Real-device pass of sprint features |
| Demo & pilot feedback | Day 10 | Screen recording + feedback captured to backlog |
| Retro | Day 10 | 3 improvements logged in `docs/retros.md` |

---

## 7. First-Week Checklist (start tomorrow)

1. Confirm **Flutter** (technical-design §16 Q1) and app/bundle IDs.
2. Create repo, run `flutter create` with flavors → S0-01.
3. Set up CI skeleton → S0-02.
4. Implement `Clock`, `ExpiryDate`, `Money` with tests → S0-04/05 (pure Dart, quick wins).
5. Write the Drift schema → S0-06.
6. Order/borrow the three test devices.
7. Book 30 min with a pharmacist to review the Add-Batch flow before S1-12/13.
