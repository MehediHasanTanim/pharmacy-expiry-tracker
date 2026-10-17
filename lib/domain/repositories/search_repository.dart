import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';

@immutable
class SearchResults {
  const SearchResults({this.medicines = const [], this.batches = const []});

  static const empty = SearchResults();

  final List<MedicineSummary> medicines;
  final List<BatchWithMedicine> batches;

  bool get isEmpty => medicines.isEmpty && batches.isEmpty;
}

abstract interface class SearchRepository {
  /// Finds medicines (brand/generic/strength) and batches (batch number).
  /// Results rank prefix matches, then word-prefix matches, then substring
  /// matches.
  Future<SearchResults> search(String query, {int limit = 30});
}

/// Recently submitted search terms, newest first.
abstract interface class RecentSearchesRepository {
  Future<List<String>> load();

  Future<void> add(String term);

  Future<void> clear();
}
