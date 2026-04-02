import 'package:video_confrence_app/core/network/api_client.dart';
import 'package:video_confrence_app/core/apis/endpoints.dart';

class RoomRepository {
  final _api = ApiClient.instance;

  Future<Map<String, dynamic>> getRoomState(String id) async {
    final res = await _api.get(ApiEndpoints.roomState(id));
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<void> updateSettings(String id, Map<String, dynamic> settings) =>
      _api.put(ApiEndpoints.roomSettings(id), data: settings);

  Future<void> muteAll(String id) =>
      _api.post(ApiEndpoints.roomMuteAll(id));

  Future<List<Map<String, dynamic>>> getActiveRooms() async {
    final res = await _api.get(ApiEndpoints.activeRooms);
    return (res.data['data'] as List).cast<Map<String, dynamic>>();
  }
}
