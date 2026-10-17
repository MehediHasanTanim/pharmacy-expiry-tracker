import 'package:pharmacy_expiry_tracker/domain/entities/expiry.dart';

abstract interface class ExpiryRepository {
  /// One page of near-expiry and expired batches (active, still in stock),
  /// in the query's sort order. Pass the previous page's [ExpiryPage.next] as
  /// [after] for the following page.
  Future<ExpiryPage> fetchPage(
    ExpiryQuery query, {
    ExpiryCursor? after,
    int limit = 50,
  });

  /// Bucket counts and value at risk, ignoring the bucket filter. Re-emits
  /// when the underlying data changes.
  Stream<ExpirySummary> watchSummary(ExpiryQuery query);

  /// Emits whenever batches or medicines change, so lists can reload.
  Stream<void> watchChanges();

  /// Distinct medicine categories, for the filter sheet.
  Future<List<String>> categories();
}
