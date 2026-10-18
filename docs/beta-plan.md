# Beta rollout and feedback loop (S6-12, S6-09)

Goal: one real pharmacy uses the app daily for two weeks, and we learn whether
alerts are reliable and whether entering stock is fast enough.

**Status: not started.** Nothing here has been run; this is the plan and the
checklist to use on the day.

## Before installing

1. Release build from `docs/release-checklist.md` (internal track or sideload).
2. Run the alert matrix and the backup/restore matrix (`docs/qa-alert-matrix.md`)
   on the pilot's own phone before leaving it with them.
3. Agree what to enter first: the 20–30 medicines they sell most, and the
   batches currently on the shelf. Enter the first five **together**, with a
   stopwatch (see metrics).

## Install checklist (at the pharmacy)

- [ ] Onboarding done; pharmacy name, currency and date format set.
- [ ] Notifications allowed; exact alarms allowed (Android 12+).
- [ ] Battery: app set to *Unrestricted* / *Don't optimise*; auto-start on for
      Xiaomi/Oppo/Vivo/Huawei/Samsung as shown on *Alert health*.
- [ ] *Alert health* → send a test alert; it arrives.
- [ ] Daily alert time chosen to match when the pharmacist is at the counter.
- [ ] First backup made and sent to the owner's email or drive.
- [ ] Phone number of the developer given for issues.

## Daily use (for the pharmacist)

1. Open the app when you arrive: Home shows what needs attention.
2. Receive a batch → *Stock → add batch* (barcode/expiry/quantity).
3. Act on the morning alert: *Expiry* tab, handle or discard.
4. Weekly: *Backup and restore → Back up now*.

## What to record

| Metric | How | Target |
|---|---|---|
| Time to add a batch (existing medicine) | Stopwatch, first 10 entries | < 30 s |
| Time to add a new medicine and batch | Stopwatch | < 60 s |
| Alert reliability | Each day: did the morning alert arrive at the set time? Note misses and the phone state (locked, restarted, battery saver). | ≥ 95% delivered |
| Missed expiry | Any batch that expired without an alert or while the app showed it as fine. | 0 |
| Data loss | Any record that disappeared. | 0 |
| Backup | Backups made, restore tried once on a spare device. | ≥ 1 per week; restore works |
| Friction | Where they hesitated, what they asked. | Written list |

Log issues in one list with: date, what happened, device, app version
(*More → Export diagnostics* includes it), severity (P0 = lost data or missed
alert; P1 = blocks daily use; P2 = annoying).

## Exit criteria for the beta

* Installed and used at ≥ 1 real pharmacy for ≥ 1 week.
* No P0 defects open.
* Metrics table filled in, with the alert-delivery rate stated honestly.
