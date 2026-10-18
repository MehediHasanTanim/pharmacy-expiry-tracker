/// The number on the app icon (HOM / S5-10): batches that need action.
abstract interface class AppBadge {
  /// Sets the icon badge; zero clears it. Best effort: a launcher or platform
  /// that cannot show badges simply ignores it.
  Future<void> setCount(int count);
}
