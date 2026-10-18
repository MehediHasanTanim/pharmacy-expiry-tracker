import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pharmacy_expiry_tracker/core/logging/error_log.dart';

void main() {
  late Directory dir;
  late ErrorLog log;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('errlog');
    log = ErrorLog(
      File(p.join(dir.path, 'logs', 'errors.log')),
      now: () => DateTime(2026, 10, 17, 9),
      maxBytes: 2000,
    );
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('records type, tag and time but scrubs user data', () {
    log.record(
      'ui',
      StateError(
        "Napa 500 mg 'Rahman Pharma' barcode 8901234567890 at /Users/tanim/Documents/db.sqlite",
      ),
    );
    final line = log.recent().single;
    expect(line, startsWith('2026-10-17T09:00:00.000 [ui] StateError: '));
    expect(line, isNot(contains('Rahman')));
    expect(line, isNot(contains('8901234567890')));
    expect(line, isNot(contains('tanim')));
    expect(line, contains('<path>'));
  });

  test('keeps only package frames from the stack', () {
    final trace = StackTrace.fromString('''
#0      main.<anonymous closure> (file:///Users/someone/project/test/x.dart:1:2)
#1      Foo.bar (package:pharmacy_expiry_tracker/data/foo.dart:42:7)
#2      Baz.qux (package:flutter/src/widgets/framework.dart:100:9)
''');
    expect(ErrorLog.topFrames(trace), [
      'package:pharmacy_expiry_tracker/data/foo.dart:42',
      'package:flutter/src/widgets/framework.dart:100',
    ]);
  });

  test('rotates so the log stays bounded', () {
    for (var i = 0; i < 100; i++) {
      log.record('t', StateError('failure number $i'));
    }
    final size =
        log.file.lengthSync() + File('${log.file.path}.1').lengthSync();
    expect(size, lessThan(4500));
    expect(log.recent(maxLines: 5), hasLength(5));
    expect(log.recent().last, contains('failure number #'));
  });

  test('never throws, even when the folder cannot be written', () {
    final bad = ErrorLog(File('/proc/definitely/not/writable/log.txt'));
    expect(() => bad.record('t', 'x'), returnsNormally);
    expect(bad.recent(), isEmpty);
  });

  test('clear removes everything', () {
    log
      ..record('t', 'x')
      ..clear();
    expect(log.recent(), isEmpty);
  });
}
