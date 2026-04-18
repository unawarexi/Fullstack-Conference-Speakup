import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';
import 'package:flutter_conference_speakup/app/domain/models/participant_model.dart';
import 'package:flutter_conference_speakup/app/domain/models/material_model.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/meeting_repository.dart';
import 'package:flutter_conference_speakup/core/db/hive.dart';

final meetingRepositoryProvider = Provider<MeetingRepository>((ref) {
  return MeetingRepository();
});

/// All meetings list (with optional status filter).
/// Uses keepAlive + 5-minute timer so tab switches don't re-fetch.
/// Falls back to Hive cache while the network request is in-flight.
final meetingsProvider = FutureProvider.family
    .autoDispose<List<MeetingModel>, String?>((ref, status) async {
  // Keep data alive for 5 minutes after all listeners are removed
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), link.close);
  ref.onDispose(timer.cancel);

  final cacheKey = 'meetings_${status ?? "all"}';

  // Return cached data immediately while the API call proceeds
  final cached = HiveService.getIfFresh(HiveService.meetingCache, cacheKey);
  if (cached != null && cached is List) {
    // Fire-and-forget: refresh in background, update cache
    ref.read(meetingRepositoryProvider).listMeetings(status: status).then(
      (fresh) {
        HiveService.putWithTTL(
          HiveService.meetingCache, cacheKey,
          fresh.map((m) => m.toJson()).toList(),
          ttlMinutes: 5,
        );
      },
      onError: (_) {},
    );
    return cached
        .map((e) => MeetingModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // No valid cache — fetch from API
  final meetings =
      await ref.read(meetingRepositoryProvider).listMeetings(status: status);
  HiveService.putWithTTL(
    HiveService.meetingCache, cacheKey,
    meetings.map((m) => m.toJson()).toList(),
    ttlMinutes: 5,
  );
  return meetings;
});

/// Single meeting by ID.
final meetingByIdProvider =
    FutureProvider.family.autoDispose<MeetingModel, String>((ref, id) {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 3), link.close);
  ref.onDispose(timer.cancel);
  return ref.read(meetingRepositoryProvider).getById(id);
});

/// Participants for a meeting.
final meetingParticipantsProvider =
    FutureProvider.family.autoDispose<List<Participant>, String>(
        (ref, meetingId) {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 3), link.close);
  ref.onDispose(timer.cancel);
  return ref.read(meetingRepositoryProvider).getParticipants(meetingId);
});

/// Materials for a meeting.
final meetingMaterialsProvider =
    FutureProvider.family.autoDispose<List<MeetingMaterialModel>, String>(
        (ref, meetingId) {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 3), link.close);
  ref.onDispose(timer.cancel);
  return ref.read(meetingRepositoryProvider).getMaterials(meetingId);
});

/// Currently active meeting room state.
final activeMeetingProvider =
    StateNotifierProvider<ActiveMeetingNotifier, MeetingRoomState>((ref) {
  return ActiveMeetingNotifier(ref);
});

class MeetingRoomState {
  final MeetingModel? meeting;
  final String? liveKitToken;
  final List<Participant> participants;
  final bool isMicOn;
  final bool isCameraOn;
  final bool isScreenSharing;
  final bool isHandRaised;
  final bool isRecording;
  final Duration elapsed;

  const MeetingRoomState({
    this.meeting,
    this.liveKitToken,
    this.participants = const [],
    this.isMicOn = true,
    this.isCameraOn = true,
    this.isScreenSharing = false,
    this.isHandRaised = false,
    this.isRecording = false,
    this.elapsed = Duration.zero,
  });

  bool get isInMeeting => meeting != null;

  MeetingRoomState copyWith({
    MeetingModel? meeting,
    String? liveKitToken,
    List<Participant>? participants,
    bool? isMicOn,
    bool? isCameraOn,
    bool? isScreenSharing,
    bool? isHandRaised,
    bool? isRecording,
    Duration? elapsed,
  }) =>
      MeetingRoomState(
        meeting: meeting ?? this.meeting,
        liveKitToken: liveKitToken ?? this.liveKitToken,
        participants: participants ?? this.participants,
        isMicOn: isMicOn ?? this.isMicOn,
        isCameraOn: isCameraOn ?? this.isCameraOn,
        isScreenSharing: isScreenSharing ?? this.isScreenSharing,
        isHandRaised: isHandRaised ?? this.isHandRaised,
        isRecording: isRecording ?? this.isRecording,
        elapsed: elapsed ?? this.elapsed,
      );
}

class ActiveMeetingNotifier extends StateNotifier<MeetingRoomState> {
  final Ref _ref;
  Timer? _elapsedTimer;

  ActiveMeetingNotifier(this._ref) : super(const MeetingRoomState());

  Future<void> joinMeeting(String meetingId, {String? password}) async {
    final repo = _ref.read(meetingRepositoryProvider);
    final meeting = await repo.join(meetingId, password: password);
    final token = await repo.getLiveKitToken(meetingId);
    final participants = await repo.getParticipants(meetingId);

    state = MeetingRoomState(
      meeting: meeting,
      liveKitToken: token,
      participants: participants,
    );
    _startElapsedTimer();
  }

  Future<void> joinByCode(String code, {String? password}) async {
    final repo = _ref.read(meetingRepositoryProvider);
    final meeting = await repo.joinByCode(code, password: password);
    final token = await repo.getLiveKitToken(meeting.id);
    final participants = await repo.getParticipants(meeting.id);

    state = MeetingRoomState(
      meeting: meeting,
      liveKitToken: token,
      participants: participants,
    );
    _startElapsedTimer();
  }

  Future<void> refreshParticipants() async {
    if (state.meeting == null) return;
    final participants = await _ref
        .read(meetingRepositoryProvider)
        .getParticipants(state.meeting!.id);
    state = state.copyWith(participants: participants);
  }

  void toggleMic() => state = state.copyWith(isMicOn: !state.isMicOn);
  void toggleCamera() => state = state.copyWith(isCameraOn: !state.isCameraOn);
  void toggleScreenShare() =>
      state = state.copyWith(isScreenSharing: !state.isScreenSharing);
  void toggleHandRaise() =>
      state = state.copyWith(isHandRaised: !state.isHandRaised);
  void toggleRecording() =>
      state = state.copyWith(isRecording: !state.isRecording);

  Future<void> leaveMeeting() async {
    if (state.meeting != null) {
      await _ref
          .read(meetingRepositoryProvider)
          .leave(state.meeting!.id);
    }
    _elapsedTimer?.cancel();
    state = const MeetingRoomState();
  }

  Future<void> endMeeting() async {
    if (state.meeting != null) {
      await _ref.read(meetingRepositoryProvider).end(state.meeting!.id);
    }
    _elapsedTimer?.cancel();
    state = const MeetingRoomState();
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsed: state.elapsed + const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }
}
