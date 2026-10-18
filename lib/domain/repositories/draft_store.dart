/// Small pieces of unfinished work that survive the app being closed.
abstract interface class DraftStore {
  Future<String?> load(String key);

  Future<void> save(String key, String value);

  Future<void> clear(String key);
}
