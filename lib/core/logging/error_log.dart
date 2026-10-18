import 'dart:io';

/// Local, bounded error log (S6-08). It never leaves the device on its own;
/// the user can export it as part of the diagnostics file.
///
/// Entries carry no user data: the error's type, a scrubbed message (quoted
/// text and long numbers removed, since those are where names, barcodes and
/// amounts would be) and the top of the stack trace.
class ErrorLog {
  ErrorLog(this.file, {DateTime Function()? now, this.maxBytes = 200 * 1024})
    : _now = now ?? DateTime.now;

  final File file;
  final int maxBytes;
  final DateTime Function() _now;

  static final _quoted = RegExp('(\'[^\']*\'|"[^"]*")');
  static final _withDigit = RegExp(r'[^\s,;:()\[\]{}]*\d[^\s,;:()\[\]{}]*');
  static final _path = RegExp(r'(/[\w.\-]+){3,}');

  /// Removes anything that could be user data from [message].
  static String scrub(String message) {
    var s = message.replaceAll(_quoted, '…').replaceAll(_path, '<path>');
    // Any word with a digit in it (lot numbers, barcodes, amounts, phone
    // numbers) goes too.
    s = s.replaceAll(_withDigit, '#').replaceAll(RegExp(r'\s+'), ' ').trim();
    return s.length > 240 ? '${s.substring(0, 240)}…' : s;
  }

  /// The lines of [trace] that point into our own code or the framework,
  /// reduced to `file:line`.
  static List<String> topFrames(StackTrace? trace, {int max = 5}) {
    if (trace == null) return const [];
    final out = <String>[];
    for (final line in trace.toString().split('\n')) {
      final m = RegExp(r'(package:[\w/.\-]+\.dart):(\d+)').firstMatch(line);
      if (m == null) continue;
      out.add('${m.group(1)}:${m.group(2)}');
      if (out.length == max) break;
    }
    return out;
  }

  /// Appends an entry. Never throws: logging must not make a failure worse.
  void record(String tag, Object error, [StackTrace? trace]) {
    try {
      _rotate();
      final frames = topFrames(trace);
      final line = StringBuffer()
        ..write(_now().toIso8601String())
        ..write(' [$tag] ')
        ..write(error.runtimeType)
        ..write(': ')
        ..write(scrub('$error'));
      if (frames.isNotEmpty) line.write(' @ ${frames.join(' < ')}');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('$line\n', mode: FileMode.append, flush: true);
    } on Object {
      // Ignored on purpose.
    }
  }

  void _rotate() {
    if (!file.existsSync() || file.lengthSync() < maxBytes) return;
    final old = File('${file.path}.1');
    if (old.existsSync()) old.deleteSync();
    file.renameSync(old.path);
  }

  /// The most recent [maxLines] entries, oldest first.
  List<String> recent({int maxLines = 100}) {
    try {
      final lines = <String>[];
      final old = File('${file.path}.1');
      if (old.existsSync()) lines.addAll(old.readAsLinesSync());
      if (file.existsSync()) lines.addAll(file.readAsLinesSync());
      return lines.length > maxLines
          ? lines.sublist(lines.length - maxLines)
          : lines;
    } on Object {
      return const [];
    }
  }

  void clear() {
    for (final f in [file, File('${file.path}.1')]) {
      if (f.existsSync()) f.deleteSync();
    }
  }
}
