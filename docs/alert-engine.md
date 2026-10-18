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
* Payment reminders were added in Sprint 4, reorder reminders in Sprint 5 and
  backup reminders in Sprint 6 (below).
* The only native code added is a small Android method channel for the health
  screen (`MainActivity.kt`): battery-optimisation state, device maker, and
  opening system settings. Scheduling stays in the plugin.

---

## Sprint 5 additions: reorder reminders and the badge

* **Reorder reminders.** A medicine with a reorder level whose *usable* stock
  (not expired, not discarded) is below the level gets a reminder at the daily
  alert time **+ 15 minutes**. One notification per day covers all such
  medicines (key `reorder:<date>`, `refs` = medicine ids). After a reminder is
  delivered, the next one waits for the interval in Alert settings (default 3
  days, `reorder_reminder_state.last_notified_on`). Snoozing a medicine skips
  reminders before the snooze date but keeps the rhythm. Restocking cancels
  pending reminders at the next replan; medicines without a level are never
  reminded.
* **Past-due recovery** (`recoverPastDue`) marks reorder reminders as notified
  so the rhythm continues after the phone was off.
* **Icon badge.** `AlertRuntime` sets the badge to expired + next-30-day
  batches (`needsActionCount`) on every summary change and on resume, through
  `app_badge_plus`. Launcher support varies on Android; failures are ignored.

---

## Sprint 6 additions: backup reminders, restore, privacy

* **Backup reminders** (`backup:<date>`): once the last backup (or, if there
  never was one, the first use, `first_run_on`, written by the first re-plan)
  is `backupReminderDays` old (default 14; 0 = off), one reminder at the daily
  alert time **+ 20 minutes**, then weekly while it stays undone, within the
  14-day planning horizon. Nothing is planned for an empty database. A backup
  moves the next reminder out; the time is recorded only when the share sheet
  was not dismissed.
* **After a restore** the old `scheduled_alerts` rows and the notifications
  the OS holds belong to another database. `AlertEngine.resetAndReplan()`
  clears the table and re-plans; the reconciler then cancels every OS
  notification that is not in the new plan (the Alert lab's id range excepted)
  and schedules the right ones. Covered by `test/data/restore_flow_test.dart`,
  which restores a backup onto a "phone" that already had other alerts.
* **Lock-screen privacy.** With `hideDetailsOnLockScreen`, every alert except
  the backup reminder keeps its title but its body becomes "Open the app to
  see details." Applied in `planAlerts`, so the plan hash changes and the
  existing notifications are replaced at the next re-plan. Android's
  per-notification `visibility` is not used; the text itself is generic.
* Limits: nothing here has run on a device (see `qa-alert-matrix.md`, B1–B11,
  V1–V3).

---

## Sprint 7 additions: orders on the way

* **Reorder orders.** *Mark as ordered* (Reorder screen) stores a
  `reorder_orders` row (one open order per medicine; a new one replaces the
  old). An open order holds back the ordinary reorder reminder for that
  medicine. The order is due on its expected date, or a week after it was
  placed if none was given.
* **Chasing.** From the day after the due date, a medicine whose order is still
  open is reminded with *"N orders are late"* (key `ordered:<date>`, same time
  as reorder reminders, same repeat interval, `AlertKind.reorder`). Delivered
  chase reminders count as the last reminder, so they follow the
  `reorderRefireDays` rhythm. *Received* or *Cancel order* closes the order and
  ordinary reminders resume at the next re-plan.
* **Per-medicine alert window** (S7-07): the planner already reads
  `medicines.alert_window_days` (`coalesce(m.alert_window_days, global)` in
  `AlertSourceImpl`); Sprint 7 added the field to the medicine form and tests.
