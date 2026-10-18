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

  @override
  String alertPayTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Payment due in $count days',
      one: 'Payment due tomorrow',
      zero: 'Payment due today',
    );
    return '$_temp0';
  }

  @override
  String get alertPayMixedTitle => 'Payments coming due';

  @override
  String alertOverdueTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Payments overdue',
      one: 'Payment overdue',
    );
    return '$_temp0';
  }

  @override
  String alertPayBody(int count, String items, int more, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invoices',
      one: '1 invoice',
    );
    String _temp1 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: ' and $more more',
      zero: '',
    );
    return '$_temp0: $items$_temp1 · $total';
  }

  @override
  String alertPayItem(String supplier, String amount) {
    return '$supplier $amount';
  }

  @override
  String get supplierSearchHint => 'Search suppliers';

  @override
  String get supplierSortName => 'Name';

  @override
  String get supplierSortBalance => 'Amount owed';

  @override
  String get supplierSortDue => 'Next due';

  @override
  String get supplierAdd => 'Add supplier';

  @override
  String get supplierEmptyBody =>
      'Add the suppliers you buy from to track what you owe them.';

  @override
  String get supplierEmptyCta => 'Add your first supplier';

  @override
  String get supplierNew => 'New supplier';

  @override
  String get supplierEdit => 'Edit supplier';

  @override
  String get supplierShowArchived => 'Show archived';

  @override
  String get fieldSupplierName => 'Supplier name';

  @override
  String get fieldContactPerson => 'Contact person';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldAddress => 'Address';

  @override
  String get fieldTaxId => 'Tax / licence ID';

  @override
  String get fieldPaymentTerms => 'Payment terms (days)';

  @override
  String get fieldPaymentTermsHelp =>
      'Used to suggest a due date on new invoices';

  @override
  String get errSupplierRequired => 'Supplier name is required';

  @override
  String get errEmailInvalid => 'Enter a valid email address';

  @override
  String get errTermsInvalid => 'Enter a whole number of days, 0 or more';

  @override
  String get supplierArchiveTitle => 'Archive this supplier?';

  @override
  String get supplierArchiveBody =>
      'They will disappear from lists and pickers. What you owe them and its reminders stay.';

  @override
  String get duesOwed => 'Owed';

  @override
  String get duesOverdue => 'Overdue';

  @override
  String get duesNextDue => 'Next due';

  @override
  String get duesNone => 'Nothing owed';

  @override
  String get duesAllClear => 'All paid up';

  @override
  String get badgeOverdue => 'Overdue';

  @override
  String get contactCall => 'Call';

  @override
  String get contactSms => 'Message';

  @override
  String get contactWhatsapp => 'WhatsApp';

  @override
  String get contactEmail => 'Email';

  @override
  String get contactFailed => 'Could not open that app on this device.';

  @override
  String get contactCopied => 'Copied to the clipboard';

  @override
  String get ledgerInvoices => 'Invoices';

  @override
  String get ledgerPayments => 'Payments';

  @override
  String get ledgerCredits => 'Credits';

  @override
  String get ledgerNoInvoices => 'No invoices yet';

  @override
  String get ledgerNoPayments => 'No payments yet';

  @override
  String get ledgerNoCredits => 'No credits yet';

  @override
  String get actionAddInvoice => 'Add invoice';

  @override
  String get actionRecordPayment => 'Record payment';

  @override
  String get actionRecordCredit => 'Record credit';

  @override
  String get actionSnoozeReminders => 'Snooze reminders';

  @override
  String get actionClearSnooze => 'Resume reminders';

  @override
  String get actionDelete => 'Delete';

  @override
  String get statusUnpaid => 'Unpaid';

  @override
  String get statusPartial => 'Part paid';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get invoiceNew => 'New invoice';

  @override
  String get invoiceEdit => 'Edit invoice';

  @override
  String get fieldInvoiceNumber => 'Invoice number (optional)';

  @override
  String get fieldInvoiceDate => 'Invoice date';

  @override
  String get fieldDueDate => 'Due date';

  @override
  String get fieldInvoiceTotal => 'Total amount';

  @override
  String get fieldInvoiceNotes => 'Notes';

  @override
  String get noDueDate => 'No due date';

  @override
  String get clearDueDate => 'Clear';

  @override
  String get errAmountInvalid => 'Enter an amount above 0, like 185.50';

  @override
  String get errDueBeforeInvoice =>
      'The due date cannot be before the invoice date';

  @override
  String get invoiceDueFromTerms =>
      'Due date set from the supplier\'s payment terms';

  @override
  String get invoiceDetailTitle => 'Invoice';

  @override
  String get invoiceTotalLabel => 'Total';

  @override
  String get invoicePaidLabel => 'Paid';

  @override
  String get invoiceCreditedLabel => 'Credited';

  @override
  String get invoiceBalanceLabel => 'Still owed';

  @override
  String get invoiceDueLabel => 'Due';

  @override
  String get invoiceDateLabel => 'Dated';

  @override
  String get invoiceDeleteTitle => 'Delete this invoice?';

  @override
  String get invoiceDeleteBody =>
      'It has no payments. Received batches stay but are no longer linked to it.';

  @override
  String get invoiceHasPayments => 'Delete its payments and credits first.';

  @override
  String get paymentTitle => 'Record payment';

  @override
  String get fieldPaymentAmount => 'Amount paid';

  @override
  String get fieldPaymentDate => 'Paid on';

  @override
  String get fieldPaymentReference => 'Reference (optional)';

  @override
  String get fieldPaymentApplyTo => 'Apply to';

  @override
  String get paymentOldestFirst => 'Oldest due first';

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get paymentMethodBank => 'Bank';

  @override
  String get paymentMethodMobile => 'Mobile wallet';

  @override
  String get paymentMethodCheque => 'Cheque';

  @override
  String get paymentMethodOther => 'Other';

  @override
  String get paymentSaved => 'Payment recorded';

  @override
  String get paymentOverTitle => 'More than is owed';

  @override
  String get paymentOverCredit => 'Record the extra as a credit';

  @override
  String get paymentDelete => 'Delete this payment?';

  @override
  String get creditTitle => 'Record credit';

  @override
  String get fieldCreditAmount => 'Credit amount';

  @override
  String get fieldCreditNote => 'Note (optional)';

  @override
  String get creditSaved => 'Credit recorded';

  @override
  String get creditGeneral => 'General credit';

  @override
  String get snoozeRemindersTitle => 'Snooze payment reminders';

  @override
  String get dueDialogTitle => 'Add a due for this delivery?';

  @override
  String get dueDialogYes => 'Add invoice';

  @override
  String get dueDialogNo => 'Not now';

  @override
  String get fieldSupplier => 'Supplier';

  @override
  String get supplierNone => 'None';

  @override
  String get fieldPreferredSupplier => 'Preferred supplier';

  @override
  String get alertSettingsPayments => 'Supplier payments';

  @override
  String get alertSettingsPayLead => 'Remind before the due date';

  @override
  String get alertSettingsOverdueEvery => 'Remind when overdue';

  @override
  String get overdueEveryOff => 'Never';

  @override
  String snackReminderSnoozed(Object date) {
    return 'Reminders snoozed until $date';
  }

  @override
  String get snackReminderResumed => 'Reminders resumed';

  @override
  String supplierOwedLine(String amount) {
    return 'Owed $amount';
  }

  @override
  String supplierOverdueLine(String amount) {
    return '$amount overdue';
  }

  @override
  String supplierNextDueLine(String date) {
    return 'Next due $date';
  }

  @override
  String duesOverdueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invoices',
      one: '1 invoice',
    );
    return '$_temp0';
  }

  @override
  String invoiceListTitle(String number) {
    return '$number';
  }

  @override
  String invoiceNumberLabel(String number) {
    return 'Invoice $number';
  }

  @override
  String invoiceNoNumber(String date) {
    return 'Invoice dated $date';
  }

  @override
  String invoiceBatchesLinked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count batches linked',
      one: '1 batch linked',
      zero: 'No batches linked',
    );
    return '$_temp0';
  }

  @override
  String invoiceDueIn(String date) {
    return 'Due $date';
  }

  @override
  String paymentLine(String amount, String date) {
    return '$amount on $date';
  }

  @override
  String paymentOverBody(String entered, String owed, String extra) {
    return 'You entered $entered but only $owed is owed. Record the extra $extra as a credit on this supplier\'s account?';
  }

  @override
  String paymentSpread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Applied to $count invoices',
      one: 'Applied to 1 invoice',
    );
    return '$_temp0';
  }

  @override
  String overdueEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String get creditForInvoice => 'Credit on invoice';

  @override
  String get contactCopyAction => 'Copy';

  @override
  String creditTooMuch(String owed) {
    return 'That is more than the $owed still owed on this invoice.';
  }

  @override
  String get batchDone => 'Done';

  @override
  String dueDialogBody(String supplier) {
    return 'Record what you owe $supplier for this delivery so you are reminded to pay.';
  }

  @override
  String alertReorderTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count medicines to reorder',
      one: '1 medicine to reorder',
    );
    return '$_temp0';
  }

  @override
  String alertReorderBody(String items, int more) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: ' and $more more',
      zero: '',
    );
    return '$items$_temp0';
  }

  @override
  String alertReorderItem(String name, int left) {
    return '$name ($left left)';
  }

  @override
  String get alertHiddenBody => 'Open the app to see details.';

  @override
  String get alertBackupTitle => 'Back up your data';

  @override
  String get alertBackupBodyNever =>
      'You have not made a backup yet. Save a copy so a lost phone does not lose your records.';

  @override
  String alertBackupBodyAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Your last backup was $_temp0 ago. Save a fresh copy.';
  }

  @override
  String get homeExpired => 'Expired on shelf';

  @override
  String get homeExpiring30 => 'Expiring soon';

  @override
  String get homeReorder => 'To reorder';

  @override
  String get homeOverdueDues => 'Overdue payments';

  @override
  String get homeWeekTitle => 'Expiring this week';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeWeekEmpty => 'Nothing expires in the next 7 days.';

  @override
  String get homeAtRisk => 'Value at risk';

  @override
  String get homeFirstTitle => 'Start by adding a medicine';

  @override
  String get homeFirstBody =>
      'Add a medicine and receive its first batch, and expiry alerts begin.';

  @override
  String get homeAddMedicine => 'Add medicine';

  @override
  String get homeNoReorder => 'All stocked';

  @override
  String get homeAllGood => 'Nothing needs attention';

  @override
  String get bannerReplanFailed => 'Alerts could not be updated. Check again.';

  @override
  String get bannerBattery => 'Battery saving may delay your alerts.';

  @override
  String get bannerCheck => 'Check';

  @override
  String get reorderTitle => 'Reorder list';

  @override
  String get reorderEmpty => 'Nothing to reorder';

  @override
  String get reorderEmptyBody =>
      'Medicines below their reorder level will show up here.';

  @override
  String get reorderUnassigned => 'No preferred supplier';

  @override
  String get reorderSuggested => 'Order';

  @override
  String get reorderSnooze => 'Snooze reminders';

  @override
  String get reorderResume => 'Resume reminders';

  @override
  String get snackReorderSnoozed => 'Reorder reminders snoozed';

  @override
  String get snackReorderResumed => 'Reorder reminders resumed';

  @override
  String get moreSectionAlerts => 'Alerts';

  @override
  String get moreSectionStock => 'Stock';

  @override
  String get moreReorderTile => 'Reorder list';

  @override
  String get moreSettingsTile => 'Settings';

  @override
  String get moreSectionApp => 'App';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPharmacy => 'Pharmacy';

  @override
  String get fieldPharmacyName => 'Pharmacy name';

  @override
  String get settingsExpiry => 'Expiry';

  @override
  String get settingsWindow => 'Near-expiry window';

  @override
  String get settingsWindowHelp =>
      'Batches expiring within this many days appear on the Expiry tab.';

  @override
  String get settingsBuckets => 'Urgency groups';

  @override
  String get settingsBucketsHelp =>
      'Days at which batches move to the next group.';

  @override
  String get settingsBucketA => 'Urgent up to';

  @override
  String get settingsBucketB => 'Soon up to';

  @override
  String get settingsBucketC => 'Later up to';

  @override
  String get errBucketsOrder =>
      'Each group must be longer than the one before.';

  @override
  String get settingsDisplay => 'Display';

  @override
  String get settingsCurrency => 'Currency symbol';

  @override
  String get settingsCurrencyHelp =>
      'Shown next to amounts. Leave empty for none.';

  @override
  String get settingsDateFormat => 'Date format';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'Follow the device';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get dateFormatDevice => 'Device default';

  @override
  String get alertSettingsReorder => 'Reorder reminders';

  @override
  String get alertSettingsReorderEvery => 'Remind again after';

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbNext => 'Next';

  @override
  String get onbBack => 'Back';

  @override
  String get onbStart => 'Get started';

  @override
  String get onb1Title => 'Never let medicine expire unnoticed';

  @override
  String get onb1Body =>
      'Record each batch with its expiry date. The app shows what is running out of time first.';

  @override
  String get onb2Title => 'Alerts that work offline';

  @override
  String get onb2Body =>
      'Reminders are scheduled on your phone, so they arrive even without a signal or with the app closed.';

  @override
  String get onb3Title => 'Keep track of dues and stock';

  @override
  String get onb3Body =>
      'See what you owe each supplier, get paid-by reminders, and know what to reorder.';

  @override
  String get onbSetupTitle => 'About your pharmacy';

  @override
  String get onbSetupBody => 'You can change all of this later in Settings.';

  @override
  String get onbAlertsTitle => 'Turn on expiry alerts';

  @override
  String get onbAlertsBody =>
      'The app needs permission to show notifications. Alerts stay on your phone.';

  @override
  String get onbDoneTitle => 'You are ready';

  @override
  String get onbDoneBody =>
      'Add your first medicine and its batches to start tracking.';

  @override
  String get onbAddFirst => 'Add first medicine';

  @override
  String get onbExplore => 'Explore the app';

  @override
  String homeBatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count batches',
      one: '1 batch',
    );
    return '$_temp0';
  }

  @override
  String homeMedicineCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count medicines',
      one: '1 medicine',
    );
    return '$_temp0';
  }

  @override
  String homeInvoiceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invoices',
      one: '1 invoice',
    );
    return '$_temp0';
  }

  @override
  String homeCardSemantics(String label, String value) {
    return '$label: $value';
  }

  @override
  String reorderLevelLine(int usable, int level) {
    return '$usable on hand · reorder at $level';
  }

  @override
  String settingsWindowDays(int count) {
    return '$count days';
  }

  @override
  String onbStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get rowActionsTooltip => 'More actions';

  @override
  String get moreSectionData => 'Data';

  @override
  String get moreBackupTile => 'Backup and restore';

  @override
  String get backupTitle => 'Backup and restore';

  @override
  String get backupLastNever => 'No backup yet';

  @override
  String backupLastAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Last backup: $days days ago',
      one: 'Last backup: yesterday',
      zero: 'Last backup: today',
    );
    return '$_temp0';
  }

  @override
  String get backupExplain =>
      'Your records live only on this phone. A backup is one file you can keep in your email, a cloud drive or on another phone.';

  @override
  String get backupNow => 'Back up now';

  @override
  String get backupEncryptTitle => 'Protect with a passphrase';

  @override
  String get backupEncryptHint =>
      'Encrypts the file. You need the passphrase to restore it, and it cannot be recovered if forgotten.';

  @override
  String get backupPassphrase => 'Passphrase';

  @override
  String get backupPassphraseConfirm => 'Repeat passphrase';

  @override
  String get backupPassphraseShort => 'Use at least 8 characters';

  @override
  String get backupPassphraseMismatch => 'The passphrases do not match';

  @override
  String get backupWorking => 'Please wait…';

  @override
  String get backupNotShared =>
      'Nothing was saved. Back up again and choose where to keep the file.';

  @override
  String get backupDone => 'Backup saved';

  @override
  String get backupRestore => 'Restore from a backup';

  @override
  String get backupRestoreHint =>
      'Replaces everything on this phone with the contents of a backup file.';

  @override
  String get backupAskPassphraseTitle => 'This backup is protected';

  @override
  String get backupAskPassphraseBody =>
      'Enter the passphrase it was made with.';

  @override
  String get backupWrongPassphrase => 'That passphrase did not work.';

  @override
  String get backupPreviewTitle => 'Restore this backup?';

  @override
  String backupPreviewMade(String date) {
    return 'Made on $date';
  }

  @override
  String backupPreviewCounts(
    int medicines,
    int batches,
    int suppliers,
    int invoices,
  ) {
    return '$medicines medicines, $batches batches, $suppliers suppliers, $invoices invoices';
  }

  @override
  String get backupPreviewReplace =>
      'This replaces all medicines, batches, suppliers and settings on this phone. A copy of the current data is kept for 24 hours.';

  @override
  String get backupRestoreAction => 'Restore';

  @override
  String get backupRestored => 'Backup restored';

  @override
  String get backupErrNotABackup => 'That file is not a backup from this app.';

  @override
  String get backupErrCorrupt =>
      'That backup is damaged and cannot be restored. Nothing was changed.';

  @override
  String get backupErrNewer =>
      'That backup was made by a newer version of the app. Update the app first.';

  @override
  String get backupErrSwap =>
      'The restore could not finish. Your previous data is unchanged.';

  @override
  String get backupErrGeneric => 'Something went wrong. Nothing was changed.';

  @override
  String get backupReminderLabel => 'Remind me to back up';

  @override
  String get backupReminderOff => 'Never';

  @override
  String backupReminderEvery(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Every $days days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String get homeBackupNever => 'Your data has never been backed up.';

  @override
  String homeBackupStale(int days) {
    return 'Your data has not been backed up for $days days.';
  }

  @override
  String get homeBackupAction => 'Back up';

  @override
  String get onboardingBackupNote =>
      'Tip: make a backup now and then in More → Backup and restore, so a lost phone does not lose your records.';

  @override
  String get settingsHideDetails => 'Hide details on the lock screen';

  @override
  String get settingsHideDetailsHelp =>
      'Notifications say that something needs attention, but not which medicines or suppliers.';

  @override
  String get shareListAction => 'Share this list';

  @override
  String get shareListCsv => 'Spreadsheet (CSV)';

  @override
  String get shareListText => 'Plain text';

  @override
  String get shareListEmpty => 'There is nothing in this list to share.';

  @override
  String shareListSubject(String date) {
    return 'Expiry list $date';
  }

  @override
  String get diagnosticsExport => 'Export diagnostics';

  @override
  String get diagnosticsHelp =>
      'A small text file for support. It lists app versions, settings and counts, and recent errors; it contains no medicine, supplier, or amount data.';

  @override
  String get errorFriendlyTitle => 'Something went wrong';

  @override
  String get errorFriendlyBody =>
      'Your data is safe. Go back and try again; if it keeps happening, export diagnostics from More.';

  @override
  String get startupFailedTitle => 'The update could not finish';

  @override
  String get startupFailedBody =>
      'Your data was put back exactly as it was. Please close the app and try again, or reinstall the previous version.';

  @override
  String get exportColMedicine => 'Medicine';

  @override
  String get exportColBatch => 'Batch';

  @override
  String get exportColExpiry => 'Expiry date';

  @override
  String get exportColDaysLeft => 'Days left';

  @override
  String get exportColStatus => 'Status';

  @override
  String get exportColQuantity => 'Quantity';

  @override
  String get exportColUnitCost => 'Unit cost';

  @override
  String get exportColValue => 'Value at risk';

  @override
  String exportTextTitle(String date) {
    return 'Expiry list, $date';
  }

  @override
  String alertOrderLateTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders are late',
      one: '1 order is late',
    );
    return '$_temp0';
  }

  @override
  String alertOrderLateItem(String name, int qty) {
    return '$name ($qty ordered)';
  }

  @override
  String get fieldAlertWindow => 'Alert window (days)';

  @override
  String get fieldAlertWindowHelp =>
      'Leave blank to use the pharmacy-wide window. Set a longer window for slow movers, a shorter one for fast sellers.';

  @override
  String get scanTitle => 'Scan barcode';

  @override
  String get scanTorch => 'Torch';

  @override
  String get scanTypeInstead => 'Type the number';

  @override
  String get scanTypeTitle => 'Barcode number';

  @override
  String get scanPermissionDenied =>
      'Camera access is off. Turn it on in the phone\'s settings, or type the number instead.';

  @override
  String get scanUnsupported =>
      'This device cannot scan. Type the number instead.';

  @override
  String get scanHint => 'Point the camera at the barcode on the pack.';

  @override
  String get scanButton => 'Scan barcode';

  @override
  String get scanInvalid => 'That barcode could not be read.';

  @override
  String get scanUnknownTitle => 'New barcode';

  @override
  String scanUnknownBody(String code) {
    return '$code is not linked to a medicine yet.';
  }

  @override
  String get scanLinkExisting => 'Link to an existing medicine';

  @override
  String get scanCreateNew => 'Create a new medicine';

  @override
  String scanLinked(String name) {
    return 'Barcode linked to $name.';
  }

  @override
  String scanTakenBy(String name) {
    return 'That barcode already belongs to $name.';
  }

  @override
  String get pickerChooseTitle => 'Choose a medicine';

  @override
  String get barcodesTitle => 'Barcodes';

  @override
  String get barcodesNone => 'No barcodes linked. Scan a pack to link one.';

  @override
  String get barcodesAdd => 'Scan to add';

  @override
  String get barcodeRemove => 'Remove barcode';

  @override
  String get receiveDeliveryTitle => 'Receive a delivery';

  @override
  String get receiveDeliveryAction => 'Receive delivery';

  @override
  String get receiveSupplier => 'Supplier';

  @override
  String get receiveNoSupplier => 'No supplier';

  @override
  String get receiveInvoiceNumber => 'Invoice number';

  @override
  String get receiveInvoiceTotal => 'Invoice total';

  @override
  String get receiveInvoiceHelp =>
      'Leave blank for no invoice. A total creates one invoice covering every batch.';

  @override
  String get receiveDate => 'Received on';

  @override
  String get receiveAddLine => 'Add a batch';

  @override
  String get receiveLineMedicine => 'Medicine';

  @override
  String get receiveLineChoose => 'Choose medicine';

  @override
  String get receiveLineBatch => 'Batch number';

  @override
  String get receiveLineExpiry => 'Expiry (MM/YYYY)';

  @override
  String get receiveLineQuantity => 'Quantity';

  @override
  String get receiveLineCost => 'Unit cost';

  @override
  String get receiveLineRemove => 'Remove line';

  @override
  String receiveLineNumber(int n) {
    return 'Batch $n';
  }

  @override
  String get receiveSave => 'Save delivery';

  @override
  String receiveSaved(int count) {
    return 'Delivery saved: $count batches.';
  }

  @override
  String get receiveDraftBanner => 'Continuing an unfinished delivery.';

  @override
  String get receiveDiscardDraft => 'Start over';

  @override
  String get receiveNeedMedicine => 'Choose a medicine';

  @override
  String get receiveNeedExpiry => 'Enter a valid expiry';

  @override
  String get receiveNeedLines => 'Add at least one batch.';

  @override
  String get receiveNeedSupplier => 'Choose a supplier to create the invoice.';

  @override
  String get receiveBadTotal => 'Enter a valid invoice total.';

  @override
  String get returnTitle => 'Return to supplier';

  @override
  String get returnAction => 'Return stock';

  @override
  String get returnSupplier => 'Return to';

  @override
  String get returnPickSupplier => 'Choose the supplier';

  @override
  String get returnLinesTitle => 'Batches to return';

  @override
  String get returnNoLines =>
      'This supplier has no batches in stock to return.';

  @override
  String get returnQuantity => 'Quantity';

  @override
  String returnLineLeft(int qty) {
    return '$qty in stock';
  }

  @override
  String get returnCredit => 'Credit from the supplier';

  @override
  String get returnCreditHelp => 'Optional. Lowers what you owe this supplier.';

  @override
  String get returnCreditInvoice => 'Apply to';

  @override
  String get returnCreditAccount => 'Account in general';

  @override
  String get returnNote => 'Note';

  @override
  String get returnSave => 'Return';

  @override
  String get returnDone => 'Return recorded.';

  @override
  String get returnShare => 'Share return list';

  @override
  String returnShareSubject(String supplier) {
    return 'Return to $supplier';
  }

  @override
  String get returnListTitle => 'Returns';

  @override
  String get returnListEmpty => 'No returns yet.';

  @override
  String returnLineText(int qty, String name, String batch) {
    return '$qty × $name, batch $batch';
  }

  @override
  String returnHeaderText(String supplier, String date) {
    return 'Return to $supplier, $date';
  }

  @override
  String returnCreditText(String amount) {
    return 'Credit expected: $amount';
  }

  @override
  String get returnNeedLines => 'Choose at least one batch.';

  @override
  String get returnBadQuantity => 'Check the quantities.';

  @override
  String get returnBadCredit => 'Enter a valid credit amount.';

  @override
  String get returnSupplierMismatch =>
      'Some of these batches came from different suppliers.';

  @override
  String get expiryReturnAction => 'Return to supplier';

  @override
  String get orderMarkOrdered => 'Mark as ordered';

  @override
  String get orderDialogTitle => 'Mark as ordered';

  @override
  String get orderQuantity => 'Quantity ordered';

  @override
  String get orderExpected => 'Expected by';

  @override
  String get orderNoDate => 'No date (assume a week)';

  @override
  String orderChipOrdered(int qty) {
    return 'Ordered $qty';
  }

  @override
  String orderChipDue(String date) {
    return 'due $date';
  }

  @override
  String orderChipLate(String date) {
    return 'late since $date';
  }

  @override
  String get orderReceived => 'Received';

  @override
  String get orderCancel => 'Cancel order';

  @override
  String get orderCancelled => 'Order cancelled.';

  @override
  String get orderUndoNote => 'Reminders resume.';

  @override
  String get orderShareSupplier => 'Share order list';

  @override
  String orderShareSubject(String supplier) {
    return 'Order for $supplier';
  }

  @override
  String orderShareHeader(String supplier) {
    return '*Order for $supplier*';
  }

  @override
  String orderShareLine(String name, int qty) {
    return '• $name × $qty';
  }

  @override
  String get orderShareNoSupplier => 'No supplier chosen';

  @override
  String get orderShareGreeting =>
      'Please confirm availability and delivery date. Thank you.';

  @override
  String returnTileQty(int qty) {
    String _temp0 = intl.Intl.pluralLogic(
      qty,
      locale: localeName,
      other: '$qty items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get startupKeyMissingTitle => 'Your data cannot be unlocked';

  @override
  String get startupKeyMissingBody =>
      'The key that protects the data on this phone is missing, for example after the phone\'s security storage was reset. Nothing was deleted or changed. Reinstalling the app will not bring the data back; restore a backup file after reinstalling.';

  @override
  String get lockTitle => 'App locked';

  @override
  String get lockEnterPin => 'Enter your PIN';

  @override
  String get lockWrongPin => 'Wrong PIN.';

  @override
  String lockAttemptsLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tries',
      one: '1 try',
    );
    return 'Wrong PIN. $_temp0 left before a short wait.';
  }

  @override
  String lockWait(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds',
      one: '1 second',
    );
    return 'Too many tries. Wait $_temp0.';
  }

  @override
  String get lockUseDevice => 'Unlock with fingerprint, face or phone lock';

  @override
  String get lockBiometricReason => 'Unlock the pharmacy expiry tracker';

  @override
  String get lockForgot =>
      'Forgot your PIN? Use the phone\'s own lock above. Your notifications keep working while the app is locked.';

  @override
  String get lockDelete => 'Delete digit';

  @override
  String lockDigit(String d) {
    return 'Digit $d';
  }

  @override
  String get settingsLockSection => 'App lock';

  @override
  String get settingsLockSwitch => 'Lock the app with a PIN';

  @override
  String get settingsLockHelp =>
      'Asks for the PIN when you open the app and after it has been in the background. Alerts still arrive while it is locked.';

  @override
  String get settingsLockChange => 'Change PIN';

  @override
  String get settingsLockBiometrics =>
      'Unlock with fingerprint, face or phone lock';

  @override
  String get settingsLockTimeout => 'Lock again after';

  @override
  String get settingsLockTimeoutNow => 'Right away';

  @override
  String settingsLockTimeoutSeconds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String settingsLockTimeoutMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get lockSetTitle => 'Choose a PIN';

  @override
  String get lockSetHint =>
      '4 to 8 digits. It cannot be recovered; the phone\'s own lock can still open the app.';

  @override
  String get lockPin => 'PIN';

  @override
  String get lockPinConfirm => 'Repeat PIN';

  @override
  String get lockPinInvalid => 'Use 4 to 8 digits.';

  @override
  String get lockPinMismatch => 'The PINs do not match.';

  @override
  String get lockCurrentTitle => 'Enter your current PIN';

  @override
  String get lockEnabledSnack => 'App lock is on.';

  @override
  String get lockDisabledSnack => 'App lock is off.';

  @override
  String get lockChangedSnack => 'PIN changed.';

  @override
  String get alertActionSnooze => 'Snooze 1 day';

  @override
  String get healthLastFired => 'Last alert delivered';

  @override
  String get healthLastFiredNone => 'None yet';

  @override
  String healthLastFiredValue(String when, String title) {
    return '$when: $title';
  }

  @override
  String get healthHistoryLink => 'See alert history';

  @override
  String healthOemSteps(String family) {
    String _temp0 = intl.Intl.selectLogic(family, {
      'xiaomi': 'Steps: Settings → Apps → Manage apps → this app → turn on Autostart, and set Battery saver to No restrictions.',
      'samsung': 'Steps: Settings → Battery → Background usage limits → Never sleeping apps → add this app.',
      'oppo': 'Steps: Settings → Battery → this app → allow background activity, and turn on Auto-launch under App management.',
      'vivo': 'Steps: iManager → App manager → Autostart → turn this app on; then Battery → High background power consumption → allow it.',
      'huawei': 'Steps: Settings → Apps → App launch → this app → Manage manually, and turn on all three switches.',
      'other': 'Steps: find the battery or app-launch settings for this app and allow it to run in the background and start automatically.',
    });
    return '$_temp0';
  }

  @override
  String get reportsTitle => 'Reports';

  @override
  String get moreReportsTile => 'Reports';

  @override
  String get reportsLoss => 'Expiry loss';

  @override
  String get reportsStock => 'Stock value';

  @override
  String get reportsDues => 'Dues aging';

  @override
  String get reportsByMonth => 'By month';

  @override
  String get reportsBySupplier => 'By supplier';

  @override
  String get reportsByMedicine => 'By medicine';

  @override
  String get reportsByCategory => 'By category';

  @override
  String get reportsRangeMonth => 'This month';

  @override
  String get reportsRange90 => 'Last 90 days';

  @override
  String get reportsRangeYear => 'This year';

  @override
  String get reportsRangeCustom => 'Choose dates';

  @override
  String get reportsIncludeDamaged => 'Include damaged stock';

  @override
  String reportsPeriod(String from, String to) {
    return '$from to $to';
  }

  @override
  String get reportsTotalLoss => 'Total loss';

  @override
  String get reportsTotalValue => 'Total value';

  @override
  String get reportsTotalOwed => 'Total owed';

  @override
  String reportsUnpriced(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n batches have',
      one: '1 batch has',
    );
    return '$_temp0 no cost price, so the real figure is higher.';
  }

  @override
  String get reportsNothing => 'Nothing to show for this period.';

  @override
  String get reportsDetails => 'Details';

  @override
  String get reportsOpenSupplier => 'Open supplier';

  @override
  String reportsGeneratedOn(String date) {
    return 'Made on $date';
  }

  @override
  String get reportsShare => 'Share report';

  @override
  String get reportsShareCsv => 'Spreadsheet (CSV)';

  @override
  String get reportsSharePdf => 'PDF';

  @override
  String reportsLossTitle(String group) {
    return 'Expiry loss, $group';
  }

  @override
  String reportsStockTitle(String group) {
    return 'Stock value, $group';
  }

  @override
  String get reportsDuesTitle => 'Dues aging';

  @override
  String reportsStockAsOf(String date) {
    return 'Stock on hand, valued at cost, as of $date';
  }

  @override
  String reportsDuesAsOf(String date) {
    return 'Unpaid supplier invoices as of $date';
  }

  @override
  String get colMonth => 'Month';

  @override
  String get colSupplier => 'Supplier';

  @override
  String get colMedicine => 'Medicine';

  @override
  String get colCategory => 'Category';

  @override
  String get colQuantity => 'Quantity';

  @override
  String get colBatches => 'Batches';

  @override
  String get colValue => 'Value';

  @override
  String get colBatch => 'Batch';

  @override
  String get colExpiry => 'Expiry';

  @override
  String get colDate => 'Date';

  @override
  String get colType => 'Type';

  @override
  String get colReference => 'Reference';

  @override
  String get colInvoiced => 'Invoiced';

  @override
  String get colPaidCredited => 'Paid / credited';

  @override
  String get colBalance => 'Balance';

  @override
  String get colTotal => 'Total';

  @override
  String get colNoCategory => 'No category';

  @override
  String get colNoSupplier => 'No supplier';

  @override
  String get agingCurrent => 'Not yet due';

  @override
  String get aging1to30 => '1-30 days late';

  @override
  String get aging31to60 => '31-60 days late';

  @override
  String get aging61to90 => '61-90 days late';

  @override
  String get agingOver90 => 'Over 90 days late';

  @override
  String get statementAction => 'Statement';

  @override
  String statementTitle(String supplier) {
    return 'Statement: $supplier';
  }

  @override
  String get statementInvoice => 'Invoice';

  @override
  String get statementPayment => 'Payment';

  @override
  String get statementCredit => 'Credit';

  @override
  String get statementOpening => 'Opening balance';

  @override
  String get statementClosing => 'Closing balance';

  @override
  String statementTotals(String invoiced, String paid, String credited) {
    return 'Invoiced $invoiced, paid $paid, credited $credited';
  }

  @override
  String get statementPickRange => 'Statement period';

  @override
  String get reportsPdfNote =>
      'The PDF cannot show some scripts (such as Bengali); the spreadsheet keeps all text.';
}
