import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:zylos/data/models/search_results.dart';
import 'package:zylos/repositories/search_repository.dart';

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepository(),
);

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<SearchResults>((ref) {
  final query = ref.watch(searchQueryProvider);
  return ref.watch(searchRepositoryProvider).search(query);
});
