# Changelog

## 1.1.0 (build 2) — unreleased

Speed, returns, reports and security. *Everything below is covered by automated
tests; none of it has been run on a device yet (see `docs/qa-alert-matrix.md`
and `docs/release-checklist.md`).*

### New
* **Barcode scanning.** Scan a pack to find a medicine, or link an unknown
  barcode to an existing or new one. A medicine can have several barcodes.
* **Receive a delivery.** Many batches from one supplier in one go, with one
  invoice for the total. Saved all-or-nothing; an unfinished entry is kept and
  can be resumed.
* **Returns to suppliers**, with an optional credit and a shareable list. Select
  several expired batches on the Expiry tab and return them together.
* **"Ordered" tracking.** Mark a reorder as ordered, with an expected date.
  Reminders pause while it is on the way and chase it if it is late; "Received"
  opens the batch form already filled in. Share an order list per supplier.
* **Alert window per medicine.**
* **Reports.** Expiry loss (by month, supplier, medicine), stock value (by
  medicine, supplier, category) and dues aging, with charts, drill-down, and
  export as spreadsheet (CSV) or PDF.
* **Supplier statement** (opening balance, invoices, payments, credits, closing
  balance) as CSV or PDF, for reconciling with the supplier.
* **App lock**: PIN, with fingerprint / face / phone screen lock as an
  alternative, locking after a chosen time in the background. Alerts keep
  arriving while the app is locked.
* **Alert health**: step-by-step battery instructions for Xiaomi, Samsung,
  OPPO/realme/OnePlus, vivo and Huawei/Honor phones; the last alert delivered;
  a **Snooze 1 day** button on notifications (Android).

### Changed
* **The database is now encrypted** on the phone (SQLCipher, key in the Android
  Keystore). Existing data is converted automatically on first start after the
  update, after a verified copy; if that fails the data stays as it was and the
  app tries again next time.
* Backups are still ordinary, portable files (optionally passphrase-protected),
  and can be restored onto any phone. Backups made by 1.0 restore as before.
* The release manifest no longer requests network access even though the
  scanner library asks for it (`tool/check_manifest.sh` enforces this).

### Known limits
* PDFs use a built-in Latin font. Text in other scripts (such as Bengali) is
  shown as "?" in PDFs; spreadsheets keep all text.
* A forgotten PIN can be bypassed with the phone's own screen lock. If the
  phone has none and the PIN is lost, the data can only be recovered from a
  backup after reinstalling.
* If the phone's secure storage is wiped while the app's data remains, the
  encrypted data cannot be opened. The app says so and changes nothing; restore
  a backup after reinstalling.
* Snooze buttons on notifications are Android only and apply to alerts
  scheduled after the update.
* iOS has not been built.

## 1.0.0 (build 1) — beta

First beta: stock and expiry tracking, local expiry alerts, supplier dues,
reorder reminders, backup and restore.
