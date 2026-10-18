import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pharmacy_expiry_tracker/domain/security/app_lock.dart';

/// [BiometricAuth] on top of the platform's local authentication. It accepts
/// the phone's screen lock as well as fingerprint or face, so a forgotten PIN
/// is never the end of the road.
class LocalBiometricAuth implements BiometricAuth {
  LocalBiometricAuth([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason);
    } on PlatformException {
      return false;
    }
  }
}
