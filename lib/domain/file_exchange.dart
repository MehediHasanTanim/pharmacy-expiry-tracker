import 'dart:io';

/// Moving files in and out of the app: the share sheet and the file picker.
/// Replaced in tests.
abstract interface class FileExchange {
  /// Offers [file] through the system share sheet. Returns false when the user
  /// dismissed the sheet without choosing anything.
  Future<bool> share(File file, {required String subject});

  /// Lets the user choose a file. Null when they cancel.
  Future<File?> pick();
}
