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
}
