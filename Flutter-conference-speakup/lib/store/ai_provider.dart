import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/app/domain/models/ai_models.dart';
import 'package:flutter_conference_speakup/core/services/websocket.dart';

// ============================================================================
// SOCKET EVENT CONSTANTS (match backend SocketEvents)
// ============================================================================

class AISocketEvents {
  AISocketEvents._();
  static const transcription = 'ai:transcription';
  static const copilotSuggestions = 'ai:copilot_suggestions';
  static const emotionSignals = 'ai:emotion_signals';
  static const coachingHints = 'ai:coaching_hints';
  static const meetingSummary = 'ai:meeting_summary';
  static const actionItems = 'ai:action_items';
  static const liveInsights = 'ai:live_insights';
  static const voiceCommand = 'ai:voice_command';
  static const voiceCommandResult = 'ai:voice_command_result';
  static const voiceCommandConfirm = 'ai:voice_command_confirm';
  static const toolExecute = 'ai:tool_execute';
  static const toolResult = 'ai:tool_result';
  static const workflowStatus = 'ai:workflow_status';
  static const toggleCopilot = 'ai:toggle_copilot';
  static const toggleTranscription = 'ai:toggle_transcription';
  static const toggleCoaching = 'ai:toggle_coaching';
  static const requestSummary = 'ai:request_summary';
}

// ============================================================================
// MEETING AI STATE — holds all AI data for active meeting
// ============================================================================

class MeetingAIState {
  final List<TranscriptionSegment> transcription;
  final List<CopilotSuggestion> suggestions;
  final Map<String, EmotionSignal> emotions; // participantId → latest
  final List<CoachingHint> coachingHints;
  final List<ActionItem> actionItems;
  final MeetingSummary? summary;
  final VoiceCommandResult? lastVoiceCommand;
  final WorkflowStatus? workflowStatus;
  final bool isCopilotEnabled;
  final bool isTranscriptionEnabled;
  final bool isCoachingEnabled;
  final bool isVoiceAssistantActive;

  const MeetingAIState({
    this.transcription = const [],
    this.suggestions = const [],
    this.emotions = const {},
    this.coachingHints = const [],
    this.actionItems = const [],
    this.summary,
    this.lastVoiceCommand,
    this.workflowStatus,
    this.isCopilotEnabled = true,
    this.isTranscriptionEnabled = true,
    this.isCoachingEnabled = false,
    this.isVoiceAssistantActive = false,
  });

  MeetingAIState copyWith({
    List<TranscriptionSegment>? transcription,
    List<CopilotSuggestion>? suggestions,
    Map<String, EmotionSignal>? emotions,
    List<CoachingHint>? coachingHints,
    List<ActionItem>? actionItems,
    MeetingSummary? summary,
    VoiceCommandResult? lastVoiceCommand,
    WorkflowStatus? workflowStatus,
    bool? isCopilotEnabled,
    bool? isTranscriptionEnabled,
    bool? isCoachingEnabled,
    bool? isVoiceAssistantActive,
  }) =>
      MeetingAIState(
        transcription: transcription ?? this.transcription,
        suggestions: suggestions ?? this.suggestions,
        emotions: emotions ?? this.emotions,
        coachingHints: coachingHints ?? this.coachingHints,
        actionItems: actionItems ?? this.actionItems,
        summary: summary ?? this.summary,
        lastVoiceCommand: lastVoiceCommand ?? this.lastVoiceCommand,
        workflowStatus: workflowStatus ?? this.workflowStatus,
        isCopilotEnabled: isCopilotEnabled ?? this.isCopilotEnabled,
        isTranscriptionEnabled: isTranscriptionEnabled ?? this.isTranscriptionEnabled,
        isCoachingEnabled: isCoachingEnabled ?? this.isCoachingEnabled,
        isVoiceAssistantActive: isVoiceAssistantActive ?? this.isVoiceAssistantActive,
      );
}

// ============================================================================
// AI STATE NOTIFIER
// ============================================================================

final meetingAIProvider =
    StateNotifierProvider<MeetingAINotifier, MeetingAIState>((ref) {
  return MeetingAINotifier();
});

class MeetingAINotifier extends StateNotifier<MeetingAIState> {
  final _ws = WebSocketService();
  final List<StreamSubscription> _subs = [];

  MeetingAINotifier() : super(const MeetingAIState());

  /// Start listening to all AI WebSocket events for a meeting.
  void startListening(String meetingId) {
    _cleanup();

    // Join AI room
    _ws.emit('meeting:join', {'meetingId': meetingId});

    // Transcription stream
    _subs.add(
      _ws.stream(AISocketEvents.transcription).listen((data) {
        if (data is Map<String, dynamic>) {
          final segment = TranscriptionSegment.fromJson(data);
          state = state.copyWith(
            transcription: [...state.transcription, segment],
          );
        }
      }),
    );

    // Copilot suggestions
    _subs.add(
      _ws.stream(AISocketEvents.copilotSuggestions).listen((data) {
        if (data is Map<String, dynamic>) {
          final suggestion = CopilotSuggestion.fromJson(data);
          state = state.copyWith(
            suggestions: [...state.suggestions, suggestion],
          );
        } else if (data is List) {
          final newSuggestions = data
              .whereType<Map<String, dynamic>>()
              .map((e) => CopilotSuggestion.fromJson(e))
              .toList();
          state = state.copyWith(
            suggestions: [...state.suggestions, ...newSuggestions],
          );
        }
      }),
    );

    // Emotion signals
    _subs.add(
      _ws.stream(AISocketEvents.emotionSignals).listen((data) {
        if (data is Map<String, dynamic>) {
          final signal = EmotionSignal.fromJson(data);
          final updated = Map<String, EmotionSignal>.from(state.emotions);
          updated[signal.participantId] = signal;
          state = state.copyWith(emotions: updated);
        }
      }),
    );

    // Coaching hints
    _subs.add(
      _ws.stream(AISocketEvents.coachingHints).listen((data) {
        if (data is Map<String, dynamic>) {
          final hint = CoachingHint.fromJson(data);
          state = state.copyWith(
            coachingHints: [...state.coachingHints, hint],
          );
        }
      }),
    );

    // Action items
    _subs.add(
      _ws.stream(AISocketEvents.actionItems).listen((data) {
        if (data is List) {
          final items = data
              .whereType<Map<String, dynamic>>()
              .map((e) => ActionItem.fromJson(e))
              .toList();
          state = state.copyWith(actionItems: items);
        }
      }),
    );

    // Meeting summary
    _subs.add(
      _ws.stream(AISocketEvents.meetingSummary).listen((data) {
        if (data is Map<String, dynamic>) {
          state = state.copyWith(
            summary: MeetingSummary.fromJson(data),
          );
        }
      }),
    );

    // Voice command results
    _subs.add(
      _ws.stream(AISocketEvents.voiceCommandResult).listen((data) {
        if (data is Map<String, dynamic>) {
          state = state.copyWith(
            lastVoiceCommand: VoiceCommandResult.fromJson(data),
          );
        }
      }),
    );

    // Tool results
    _subs.add(
      _ws.stream(AISocketEvents.toolResult).listen((data) {
        // Tool results can update voice command state
        if (data is Map<String, dynamic>) {
          state = state.copyWith(
            lastVoiceCommand: VoiceCommandResult(
              command: data['tool_name'] as String?,
              result: data['result']?.toString(),
              status: 'executed',
            ),
          );
        }
      }),
    );

    // Workflow status updates
    _subs.add(
      _ws.stream(AISocketEvents.workflowStatus).listen((data) {
        if (data is Map<String, dynamic>) {
          state = state.copyWith(
            workflowStatus: WorkflowStatus.fromJson(data),
          );
        }
      }),
    );
  }

  // ── Feature toggles ──

  void toggleCopilot() {
    final enabled = !state.isCopilotEnabled;
    state = state.copyWith(isCopilotEnabled: enabled);
    _ws.emit(AISocketEvents.toggleCopilot, {'enabled': enabled});
  }

  void toggleTranscription() {
    final enabled = !state.isTranscriptionEnabled;
    state = state.copyWith(isTranscriptionEnabled: enabled);
    _ws.emit(AISocketEvents.toggleTranscription, {'enabled': enabled});
  }

  void toggleCoaching() {
    final enabled = !state.isCoachingEnabled;
    state = state.copyWith(isCoachingEnabled: enabled);
    _ws.emit(AISocketEvents.toggleCoaching, {'enabled': enabled});
  }

  void toggleVoiceAssistant() {
    state = state.copyWith(
      isVoiceAssistantActive: !state.isVoiceAssistantActive,
    );
  }

  // ── Voice commands ──

  void sendVoiceCommand(String text, String meetingId) {
    _ws.emit(AISocketEvents.voiceCommand, {
      'text': text,
      'meetingId': meetingId,
    });
  }

  void confirmVoiceCommand(String meetingId, Map<String, dynamic> parsedCommand) {
    _ws.emit(AISocketEvents.voiceCommandConfirm, {
      'meetingId': meetingId,
      'parsedCommand': parsedCommand,
    });
  }

  // ── Tool execution ──

  void executeTool(String toolName, Map<String, dynamic> parameters) {
    _ws.emit(AISocketEvents.toolExecute, {
      'toolName': toolName,
      'parameters': parameters,
    });
  }

  // ── Summary request ──

  void requestSummary(String meetingId) {
    _ws.emit(AISocketEvents.requestSummary, {'meetingId': meetingId});
  }

  // ── Suggestion management ──

  void dismissSuggestion(String id) {
    state = state.copyWith(
      suggestions: state.suggestions
          .map((s) => s.id == id ? s.copyWith(isDismissed: true) : s)
          .toList(),
    );
  }

  // ── Cleanup ──

  void stopListening() {
    _cleanup();
    state = const MeetingAIState();
  }

  void _cleanup() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}
