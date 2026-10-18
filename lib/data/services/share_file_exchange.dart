import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:pharmacy_expiry_tracker/domain/file_exchange.dart';
import 'package:share_plus/share_plus.dart';

/// [FileExchange] backed by the platform share sheet and file picker.
class ShareFileExchange implements FileExchange {
  const ShareFileExchange();

  @override
  Future<bool> share(File file, {required String subject}) async {
    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: subject),
    );
    // Some platforms cannot tell; only an explicit dismissal counts as "no".
    return result.status != ShareResultStatus.dismissed;
  }

  @override
  Future<File?> pick() async {
    final picked = await FilePicker.pickFiles();
    if (picked.isEmpty) return null;
    final path = picked.first.path;
    return path == null ? null : File(path);
  }
}
