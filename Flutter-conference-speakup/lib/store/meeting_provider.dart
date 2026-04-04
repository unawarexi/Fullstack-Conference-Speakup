import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';
import 'package:flutter_conference_speakup/app/domain/models/participant_model.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/meeting_repository.dart';
import 'package:flutter_conference_speakup/core/db/hive.dart';

final meetingRepositoryProvider = Provider<MeetingRepository>((ref) {
  return MeetingRepository();
});

/// All meetings list (with optional status filter).
final meetingsProvider = FutureProvider.family
    .autoDispose<List<MeetingModel>, String?>((ref, status) async {
  final meetings =
      await ref.read(meetingRepositoryProvider).listMeetings(status: status);
  // Cache meetings
  HiveService.meetingCache.put(
    'meetings_${status ?? "all"}',
    meetings.map((m) => m.toJson()).toList(),
  );
  return meetings;
});

/// Single meeting by ID.
final meetingByIdProvider =
    FutureProvider.family.autoDispose<MeetingModel, String>((ref, id) {
  return ref.read(meetingRepositoryProvider).getById(id);
});

/// Participants for a meeting.
final meetingParticipantsProvider =
    FutureProvider.family.autoDispose<List<Participant>, String>(
        (ref, meetingId) {
  return ref.read(meetingRepositoryProvider).getParticipants(meetingId);
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

  Future<void> joinByCode(String code) async {
    final repo = _ref.read(meetingRepositoryProvider);
    final meeting = await repo.joinByCode(code);
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
