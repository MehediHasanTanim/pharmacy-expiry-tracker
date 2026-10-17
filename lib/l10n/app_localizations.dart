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
