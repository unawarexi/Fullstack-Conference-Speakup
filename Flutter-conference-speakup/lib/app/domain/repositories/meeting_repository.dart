import 'package:flutter_conference_speakup/core/network/api_client.dart';
import 'package:flutter_conference_speakup/core/apis/endpoints.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';
import 'package:flutter_conference_speakup/app/domain/models/participant_model.dart';

class MeetingRepository {
  final _api = ApiClient.instance;

  Future<List<MeetingModel>> listMeetings({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _api.get(ApiEndpoints.meetings, queryParameters: {
      if (status != null) 'status': status,
      'page': page,
      'limit': limit,
    });
    final list = res.data['data'] as List;
    return list.map((e) => MeetingModel.fromJson(e)).toList();
  }

  Future<MeetingModel> create(Map<String, dynamic> data) async {
    final res = await _api.post(ApiEndpoints.meetings, data: data);
    return MeetingModel.fromJson(res.data['data']);
  }

  Future<MeetingModel> getById(String id) async {
    final res = await _api.get(ApiEndpoints.meeting(id));
    return MeetingModel.fromJson(res.data['data']);
  }

  Future<MeetingModel> update(String id, Map<String, dynamic> data) async {
    final res = await _api.put(ApiEndpoints.meeting(id), data: data);
    return MeetingModel.fromJson(res.data['data']);
  }

  Future<void> delete(String id) => _api.delete(ApiEndpoints.meeting(id));

  Future<MeetingModel> joinByCode(String code) async {
    final res = await _api.get(ApiEndpoints.joinByCode(code));
    return MeetingModel.fromJson(res.data['data']);
  }

  Future<MeetingModel> join(String meetingId, {String? password}) async {
    final res = await _api.post(ApiEndpoints.joinMeeting(meetingId), data: {
      if (password != null) 'password': password,
    });
    return MeetingModel.fromJson(res.data['data']);
  }

  Future<void> leave(String meetingId) =>
      _api.post(ApiEndpoints.leaveMeeting(meetingId));

  Future<void> end(String meetingId) =>
      _api.post(ApiEndpoints.endMeeting(meetingId));

  Future<void> lock(String meetingId) =>
      _api.post(ApiEndpoints.lockMeeting(meetingId));

  Future<void> unlock(String meetingId) =>
      _api.post(ApiEndpoints.unlockMeeting(meetingId));

  Future<List<Participant>> getParticipants(String meetingId) async {
    final res = await _api.get(ApiEndpoints.meetingParticipants(meetingId));
    final list = res.data['data'] as List;
    return list.map((e) => Participant.fromJson(e)).toList();
  }

  Future<void> kickParticipant(String meetingId, String participantId) =>
      _api.post(ApiEndpoints.kickParticipant(meetingId, participantId));

  /// Get LiveKit token for WebRTC connection.
  Future<String> getLiveKitToken(String meetingId) async {
    final res = await _api.get(ApiEndpoints.meetingToken(meetingId));
    return res.data['data']['token'] as String;
  }
}
