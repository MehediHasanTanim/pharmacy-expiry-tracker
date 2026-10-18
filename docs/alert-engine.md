# Alert Engine — as built (Sprint 3)

How expiry alerts are planned and scheduled. Companion to
[technical-design.md §6](technical-design.md); where this differs from the
design, this document is current.

## Pipeline

```
data change / settings change / launch / resume / background task
        │  (AlertCoordinator: 500 ms debounce, single-flight)
        ▼
 AlertEngine.replan()
   1. load settings
   2. recoverPastDue  : pending rows whose time has passed → FIRED + alert history
   3. load batches    : active, unhandled, in stock, medicine not archived
   4. planAlerts()    : pure function → the alerts that should exist
   5. assignOsIds()   : stable 31-bit id per alert key
   6. reconcile()     : desired vs recorded vs what the OS really holds
   7. AlertScheduler.apply()  : cancel / schedule in one DB transaction
        ▼
 NotificationPlugin  →  OS scheduler  (works offline, app closed)
```

The database is the source of truth; notifications are a nudge. Re-planning is
idempotent: running it again changes nothing.

## What gets planned (`planAlerts`)

* **Lead-time alerts** — for every unhandled batch with stock and every
  configured lead time (default 90, 60, 30, 14, 7, 1 days), one notification per
  fire date covering all batches that reach a lead time that day. Key
  `lead:YYYY-MM-DD`.
* **Expiry-day alerts** — lead time 0, separate notification. Key `day:…`.
* **Daily digest** — next 14 days. Key `digest:…`. Text says exact counts only
  when it is due within 24 h of planning; further out it is generic, because the
  data may change before it is delivered. With "skip empty digests" on, days
  whose projected counts are zero are omitted.
* **Payment reminders** — for every unpaid invoice with a due date: a reminder
  N days before (default 3) and on the due date, then every N days while
  overdue (default 3), anchored on the due date so the same days come out
  however often we plan. Overdue repeats are scheduled 14 days ahead. One
  notification per day per kind (`pay:`, `paydue:`, `overdue:`) covers every
  invoice reminding that day, 10 minutes after the digest; it links to the
  supplier when only one is involved. A per-invoice snooze silences reminders
  until its date. Paying (or crediting) an invoice in full removes it from the
  plan, so its reminders are cancelled on the next pass; a part payment changes
  the amount in the text, so the reminders are replaced, not duplicated.
* **Quiet hours** — an alert inside the window moves to its end (handles
  overnight windows).
* **Cap** — the earliest 60 alerts across all kinds (iOS keeps 64).

Rules worth knowing:

| Rule | Behaviour |
|---|---|
| Alert time | Digest at the *alert time* setting; lead/expiry-day alerts **5 minutes later**, so the two never arrive together. |
| Past | A lead date earlier than today is skipped; today's is skipped once its time has passed. |
| Snooze | "Snoozed until D" means silent until D and **resuming on D**. (The design draft said "through D"; resuming on D is what "until the next alert" needs.) |
| Handled / empty | No alerts. |
| Per-medicine window | Lead times longer than the medicine's window are not alerted. |
| Delivery | Inexact (`preferExact: false`): date-level alerts need no minute precision and no exact-alarm permission. |

## Identity and idempotence

* **Key** — deterministic per logical alert (`lead:2026-11-17`). Same input,
  same keys.
* **Content hash** — over title, body, route and fire time. A change in any of
  them reschedules; otherwise nothing is touched.
* **OS id** — FNV-1a of the key, 31-bit, probed past any id already used by a
  row (fired and cancelled rows keep theirs; the column is unique) and past the
  Alert-lab range 9 000 000–9 000 999. A key keeps its id for life, so
  rescheduling replaces rather than duplicates.

## Reconciliation

For each desired alert: schedule if there is no pending row, the hash differs,
**or the OS no longer holds that id** (force-stop, reboot gap, permission
toggled). Pending rows no longer desired are cancelled. OS notifications the
engine has no record of are cancelled as orphans — except lab ids.

## Failure handling

The cancel/schedule/upsert sequence runs in a transaction. If the OS refuses any
call, the rows roll back and notifications scheduled so far are withdrawn, so
the OS never holds alerts the engine does not know about. The pass returns a
summary with the error (it never throws) and the next pass starts clean.

## Triggers

| Trigger | Where |
|---|---|
| Batch added / edited / adjusted, snooze, handled, medicine changed | `DataChangeBus` → coordinator (debounced) |
| Any settings change | settings stream → coordinator |
| App start, return to foreground | `AlertRuntime` |
| Permission granted | permission screen |
| "Check again" | Alert health screen |
| Every 12 h while closed (Android) | WorkManager → headless `runBackgroundReplan` |

Planning is bounded: it loads batches within `maxLead + 120` days and widens
only if the plan is not yet full or reaches the part of the timeline an unseen
batch could still affect. Measured: planning 50 000 batches ≈ 25 ms; a full
pass (database load + plan + diff) ≈ 300 ms.

## Screens

* **Home** — permission banner: explains first, then asks; after a refusal it
  opens system settings.
* **More → Alert settings** — lead times (chips), alert time, digest, skip
  empty, quiet hours.
* **More → Alert health** — notification and exact-alarm state, battery
  optimisation (Android) with OEM advice, next alert, scheduled count vs. what
  the OS reports, last check, **Send test alert** (10 s, through the real path),
  **Check again**.
* **More → Alert history** — alerts that have come due, newest first; opening
  one marks it read and follows its link.
* **Deep links** — a tapped notification's payload is a route
  (`/expiry?bucket=d30&date=…`). Only known in-app routes are followed. A link
  is held while `deepLinkReadyProvider` is false (reserved for onboarding / app
  lock) and followed on `flush()`.

## Not done / limits

* **No device verification.** Everything above is covered by automated tests
  against a fake scheduler; none of it has been observed delivering a real
  notification. See [qa-alert-matrix.md](qa-alert-matrix.md).
* **iOS background refresh is not registered.** Alerts already scheduled are
  delivered by the OS; re-planning happens on app launch/resume. (Needs Xcode
  to build and verify.)
* **Time-zone / clock changes** are noticed at the next launch, resume or
  12-hourly run, not the instant they happen (that needs a native receiver).
* **Reorder and backup reminders** share the engine's structure (`AlertKind`)
  but are not planned yet (Sprints 5–6). Payment reminders were added in
  Sprint 4.
* The only native code added is a small Android method channel for the health
  screen (`MainActivity.kt`): battery-optimisation state, device maker, and
  opening system settings. Scheduling stays in the plugin.
