// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_page_state.freezed.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState.uninitialized() = Uninitialized;

  const factory SearchState.searching() = Searching;

  factory SearchState.success({
    required List<RepositorySummary> repositories,
    required String query,
    required int page,
    required bool hasNext,
  }) = Success;

  const factory SearchState.fetchingNext({
    required List<RepositorySummary> repositories,
    required String query,
    required int page,
  }) = FetchingNext;

  const factory SearchState.fail() = Fail;

  const factory SearchState.empty() = Empty;
}

@freezed
class RepositorySummary with _$RepositorySummary {
  const factory RepositorySummary({
    required String owner,
    required String name,
    required String imageUrl,
  }) = _RepositorySummary;
}
