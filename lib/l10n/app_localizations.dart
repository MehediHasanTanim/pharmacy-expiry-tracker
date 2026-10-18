import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Expiry Tracker'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get tabStock;

  /// No description provided for @tabExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get tabExpiry;

  /// No description provided for @tabSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get tabSuppliers;

  /// No description provided for @tabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// No description provided for @emptyHome.
  ///
  /// In en, this message translates to:
  /// **'Your dashboard will appear here'**
  String get emptyHome;

  /// No description provided for @emptyStock.
  ///
  /// In en, this message translates to:
  /// **'No medicines yet'**
  String get emptyStock;

  /// No description provided for @emptyExpiry.
  ///
  /// In en, this message translates to:
  /// **'Nothing is near expiry'**
  String get emptyExpiry;

  /// No description provided for @emptySuppliers.
  ///
  /// In en, this message translates to:
  /// **'No suppliers yet'**
  String get emptySuppliers;

  /// No description provided for @emptyMore.
  ///
  /// In en, this message translates to:
  /// **'Settings and reports will appear here'**
  String get emptyMore;

  /// No description provided for @bucketExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get bucketExpired;

  /// No description provided for @bucketD30.
  ///
  /// In en, this message translates to:
  /// **'30 days or less'**
  String get bucketD30;

  /// No description provided for @bucketD60.
  ///
  /// In en, this message translates to:
  /// **'31 to 60 days'**
  String get bucketD60;

  /// No description provided for @bucketD90.
  ///
  /// In en, this message translates to:
  /// **'61 to 90 days'**
  String get bucketD90;

  /// No description provided for @bucketOk.
  ///
  /// In en, this message translates to:
  /// **'More than 90 days'**
  String get bucketOk;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get actionArchive;

  /// No description provided for @actionRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get actionRestore;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get actionDiscard;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @stockSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search medicines or batch numbers'**
  String get stockSearchHint;

  /// No description provided for @stockShowArchived.
  ///
  /// In en, this message translates to:
  /// **'Show archived'**
  String get stockShowArchived;

  /// No description provided for @stockAddStock.
  ///
  /// In en, this message translates to:
  /// **'Add stock'**
  String get stockAddStock;

  /// No description provided for @stockEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Add your first medicine'**
  String get stockEmptyCta;

  /// No description provided for @stockEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a medicine, then receive its batches to start tracking expiry.'**
  String get stockEmptyBody;

  /// No description provided for @stockNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get stockNoResults;

  /// No description provided for @sectionMedicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get sectionMedicines;

  /// No description provided for @sectionBatches.
  ///
  /// In en, this message translates to:
  /// **'Batches'**
  String get sectionBatches;

  /// No description provided for @searchRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchRecent;

  /// No description provided for @searchClearRecent.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClearRecent;

  /// No description provided for @archivedBadge.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedBadge;

  /// No description provided for @noStock.
  ///
  /// In en, this message translates to:
  /// **'No stock'**
  String get noStock;

  /// No description provided for @medicineNew.
  ///
  /// In en, this message translates to:
  /// **'New medicine'**
  String get medicineNew;

  /// No description provided for @medicineEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit medicine'**
  String get medicineEdit;

  /// No description provided for @fieldBrandName.
  ///
  /// In en, this message translates to:
  /// **'Brand name'**
  String get fieldBrandName;

  /// No description provided for @fieldGenericName.
  ///
  /// In en, this message translates to:
  /// **'Generic name'**
  String get fieldGenericName;

  /// No description provided for @fieldStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength (e.g. 500 mg)'**
  String get fieldStrength;

  /// No description provided for @fieldDosageForm.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get fieldDosageForm;

  /// No description provided for @fieldUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get fieldUnit;

  /// No description provided for @fieldPackSize.
  ///
  /// In en, this message translates to:
  /// **'Pack size'**
  String get fieldPackSize;

  /// No description provided for @fieldManufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get fieldManufacturer;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get fieldCategory;

  /// No description provided for @fieldReorderLevel.
  ///
  /// In en, this message translates to:
  /// **'Reorder level'**
  String get fieldReorderLevel;

  /// No description provided for @fieldReorderHelp.
  ///
  /// In en, this message translates to:
  /// **'Remind me to reorder when stock falls below this'**
  String get fieldReorderHelp;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// No description provided for @errBrandRequired.
  ///
  /// In en, this message translates to:
  /// **'Brand name is required'**
  String get errBrandRequired;

  /// No description provided for @errNonNegativeInt.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number, 0 or more'**
  String get errNonNegativeInt;

  /// No description provided for @errPositiveInt.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number above 0'**
  String get errPositiveInt;

  /// No description provided for @duplicateMedicineTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicate'**
  String get duplicateMedicineTitle;

  /// No description provided for @duplicateMedicineBody.
  ///
  /// In en, this message translates to:
  /// **'A medicine with the same name, strength and form already exists.'**
  String get duplicateMedicineBody;

  /// No description provided for @duplicateSaveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get duplicateSaveAnyway;

  /// No description provided for @duplicateViewExisting.
  ///
  /// In en, this message translates to:
  /// **'View existing'**
  String get duplicateViewExisting;

  /// No description provided for @medicineArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive this medicine?'**
  String get medicineArchiveTitle;

  /// No description provided for @medicineArchiveBody.
  ///
  /// In en, this message translates to:
  /// **'It will be hidden from lists and stop alerting. History is kept and you can restore it later.'**
  String get medicineArchiveBody;

  /// No description provided for @formDosageTablet.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get formDosageTablet;

  /// No description provided for @formDosageCapsule.
  ///
  /// In en, this message translates to:
  /// **'Capsule'**
  String get formDosageCapsule;

  /// No description provided for @formDosageSyrup.
  ///
  /// In en, this message translates to:
  /// **'Syrup'**
  String get formDosageSyrup;

  /// No description provided for @formDosageInjection.
  ///
  /// In en, this message translates to:
  /// **'Injection'**
  String get formDosageInjection;

  /// No description provided for @formDosageOintment.
  ///
  /// In en, this message translates to:
  /// **'Ointment'**
  String get formDosageOintment;

  /// No description provided for @formDosageDrops.
  ///
  /// In en, this message translates to:
  /// **'Drops'**
  String get formDosageDrops;

  /// No description provided for @formDosageOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get formDosageOther;

  /// No description provided for @unitStrip.
  ///
  /// In en, this message translates to:
  /// **'Strip'**
  String get unitStrip;

  /// No description provided for @unitBox.
  ///
  /// In en, this message translates to:
  /// **'Box'**
  String get unitBox;

  /// No description provided for @unitBottle.
  ///
  /// In en, this message translates to:
  /// **'Bottle'**
  String get unitBottle;

  /// No description provided for @unitVial.
  ///
  /// In en, this message translates to:
  /// **'Vial'**
  String get unitVial;

  /// No description provided for @unitPiece.
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get unitPiece;

  /// No description provided for @detailBatches.
  ///
  /// In en, this message translates to:
  /// **'Batches'**
  String get detailBatches;

  /// No description provided for @detailNoBatches.
  ///
  /// In en, this message translates to:
  /// **'No batches yet'**
  String get detailNoBatches;

  /// No description provided for @detailAddBatch.
  ///
  /// In en, this message translates to:
  /// **'Add batch'**
  String get detailAddBatch;

  /// No description provided for @detailOnHandLabel.
  ///
  /// In en, this message translates to:
  /// **'On hand'**
  String get detailOnHandLabel;

  /// No description provided for @detailReorderLabel.
  ///
  /// In en, this message translates to:
  /// **'Reorder level'**
  String get detailReorderLabel;

  /// No description provided for @batchNew.
  ///
  /// In en, this message translates to:
  /// **'Receive batch'**
  String get batchNew;

  /// No description provided for @batchEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit batch'**
  String get batchEdit;

  /// No description provided for @fieldBatchNumber.
  ///
  /// In en, this message translates to:
  /// **'Batch number'**
  String get fieldBatchNumber;

  /// No description provided for @fieldQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get fieldQuantity;

  /// No description provided for @fieldCostPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost price (optional)'**
  String get fieldCostPrice;

  /// No description provided for @fieldSellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling price (optional)'**
  String get fieldSellingPrice;

  /// No description provided for @fieldReceivedDate.
  ///
  /// In en, this message translates to:
  /// **'Received on'**
  String get fieldReceivedDate;

  /// No description provided for @saveAndAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Save & add another'**
  String get saveAndAddAnother;

  /// No description provided for @errBatchRequired.
  ///
  /// In en, this message translates to:
  /// **'Batch number is required'**
  String get errBatchRequired;

  /// No description provided for @errExpiryRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the expiry date'**
  String get errExpiryRequired;

  /// No description provided for @errExpiryInvalid.
  ///
  /// In en, this message translates to:
  /// **'That is not a valid date'**
  String get errExpiryInvalid;

  /// No description provided for @errQuantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity above 0'**
  String get errQuantityRequired;

  /// No description provided for @errPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount like 12.50'**
  String get errPrice;

  /// No description provided for @quantityLockedHint.
  ///
  /// In en, this message translates to:
  /// **'To change quantity, use Adjust stock'**
  String get quantityLockedHint;

  /// No description provided for @batchSaved.
  ///
  /// In en, this message translates to:
  /// **'Batch saved'**
  String get batchSaved;

  /// No description provided for @batchMergedInfo.
  ///
  /// In en, this message translates to:
  /// **'Quantity added to the existing batch'**
  String get batchMergedInfo;

  /// No description provided for @duplicateBatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch already exists'**
  String get duplicateBatchTitle;

  /// No description provided for @duplicateBatchExact.
  ///
  /// In en, this message translates to:
  /// **'This medicine already has this batch number with the same expiry. Add the quantity to it?'**
  String get duplicateBatchExact;

  /// No description provided for @duplicateBatchDiffers.
  ///
  /// In en, this message translates to:
  /// **'This medicine already has a batch with this number but a different expiry. Add to it, or keep it as a separate batch?'**
  String get duplicateBatchDiffers;

  /// No description provided for @duplicateBatchAddTo.
  ///
  /// In en, this message translates to:
  /// **'Add to existing'**
  String get duplicateBatchAddTo;

  /// No description provided for @duplicateBatchSeparate.
  ///
  /// In en, this message translates to:
  /// **'Create separate'**
  String get duplicateBatchSeparate;

  /// No description provided for @expiryLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get expiryLabel;

  /// No description provided for @expiryMonth.
  ///
  /// In en, this message translates to:
  /// **'MM'**
  String get expiryMonth;

  /// No description provided for @expiryYear.
  ///
  /// In en, this message translates to:
  /// **'YYYY'**
  String get expiryYear;

  /// No description provided for @expiryDay.
  ///
  /// In en, this message translates to:
  /// **'DD'**
  String get expiryDay;

  /// No description provided for @expiryExactToggle.
  ///
  /// In en, this message translates to:
  /// **'Exact date'**
  String get expiryExactToggle;

  /// No description provided for @expiryWarnPast.
  ///
  /// In en, this message translates to:
  /// **'This date is already in the past'**
  String get expiryWarnPast;

  /// No description provided for @expiryWarnFar.
  ///
  /// In en, this message translates to:
  /// **'This is more than 10 years away. Check the date.'**
  String get expiryWarnFar;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusDepleted.
  ///
  /// In en, this message translates to:
  /// **'Depleted'**
  String get statusDepleted;

  /// No description provided for @statusReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get statusReturned;

  /// No description provided for @statusDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Discarded'**
  String get statusDiscarded;

  /// No description provided for @adjustTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust stock'**
  String get adjustTitle;

  /// No description provided for @adjustReasonSold.
  ///
  /// In en, this message translates to:
  /// **'Sold / used'**
  String get adjustReasonSold;

  /// No description provided for @adjustReasonDamaged.
  ///
  /// In en, this message translates to:
  /// **'Damaged'**
  String get adjustReasonDamaged;

  /// No description provided for @adjustReasonExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired, discarded'**
  String get adjustReasonExpired;

  /// No description provided for @adjustReasonReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned to supplier'**
  String get adjustReasonReturned;

  /// No description provided for @adjustReasonCorrection.
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get adjustReasonCorrection;

  /// No description provided for @adjustReasonReceived.
  ///
  /// In en, this message translates to:
  /// **'Received more'**
  String get adjustReasonReceived;

  /// No description provided for @adjustReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get adjustReasonOther;

  /// No description provided for @adjustQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get adjustQuantity;

  /// No description provided for @adjustAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adjustAll;

  /// No description provided for @adjustNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get adjustNote;

  /// No description provided for @adjustCorrectionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get adjustCorrectionAdd;

  /// No description provided for @adjustCorrectionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get adjustCorrectionRemove;

  /// No description provided for @adjustApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get adjustApply;

  /// No description provided for @adjustConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Write off stock?'**
  String get adjustConfirmTitle;

  /// No description provided for @adjustErrTooMany.
  ///
  /// In en, this message translates to:
  /// **'Only {available} on hand'**
  String adjustErrTooMany(Object available);

  /// No description provided for @adjustHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get adjustHistory;

  /// No description provided for @adjustNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No changes yet'**
  String get adjustNoHistory;

  /// No description provided for @batchDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch'**
  String get batchDetailTitle;

  /// No description provided for @batchDetailExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get batchDetailExpiry;

  /// No description provided for @batchDetailReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get batchDetailReceived;

  /// No description provided for @batchDetailCost.
  ///
  /// In en, this message translates to:
  /// **'Cost price'**
  String get batchDetailCost;

  /// No description provided for @batchDetailSelling.
  ///
  /// In en, this message translates to:
  /// **'Selling price'**
  String get batchDetailSelling;

  /// No description provided for @batchDetailNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get batchDetailNotes;

  /// No description provided for @batchDetailOnHand.
  ///
  /// In en, this message translates to:
  /// **'On hand'**
  String get batchDetailOnHand;

  /// No description provided for @batchDetailLifetime.
  ///
  /// In en, this message translates to:
  /// **'Received in total'**
  String get batchDetailLifetime;

  /// No description provided for @batchDetailWriteOff.
  ///
  /// In en, this message translates to:
  /// **'Value written off'**
  String get batchDetailWriteOff;

  /// No description provided for @devTools.
  ///
  /// In en, this message translates to:
  /// **'Developer tools'**
  String get devTools;

  /// No description provided for @devSeed.
  ///
  /// In en, this message translates to:
  /// **'Add demo data'**
  String get devSeed;

  /// No description provided for @devSeedBody.
  ///
  /// In en, this message translates to:
  /// **'Adds 5,000 medicines and about 10,000 batches. This can take a few seconds.'**
  String get devSeedBody;

  /// No description provided for @devSeedDone.
  ///
  /// In en, this message translates to:
  /// **'Demo data added'**
  String get devSeedDone;

  /// No description provided for @stockOnHand.
  ///
  /// In en, this message translates to:
  /// **'{count} on hand'**
  String stockOnHand(int count);

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Expires today} =1{1 day left} other{{count} days left}}'**
  String daysLeft(int count);

  /// No description provided for @expiredAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Expired 1 day ago} other{Expired {count} days ago}}'**
  String expiredAgo(int count);

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String expiresOn(String date);

  /// No description provided for @batchTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{qty} on hand · {date}'**
  String batchTileSubtitle(int qty, String date);

  /// No description provided for @adjustDelta.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unit} other{{count} units}}'**
  String adjustDelta(int count);

  /// No description provided for @adjustConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Write off {quantity} of batch {batch}? This is recorded as a loss.'**
  String adjustConfirmBody(String quantity, String batch);

  /// No description provided for @batchBy.
  ///
  /// In en, this message translates to:
  /// **'Batch {number}'**
  String batchBy(String number);

  /// No description provided for @chipAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get chipAll;

  /// No description provided for @chipExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get chipExpired;

  /// No description provided for @chip30.
  ///
  /// In en, this message translates to:
  /// **'0–30 d'**
  String get chip30;

  /// No description provided for @chip60.
  ///
  /// In en, this message translates to:
  /// **'31–60 d'**
  String get chip60;

  /// No description provided for @chip90.
  ///
  /// In en, this message translates to:
  /// **'61–90 d'**
  String get chip90;

  /// No description provided for @chipLater.
  ///
  /// In en, this message translates to:
  /// **'91+ d'**
  String get chipLater;

  /// No description provided for @expiryEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Batches close to expiry will show up here.'**
  String get expiryEmptyHint;

  /// No description provided for @expiryNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No batches match these filters'**
  String get expiryNoMatches;

  /// No description provided for @expiryClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get expiryClearFilters;

  /// No description provided for @expirySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search name or batch number'**
  String get expirySearchHint;

  /// No description provided for @expirySectionExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired · remove from shelf'**
  String get expirySectionExpired;

  /// No description provided for @expiryValueNone.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get expiryValueNone;

  /// No description provided for @expiryHandled.
  ///
  /// In en, this message translates to:
  /// **'Handled'**
  String get expiryHandled;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter and sort'**
  String get filterTitle;

  /// No description provided for @filterSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get filterSortBy;

  /// No description provided for @sortSoonest.
  ///
  /// In en, this message translates to:
  /// **'Soonest expiry'**
  String get sortSoonest;

  /// No description provided for @sortValue.
  ///
  /// In en, this message translates to:
  /// **'Highest value at risk'**
  String get sortValue;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @filterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filterCategory;

  /// No description provided for @filterForm.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get filterForm;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterHideHandled.
  ///
  /// In en, this message translates to:
  /// **'Hide handled batches'**
  String get filterHideHandled;

  /// No description provided for @filterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filterReset;

  /// No description provided for @filterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get filterApply;

  /// No description provided for @actionSold.
  ///
  /// In en, this message translates to:
  /// **'Sold or adjust quantity'**
  String get actionSold;

  /// No description provided for @actionDiscardAll.
  ///
  /// In en, this message translates to:
  /// **'Discard remaining stock'**
  String get actionDiscardAll;

  /// No description provided for @actionSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze alerts'**
  String get actionSnooze;

  /// No description provided for @actionHandled.
  ///
  /// In en, this message translates to:
  /// **'Mark as handled'**
  String get actionHandled;

  /// No description provided for @actionUnhandled.
  ///
  /// In en, this message translates to:
  /// **'Mark as not handled'**
  String get actionUnhandled;

  /// No description provided for @actionOpenBatch.
  ///
  /// In en, this message translates to:
  /// **'Open batch'**
  String get actionOpenBatch;

  /// No description provided for @snoozeTitle.
  ///
  /// In en, this message translates to:
  /// **'Snooze alerts for this batch'**
  String get snoozeTitle;

  /// No description provided for @snooze1d.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get snooze1d;

  /// No description provided for @snooze3d.
  ///
  /// In en, this message translates to:
  /// **'In 3 days'**
  String get snooze3d;

  /// No description provided for @snooze1w.
  ///
  /// In en, this message translates to:
  /// **'In 1 week'**
  String get snooze1w;

  /// No description provided for @snackHandled.
  ///
  /// In en, this message translates to:
  /// **'Marked as handled'**
  String get snackHandled;

  /// No description provided for @snackUnhandled.
  ///
  /// In en, this message translates to:
  /// **'Marked as not handled'**
  String get snackUnhandled;

  /// No description provided for @snackUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get snackUndo;

  /// No description provided for @tooltipFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter and sort'**
  String get tooltipFilter;

  /// No description provided for @tooltipSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tooltipSearch;

  /// No description provided for @tooltipSelect.
  ///
  /// In en, this message translates to:
  /// **'Select batches'**
  String get tooltipSelect;

  /// No description provided for @selectCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get selectCancel;

  /// No description provided for @discardSelected.
  ///
  /// In en, this message translates to:
  /// **'Discard selected'**
  String get discardSelected;

  /// No description provided for @expiryValueAtRisk.
  ///
  /// In en, this message translates to:
  /// **'Value at risk: {amount}'**
  String expiryValueAtRisk(String amount);

  /// No description provided for @expiryValuePartial.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 batch has no price} other{{count} batches have no price}}'**
  String expiryValuePartial(int count);

  /// No description provided for @expiryEmptyDays.
  ///
  /// In en, this message translates to:
  /// **'Nothing expires within {days} days.'**
  String expiryEmptyDays(int days);

  /// No description provided for @snoozeNext.
  ///
  /// In en, this message translates to:
  /// **'Until the next alert ({date})'**
  String snoozeNext(String date);

  /// No description provided for @snackSnoozed.
  ///
  /// In en, this message translates to:
  /// **'Alerts snoozed until {date}'**
  String snackSnoozed(String date);

  /// No description provided for @snackDiscarded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 batch discarded} other{{count} batches discarded}}'**
  String snackDiscarded(int count);

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @bulkDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Write off the remaining stock of 1 batch? This is recorded as a loss.} other{Write off the remaining stock of {count} batches? This is recorded as a loss.}}'**
  String bulkDiscardBody(int count);

  /// No description provided for @rowValue.
  ///
  /// In en, this message translates to:
  /// **'Value: {amount}'**
  String rowValue(String amount);

  /// No description provided for @rowSnoozed.
  ///
  /// In en, this message translates to:
  /// **'Snoozed until {date}'**
  String rowSnoozed(String date);

  /// No description provided for @rowSection.
  ///
  /// In en, this message translates to:
  /// **'{label}, {count}'**
  String rowSection(String label, int count);

  /// No description provided for @alertLeadTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Expires today} =1{Expires tomorrow} other{Expiry in {count} days}}'**
  String alertLeadTitle(int count);

  /// No description provided for @alertMixedTitle.
  ///
  /// In en, this message translates to:
  /// **'Batches nearing expiry'**
  String get alertMixedTitle;

  /// No description provided for @alertBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 batch} other{{count} batches}}: {items}{more, plural, =0{} other{ and {more} more}}'**
  String alertBody(int count, String items, int more);

  /// No description provided for @alertItem.
  ///
  /// In en, this message translates to:
  /// **'{name} ({batch})'**
  String alertItem(String name, String batch);

  /// No description provided for @alertDigestTitle.
  ///
  /// In en, this message translates to:
  /// **'Expiry digest'**
  String get alertDigestTitle;

  /// No description provided for @alertDigestBody.
  ///
  /// In en, this message translates to:
  /// **'{near, plural, =0{Nothing expiring soon} =1{1 batch expiring soon} other{{near} batches expiring soon}} · {expired, plural, =0{none expired} =1{1 expired on the shelf} other{{expired} expired on the shelf}}'**
  String alertDigestBody(int near, int expired);

  /// No description provided for @alertDigestGeneric.
  ///
  /// In en, this message translates to:
  /// **'Open the app to review today\'s expiry actions.'**
  String get alertDigestGeneric;

  /// No description provided for @alertTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Test alert'**
  String get alertTestTitle;

  /// No description provided for @alertTestBody.
  ///
  /// In en, this message translates to:
  /// **'Expiry alerts are working on this device.'**
  String get alertTestBody;

  /// No description provided for @alertCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert history'**
  String get alertCenterTitle;

  /// No description provided for @alertCenterEmpty.
  ///
  /// In en, this message translates to:
  /// **'No alerts yet'**
  String get alertCenterEmpty;

  /// No description provided for @alertCenterMissed.
  ///
  /// In en, this message translates to:
  /// **'Delivered or missed while the app was closed'**
  String get alertCenterMissed;

  /// No description provided for @alertSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert settings'**
  String get alertSettingsTitle;

  /// No description provided for @alertSettingsLeadTimes.
  ///
  /// In en, this message translates to:
  /// **'Alert before expiry'**
  String get alertSettingsLeadTimes;

  /// No description provided for @alertSettingsLeadHelp.
  ///
  /// In en, this message translates to:
  /// **'Days before expiry to alert. 0 is the expiry day.'**
  String get alertSettingsLeadHelp;

  /// No description provided for @alertSettingsAddLead.
  ///
  /// In en, this message translates to:
  /// **'Add days'**
  String get alertSettingsAddLead;

  /// No description provided for @alertSettingsLeadDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Days before expiry'**
  String get alertSettingsLeadDialogTitle;

  /// No description provided for @alertSettingsLeadInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number from 0 to 365'**
  String get alertSettingsLeadInvalid;

  /// No description provided for @alertSettingsDigest.
  ///
  /// In en, this message translates to:
  /// **'Daily digest'**
  String get alertSettingsDigest;

  /// No description provided for @alertSettingsDigestTime.
  ///
  /// In en, this message translates to:
  /// **'Alert time'**
  String get alertSettingsDigestTime;

  /// No description provided for @alertSettingsSkipEmpty.
  ///
  /// In en, this message translates to:
  /// **'Skip the digest when nothing is due'**
  String get alertSettingsSkipEmpty;

  /// No description provided for @alertSettingsQuiet.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get alertSettingsQuiet;

  /// No description provided for @alertSettingsQuietFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get alertSettingsQuietFrom;

  /// No description provided for @alertSettingsQuietTo.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get alertSettingsQuietTo;

  /// No description provided for @alertSettingsHealth.
  ///
  /// In en, this message translates to:
  /// **'Alert health'**
  String get alertSettingsHealth;

  /// No description provided for @alertSettingsHealthSub.
  ///
  /// In en, this message translates to:
  /// **'Check that alerts can reach you'**
  String get alertSettingsHealthSub;

  /// No description provided for @healthTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert health'**
  String get healthTitle;

  /// No description provided for @healthNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get healthNotifications;

  /// No description provided for @healthExactAlarms.
  ///
  /// In en, this message translates to:
  /// **'Exact alarms'**
  String get healthExactAlarms;

  /// No description provided for @healthBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery optimisation'**
  String get healthBattery;

  /// No description provided for @healthNextAlert.
  ///
  /// In en, this message translates to:
  /// **'Next alert'**
  String get healthNextAlert;

  /// No description provided for @healthPending.
  ///
  /// In en, this message translates to:
  /// **'Scheduled alerts'**
  String get healthPending;

  /// No description provided for @healthLastPlanned.
  ///
  /// In en, this message translates to:
  /// **'Last checked'**
  String get healthLastPlanned;

  /// No description provided for @healthAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get healthAllowed;

  /// No description provided for @healthBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get healthBlocked;

  /// No description provided for @healthNotApplicable.
  ///
  /// In en, this message translates to:
  /// **'Not needed'**
  String get healthNotApplicable;

  /// No description provided for @healthUnrestricted.
  ///
  /// In en, this message translates to:
  /// **'Unrestricted'**
  String get healthUnrestricted;

  /// No description provided for @healthRestricted.
  ///
  /// In en, this message translates to:
  /// **'Restricted — alerts may be delayed'**
  String get healthRestricted;

  /// No description provided for @healthNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get healthNone;

  /// No description provided for @healthNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get healthNever;

  /// No description provided for @healthSendTest.
  ///
  /// In en, this message translates to:
  /// **'Send test alert'**
  String get healthSendTest;

  /// No description provided for @healthTestScheduled.
  ///
  /// In en, this message translates to:
  /// **'A test alert will arrive in a few seconds. Close the app to try it.'**
  String get healthTestScheduled;

  /// No description provided for @healthOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get healthOpenSettings;

  /// No description provided for @healthOpenBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery settings'**
  String get healthOpenBattery;

  /// No description provided for @healthRefresh.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get healthRefresh;

  /// No description provided for @healthOemTip.
  ///
  /// In en, this message translates to:
  /// **'On {brand} phones, also allow the app to start automatically and exclude it from battery saving, otherwise the system may stop alerts.'**
  String healthOemTip(String brand);

  /// No description provided for @permissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Get expiry alerts'**
  String get permissionTitle;

  /// No description provided for @permissionBody.
  ///
  /// In en, this message translates to:
  /// **'The app can warn you before medicines expire, even when it is closed and offline. To do that it needs permission to show notifications.'**
  String get permissionBody;

  /// No description provided for @permissionAllow.
  ///
  /// In en, this message translates to:
  /// **'Turn on alerts'**
  String get permissionAllow;

  /// No description provided for @permissionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get permissionNotNow;

  /// No description provided for @permissionBannerAsk.
  ///
  /// In en, this message translates to:
  /// **'Turn on expiry alerts so nothing expires unnoticed.'**
  String get permissionBannerAsk;

  /// No description provided for @permissionBannerDenied.
  ///
  /// In en, this message translates to:
  /// **'Alerts are off — expiry warnings will not reach you.'**
  String get permissionBannerDenied;

  /// No description provided for @permissionBannerAction.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get permissionBannerAction;

  /// No description provided for @permissionBannerSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get permissionBannerSettings;

  /// No description provided for @healthMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String healthMinutes(int minutes);

  /// No description provided for @leadChip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{On expiry day} =1{1 day before} other{{count} days before}}'**
  String leadChip(int count);

  /// No description provided for @healthLastError.
  ///
  /// In en, this message translates to:
  /// **'The last check failed. Tap \"Check again\".'**
  String get healthLastError;

  /// No description provided for @healthOsPending.
  ///
  /// In en, this message translates to:
  /// **'{count} waiting in the system'**
  String healthOsPending(int count);

  /// No description provided for @alertSettingsNoLeads.
  ///
  /// In en, this message translates to:
  /// **'No lead-time alerts. Add at least one to be warned before expiry.'**
  String get alertSettingsNoLeads;

  /// No description provided for @alertCenterOpenHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to review'**
  String get alertCenterOpenHint;

  /// No description provided for @alertTimeHelp.
  ///
  /// In en, this message translates to:
  /// **'Digest and lead-time alerts arrive around this time.'**
  String get alertTimeHelp;

  /// No description provided for @alertPayTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Payment due today} =1{Payment due tomorrow} other{Payment due in {count} days}}'**
  String alertPayTitle(int count);

  /// No description provided for @alertPayMixedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments coming due'**
  String get alertPayMixedTitle;

  /// No description provided for @alertOverdueTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Payment overdue} other{Payments overdue}}'**
  String alertOverdueTitle(int count);

  /// No description provided for @alertPayBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 invoice} other{{count} invoices}}: {items}{more, plural, =0{} other{ and {more} more}} · {total}'**
  String alertPayBody(int count, String items, int more, String total);

  /// No description provided for @alertPayItem.
  ///
  /// In en, this message translates to:
  /// **'{supplier} {amount}'**
  String alertPayItem(String supplier, String amount);

  /// No description provided for @supplierSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search suppliers'**
  String get supplierSearchHint;

  /// No description provided for @supplierSortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get supplierSortName;

  /// No description provided for @supplierSortBalance.
  ///
  /// In en, this message translates to:
  /// **'Amount owed'**
  String get supplierSortBalance;

  /// No description provided for @supplierSortDue.
  ///
  /// In en, this message translates to:
  /// **'Next due'**
  String get supplierSortDue;

  /// No description provided for @supplierAdd.
  ///
  /// In en, this message translates to:
  /// **'Add supplier'**
  String get supplierAdd;

  /// No description provided for @supplierEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the suppliers you buy from to track what you owe them.'**
  String get supplierEmptyBody;

  /// No description provided for @supplierEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Add your first supplier'**
  String get supplierEmptyCta;

  /// No description provided for @supplierNew.
  ///
  /// In en, this message translates to:
  /// **'New supplier'**
  String get supplierNew;

  /// No description provided for @supplierEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit supplier'**
  String get supplierEdit;

  /// No description provided for @supplierShowArchived.
  ///
  /// In en, this message translates to:
  /// **'Show archived'**
  String get supplierShowArchived;

  /// No description provided for @fieldSupplierName.
  ///
  /// In en, this message translates to:
  /// **'Supplier name'**
  String get fieldSupplierName;

  /// No description provided for @fieldContactPerson.
  ///
  /// In en, this message translates to:
  /// **'Contact person'**
  String get fieldContactPerson;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get fieldPhone;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get fieldAddress;

  /// No description provided for @fieldTaxId.
  ///
  /// In en, this message translates to:
  /// **'Tax / licence ID'**
  String get fieldTaxId;

  /// No description provided for @fieldPaymentTerms.
  ///
  /// In en, this message translates to:
  /// **'Payment terms (days)'**
  String get fieldPaymentTerms;

  /// No description provided for @fieldPaymentTermsHelp.
  ///
  /// In en, this message translates to:
  /// **'Used to suggest a due date on new invoices'**
  String get fieldPaymentTermsHelp;

  /// No description provided for @errSupplierRequired.
  ///
  /// In en, this message translates to:
  /// **'Supplier name is required'**
  String get errSupplierRequired;

  /// No description provided for @errEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get errEmailInvalid;

  /// No description provided for @errTermsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number of days, 0 or more'**
  String get errTermsInvalid;

  /// No description provided for @supplierArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive this supplier?'**
  String get supplierArchiveTitle;

  /// No description provided for @supplierArchiveBody.
  ///
  /// In en, this message translates to:
  /// **'They will disappear from lists and pickers. What you owe them and its reminders stay.'**
  String get supplierArchiveBody;

  /// No description provided for @duesOwed.
  ///
  /// In en, this message translates to:
  /// **'Owed'**
  String get duesOwed;

  /// No description provided for @duesOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get duesOverdue;

  /// No description provided for @duesNextDue.
  ///
  /// In en, this message translates to:
  /// **'Next due'**
  String get duesNextDue;

  /// No description provided for @duesNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing owed'**
  String get duesNone;

  /// No description provided for @duesAllClear.
  ///
  /// In en, this message translates to:
  /// **'All paid up'**
  String get duesAllClear;

  /// No description provided for @badgeOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get badgeOverdue;

  /// No description provided for @contactCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get contactCall;

  /// No description provided for @contactSms.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get contactSms;

  /// No description provided for @contactWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get contactWhatsapp;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactEmail;

  /// No description provided for @contactFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open that app on this device.'**
  String get contactFailed;

  /// No description provided for @contactCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to the clipboard'**
  String get contactCopied;

  /// No description provided for @ledgerInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get ledgerInvoices;

  /// No description provided for @ledgerPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get ledgerPayments;

  /// No description provided for @ledgerCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get ledgerCredits;

  /// No description provided for @ledgerNoInvoices.
  ///
  /// In en, this message translates to:
  /// **'No invoices yet'**
  String get ledgerNoInvoices;

  /// No description provided for @ledgerNoPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get ledgerNoPayments;

  /// No description provided for @ledgerNoCredits.
  ///
  /// In en, this message translates to:
  /// **'No credits yet'**
  String get ledgerNoCredits;

  /// No description provided for @actionAddInvoice.
  ///
  /// In en, this message translates to:
  /// **'Add invoice'**
  String get actionAddInvoice;

  /// No description provided for @actionRecordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get actionRecordPayment;

  /// No description provided for @actionRecordCredit.
  ///
  /// In en, this message translates to:
  /// **'Record credit'**
  String get actionRecordCredit;

  /// No description provided for @actionSnoozeReminders.
  ///
  /// In en, this message translates to:
  /// **'Snooze reminders'**
  String get actionSnoozeReminders;

  /// No description provided for @actionClearSnooze.
  ///
  /// In en, this message translates to:
  /// **'Resume reminders'**
  String get actionClearSnooze;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @statusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get statusUnpaid;

  /// No description provided for @statusPartial.
  ///
  /// In en, this message translates to:
  /// **'Part paid'**
  String get statusPartial;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @invoiceNew.
  ///
  /// In en, this message translates to:
  /// **'New invoice'**
  String get invoiceNew;

  /// No description provided for @invoiceEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit invoice'**
  String get invoiceEdit;

  /// No description provided for @fieldInvoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice number (optional)'**
  String get fieldInvoiceNumber;

  /// No description provided for @fieldInvoiceDate.
  ///
  /// In en, this message translates to:
  /// **'Invoice date'**
  String get fieldInvoiceDate;

  /// No description provided for @fieldDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get fieldDueDate;

  /// No description provided for @fieldInvoiceTotal.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get fieldInvoiceTotal;

  /// No description provided for @fieldInvoiceNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldInvoiceNotes;

  /// No description provided for @noDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get noDueDate;

  /// No description provided for @clearDueDate.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearDueDate;

  /// No description provided for @errAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above 0, like 185.50'**
  String get errAmountInvalid;

  /// No description provided for @errDueBeforeInvoice.
  ///
  /// In en, this message translates to:
  /// **'The due date cannot be before the invoice date'**
  String get errDueBeforeInvoice;

  /// No description provided for @invoiceDueFromTerms.
  ///
  /// In en, this message translates to:
  /// **'Due date set from the supplier\'s payment terms'**
  String get invoiceDueFromTerms;

  /// No description provided for @invoiceDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoiceDetailTitle;

  /// No description provided for @invoiceTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get invoiceTotalLabel;

  /// No description provided for @invoicePaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get invoicePaidLabel;

  /// No description provided for @invoiceCreditedLabel.
  ///
  /// In en, this message translates to:
  /// **'Credited'**
  String get invoiceCreditedLabel;

  /// No description provided for @invoiceBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Still owed'**
  String get invoiceBalanceLabel;

  /// No description provided for @invoiceDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get invoiceDueLabel;

  /// No description provided for @invoiceDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Dated'**
  String get invoiceDateLabel;

  /// No description provided for @invoiceDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this invoice?'**
  String get invoiceDeleteTitle;

  /// No description provided for @invoiceDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It has no payments. Received batches stay but are no longer linked to it.'**
  String get invoiceDeleteBody;

  /// No description provided for @invoiceHasPayments.
  ///
  /// In en, this message translates to:
  /// **'Delete its payments and credits first.'**
  String get invoiceHasPayments;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get paymentTitle;

  /// No description provided for @fieldPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get fieldPaymentAmount;

  /// No description provided for @fieldPaymentDate.
  ///
  /// In en, this message translates to:
  /// **'Paid on'**
  String get fieldPaymentDate;

  /// No description provided for @fieldPaymentReference.
  ///
  /// In en, this message translates to:
  /// **'Reference (optional)'**
  String get fieldPaymentReference;

  /// No description provided for @fieldPaymentApplyTo.
  ///
  /// In en, this message translates to:
  /// **'Apply to'**
  String get fieldPaymentApplyTo;

  /// No description provided for @paymentOldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest due first'**
  String get paymentOldestFirst;

  /// No description provided for @paymentMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get paymentMethodBank;

  /// No description provided for @paymentMethodMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile wallet'**
  String get paymentMethodMobile;

  /// No description provided for @paymentMethodCheque.
  ///
  /// In en, this message translates to:
  /// **'Cheque'**
  String get paymentMethodCheque;

  /// No description provided for @paymentMethodOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get paymentMethodOther;

  /// No description provided for @paymentSaved.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded'**
  String get paymentSaved;

  /// No description provided for @paymentOverTitle.
  ///
  /// In en, this message translates to:
  /// **'More than is owed'**
  String get paymentOverTitle;

  /// No description provided for @paymentOverCredit.
  ///
  /// In en, this message translates to:
  /// **'Record the extra as a credit'**
  String get paymentOverCredit;

  /// No description provided for @paymentDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete this payment?'**
  String get paymentDelete;

  /// No description provided for @creditTitle.
  ///
  /// In en, this message translates to:
  /// **'Record credit'**
  String get creditTitle;

  /// No description provided for @fieldCreditAmount.
  ///
  /// In en, this message translates to:
  /// **'Credit amount'**
  String get fieldCreditAmount;

  /// No description provided for @fieldCreditNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get fieldCreditNote;

  /// No description provided for @creditSaved.
  ///
  /// In en, this message translates to:
  /// **'Credit recorded'**
  String get creditSaved;

  /// No description provided for @creditGeneral.
  ///
  /// In en, this message translates to:
  /// **'General credit'**
  String get creditGeneral;

  /// No description provided for @snoozeRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Snooze payment reminders'**
  String get snoozeRemindersTitle;

  /// No description provided for @dueDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a due for this delivery?'**
  String get dueDialogTitle;

  /// No description provided for @dueDialogYes.
  ///
  /// In en, this message translates to:
  /// **'Add invoice'**
  String get dueDialogYes;

  /// No description provided for @dueDialogNo.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get dueDialogNo;

  /// No description provided for @fieldSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get fieldSupplier;

  /// No description provided for @supplierNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get supplierNone;

  /// No description provided for @fieldPreferredSupplier.
  ///
  /// In en, this message translates to:
  /// **'Preferred supplier'**
  String get fieldPreferredSupplier;

  /// No description provided for @alertSettingsPayments.
  ///
  /// In en, this message translates to:
  /// **'Supplier payments'**
  String get alertSettingsPayments;

  /// No description provided for @alertSettingsPayLead.
  ///
  /// In en, this message translates to:
  /// **'Remind before the due date'**
  String get alertSettingsPayLead;

  /// No description provided for @alertSettingsOverdueEvery.
  ///
  /// In en, this message translates to:
  /// **'Remind when overdue'**
  String get alertSettingsOverdueEvery;

  /// No description provided for @overdueEveryOff.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get overdueEveryOff;

  /// No description provided for @snackReminderSnoozed.
  ///
  /// In en, this message translates to:
  /// **'Reminders snoozed until {date}'**
  String snackReminderSnoozed(Object date);

  /// No description provided for @snackReminderResumed.
  ///
  /// In en, this message translates to:
  /// **'Reminders resumed'**
  String get snackReminderResumed;

  /// No description provided for @supplierOwedLine.
  ///
  /// In en, this message translates to:
  /// **'Owed {amount}'**
  String supplierOwedLine(String amount);

  /// No description provided for @supplierOverdueLine.
  ///
  /// In en, this message translates to:
  /// **'{amount} overdue'**
  String supplierOverdueLine(String amount);

  /// No description provided for @supplierNextDueLine.
  ///
  /// In en, this message translates to:
  /// **'Next due {date}'**
  String supplierNextDueLine(String date);

  /// No description provided for @duesOverdueCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 invoice} other{{count} invoices}}'**
  String duesOverdueCount(int count);

  /// No description provided for @invoiceListTitle.
  ///
  /// In en, this message translates to:
  /// **'{number}'**
  String invoiceListTitle(String number);

  /// No description provided for @invoiceNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoice {number}'**
  String invoiceNumberLabel(String number);

  /// No description provided for @invoiceNoNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice dated {date}'**
  String invoiceNoNumber(String date);

  /// No description provided for @invoiceBatchesLinked.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No batches linked} =1{1 batch linked} other{{count} batches linked}}'**
  String invoiceBatchesLinked(int count);

  /// No description provided for @invoiceDueIn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String invoiceDueIn(String date);

  /// No description provided for @paymentLine.
  ///
  /// In en, this message translates to:
  /// **'{amount} on {date}'**
  String paymentLine(String amount, String date);

  /// No description provided for @paymentOverBody.
  ///
  /// In en, this message translates to:
  /// **'You entered {entered} but only {owed} is owed. Record the extra {extra} as a credit on this supplier\'s account?'**
  String paymentOverBody(String entered, String owed, String extra);

  /// No description provided for @paymentSpread.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Applied to 1 invoice} other{Applied to {count} invoices}}'**
  String paymentSpread(int count);

  /// No description provided for @overdueEveryDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every day} other{Every {count} days}}'**
  String overdueEveryDays(int count);

  /// label
  ///
  /// In en, this message translates to:
  /// **'Credit on invoice'**
  String get creditForInvoice;

  /// No description provided for @contactCopyAction.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get contactCopyAction;

  /// No description provided for @creditTooMuch.
  ///
  /// In en, this message translates to:
  /// **'That is more than the {owed} still owed on this invoice.'**
  String creditTooMuch(String owed);

  /// No description provided for @batchDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get batchDone;

  /// No description provided for @dueDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Record what you owe {supplier} for this delivery so you are reminded to pay.'**
  String dueDialogBody(String supplier);

  /// No description provided for @alertReorderTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 medicine to reorder} other{{count} medicines to reorder}}'**
  String alertReorderTitle(int count);

  /// No description provided for @alertReorderBody.
  ///
  /// In en, this message translates to:
  /// **'{items}{more, plural, =0{} other{ and {more} more}}'**
  String alertReorderBody(String items, int more);

  /// No description provided for @alertReorderItem.
  ///
  /// In en, this message translates to:
  /// **'{name} ({left} left)'**
  String alertReorderItem(String name, int left);

  /// No description provided for @homeExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired on shelf'**
  String get homeExpired;

  /// No description provided for @homeExpiring30.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get homeExpiring30;

  /// No description provided for @homeReorder.
  ///
  /// In en, this message translates to:
  /// **'To reorder'**
  String get homeReorder;

  /// No description provided for @homeOverdueDues.
  ///
  /// In en, this message translates to:
  /// **'Overdue payments'**
  String get homeOverdueDues;

  /// No description provided for @homeWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Expiring this week'**
  String get homeWeekTitle;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeWeekEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing expires in the next 7 days.'**
  String get homeWeekEmpty;

  /// No description provided for @homeAtRisk.
  ///
  /// In en, this message translates to:
  /// **'Value at risk'**
  String get homeAtRisk;

  /// No description provided for @homeFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Start by adding a medicine'**
  String get homeFirstTitle;

  /// No description provided for @homeFirstBody.
  ///
  /// In en, this message translates to:
  /// **'Add a medicine and receive its first batch, and expiry alerts begin.'**
  String get homeFirstBody;

  /// No description provided for @homeAddMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add medicine'**
  String get homeAddMedicine;

  /// No description provided for @homeNoReorder.
  ///
  /// In en, this message translates to:
  /// **'All stocked'**
  String get homeNoReorder;

  /// No description provided for @homeAllGood.
  ///
  /// In en, this message translates to:
  /// **'Nothing needs attention'**
  String get homeAllGood;

  /// No description provided for @bannerReplanFailed.
  ///
  /// In en, this message translates to:
  /// **'Alerts could not be updated. Check again.'**
  String get bannerReplanFailed;

  /// No description provided for @bannerBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery saving may delay your alerts.'**
  String get bannerBattery;

  /// No description provided for @bannerCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get bannerCheck;

  /// No description provided for @reorderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reorder list'**
  String get reorderTitle;

  /// No description provided for @reorderEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to reorder'**
  String get reorderEmpty;

  /// No description provided for @reorderEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Medicines below their reorder level will show up here.'**
  String get reorderEmptyBody;

  /// No description provided for @reorderUnassigned.
  ///
  /// In en, this message translates to:
  /// **'No preferred supplier'**
  String get reorderUnassigned;

  /// No description provided for @reorderSuggested.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get reorderSuggested;

  /// No description provided for @reorderSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze reminders'**
  String get reorderSnooze;

  /// No description provided for @reorderResume.
  ///
  /// In en, this message translates to:
  /// **'Resume reminders'**
  String get reorderResume;

  /// No description provided for @snackReorderSnoozed.
  ///
  /// In en, this message translates to:
  /// **'Reorder reminders snoozed'**
  String get snackReorderSnoozed;

  /// No description provided for @snackReorderResumed.
  ///
  /// In en, this message translates to:
  /// **'Reorder reminders resumed'**
  String get snackReorderResumed;

  /// No description provided for @moreSectionAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get moreSectionAlerts;

  /// No description provided for @moreSectionStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get moreSectionStock;

  /// No description provided for @moreReorderTile.
  ///
  /// In en, this message translates to:
  /// **'Reorder list'**
  String get moreReorderTile;

  /// No description provided for @moreSettingsTile.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get moreSettingsTile;

  /// No description provided for @moreSectionApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get moreSectionApp;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get settingsPharmacy;

  /// No description provided for @fieldPharmacyName.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy name'**
  String get fieldPharmacyName;

  /// No description provided for @settingsExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get settingsExpiry;

  /// No description provided for @settingsWindow.
  ///
  /// In en, this message translates to:
  /// **'Near-expiry window'**
  String get settingsWindow;

  /// No description provided for @settingsWindowHelp.
  ///
  /// In en, this message translates to:
  /// **'Batches expiring within this many days appear on the Expiry tab.'**
  String get settingsWindowHelp;

  /// No description provided for @settingsBuckets.
  ///
  /// In en, this message translates to:
  /// **'Urgency groups'**
  String get settingsBuckets;

  /// No description provided for @settingsBucketsHelp.
  ///
  /// In en, this message translates to:
  /// **'Days at which batches move to the next group.'**
  String get settingsBucketsHelp;

  /// No description provided for @settingsBucketA.
  ///
  /// In en, this message translates to:
  /// **'Urgent up to'**
  String get settingsBucketA;

  /// No description provided for @settingsBucketB.
  ///
  /// In en, this message translates to:
  /// **'Soon up to'**
  String get settingsBucketB;

  /// No description provided for @settingsBucketC.
  ///
  /// In en, this message translates to:
  /// **'Later up to'**
  String get settingsBucketC;

  /// No description provided for @errBucketsOrder.
  ///
  /// In en, this message translates to:
  /// **'Each group must be longer than the one before.'**
  String get errBucketsOrder;

  /// No description provided for @settingsDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get settingsDisplay;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency symbol'**
  String get settingsCurrency;

  /// No description provided for @settingsCurrencyHelp.
  ///
  /// In en, this message translates to:
  /// **'Shown next to amounts. Leave empty for none.'**
  String get settingsCurrencyHelp;

  /// No description provided for @settingsDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get settingsDateFormat;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow the device'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @dateFormatDevice.
  ///
  /// In en, this message translates to:
  /// **'Device default'**
  String get dateFormatDevice;

  /// No description provided for @alertSettingsReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder reminders'**
  String get alertSettingsReorder;

  /// No description provided for @alertSettingsReorderEvery.
  ///
  /// In en, this message translates to:
  /// **'Remind again after'**
  String get alertSettingsReorderEvery;

  /// No description provided for @onbSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onbSkip;

  /// No description provided for @onbNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onbNext;

  /// No description provided for @onbBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onbBack;

  /// No description provided for @onbStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onbStart;

  /// No description provided for @onb1Title.
  ///
  /// In en, this message translates to:
  /// **'Never let medicine expire unnoticed'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In en, this message translates to:
  /// **'Record each batch with its expiry date. The app shows what is running out of time first.'**
  String get onb1Body;

  /// No description provided for @onb2Title.
  ///
  /// In en, this message translates to:
  /// **'Alerts that work offline'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In en, this message translates to:
  /// **'Reminders are scheduled on your phone, so they arrive even without a signal or with the app closed.'**
  String get onb2Body;

  /// No description provided for @onb3Title.
  ///
  /// In en, this message translates to:
  /// **'Keep track of dues and stock'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In en, this message translates to:
  /// **'See what you owe each supplier, get paid-by reminders, and know what to reorder.'**
  String get onb3Body;

  /// No description provided for @onbSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'About your pharmacy'**
  String get onbSetupTitle;

  /// No description provided for @onbSetupBody.
  ///
  /// In en, this message translates to:
  /// **'You can change all of this later in Settings.'**
  String get onbSetupBody;

  /// No description provided for @onbAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on expiry alerts'**
  String get onbAlertsTitle;

  /// No description provided for @onbAlertsBody.
  ///
  /// In en, this message translates to:
  /// **'The app needs permission to show notifications. Alerts stay on your phone.'**
  String get onbAlertsBody;

  /// No description provided for @onbDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'You are ready'**
  String get onbDoneTitle;

  /// No description provided for @onbDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first medicine and its batches to start tracking.'**
  String get onbDoneBody;

  /// No description provided for @onbAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add first medicine'**
  String get onbAddFirst;

  /// No description provided for @onbExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore the app'**
  String get onbExplore;

  /// No description provided for @homeBatchCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 batch} other{{count} batches}}'**
  String homeBatchCount(int count);

  /// No description provided for @homeMedicineCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 medicine} other{{count} medicines}}'**
  String homeMedicineCount(int count);

  /// No description provided for @homeInvoiceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 invoice} other{{count} invoices}}'**
  String homeInvoiceCount(int count);

  /// No description provided for @homeCardSemantics.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String homeCardSemantics(String label, String value);

  /// No description provided for @reorderLevelLine.
  ///
  /// In en, this message translates to:
  /// **'{usable} on hand · reorder at {level}'**
  String reorderLevelLine(int usable, int level);

  /// No description provided for @settingsWindowDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String settingsWindowDays(int count);

  /// No description provided for @onbStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onbStep(int current, int total);

  /// No description provided for @rowActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get rowActionsTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
