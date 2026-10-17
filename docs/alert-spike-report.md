# Alert Spike Report (Sprint 2, S2-10 … S2-14)

**Date:** 2026-10-17 · **Status: partially complete — device verification outstanding**

## What was asked

Prove a technical path for on-device scheduled expiry notifications: schedule a
test notification two minutes ahead and see it fire in airplane mode with the
app force-closed, on Android and iOS; check OEM behaviour; then decide whether
`flutter_local_notifications` is enough or a native channel is needed.

## What was done

| Task | Outcome |
|---|---|
| S2-10 plugin seam | **Done.** `NotificationPlugin` interface (`lib/domain/notifications/`) with `LocalNotificationPlugin` (flutter_local_notifications 22) and an in-memory `FakeNotificationPlugin` for tests. |
| S2-11 Android spike | **Wired, not run.** Channels, `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, boot/update receivers, core-library desugaring, exact→inexact fallback. The debug and release APKs build and the manifest check passes. **Nothing was run on a device or emulator** (none is available in this environment). |
| S2-12 iOS spike | **Wired, not run.** Authorization requested explicitly (not at launch), foreground presentation delegate in `AppDelegate.swift`, calendar-style zoned scheduling. **Not built** — this Mac has command-line tools only, no Xcode. |
| S2-13 OEM spike | **Not run.** Test procedure written in [qa-alert-matrix.md](qa-alert-matrix.md). |
| S2-14 go/no-go | **Provisional** (below). |

**To run the spike:** `flutter run --flavor dev --release` on a device, then
More → *Alert lab*, and work through `qa-alert-matrix.md`.

## What the lab provides

* Permission status (notifications, exact alarms) and a pending-notification
  count read back from the OS.
* Buttons: request permission, request exact alarms, alert in 10 s, in 2 min
  exact, in 2 min inexact, **schedule 70** (to observe the iOS cap), cancel all.
* The payload of the notification that launched the app, and of the last one
  tapped while running.
* A timestamped log to paste into the matrix.

Automated coverage (no OS involved): the lab's behaviour against the fake
plugin, including a simulated 64-notification cap.

## What is known without a device

These come from the plugin and platform documentation, not from observation.
Treat them as hypotheses the matrix must confirm.

1. **Android force-stop clears pending alarms.** Alerts then resume only when
   the user opens the app. No library can avoid this. Mitigation is the
   design's: re-plan on every launch/foreground, and keep the in-app
   dashboard as the source of truth.
2. **Exact alarms are a permission, not a given.** `SCHEDULE_EXACT_ALARM` can
   be revoked; Play restricts `USE_EXACT_ALARM` to alarm/calendar apps.
   Expiry alerts are date-level, so a few minutes of drift is acceptable.
3. **iOS keeps at most 64 pending local notifications.** Already handled in
   the design by grouping and a rolling 60-entry window.
4. **iOS delivers with the app killed**; notifications are held by the OS.
5. **Boot restore:** the plugin's receiver re-registers notifications it
   scheduled after reboot and app update on Android. It does not re-plan
   (e.g. new batches' alerts) — that needs Dart and happens on next launch or
   from a background task (Sprint 3).
6. **OEM battery managers** (Xiaomi, Samsung, Oppo, Vivo, Huawei) can kill the
   app and drop alarms despite correct code. Mitigation is user-facing
   guidance in the Alert health screen; the matrix will say which settings
   matter.

## Provisional decision

**Proceed with `flutter_local_notifications` behind the `NotificationPlugin`
seam. Do not add a native Kotlin/Swift channel yet.**

Reasons: the plugin covers scheduling, channels, permissions, boot/update
restore and launch payloads; the seam keeps a later swap cheap; and no failure
has been observed that a native channel would fix.

Because nothing was observed on a device, **this decision is reversible and
must be confirmed** by the matrix before Sprint 3 relies on it. Add a scoped
native channel (S3-11) only if one of these trips:

| Tripwire | Native fix |
|---|---|
| Exact alarms are required for correctness and the plugin cannot use `setAlarmClock`/express alarms where needed | Kotlin `AlarmManager` wrapper |
| Plugin boot receiver fails to restore on Samsung/Xiaomi even with mitigations | Own boot receiver that launches a Dart re-plan |
| iOS silently drops the *soonest* notification past 64 instead of the latest | Planner stays under the cap with margin (already 60); no native change needed |
| Timezone change does not re-fire/shift pending alerts | Native `TIMEZONE_CHANGED` receiver that schedules a re-plan |

## Recommendations carried into Sprint 3

1. **Default lead-time alerts to inexact delivery** (`preferExact: false`),
   keeping exact for the lab only. Date-level alerts do not need minute
   precision, and this avoids the permission prompt and Play policy exposure.
   Revisit if matrix row J2 shows unacceptable drift.
2. **Request notification permission with an explanation first**, then the
   system prompt (already how `LocalNotificationPlugin` initialises: no
   permission is requested on launch).
3. **Re-plan on launch, foreground, data change, and after boot/zone change**;
   treat a missed Android force-stop as expected, not a bug.
4. Build the Alert health screen around the matrix results: permission state,
   exact-alarm state, battery-optimisation guidance per OEM, last re-plan time,
   and a *Send test alert* button (the lab's 10-second button, productised).

## Configuration reference

* **Android** (`android/app/`): `AndroidManifest.xml` declares
  `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, and
  the plugin's `ScheduledNotificationReceiver` and
  `ScheduledNotificationBootReceiver` (boot, quickboot, package replaced).
  `build.gradle.kts` enables core-library desugaring (`desugar_jdk_libs`
  2.1.4). minSdk 26.
* **iOS** (`ios/Runner/AppDelegate.swift`): sets the
  `UNUserNotificationCenter` delegate so alerts show in the foreground.
  Permission is requested from Dart, on demand.
* **Dart:** channels are created at `initialize`; time zone is resolved with
  `flutter_timezone`, falling back to UTC if unknown.
