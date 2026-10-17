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
}
