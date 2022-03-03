// 📦 Package imports:
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:retrofit/retrofit.dart';

// 🌎 Project imports:
import 'package:flutter_github_search/api/data/search_result.dart';
import 'package:flutter_github_search/api/dio.dart';

part 'search_api.g.dart';

@RestApi(baseUrl: 'https://api.github.com')
abstract class SearchApi {
  factory SearchApi(Dio dio) = _SearchApi;
  factory SearchApi.withReader(Reader reader) => SearchApi(reader(dioProvider));

  @GET('/search/repositories')
  Future<SearchResult> search(
    @Query('q') String query,
    @Query('page') int page,
  );
}
