import 'package:pharmacy_expiry_tracker/domain/contact_launcher.dart';

class FakeContactLauncher implements ContactLauncher {
  FakeContactLauncher({this.succeeds = true});

  bool succeeds;
  final calls = <String>[];

  @override
  Future<bool> call(String phone) async {
    calls.add('call:$phone');
    return succeeds;
  }

  @override
  Future<bool> sms(String phone) async {
    calls.add('sms:$phone');
    return succeeds;
  }

  @override
  Future<bool> whatsapp(String phone) async {
    calls.add('whatsapp:$phone');
    return succeeds;
  }

  @override
  Future<bool> email(String address) async {
    calls.add('email:$address');
    return succeeds;
  }
}
