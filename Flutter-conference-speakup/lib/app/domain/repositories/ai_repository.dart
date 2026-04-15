import 'package:flutter_conference_speakup/core/network/api_client.dart';
import 'package:flutter_conference_speakup/core/apis/endpoints.dart';
import 'package:flutter_conference_speakup/app/domain/models/ai_models.dart';

class AIRepository {
  final _api = ApiClient.instance;

  // ── Transcription ──

  Future<List<TranscriptionSegment>> getTranscript(String meetingId) async {
    final res = await _api.get(ApiEndpoints.aiTranscript(meetingId));
    final list = res.data['data'] as List? ?? [];
    return list
        .map((e) => TranscriptionSegment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Copilot ──

  Future<List<CopilotSuggestion>> getCopilotSuggestions(String meetingId) async {
    final res = await _api.post(ApiEndpoints.aiCopilotSuggestions, data: {
      'meeting_id': meetingId,
    });
    final list = res.data['data'] as List? ?? [];
    return list
        .map((e) => CopilotSuggestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getCoachingReport(String meetingId) async {
    final res = await _api.post(ApiEndpoints.aiCoachingReport, data: {
      'meeting_id': meetingId,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> predictOutcome(String meetingId) async {
    final res = await _api.post(ApiEndpoints.aiPredictOutcome, data: {
      'meeting_id': meetingId,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getKnowledgeGaps(String meetingId) async {
    final res = await _api.post(ApiEndpoints.aiKnowledgeGaps, data: {
      'meeting_id': meetingId,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── Memory ──

  Future<MeetingSummary> getMeetingSummary(String meetingId) async {
    final res = await _api.post(ApiEndpoints.aiMeetingSummary, data: {
      'meeting_id': meetingId,
    });
    return MeetingSummary.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> queryMemory(String query) async {
    final res = await _api.post(ApiEndpoints.aiMemoryQuery, data: {
      'query': query,
    });
    return (res.data['data'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];
  }

  Future<Map<String, dynamic>> getMemoryReplay(String meetingId) async {
    final res = await _api.post(ApiEndpoints.aiMemoryReplay, data: {
      'meeting_id': meetingId,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getRelationship(
      String userId, String targetId) async {
    final res = await _api.get(ApiEndpoints.aiRelationship(userId, targetId));
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── Emotion ──

  Future<Map<String, dynamic>> getMeetingEmotions(String meetingId) async {
    final res = await _api.get(ApiEndpoints.aiMeetingEmotions(meetingId));
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── Assistant ──

  Future<VoiceCommandResult> sendVoiceCommand(
      String text, String meetingId) async {
    final res = await _api.post(ApiEndpoints.aiVoiceCommand, data: {
      'text': text,
      'meeting_id': meetingId,
    });
    return VoiceCommandResult.fromJson(
        res.data['data'] as Map<String, dynamic>);
  }

  Future<VoiceCommandResult> confirmVoiceCommand(
      String meetingId, Map<String, dynamic> parsedCommand) async {
    final res = await _api.post(ApiEndpoints.aiVoiceCommandConfirm, data: {
      'meeting_id': meetingId,
      'parsed_command': parsedCommand,
    });
    return VoiceCommandResult.fromJson(
        res.data['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getMeetingContext(String meetingId) async {
    final res = await _api.post(ApiEndpoints.aiMeetingContext, data: {
      'meeting_id': meetingId,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── Tools ──

  Future<List<Map<String, dynamic>>> getToolsSchema() async {
    final res = await _api.get(ApiEndpoints.aiToolsSchema);
    return (res.data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<Map<String, dynamic>> executeTool(
      String name, Map<String, dynamic> parameters) async {
    final res = await _api.post(ApiEndpoints.aiToolsExecute, data: {
      'tool_name': name,
      'parameters': parameters,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── Workflows ──

  Future<WorkflowStatus> runPostMeetingWorkflow(
      String meetingId, Map<String, dynamic>? config) async {
    final res = await _api.post(ApiEndpoints.aiWorkflowPostMeeting, data: {
      'meeting_id': meetingId,
      if (config != null) 'config': config,
    });
    return WorkflowStatus.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<WorkflowStatus> runPreMeetingWorkflow(String meetingId) async {
    final res = await _api.post(ApiEndpoints.aiWorkflowPreMeeting, data: {
      'meeting_id': meetingId,
    });
    return WorkflowStatus.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<WorkflowStatus> getWorkflowStatus(String workflowId) async {
    final res = await _api.get(ApiEndpoints.aiWorkflowStatus(workflowId));
    return WorkflowStatus.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<List<WorkflowStatus>> getActiveWorkflows() async {
    final res = await _api.get(ApiEndpoints.aiWorkflowActive);
    final list = res.data['data'] as List? ?? [];
    return list
        .map((e) => WorkflowStatus.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Agents ──

  Future<Map<String, dynamic>> getAgentState(String sessionId) async {
    final res = await _api.get(ApiEndpoints.aiAgentState(sessionId));
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> runPostMeetingAgent(String meetingId) async {
    final res = await _api.post(ApiEndpoints.aiPostMeetingAgent, data: {
      'meeting_id': meetingId,
    });
    return res.data['data'] as Map<String, dynamic>;
  }
}
