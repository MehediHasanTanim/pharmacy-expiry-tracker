/// Runs `action` atomically: if it throws, every write inside is rolled back.
abstract interface class TransactionRunner {
  Future<T> run<T>(Future<T> Function() action);
}
