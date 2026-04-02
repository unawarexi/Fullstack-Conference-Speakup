import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_confrence_app/store/meeting_provider.dart';

void main() {
  group('MeetingRoomState', () {
    test('initial state has all defaults', () {
      const state = MeetingRoomState();
      expect(state.meeting, isNull);
      expect(state.liveKitToken, isNull);
      expect(state.participants, isEmpty);
      expect(state.isMicOn, true);
      expect(state.isCameraOn, true);
      expect(state.isScreenSharing, false);
      expect(state.isHandRaised, false);
      expect(state.isRecording, false);
      expect(state.elapsed, Duration.zero);
      expect(state.isInMeeting, false);
    });

    test('copyWith preserves unmodified fields', () {
      const state = MeetingRoomState();
      final updated = state.copyWith(isMicOn: false);
      expect(updated.isMicOn, false);
      expect(updated.isCameraOn, true); // unchanged
      expect(updated.isScreenSharing, false); // unchanged
    });

    test('copyWith modifies multiple fields', () {
      const state = MeetingRoomState();
      final updated = state.copyWith(
        isMicOn: false,
        isCameraOn: false,
        isHandRaised: true,
        elapsed: const Duration(seconds: 30),
      );
      expect(updated.isMicOn, false);
      expect(updated.isCameraOn, false);
      expect(updated.isHandRaised, true);
      expect(updated.elapsed, const Duration(seconds: 30));
    });
  });

  group('ActiveMeetingNotifier toggles', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('toggleMic flips isMicOn', () {
      final notifier = container.read(activeMeetingProvider.notifier);
      expect(container.read(activeMeetingProvider).isMicOn, true);
      notifier.toggleMic();
      expect(container.read(activeMeetingProvider).isMicOn, false);
      notifier.toggleMic();
      expect(container.read(activeMeetingProvider).isMicOn, true);
    });

    test('toggleCamera flips isCameraOn', () {
      final notifier = container.read(activeMeetingProvider.notifier);
      notifier.toggleCamera();
      expect(container.read(activeMeetingProvider).isCameraOn, false);
    });

    test('toggleScreenShare flips isScreenSharing', () {
      final notifier = container.read(activeMeetingProvider.notifier);
      notifier.toggleScreenShare();
      expect(container.read(activeMeetingProvider).isScreenSharing, true);
    });

    test('toggleHandRaise flips isHandRaised', () {
      final notifier = container.read(activeMeetingProvider.notifier);
      notifier.toggleHandRaise();
      expect(container.read(activeMeetingProvider).isHandRaised, true);
    });

    test('toggleRecording flips isRecording', () {
      final notifier = container.read(activeMeetingProvider.notifier);
      notifier.toggleRecording();
      expect(container.read(activeMeetingProvider).isRecording, true);
    });
  });
}
