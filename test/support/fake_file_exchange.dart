import 'dart:io';

import 'package:pharmacy_expiry_tracker/domain/file_exchange.dart';

class FakeFileExchange implements FileExchange {
  /// What the share sheet "does" with the file: false = user dismissed it.
  bool accepts = true;

  /// The file the picker returns; null = user cancelled.
  File? toPick;

  final shared = <File>[];

  /// Bytes of each shared file, read at share time (the app may delete it
  /// later).
  final sharedBytes = <List<int>>[];

  @override
  Future<bool> share(File file, {required String subject}) async {
    shared.add(file);
    sharedBytes.add(file.readAsBytesSync());
    return accepts;
  }

  @override
  Future<File?> pick() async => toPick;
}
