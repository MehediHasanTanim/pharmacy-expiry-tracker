import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/expiry_bucket.dart';

enum ExpirySort {
  soonest,
  valueAtRisk,
  name;

  /// Stable name used in settings storage.
  String get stored => switch (this) {
    ExpirySort.soonest => 'soonest',
    ExpirySort.valueAtRisk => 'value',
    ExpirySort.name => 'name',
  };

  static ExpirySort fromStored(String v) => ExpirySort.values.firstWhere(
    (e) => e.stored == v,
    orElse: () => ExpirySort.soonest,
  );
}

/// Which batches the Expiry tab lists (EXP-4).
@immutable
class ExpiryFilter {
  const ExpiryFilter({
    this.bucket,
    this.category,
    this.form,
    this.supplierId,
    this.query = '',
    this.hideHandled = false,
  });

  final ExpiryBucket? bucket;
  final String? category;
  final DosageForm? form;
  final String? supplierId;

  /// Matches medicine name/generic/strength or batch number.
  final String query;

  /// Hides batches marked handled (expired ones always stay visible).
  final bool hideHandled;

  /// Filters other than the bucket chips and the free-text search.
  bool get hasSheetFilters =>
      category != null || form != null || supplierId != null || hideHandled;

  bool get isActive => hasSheetFilters || bucket != null || query.isNotEmpty;

  ExpiryFilter copyWith({
    ExpiryBucket? bucket,
    String? query,
    bool clearBucket = false,
  }) {
    return ExpiryFilter(
      bucket: clearBucket ? null : bucket ?? this.bucket,
      category: category,
      form: form,
      supplierId: supplierId,
      query: query ?? this.query,
      hideHandled: hideHandled,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ExpiryFilter &&
      other.bucket == bucket &&
      other.category == category &&
      other.form == form &&
      other.supplierId == supplierId &&
      other.query == query &&
      other.hideHandled == hideHandled;

  @override
  int get hashCode =>
      Object.hash(bucket, category, form, supplierId, query, hideHandled);
}

/// Everything the expiry queries depend on.
@immutable
class ExpiryQuery {
  const ExpiryQuery({
    required this.today,
    this.globalWindowDays = 90,
    this.thresholds = const [30, 60, 90],
    this.filter = const ExpiryFilter(),
    this.sort = ExpirySort.soonest,
  });

  final DateTime today;

  /// Near-expiry window for medicines without their own override.
  final int globalWindowDays;
  final List<int> thresholds;
  final ExpiryFilter filter;
  final ExpirySort sort;

  @override
  bool operator ==(Object other) =>
      other is ExpiryQuery &&
      other.today == today &&
      other.globalWindowDays == globalWindowDays &&
      listEquals(other.thresholds, thresholds) &&
      other.filter == filter &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
    today,
    globalWindowDays,
    Object.hashAll(thresholds),
    filter,
    sort,
  );
}

/// One batch on the Expiry tab.
@immutable
class ExpiryItem {
  const ExpiryItem({
    required this.batch,
    required this.medicine,
    required this.daysLeft,
    required this.bucket,
  });

  final Batch batch;
  final Medicine medicine;

  /// Negative once expired.
  final int daysLeft;
  final ExpiryBucket bucket;

  ExpiryDate get expiry => batch.expiry;

  /// Cost of the stock still on hand, or null when no cost price is known.
  Money? get valueAtRisk => batch.costPrice?.times(batch.quantityOnHand);

  bool get isExpired => daysLeft < 0;
}

/// Position after the last row of a page (keyset pagination).
@immutable
class ExpiryCursor {
  const ExpiryCursor(this.key, this.id);

  final String key;
  final String id;
}

@immutable
class ExpiryPage {
  const ExpiryPage(this.items, {this.next});

  final List<ExpiryItem> items;

  /// Null when this was the last page.
  final ExpiryCursor? next;
}

/// Sum of stock value, noting how many batches had no cost price.
@immutable
class ValueAtRisk {
  const ValueAtRisk({this.total = Money.zero, this.missingCost = 0});

  final Money total;

  /// Batches that could not be valued.
  final int missingCost;

  /// True when [total] understates the value because some prices are missing.
  bool get isPartial => missingCost > 0;

  @override
  bool operator ==(Object other) =>
      other is ValueAtRisk &&
      other.total == total &&
      other.missingCost == missingCost;

  @override
  int get hashCode => Object.hash(total, missingCost);
}

/// Counts per urgency bucket plus total value, ignoring the bucket filter so
/// the header chips always show every bucket.
@immutable
class ExpirySummary {
  const ExpirySummary({
    this.counts = const {},
    this.value = const ValueAtRisk(),
  });

  final Map<ExpiryBucket, int> counts;
  final ValueAtRisk value;

  int count(ExpiryBucket b) => counts[b] ?? 0;

  int get total => counts.values.fold(0, (a, b) => a + b);

  @override
  bool operator ==(Object other) =>
      other is ExpirySummary &&
      mapEquals(other.counts, counts) &&
      other.value == value;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(counts.entries.map((e) => Object.hash(e.key, e.value))),
    value,
  );
}

/// A batch's alert suppression state, captured so a change can be undone.
@immutable
class AlertState {
  const AlertState({this.snoozedUntil, this.handledAt});

  final DateTime? snoozedUntil;
  final DateTime? handledAt;
}
