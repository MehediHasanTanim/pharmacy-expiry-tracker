/// Notifications that offer a "Snooze 1 day" button carry what is needed to
/// show them again in their payload, because the button can be pressed with
/// the app closed (a background isolate that has only the payload). Plain
/// payloads are just the route.
const _sep = '\u0001';

String encodeActionPayload({
  required String? route,
  required String title,
  required String body,
  required String snoozeLabel,
}) => [route ?? '', title, body, snoozeLabel].join(_sep);

typedef ActionPayload = ({
  String? route,
  String title,
  String body,
  String snoozeLabel,
});

/// The parts of an encoded payload, or null for a plain route.
ActionPayload? decodeActionPayload(String? payload) {
  if (payload == null || !payload.contains(_sep)) return null;
  final p = payload.split(_sep);
  if (p.length != 4) return null;
  return (
    route: p[0].isEmpty ? null : p[0],
    title: p[1],
    body: p[2],
    snoozeLabel: p[3],
  );
}

/// The in-app route in any payload, encoded or plain.
String? routeOf(String? payload) {
  final decoded = decodeActionPayload(payload);
  return decoded == null ? payload : decoded.route;
}
