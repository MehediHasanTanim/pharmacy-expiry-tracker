import 'package:pharmacy_expiry_tracker/domain/entities/report.dart';

abstract interface class ReportRepository {
  /// Stock written off as expired (and optionally damaged) in [range], valued
  /// at cost, grouped by [group]. Largest loss first (months: newest first).
  Future<GroupedReport> expiryLoss(
    DateRange range,
    LossGroup group, {
    bool includeDamaged = false,
  });

  /// The write-offs behind one row of [expiryLoss] (`key` as in the row).
  Future<List<LossDetail>> expiryLossDetails(
    DateRange range,
    LossGroup group,
    String key, {
    bool includeDamaged = false,
  });

  /// Stock on hand (active, not discarded) valued at cost, grouped by
  /// [group]. Includes stock that has expired but is still on the shelf.
  Future<GroupedReport> stockValuation(ValuationGroup group);

  Future<List<StockDetail>> stockDetails(ValuationGroup group, String key);

  /// What is still owed to suppliers, by how overdue it is as of [today].
  Future<AgingReport> duesAging(DateTime today);
}
