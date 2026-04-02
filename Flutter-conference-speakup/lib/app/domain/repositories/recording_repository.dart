import 'package:video_confrence_app/core/network/api_client.dart';
import 'package:video_confrence_app/core/apis/endpoints.dart';
import 'package:video_confrence_app/app/domain/models/participant_model.dart';

class RecordingRepository {
  final _api = ApiClient.instance;

  Future<List<RecordingModel>> getRecordings() async {
    final res = await _api.get(ApiEndpoints.recordings);
    final list = res.data['data'] as List;
    return list.map((e) => RecordingModel.fromJson(e)).toList();
  }

  Future<RecordingModel> getById(String id) async {
    final res = await _api.get(ApiEndpoints.recording(id));
    return RecordingModel.fromJson(res.data['data']);
  }

  Future<String> getDownloadUrl(String id) async {
    final res = await _api.get(ApiEndpoints.recordingDownload(id));
    return res.data['data']['url'] as String;
  }

  Future<void> delete(String id) =>
      _api.delete(ApiEndpoints.recording(id));

  Future<void> startRecording(String meetingId) =>
      _api.post(ApiEndpoints.startRecording(meetingId));

  Future<void> stopRecording(String meetingId) =>
      _api.post(ApiEndpoints.stopRecording(meetingId));
}
