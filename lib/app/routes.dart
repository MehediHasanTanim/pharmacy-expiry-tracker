/// Route paths. Notification payloads carry one of these (technical design §9).
abstract final class Routes {
  static const home = '/home';
  static const stock = '/stock';
  static const expiry = '/expiry';
  static const suppliers = '/suppliers';
  static const more = '/more';
  static const alertLab = '/more/alert-lab';

  /// e.g. `/expiry?bucket=d30&date=2026-11-17`.
  static String expiryFiltered({String? bucket, String? date}) {
    return Uri(
      path: expiry,
      queryParameters: {'bucket': ?bucket, 'date': ?date},
    ).toString();
  }
}
