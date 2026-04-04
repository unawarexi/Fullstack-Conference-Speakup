import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/search_repository.dart';
import 'package:flutter_conference_speakup/app/domain/models/user_model.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository();
});

/// Search query state.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Global search results.
final searchResultsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return {'users': <UserModel>[], 'meetings': <MeetingModel>[]};
  return ref.read(searchRepositoryProvider).globalSearch(query);
});

/// User search results.
final userSearchProvider =
    FutureProvider.family.autoDispose<List<UserModel>, String>((ref, query) {
  if (query.isEmpty) return Future.value([]);
  return ref.read(searchRepositoryProvider).searchUsers(query);
});

/// Meeting search results.
final meetingSearchProvider =
    FutureProvider.family.autoDispose<List<MeetingModel>, String>((ref, query) {
  if (query.isEmpty) return Future.value([]);
  return ref.read(searchRepositoryProvider).searchMeetings(query);
});
