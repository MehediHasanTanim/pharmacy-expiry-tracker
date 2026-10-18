// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Expiry Tracker';

  @override
  String get tabHome => 'Home';

  @override
  String get tabStock => 'Stock';

  @override
  String get tabExpiry => 'Expiry';

  @override
  String get tabSuppliers => 'Suppliers';

  @override
  String get tabMore => 'More';

  @override
  String get emptyHome => 'Your dashboard will appear here';

  @override
  String get emptyStock => 'No medicines yet';

  @override
  String get emptyExpiry => 'Nothing is near expiry';

  @override
  String get emptySuppliers => 'No suppliers yet';

  @override
  String get emptyMore => 'Settings and reports will appear here';

  @override
  String get bucketExpired => 'Expired';

  @override
  String get bucketD30 => '30 days or less';

  @override
  String get bucketD60 => '31 to 60 days';

  @override
  String get bucketD90 => '61 to 90 days';

  @override
  String get bucketOk => 'More than 90 days';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionArchive => 'Archive';

  @override
  String get actionRestore => 'Restore';

  @override
  String get actionClose => 'Close';

  @override
  String get actionDiscard => 'Discard';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get stockSearchHint => 'Search medicines or batch numbers';

  @override
  String get stockShowArchived => 'Show archived';

  @override
  String get stockAddStock => 'Add stock';

  @override
  String get stockEmptyCta => 'Add your first medicine';

  @override
  String get stockEmptyBody =>
      'Add a medicine, then receive its batches to start tracking expiry.';

  @override
  String get stockNoResults => 'No matches';

  @override
  String get sectionMedicines => 'Medicines';

  @override
  String get sectionBatches => 'Batches';

  @override
  String get searchRecent => 'Recent searches';

  @override
  String get searchClearRecent => 'Clear';

  @override
  String get archivedBadge => 'Archived';

  @override
  String get noStock => 'No stock';

  @override
  String get medicineNew => 'New medicine';

  @override
  String get medicineEdit => 'Edit medicine';

  @override
  String get fieldBrandName => 'Brand name';

  @override
  String get fieldGenericName => 'Generic name';

  @override
  String get fieldStrength => 'Strength (e.g. 500 mg)';

  @override
  String get fieldDosageForm => 'Form';

  @override
  String get fieldUnit => 'Unit';

  @override
  String get fieldPackSize => 'Pack size';

  @override
  String get fieldManufacturer => 'Manufacturer';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldReorderLevel => 'Reorder level';

  @override
  String get fieldReorderHelp =>
      'Remind me to reorder when stock falls below this';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get errBrandRequired => 'Brand name is required';

  @override
  String get errNonNegativeInt => 'Enter a whole number, 0 or more';

  @override
  String get errPositiveInt => 'Enter a whole number above 0';

  @override
  String get duplicateMedicineTitle => 'Possible duplicate';

  @override
  String get duplicateMedicineBody =>
      'A medicine with the same name, strength and form already exists.';

  @override
  String get duplicateSaveAnyway => 'Save anyway';

  @override
  String get duplicateViewExisting => 'View existing';

  @override
  String get medicineArchiveTitle => 'Archive this medicine?';

  @override
  String get medicineArchiveBody =>
      'It will be hidden from lists and stop alerting. History is kept and you can restore it later.';

  @override
  String get formDosageTablet => 'Tablet';

  @override
  String get formDosageCapsule => 'Capsule';

  @override
  String get formDosageSyrup => 'Syrup';

  @override
  String get formDosageInjection => 'Injection';

  @override
  String get formDosageOintment => 'Ointment';

  @override
  String get formDosageDrops => 'Drops';

  @override
  String get formDosageOther => 'Other';

  @override
  String get unitStrip => 'Strip';

  @override
  String get unitBox => 'Box';

  @override
  String get unitBottle => 'Bottle';

  @override
  String get unitVial => 'Vial';

  @override
  String get unitPiece => 'Piece';

  @override
  String get detailBatches => 'Batches';

  @override
  String get detailNoBatches => 'No batches yet';

  @override
  String get detailAddBatch => 'Add batch';

  @override
  String get detailOnHandLabel => 'On hand';

  @override
  String get detailReorderLabel => 'Reorder level';

  @override
  String get batchNew => 'Receive batch';

  @override
  String get batchEdit => 'Edit batch';

  @override
  String get fieldBatchNumber => 'Batch number';

  @override
  String get fieldQuantity => 'Quantity';

  @override
  String get fieldCostPrice => 'Cost price (optional)';

  @override
  String get fieldSellingPrice => 'Selling price (optional)';

  @override
  String get fieldReceivedDate => 'Received on';

  @override
  String get saveAndAddAnother => 'Save & add another';

  @override
  String get errBatchRequired => 'Batch number is required';

  @override
  String get errExpiryRequired => 'Enter the expiry date';

  @override
  String get errExpiryInvalid => 'That is not a valid date';

  @override
  String get errQuantityRequired => 'Enter a quantity above 0';

  @override
  String get errPrice => 'Enter an amount like 12.50';

  @override
  String get quantityLockedHint => 'To change quantity, use Adjust stock';

  @override
  String get batchSaved => 'Batch saved';

  @override
  String get batchMergedInfo => 'Quantity added to the existing batch';

  @override
  String get duplicateBatchTitle => 'Batch already exists';

  @override
  String get duplicateBatchExact =>
      'This medicine already has this batch number with the same expiry. Add the quantity to it?';

  @override
  String get duplicateBatchDiffers =>
      'This medicine already has a batch with this number but a different expiry. Add to it, or keep it as a separate batch?';

  @override
  String get duplicateBatchAddTo => 'Add to existing';

  @override
  String get duplicateBatchSeparate => 'Create separate';

  @override
  String get expiryLabel => 'Expiry';

  @override
  String get expiryMonth => 'MM';

  @override
  String get expiryYear => 'YYYY';

  @override
  String get expiryDay => 'DD';

  @override
  String get expiryExactToggle => 'Exact date';

  @override
  String get expiryWarnPast => 'This date is already in the past';

  @override
  String get expiryWarnFar =>
      'This is more than 10 years away. Check the date.';

  @override
  String get statusActive => 'Active';

  @override
  String get statusDepleted => 'Depleted';

  @override
  String get statusReturned => 'Returned';

  @override
  String get statusDiscarded => 'Discarded';

  @override
  String get adjustTitle => 'Adjust stock';

  @override
  String get adjustReasonSold => 'Sold / used';

  @override
  String get adjustReasonDamaged => 'Damaged';

  @override
  String get adjustReasonExpired => 'Expired, discarded';

  @override
  String get adjustReasonReturned => 'Returned to supplier';

  @override
  String get adjustReasonCorrection => 'Correction';

  @override
  String get adjustReasonReceived => 'Received more';

  @override
  String get adjustReasonOther => 'Other';

  @override
  String get adjustQuantity => 'Quantity';

  @override
  String get adjustAll => 'All';

  @override
  String get adjustNote => 'Note (optional)';

  @override
  String get adjustCorrectionAdd => 'Add';

  @override
  String get adjustCorrectionRemove => 'Remove';

  @override
  String get adjustApply => 'Apply';

  @override
  String get adjustConfirmTitle => 'Write off stock?';

  @override
  String adjustErrTooMany(Object available) {
    return 'Only $available on hand';
  }

  @override
  String get adjustHistory => 'History';

  @override
  String get adjustNoHistory => 'No changes yet';

  @override
  String get batchDetailTitle => 'Batch';

  @override
  String get batchDetailExpiry => 'Expiry';

  @override
  String get batchDetailReceived => 'Received';

  @override
  String get batchDetailCost => 'Cost price';

  @override
  String get batchDetailSelling => 'Selling price';

  @override
  String get batchDetailNotes => 'Notes';

  @override
  String get batchDetailOnHand => 'On hand';

  @override
  String get batchDetailLifetime => 'Received in total';

  @override
  String get batchDetailWriteOff => 'Value written off';

  @override
  String get devTools => 'Developer tools';

  @override
  String get devSeed => 'Add demo data';

  @override
  String get devSeedBody =>
      'Adds 5,000 medicines and about 10,000 batches. This can take a few seconds.';

  @override
  String get devSeedDone => 'Demo data added';

  @override
  String stockOnHand(int count) {
    return '$count on hand';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
      zero: 'Expires today',
    );
    return '$_temp0';
  }

  @override
  String expiredAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Expired $count days ago',
      one: 'Expired 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String expiresOn(String date) {
    return 'Expires $date';
  }

  @override
  String batchTileSubtitle(int qty, String date) {
    return '$qty on hand · $date';
  }

  @override
  String adjustDelta(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count units',
      one: '1 unit',
    );
    return '$_temp0';
  }

  @override
  String adjustConfirmBody(String quantity, String batch) {
    return 'Write off $quantity of batch $batch? This is recorded as a loss.';
  }

  @override
  String batchBy(String number) {
    return 'Batch $number';
  }

  @override
  String get chipAll => 'All';

  @override
  String get chipExpired => 'Expired';

  @override
  String get chip30 => '0–30 d';

  @override
  String get chip60 => '31–60 d';

  @override
  String get chip90 => '61–90 d';

  @override
  String get chipLater => '91+ d';

  @override
  String get expiryEmptyHint => 'Batches close to expiry will show up here.';

  @override
  String get expiryNoMatches => 'No batches match these filters';

  @override
  String get expiryClearFilters => 'Clear filters';

  @override
  String get expirySearchHint => 'Search name or batch number';

  @override
  String get expirySectionExpired => 'Expired · remove from shelf';

  @override
  String get expiryValueNone => '—';

  @override
  String get expiryHandled => 'Handled';

  @override
  String get filterTitle => 'Filter and sort';

  @override
  String get filterSortBy => 'Sort by';

  @override
  String get sortSoonest => 'Soonest expiry';

  @override
  String get sortValue => 'Highest value at risk';

  @override
  String get sortName => 'Name';

  @override
  String get filterCategory => 'Category';

  @override
  String get filterForm => 'Form';

  @override
  String get filterAll => 'All';

  @override
  String get filterHideHandled => 'Hide handled batches';

  @override
  String get filterReset => 'Reset';

  @override
  String get filterApply => 'Apply';

  @override
  String get actionSold => 'Sold or adjust quantity';

  @override
  String get actionDiscardAll => 'Discard remaining stock';

  @override
  String get actionSnooze => 'Snooze alerts';

  @override
  String get actionHandled => 'Mark as handled';

  @override
  String get actionUnhandled => 'Mark as not handled';

  @override
  String get actionOpenBatch => 'Open batch';

  @override
  String get snoozeTitle => 'Snooze alerts for this batch';

  @override
  String get snooze1d => 'Tomorrow';

  @override
  String get snooze3d => 'In 3 days';

  @override
  String get snooze1w => 'In 1 week';

  @override
  String get snackHandled => 'Marked as handled';

  @override
  String get snackUnhandled => 'Marked as not handled';

  @override
  String get snackUndo => 'Undo';

  @override
  String get tooltipFilter => 'Filter and sort';

  @override
  String get tooltipSearch => 'Search';

  @override
  String get tooltipSelect => 'Select batches';

  @override
  String get selectCancel => 'Cancel selection';

  @override
  String get discardSelected => 'Discard selected';

  @override
  String expiryValueAtRisk(String amount) {
    return 'Value at risk: $amount';
  }

  @override
  String expiryValuePartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count batches have no price',
      one: '1 batch has no price',
    );
    return '$_temp0';
  }

  @override
  String expiryEmptyDays(int days) {
    return 'Nothing expires within $days days.';
  }

  @override
  String snoozeNext(String date) {
    return 'Until the next alert ($date)';
  }

  @override
  String snackSnoozed(String date) {
    return 'Alerts snoozed until $date';
  }

  @override
  String snackDiscarded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count batches discarded',
      one: '1 batch discarded',
    );
    return '$_temp0';
  }

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String bulkDiscardBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Write off the remaining stock of $count batches? This is recorded as a loss.',
      one: 'Write off the remaining stock of 1 batch? This is recorded as a loss.',
    );
    return '$_temp0';
  }

  @override
  String rowValue(String amount) {
    return 'Value: $amount';
  }

  @override
  String rowSnoozed(String date) {
    return 'Snoozed until $date';
  }

  @override
  String rowSection(String label, int count) {
    return '$label, $count';
  }

  @override
  String alertLeadTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Expiry in $count days',
      one: 'Expires tomorrow',
      zero: 'Expires today',
    );
    return '$_temp0';
  }

  @override
  String get alertMixedTitle => 'Batches nearing expiry';

  @override
  String alertBody(int count, String items, int more) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count batches',
      one: '1 batch',
    );
    String _temp1 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: ' and $more more',
      zero: '',
    );
    return '$_temp0: $items$_temp1';
  }

  @override
  String alertItem(String name, String batch) {
    return '$name ($batch)';
  }

  @override
  String get alertDigestTitle => 'Expiry digest';

  @override
  String alertDigestBody(int near, int expired) {
    String _temp0 = intl.Intl.pluralLogic(
      near,
      locale: localeName,
      other: '$near batches expiring soon',
      one: '1 batch expiring soon',
      zero: 'Nothing expiring soon',
    );
    String _temp1 = intl.Intl.pluralLogic(
      expired,
      locale: localeName,
      other: '$expired expired on the shelf',
      one: '1 expired on the shelf',
      zero: 'none expired',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get alertDigestGeneric =>
      'Open the app to review today\'s expiry actions.';

  @override
  String get alertTestTitle => 'Test alert';

  @override
  String get alertTestBody => 'Expiry alerts are working on this device.';

  @override
  String get alertCenterTitle => 'Alert history';

  @override
  String get alertCenterEmpty => 'No alerts yet';

  @override
  String get alertCenterMissed =>
      'Delivered or missed while the app was closed';

  @override
  String get alertSettingsTitle => 'Alert settings';

  @override
  String get alertSettingsLeadTimes => 'Alert before expiry';

  @override
  String get alertSettingsLeadHelp =>
      'Days before expiry to alert. 0 is the expiry day.';

  @override
  String get alertSettingsAddLead => 'Add days';

  @override
  String get alertSettingsLeadDialogTitle => 'Days before expiry';

  @override
  String get alertSettingsLeadInvalid => 'Enter a whole number from 0 to 365';

  @override
  String get alertSettingsDigest => 'Daily digest';

  @override
  String get alertSettingsDigestTime => 'Alert time';

  @override
  String get alertSettingsSkipEmpty => 'Skip the digest when nothing is due';

  @override
  String get alertSettingsQuiet => 'Quiet hours';

  @override
  String get alertSettingsQuietFrom => 'From';

  @override
  String get alertSettingsQuietTo => 'Until';

  @override
  String get alertSettingsHealth => 'Alert health';

  @override
  String get alertSettingsHealthSub => 'Check that alerts can reach you';

  @override
  String get healthTitle => 'Alert health';

  @override
  String get healthNotifications => 'Notifications';

  @override
  String get healthExactAlarms => 'Exact alarms';

  @override
  String get healthBattery => 'Battery optimisation';

  @override
  String get healthNextAlert => 'Next alert';

  @override
  String get healthPending => 'Scheduled alerts';

  @override
  String get healthLastPlanned => 'Last checked';

  @override
  String get healthAllowed => 'Allowed';

  @override
  String get healthBlocked => 'Blocked';

  @override
  String get healthNotApplicable => 'Not needed';

  @override
  String get healthUnrestricted => 'Unrestricted';

  @override
  String get healthRestricted => 'Restricted — alerts may be delayed';

  @override
  String get healthNone => 'None';

  @override
  String get healthNever => 'Never';

  @override
  String get healthSendTest => 'Send test alert';

  @override
  String get healthTestScheduled =>
      'A test alert will arrive in a few seconds. Close the app to try it.';

  @override
  String get healthOpenSettings => 'Open settings';

  @override
  String get healthOpenBattery => 'Battery settings';

  @override
  String get healthRefresh => 'Check again';

  @override
  String healthOemTip(String brand) {
    return 'On $brand phones, also allow the app to start automatically and exclude it from battery saving, otherwise the system may stop alerts.';
  }

  @override
  String get permissionTitle => 'Get expiry alerts';

  @override
  String get permissionBody =>
      'The app can warn you before medicines expire, even when it is closed and offline. To do that it needs permission to show notifications.';

  @override
  String get permissionAllow => 'Turn on alerts';

  @override
  String get permissionNotNow => 'Not now';

  @override
  String get permissionBannerAsk =>
      'Turn on expiry alerts so nothing expires unnoticed.';

  @override
  String get permissionBannerDenied =>
      'Alerts are off — expiry warnings will not reach you.';

  @override
  String get permissionBannerAction => 'Turn on';

  @override
  String get permissionBannerSettings => 'Open settings';

  @override
  String healthMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String leadChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days before',
      one: '1 day before',
      zero: 'On expiry day',
    );
    return '$_temp0';
  }

  @override
  String get healthLastError => 'The last check failed. Tap \"Check again\".';

  @override
  String healthOsPending(int count) {
    return '$count waiting in the system';
  }

  @override
  String get alertSettingsNoLeads =>
      'No lead-time alerts. Add at least one to be warned before expiry.';

  @override
  String get alertCenterOpenHint => 'Tap to review';

  @override
  String get alertTimeHelp =>
      'Digest and lead-time alerts arrive around this time.';
}
