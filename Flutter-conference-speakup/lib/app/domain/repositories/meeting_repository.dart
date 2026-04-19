import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_conference_speakup/core/network/api_client.dart';
import 'package:flutter_conference_speakup/core/apis/endpoints.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';
import 'package:flutter_conference_speakup/app/domain/models/participant_model.dart';
import 'package:flutter_conference_speakup/app/domain/models/material_model.dart';

class MeetingRepository {
  final _api = ApiClient.instance;

  Future<List<MeetingModel>> listMeetings({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _api.get(ApiEndpoints.meetings, queryParameters: {
      'status': ?status,
      'page': page,
      'limit': limit,
    });
    final list = res.data['data']['meetings'] as List;
    return list.map((e) => MeetingModel.fromJson(e)).toList();
  }

  Future<MeetingModel> create(Map<String, dynamic> data) async {
    final res = await _api.post(ApiEndpoints.meetings, data: data);
    return MeetingModel.fromJson(res.data['data']['meeting']);
  }

  Future<MeetingModel> getById(String id) async {
    final res = await _api.get(ApiEndpoints.meeting(id));
    return MeetingModel.fromJson(res.data['data']['meeting']);
  }

  Future<MeetingModel> update(String id, Map<String, dynamic> data) async {
    final res = await _api.put(ApiEndpoints.meeting(id), data: data);
    return MeetingModel.fromJson(res.data['data']['meeting']);
  }

  Future<void> delete(String id) => _api.delete(ApiEndpoints.meeting(id));

  Future<MeetingModel> joinByCode(String code, {String? password}) async {
    final res = await _api.get(
      ApiEndpoints.joinByCode(code),
      queryParameters: {
        if (password != null && password.isNotEmpty) 'password': password,
      },
    );
    return MeetingModel.fromJson(res.data['data']['meeting']);
  }

  Future<MeetingModel> join(String meetingId, {String? password}) async {
    // POST join returns participant, not meeting — so join then fetch meeting
    await _api.post(ApiEndpoints.joinMeeting(meetingId), data: {
      'password': ?password,
    });
    return getById(meetingId);
  }

  /// Returns true if the meeting was auto-ended (e.g. 2-person call).
  Future<bool> leave(String meetingId) async {
    final res = await _api.post(ApiEndpoints.leaveMeeting(meetingId));
    return res.data['data']?['autoEnded'] == true;
  }

  Future<void> end(String meetingId) =>
      _api.post(ApiEndpoints.endMeeting(meetingId));

  Future<void> lock(String meetingId) =>
      _api.post(ApiEndpoints.lockMeeting(meetingId));

  Future<void> unlock(String meetingId) =>
      _api.post(ApiEndpoints.unlockMeeting(meetingId));

  Future<List<Participant>> getParticipants(String meetingId) async {
    final res = await _api.get(ApiEndpoints.meetingParticipants(meetingId));
    final list = res.data['data']['participants'] as List;
    return list.map((e) => Participant.fromJson(e)).toList();
  }

  Future<void> kickParticipant(String meetingId, String participantId, {bool ban = false, String? reason}) =>
      _api.post(ApiEndpoints.kickParticipant(meetingId, participantId), data: {
        'ban': ban,
        if (reason != null) 'reason': reason,
      });

  Future<void> banParticipant(String meetingId, String userId, {String? reason}) =>
      _api.post(ApiEndpoints.banParticipant(meetingId, userId), data: {
        if (reason != null) 'reason': reason,
      });

  Future<void> unbanParticipant(String meetingId, String userId) =>
      _api.delete(ApiEndpoints.unbanParticipant(meetingId, userId));

  /// Get LiveKit token for WebRTC connection.
  Future<String> getLiveKitToken(String meetingId) async {
    final res = await _api.get(ApiEndpoints.meetingToken(meetingId));
    return res.data['data']['token'] as String;
  }

  // ──────────── Materials ────────────

  Future<MeetingMaterialModel> uploadMaterial(
    String meetingId,
    File file, {
    void Function(int, int)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });
    final res = await _api.upload(
      ApiEndpoints.meetingMaterials(meetingId),
      formData: formData,
      onSendProgress: onProgress,
    );
    return MeetingMaterialModel.fromJson(res.data['data']['material']);
  }

  Future<List<MeetingMaterialModel>> getMaterials(String meetingId) async {
    final res = await _api.get(ApiEndpoints.meetingMaterials(meetingId));
    final list = res.data['data']['materials'] as List;
    return list.map((e) => MeetingMaterialModel.fromJson(e)).toList();
  }

  Future<MeetingMaterialModel> getMaterialById(String materialId) async {
    final res = await _api.get(ApiEndpoints.material(materialId));
    return MeetingMaterialModel.fromJson(res.data['data']['material']);
  }

  Future<void> deleteMaterial(String materialId) =>
      _api.delete(ApiEndpoints.material(materialId));

  /// Recreate a past meeting with optional overrides.
  Future<MeetingModel> recreate(String meetingId, {Map<String, dynamic>? overrides}) async {
    final res = await _api.post(
      ApiEndpoints.recreateMeeting(meetingId),
      data: overrides ?? {},
    );
    return MeetingModel.fromJson(res.data['data']['meeting']);
  }
}
