# Alert Delivery QA Matrix

Manual test plan for on-device scheduled notifications (feature spec ALR-1,
ALR-5, ALR-6, ALR-15). Run it with the **Alert lab** (dev flavor → More tab →
*Alert lab*), which schedules real OS notifications without touching app data.

**Status: no results recorded yet.** Every cell below is `☐` (not run). The
Sprint 2 spike produced the lab and this plan; nobody has run it on a physical
device. Fill the table in and attach the notes to the spike report
([alert-spike-report.md](alert-spike-report.md)) before Sprint 3 depends on it.

## Devices

| ID | Device | OS | Why |
|---|---|---|---|
| P | Google Pixel (or any stock-Android) | Android 14+ | Reference behaviour |
| S | Samsung Galaxy (One UI) | Android 13+ | "Sleeping apps" / "Deep sleeping apps" |
| X | Xiaomi / Redmi / Poco (MIUI or HyperOS) | Android 12+ | Autostart + aggressive battery manager |
| I | iPhone | iOS 15 and latest | 64-notification cap, Focus modes |

Record for each run: device, OS build, date, app flavor/build, and
**scheduled time vs. actual delivery time**.

## Setup

```bash
flutter run --flavor dev --release      # release mode: debug builds behave differently
```

1. Open **More → Alert lab**.
2. Tap **Request + exact alarms** and grant everything.
3. Confirm *Notifications allowed: true* (and *Exact alarms allowed: true* on
   Android 12+).

Use **In 2 min (exact)** unless a row says otherwise.

## Scenarios

Result key: ✅ delivered on time (±1 min exact, ±10 min inexact) · ⚠️ late or
degraded (note how) · ❌ not delivered · ☐ not run.

### A. Delivery with the app in different states

| # | Steps | Expect | P | S | X | I |
|---|---|---|---|---|---|---|
| A1 | Schedule, stay in the app | Banner appears (iOS needs the foreground delegate; already set) | ☐ | ☐ | ☐ | ☐ |
| A2 | Schedule, press Home | Delivered | ☐ | ☐ | ☐ | ☐ |
| A3 | Schedule, swipe app away from recents | Delivered | ☐ | ☐ | ☐ | ☐ |
| A4 | Schedule, **force-stop** (Android: Settings → App info → Force stop; iOS: swipe away) | Android: **not delivered is the documented platform behaviour** until the app is opened again; record what actually happens. iOS: delivered | ☐ | ☐ | ☐ | ☐ |
| A5 | Schedule, lock the screen, leave it for 5 min | Delivered, screen wakes or shade shows it | ☐ | ☐ | ☐ | ☐ |

> A4 matters most: on Android a force-stopped app has its alarms cleared by the
> OS. That is why the plan re-plans on every launch and keeps a daily digest.

### B. Offline (ALR-15)

| # | Steps | Expect | P | S | X | I |
|---|---|---|---|---|---|---|
| B1 | Turn on **airplane mode**, schedule, close the app | Delivered | ☐ | ☐ | ☐ | ☐ |
| B2 | Airplane mode **and** swipe the app away | Delivered | ☐ | ☐ | ☐ | ☐ |
| B3 | Confirm the release build declares no `INTERNET` permission (`tool/check_manifest.sh`) | Passes | ☐ | – | – | – |

### C. Reboot and updates (ALR-6)

| # | Steps | Expect | P | S | X | I |
|---|---|---|---|---|---|---|
| C1 | Schedule **In 10 min**, reboot the phone, do not open the app | Delivered (Android: plugin boot receiver restores it) | ☐ | ☐ | ☐ | ☐ |
| C2 | Same, but open the app after reboot | Delivered once, no duplicate | ☐ | ☐ | ☐ | ☐ |
| C3 | Schedule In 10 min, install a newer build over it (`flutter install`) | Still delivered (`MY_PACKAGE_REPLACED`) | ☐ | ☐ | ☐ | ☐ |

### D. Power management (Android)

| # | Steps | Expect | P | S | X |
|---|---|---|---|---|---|
| D1 | `adb shell dumpsys deviceidle force-idle`, then schedule **exact** | Delivered (exactAllowWhileIdle) | ☐ | ☐ | ☐ |
| D2 | Same with **inexact** | Delivered, possibly late; record delay | ☐ | ☐ | ☐ |
| D3 | `adb shell cmd appops set <pkg> SCHEDULE_EXACT_ALARM deny`, schedule **exact** | App falls back to inexact; lab status shows *Exact alarms allowed: false*; still delivered | ☐ | ☐ | ☐ |
| D4 | Battery saver on, default OEM settings, screen off 10 min | Delivered | ☐ | ☐ | ☐ |
| D5 | Overnight: schedule for ~8 h ahead (inexact) | Delivered within 10 min | ☐ | ☐ | ☐ |

Package ids: `com.pharmacytracker.pharmacy_expiry_tracker.dev` (dev flavor).

### E. OEM restrictions (Samsung, Xiaomi, others)

Run A3, A4, B2, C1 and D5 **twice**: once with factory-default battery
settings, once after applying the mitigation. Note exactly which setting fixed
it, because the in-app Alert health screen (Sprint 3) must tell users.

| Device | Default settings | Mitigation tried | After mitigation |
|---|---|---|---|
| S | ☐ | Battery → Background usage limits → remove app from *Sleeping apps*; set *Unrestricted* | ☐ |
| X | ☐ | Security → Autostart **on**; Battery saver → *No restrictions*; lock app in recents | ☐ |
| Other (Oppo / Vivo / Huawei / Realme) if available | ☐ | App launch → manage manually, allow background activity | ☐ |

### F. Permissions

| # | Steps | Expect | P | S | X | I |
|---|---|---|---|---|---|---|
| F1 | Deny notification permission at the prompt | Status shows *Notifications allowed: false*; scheduling does not crash; nothing delivered | ☐ | ☐ | ☐ | ☐ |
| F2 | Later enable it in system settings, return to the app, **Refresh** | Status flips to true | ☐ | ☐ | ☐ | ☐ |
| F3 | Revoke notification permission while an alert is pending | Not delivered; app does not crash | ☐ | ☐ | ☐ | ☐ |
| F4 | Android 13+: first install, fresh permission prompt appears | Prompt shown once | ☐ | ☐ | ☐ | – |

### G. Time changes

| # | Steps | Expect | P | S | X | I |
|---|---|---|---|---|---|---|
| G1 | Schedule In 10 min, change time zone by +2 h | Record: delivered at the original instant or shifted. (Planner must re-plan on zone change.) | ☐ | ☐ | ☐ | ☐ |
| G2 | Set the clock forward 1 day, back again | Record behaviour; no crash, no duplicates | ☐ | ☐ | ☐ | ☐ |
| G3 | Around a DST transition (or emulate by setting the date) | A 09:00 alert stays at 09:00 local | ☐ | ☐ | ☐ | ☐ |

### H. Pending-notification cap (ALR-5)

| # | Steps | Expect | Result |
|---|---|---|---|
| H1 | iOS: **Schedule 70 (cap test)** | Lab log shows how many the OS reports pending. iOS documents 64. | ☐ |
| H2 | Android: same | All 70 pending (no practical cap) | ☐ |
| H3 | iOS: after H1, cancel all, schedule 64, then one more | Which one is dropped — the newest or the soonest? Record. (The planner keeps the *soonest* 60, so confirm the OS agrees.) | ☐ |

### I. Tap handling

| # | Steps | Expect | P | S | X | I |
|---|---|---|---|---|---|---|
| I1 | Tap the notification while the app is running | Lab shows *Last tapped payload* | ☐ | ☐ | ☐ | ☐ |
| I2 | Tap it with the app closed | App starts; lab shows *Launched by notification: /expiry?bucket=d30* | ☐ | ☐ | ☐ | ☐ |
| I3 | Tap it with the app in the background | App comes forward, payload delivered | ☐ | ☐ | ☐ | ☐ |

### J. Exactness (Android)

| # | Steps | Expect | P | S | X |
|---|---|---|---|---|---|
| J1 | Five alerts at +2 min, **exact**; log scheduled vs. delivered | Within ±1 min | ☐ | ☐ | ☐ |
| J2 | Five alerts at +2 min, **inexact** | Record the drift; used to decide whether exact alarms are worth the permission | ☐ | ☐ | ☐ |

## Pass criteria for starting Sprint 3

* A2, A3, B1, B2, C1, D1 pass on **P** and **I**.
* A3, B2, C1 pass on **S** and **X** *with* the documented mitigation, and the
  mitigation steps are written down.
* H1 observed on **I**.
* Anything ❌ that is not the documented Android force-stop behaviour gets a
  line in the spike report and a decision: accept, mitigate in-app, or add a
  native channel.

---

## Sprint 3 additions: engine and screens

The scenarios above exercise the OS. These check the engine on top of it, in
the **real app** (any flavor), using real data. Record results the same way.

| # | Steps | Expect | P | S | X | I |
|---|---|---|---|---|---|---|
| K1 | Add a medicine and a batch expiring in ~40 days. More → *Alert health* | *Scheduled alerts* ≥ 5 and equals the system's count; *Next alert* is tomorrow-ish | ☐ | ☐ | ☐ | ☐ |
| K2 | Discard that batch (Expiry tab → swipe → Discard) | Scheduled count drops; none for that batch remain | ☐ | ☐ | ☐ | ☐ |
| K3 | Edit its expiry to a nearer date | Alerts move (check *Next alert*) | ☐ | ☐ | ☐ | ☐ |
| K4 | Snooze it from the Expiry tab, then Undo | Alerts disappear then return | ☐ | ☐ | ☐ | ☐ |
| K5 | *Alert health → Send test alert*, close the app, wait 10 s | Test notification arrives; tapping opens *Alert health* | ☐ | ☐ | ☐ | ☐ |
| K6 | Set the alert time ~3 min ahead, with a batch whose alert falls today | Alert arrives within a few minutes of the new time; digest 5 min before it | ☐ | ☐ | ☐ | ☐ |
| K7 | Same with **airplane mode** on and the app swiped away | Still arrives (ALR-15) | ☐ | ☐ | ☐ | ☐ |
| K8 | Tap a delivered lead-time alert | Expiry tab opens with that urgency bucket selected | ☐ | ☐ | ☐ | ☐ |
| K9 | Leave the app closed past a delivery time, then open it | *Alert history* lists the alert as delivered/missed | ☐ | ☐ | ☐ | ☐ |
| K10 | Force-stop (Android), wait past a delivery time, reopen | Alerts re-planned on launch; *Check again* shows scheduled = system count | ☐ | ☐ | ☐ | – |
| K11 | Turn notifications off in system settings, return | Home banner appears; *Alert health* shows *Blocked* with *Open settings* | ☐ | ☐ | ☐ | ☐ |
| K12 | Turn them back on, return | Banner disappears; alerts rescheduled (count matches) | ☐ | ☐ | ☐ | ☐ |
| K13 | Quiet hours on, window covering the alert time | Alert arrives at the end of the window | ☐ | ☐ | ☐ | ☐ |
| K14 | Android: `adb shell cmd jobscheduler run -f <pkg> <job id>` (find id with `dumpsys jobscheduler`) for the WorkManager job | Log shows a background pass; no duplicates afterwards | ☐ | ☐ | ☐ | – |
| K15 | Android: battery optimisation *Restricted* | *Alert health* says so, offers *Battery settings*; OEM tip on Xiaomi/Samsung/etc. | ☐ | ☐ | ☐ | – |

### Exit criteria for Sprint 3 (from the plan)

* ≥ 95% of test alerts delivered across the matrix.
* No duplicate notifications after repeated re-plans (K1–K4 + `Check again`
  several times: count stays equal to the system's).
* ALR-15 verified in airplane mode (B1, B2, K7).

---

## Sprint 4 additions: payment reminders

Run on a real device with real data (any flavor). Reminders arrive **10 minutes
after the daily alert time** (default 09:10).

| # | Steps | Expect | P | S | X | I |
|---|---|---|---|---|---|---|
| P1 | Add a supplier, then an invoice due **tomorrow** (More → *Alert health*) | *Scheduled alerts* rises by 3+ (3-day lead is past; due day and overdue repeats) | ☐ | ☐ | ☐ | ☐ |
| P2 | Set the alert time ~3 min ahead with an invoice due **today** | "Payment due today" arrives ~13 min later (alert time + 10), body names the supplier and amount | ☐ | ☐ | ☐ | ☐ |
| P3 | Same with **airplane mode** on and the app swiped away | Still arrives | ☐ | ☐ | ☐ | ☐ |
| P4 | Tap the payment notification | Opens that supplier's page (or the Suppliers tab for several) | ☐ | ☐ | ☐ | ☐ |
| P5 | Record a **partial** payment, then *Check again* in Alert health | Count unchanged; the next notification's text shows the smaller amount | ☐ | ☐ | ☐ | ☐ |
| P6 | Pay the invoice **in full**, *Check again* | Its reminders are gone from *Scheduled alerts*; nothing arrives later | ☐ | ☐ | ☐ | ☐ |
| P7 | Delete the payment | Reminders come back | ☐ | ☐ | ☐ | ☐ |
| P8 | Invoice → *Snooze reminders* → tomorrow | No reminder today; resumes on the snooze date | ☐ | ☐ | ☐ | ☐ |
| P9 | Overdue invoice, repeat every 3 days | "Payment overdue" arrives every 3 days from the due date until paid | ☐ | ☐ | ☐ | ☐ |
| P10 | More → Alert settings → *Supplier payments*: remove "3 days", set repeat to *Never* | Only due-day reminder remains | ☐ | ☐ | ☐ | ☐ |

Exit criteria (Sprint 4): a due-date reminder fires on the device; paying cancels
the remaining reminders (P6) with no duplicates after repeated *Check again*.

---

## Sprint 5 additions: reorder reminders and badge

Reminders arrive **15 minutes after the daily alert time** (default 09:15).

| # | Steps | Expect | P | S | X | I |
|---|---|---|---|---|---|---|
| R1 | Medicine with reorder level 20, stock 5; alert time ~3 min ahead | "1 medicine to reorder" arrives ~18 min later | ☐ | ☐ | ☐ | ☐ |
| R2 | Tap the notification | Opens the reorder list | ☐ | ☐ | ☐ | ☐ |
| R3 | Receive a reminder, do not restock | Next arrives after the set interval (default 3 days), not daily | ☐ | ☐ | ☐ | ☐ |
| R4 | Restock above the level, *Check again* | Reorder reminders disappear from *Scheduled alerts* | ☐ | ☐ | ☐ | ☐ |
| R5 | Snooze a medicine until tomorrow | No reminder today | ☐ | ☐ | ☐ | ☐ |
| R6 | Airplane mode, app swiped away | Reminder still arrives | ☐ | ☐ | ☐ | ☐ |
| R7 | Add an expired batch so the badge count should be 1; background the app | Launcher icon shows 1 where the launcher supports badges (iOS always) | ☐ | ☐ | ☐ | ☐ |

---

## Sprint 6 additions: backup, restore, privacy

Run on every device in the matrix. "File" = the backup file the share sheet
produced; keep it somewhere the phone can browse (Files, Drive, email).

| # | Steps | Expect | P | S | X | I |
|---|---|---|---|---|---|---|
| B1 | More → Backup and restore → *Back up now* (no passphrase), save to Files/Drive | Share sheet opens; status becomes "Last backup: today"; Home banner (if shown) disappears | ☐ | ☐ | ☐ | ☐ |
| B2 | Same with a passphrase | File ends `.pxenc`; opening it in a text viewer shows no readable names | ☐ | ☐ | ☐ | ☐ |
| B3 | Dismiss the share sheet without saving | "Nothing was saved"; last-backup time unchanged | ☐ | ☐ | ☐ | ☐ |
| B4 | On a **second phone** (or after *Clear data*), install, restore the file | Preview shows right counts; after confirming, all medicines, batches, suppliers, settings are back | ☐ | ☐ | ☐ | ☐ |
| B5 | After B4: *Alert health* → *Check again*; wait for a test alert and the next real one | Scheduled count matches the restored data; no alerts from the previous data; notification permission prompt appears if missing | ☐ | ☐ | ☐ | ☐ |
| B6 | Restore with the wrong passphrase, then the right one | "That passphrase did not work", then success | ☐ | ☐ | ☐ | ☐ |
| B7 | Choose a non-backup file (photo, PDF) | "That file is not a backup from this app."; data unchanged | ☐ | ☐ | ☐ | ☐ |
| B8 | Kill the app during *Restore* (just after confirming) | On reopen, either the old or the new data is fully there, never a mix; no crash | ☐ | ☐ | ☐ | ☐ |
| B9 | Restore, then check for a safety copy and wait > 24 h, reopen | Old data is not accessible in the UI; the `.bak-…` file is removed at the next launch | ☐ | ☐ | ☐ | ☐ |
| B10 | Large data (More → dev *Seed* 5 000 medicines / 10 000 batches), back up and restore | Completes without freezing the UI; note the time | ☐ | ☐ | ☐ | ☐ |
| B11 | Last backup older than the reminder (or set reminder to 7 days and change the phone date) | Notification "Back up your data" arrives 20 min after the daily alert time; tap opens Backup and restore | ☐ | ☐ | ☐ | ☐ |
| V1 | Alert settings → *Hide details on the lock screen* on, then trigger a test/real alert with the phone locked | Lock screen shows the title and "Open the app to see details." only | ☐ | ☐ | ☐ | ☐ |
| V2 | Expiry tab → share icon → *Spreadsheet (CSV)* → open in Excel/Sheets; and *Plain text* → paste into a chat | Columns are correct, accents intact; text is readable | ☐ | ☐ | ☐ | ☐ |
| V3 | More → *Export diagnostics* | A text file with versions, counts and errors; no names or amounts | ☐ | ☐ | ☐ | ☐ |

Exit criteria (Sprint 6): B4/B5 pass on at least two devices; no data-loss or
missed-alert defects open.
