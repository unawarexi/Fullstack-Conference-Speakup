import 'package:video_confrence_app/core/network/api_client.dart';
import 'package:video_confrence_app/core/apis/endpoints.dart';
import 'package:video_confrence_app/app/domain/models/user_model.dart';
import 'package:video_confrence_app/app/domain/models/meeting_model.dart';

class SearchRepository {
  final _api = ApiClient.instance;

  /// Global search across users and meetings.
  Future<Map<String, dynamic>> globalSearch(String query) async {
    final res = await _api.get(ApiEndpoints.search, queryParameters: {
      'q': query,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final res = await _api.get(ApiEndpoints.searchUsers, queryParameters: {
      'q': query,
    });
    final list = res.data['data'] as List;
    return list.map((e) => UserModel.fromJson(e)).toList();
  }

  Future<List<MeetingModel>> searchMeetings(String query) async {
    final res = await _api.get(ApiEndpoints.searchMeetings, queryParameters: {
      'q': query,
    });
    final list = res.data['data'] as List;
    return list.map((e) => MeetingModel.fromJson(e)).toList();
  }
}
