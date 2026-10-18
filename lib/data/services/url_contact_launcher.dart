import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/domain/contact_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

/// Phone numbers as they should appear in a link: digits and a leading `+`.
String dialable(String phone) {
  final trimmed = phone.trim();
  final plus = trimmed.startsWith('+') ? '+' : '';
  return plus + trimmed.replaceAll(RegExp('[^0-9]'), '');
}

/// WhatsApp links want the number as digits only, country code included.
String whatsappNumber(String phone) => phone.replaceAll(RegExp('[^0-9]'), '');

/// [ContactLauncher] using `url_launcher`.
class UrlContactLauncher implements ContactLauncher {
  const UrlContactLauncher();

  @override
  Future<bool> call(String phone) =>
      _open(Uri(scheme: 'tel', path: dialable(phone)));

  @override
  Future<bool> sms(String phone) =>
      _open(Uri(scheme: 'sms', path: dialable(phone)));

  @override
  Future<bool> whatsapp(String phone) =>
      _open(Uri.https('wa.me', '/${whatsappNumber(phone)}'), external: true);

  @override
  Future<bool> email(String address) =>
      _open(Uri(scheme: 'mailto', path: address.trim()));

  Future<bool> _open(Uri uri, {bool external = false}) async {
    try {
      return await launchUrl(
        uri,
        mode: external
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
      );
    } on Object catch (e) {
      // No app for the scheme, or the platform refused: report, don't crash.
      debugPrint('Could not open $uri: $e');
      return false;
    }
  }
}
