/// Why a backup could not be read or restored. The UI maps each to its own
/// plain-language message; none of them carries user data.
enum BackupFailureKind {
  /// The file is not one of our backups.
  notABackup,

  /// The backup is encrypted and no passphrase was given.
  needsPassphrase,

  /// The passphrase does not open the backup.
  wrongPassphrase,

  /// The file is damaged: bad archive, checksum mismatch, or a database that
  /// fails its integrity check.
  corrupt,

  /// Made by a newer version of the app, whose data this version may not
  /// understand.
  newerVersion,

  /// The swap of the database file failed; the previous data was put back.
  swapFailed,
}

class BackupException implements Exception {
  const BackupException(this.kind, [this.detail]);

  final BackupFailureKind kind;

  /// Technical detail for the log only (never shown, never user data).
  final String? detail;

  @override
  String toString() =>
      'BackupException(${kind.name}${detail == null ? '' : ': $detail'})';
}
