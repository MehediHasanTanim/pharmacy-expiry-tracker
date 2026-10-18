import 'package:pharmacy_expiry_tracker/domain/security/app_lock.dart';

class FakeBiometrics implements BiometricAuth {
  FakeBiometrics({this.available = false, this.succeeds = true});

  bool available;
  bool succeeds;
  int prompts = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate(String reason) async {
    prompts++;
    return succeeds;
  }
}
