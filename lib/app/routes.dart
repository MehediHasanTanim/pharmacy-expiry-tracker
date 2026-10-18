/// Route paths. Notification payloads carry one of these (technical design §9).
abstract final class Routes {
  static const home = '/home';
  static const stock = '/stock';
  static const expiry = '/expiry';
  static const suppliers = '/suppliers';
  static const more = '/more';
  static const reorder = '/more/reorder';
  static const settings = '/more/settings';
  static const backup = '/more/backup';
  static const onboarding = '/onboarding';
  static const alertLab = '/more/alert-lab';
  static const alertSettings = '/more/alerts';
  static const alertHealth = '/more/alerts/health';
  static const alertHistory = '/more/alerts/history';
  static const alertPermission = '/alerts/permission';

  /// e.g. `/expiry?bucket=d30&date=2026-11-17`.
  static String expiryFiltered({String? bucket, String? date}) {
    return Uri(
      path: expiry,
      queryParameters: {'bucket': ?bucket, 'date': ?date},
    ).toString();
  }
}
