// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 🌎 Project imports:
import 'package:flutter_github_search/api/data/search_result.dart';
import 'package:flutter_github_search/api/search_api.dart';
import 'package:flutter_github_search/ui/page/search/search_page_state.dart';

// 別ファイルの方が良いかも
final isSearchModeProvider = StateNotifierProvider<IsSearchModeNotifier, bool>(
  (ref) => IsSearchModeNotifier(),
);

class IsSearchModeNotifier extends StateNotifier<bool> {
  IsSearchModeNotifier() : super(false);

  void toggle() => state = !state;
}

final searchPageStateNotifierProvider =
    StateNotifierProvider.autoDispose<SearchPageStateNotifier, SearchState>(
        (ref) => SearchPageStateNotifier(ref.read));

class SearchPageStateNotifier extends StateNotifier<SearchState> {
  SearchPageStateNotifier(this._reader)
      : super(const SearchState.uninitialized());

  final Reader _reader;
  late final _searchApi = _reader(searchApiProvider);

  Future<void> searchRepositories(String query) async {
    if (state is Searching) {
      return;
    }

    state = const SearchState.searching();

    const page = 1;
    final SearchResult result;
    try {
      result = await _searchApi.search(query, page);
    } on Exception catch (e) {
      debugPrint('$e');
      state = const SearchState.fail();
      return;
    }

    if (result.items.isEmpty) {
      state = const SearchState.empty();
      return;
    }

    state = SearchState.success(
      repositories: result.repositories,
      query: query,
      page: page,
      hasNext: result.hasNext,
    );
  }

  Future<void> fetchNext() async {
    if (state is Searching || state is FetchingNext) {
      return;
    }

    final currentState = state.maybeMap(
      success: (value) => value,
      orElse: () {
        AssertionError();
      },
    )!;

    final query = currentState.query;
    final page = currentState.page + 1;
    state = SearchState.fetchingNext(
      repositories: currentState.repositories,
      query: query,
      page: page,
    );

    final SearchResult result;
    try {
      result = await _searchApi.search(query, page);
    } on Exception catch (e) {
      debugPrint('$e');
      state = SearchState.success(
        repositories: currentState.repositories,
        query: query,
        page: page,
        hasNext: false,
      );
      return;
    }

    state = SearchState.success(
      repositories: currentState.repositories + result.repositories,
      query: query,
      page: page,
      hasNext: result.hasNext,
    );
  }

  set debugState(SearchState state) {
    assert(() {
      this.state = state;
      return true;
    }(), '');
  }
}

extension Pagination on SearchResult {
  bool get hasNext => totalCount > items.length;

  List<RepositorySummary> get repositories => items
      .map((repo) => RepositorySummary(
            owner: repo.owner.login,
            name: repo.name,
            imageUrl: repo.owner.avatarUrl,
          ))
      .toList();
}
