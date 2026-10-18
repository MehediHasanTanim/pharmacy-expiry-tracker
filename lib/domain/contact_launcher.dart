/// Opens other apps to reach a supplier (SUP-2). Each method returns whether
/// the request was handed to an app that could handle it.
abstract interface class ContactLauncher {
  Future<bool> call(String phone);

  Future<bool> sms(String phone);

  Future<bool> whatsapp(String phone);

  Future<bool> email(String address);
}
