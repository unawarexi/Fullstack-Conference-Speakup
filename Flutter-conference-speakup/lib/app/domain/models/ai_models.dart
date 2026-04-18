// ============================================================================
// SpeakUp — AI Feature Models
// ============================================================================

/// Real-time transcription segment from speech-to-text.
class TranscriptionSegment {
  final String text;
  final String? speakerId;
  final String? speakerName;
  final double confidence;
  final DateTime timestamp;
  final String? language;
  final bool isFinal;

  const TranscriptionSegment({
    required this.text,
    this.speakerId,
    this.speakerName,
    this.confidence = 1.0,
    required this.timestamp,
    this.language,
    this.isFinal = false,
  });

  factory TranscriptionSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptionSegment(
      text: json['text'] as String? ?? '',
      speakerId: json['speaker_id'] as String? ?? json['speakerId'] as String?,
      speakerName: json['speaker_name'] as String? ?? json['speakerName'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String).toLocal()
          : DateTime.now(),
      language: json['language'] as String?,
      isFinal: json['is_final'] as bool? ?? json['isFinal'] as bool? ?? false,
    );
  }
}

/// AI copilot suggestion during meeting.
enum SuggestionType { talkingPoint, question, insight, warning, followUp }

class CopilotSuggestion {
  final String id;
  final SuggestionType type;
  final String text;
  final String? context;
  final double confidence;
  final DateTime timestamp;
  final bool isDismissed;

  const CopilotSuggestion({
    required this.id,
    required this.type,
    required this.text,
    this.context,
    this.confidence = 0.8,
    required this.timestamp,
    this.isDismissed = false,
  });

  CopilotSuggestion copyWith({bool? isDismissed}) => CopilotSuggestion(
        id: id,
        type: type,
        text: text,
        context: context,
        confidence: confidence,
        timestamp: timestamp,
        isDismissed: isDismissed ?? this.isDismissed,
      );

  factory CopilotSuggestion.fromJson(Map<String, dynamic> json) {
    return CopilotSuggestion(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _parseSuggestionType(json['type'] as String? ?? 'insight'),
      text: json['text'] as String? ?? '',
      context: json['context'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.8,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String).toLocal()
          : DateTime.now(),
    );
  }

  static SuggestionType _parseSuggestionType(String type) {
    return switch (type) {
      'talking_point' => SuggestionType.talkingPoint,
      'question' => SuggestionType.question,
      'warning' => SuggestionType.warning,
      'follow_up' => SuggestionType.followUp,
      _ => SuggestionType.insight,
    };
  }
}

/// Emotion signal for a participant.
class EmotionSignal {
  final String participantId;
  final String? participantName;
  final String emotion;
  final double confidence;
  final double engagementScore;
  final DateTime timestamp;

  const EmotionSignal({
    required this.participantId,
    this.participantName,
    required this.emotion,
    this.confidence = 0.7,
    this.engagementScore = 0.5,
    required this.timestamp,
  });

  factory EmotionSignal.fromJson(Map<String, dynamic> json) {
    return EmotionSignal(
      participantId: json['participant_id'] as String? ?? json['participantId'] as String? ?? '',
      participantName: json['participant_name'] as String? ?? json['participantName'] as String?,
      emotion: json['emotion'] as String? ?? 'neutral',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.7,
      engagementScore: (json['engagement_score'] as num?)?.toDouble() ??
          (json['engagementScore'] as num?)?.toDouble() ?? 0.5,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String).toLocal()
          : DateTime.now(),
    );
  }

  String get emoji => switch (emotion) {
        'happy' || 'joy' => '😊',
        'excited' || 'enthusiastic' => '🤩',
        'confused' || 'uncertain' => '😕',
        'frustrated' || 'angry' => '😤',
        'bored' || 'disengaged' => '😴',
        'surprised' => '😲',
        'sad' || 'disappointed' => '😞',
        'focused' || 'attentive' => '🎯',
        _ => '😐',
      };
}

/// Real-time coaching hint.
enum CoachingType { pace, clarity, engagement, volume, filler, pause }

class CoachingHint {
  final CoachingType type;
  final String message;
  final String severity; // low, medium, high
  final DateTime timestamp;

  const CoachingHint({
    required this.type,
    required this.message,
    this.severity = 'low',
    required this.timestamp,
  });

  factory CoachingHint.fromJson(Map<String, dynamic> json) {
    return CoachingHint(
      type: _parseCoachingType(json['type'] as String? ?? 'engagement'),
      message: json['message'] as String? ?? '',
      severity: json['severity'] as String? ?? 'low',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String).toLocal()
          : DateTime.now(),
    );
  }

  static CoachingType _parseCoachingType(String type) {
    return switch (type) {
      'pace' => CoachingType.pace,
      'clarity' => CoachingType.clarity,
      'volume' => CoachingType.volume,
      'filler' => CoachingType.filler,
      'pause' => CoachingType.pause,
      _ => CoachingType.engagement,
    };
  }
}

/// Action item extracted from meeting.
class ActionItem {
  final String id;
  final String text;
  final String? assignee;
  final String? deadline;
  final String priority; // low, medium, high
  final bool isCompleted;

  const ActionItem({
    required this.id,
    required this.text,
    this.assignee,
    this.deadline,
    this.priority = 'medium',
    this.isCompleted = false,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['text'] as String? ?? '',
      assignee: json['assignee'] as String?,
      deadline: json['deadline'] as String?,
      priority: json['priority'] as String? ?? 'medium',
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }
}

/// Meeting summary generated by AI.
class MeetingSummary {
  final String meetingId;
  final String summary;
  final List<String> keyTopics;
  final List<ActionItem> actionItems;
  final List<String> decisions;
  final int durationMinutes;
  final double sentimentScore;
  final DateTime generatedAt;

  const MeetingSummary({
    required this.meetingId,
    required this.summary,
    this.keyTopics = const [],
    this.actionItems = const [],
    this.decisions = const [],
    this.durationMinutes = 0,
    this.sentimentScore = 0.5,
    required this.generatedAt,
  });

  factory MeetingSummary.fromJson(Map<String, dynamic> json) {
    return MeetingSummary(
      meetingId: json['meeting_id'] as String? ?? json['meetingId'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      keyTopics: (json['key_topics'] as List?)?.cast<String>() ??
          (json['keyTopics'] as List?)?.cast<String>() ?? [],
      actionItems: (json['action_items'] as List?)
              ?.map((e) => ActionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['actionItems'] as List?)
              ?.map((e) => ActionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      decisions: (json['decisions'] as List?)?.cast<String>() ?? [],
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      sentimentScore: (json['sentiment_score'] as num?)?.toDouble() ?? 0.5,
      generatedAt: json['generated_at'] != null
          ? DateTime.parse(json['generated_at'] as String).toLocal()
          : DateTime.now(),
    );
  }
}

/// Voice command result from AI assistant.
class VoiceCommandResult {
  final String? command;
  final bool detected;
  final bool needsConfirmation;
  final String? parsedAction;
  final Map<String, dynamic>? parsedParameters;
  final String? result;
  final String? error;
  final String status; // detected, confirmed, executed, failed

  const VoiceCommandResult({
    this.command,
    this.detected = false,
    this.needsConfirmation = false,
    this.parsedAction,
    this.parsedParameters,
    this.result,
    this.error,
    this.status = 'detected',
  });

  factory VoiceCommandResult.fromJson(Map<String, dynamic> json) {
    return VoiceCommandResult(
      command: json['command'] as String?,
      detected: json['detected'] as bool? ?? false,
      needsConfirmation: json['needs_confirmation'] as bool? ??
          json['needsConfirmation'] as bool? ?? false,
      parsedAction: json['parsed_action'] as String? ?? json['parsedAction'] as String?,
      parsedParameters: json['parsed_parameters'] as Map<String, dynamic>? ??
          json['parsedParameters'] as Map<String, dynamic>?,
      result: json['result'] as String?,
      error: json['error'] as String?,
      status: json['status'] as String? ?? 'detected',
    );
  }
}

/// Workflow execution status.
class WorkflowStatus {
  final String workflowId;
  final String status; // running, completed, failed
  final double progress;
  final String? currentStep;
  final List<WorkflowStepStatus> steps;
  final String? error;

  const WorkflowStatus({
    required this.workflowId,
    this.status = 'running',
    this.progress = 0,
    this.currentStep,
    this.steps = const [],
    this.error,
  });

  factory WorkflowStatus.fromJson(Map<String, dynamic> json) {
    return WorkflowStatus(
      workflowId: json['workflow_id'] as String? ?? json['workflowId'] as String? ?? '',
      status: json['status'] as String? ?? 'running',
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      currentStep: json['current_step'] as String? ?? json['currentStep'] as String?,
      steps: (json['steps'] as List?)
              ?.map((e) => WorkflowStepStatus.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      error: json['error'] as String?,
    );
  }
}

class WorkflowStepStatus {
  final String name;
  final String status;
  final String? result;

  const WorkflowStepStatus({
    required this.name,
    this.status = 'pending',
    this.result,
  });

  factory WorkflowStepStatus.fromJson(Map<String, dynamic> json) {
    return WorkflowStepStatus(
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      result: json['result'] as String?,
    );
  }
}
