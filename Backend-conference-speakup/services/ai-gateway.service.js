// ============================================================================
// SpeakUp — AI Gateway Service
// Express ↔ FastAPI communication layer
// All AI requests from Express go through this service
// ============================================================================

import { env } from "../config/env.config.js";
import { createLogger } from "../logs/logger.js";

const log = createLogger("AI-Gateway");

const AI_BASE_URL = env.AI_SERVICE_URL || "http://localhost:8000/api/v1";
const AI_INTERNAL_KEY = env.AI_INTERNAL_API_KEY || "";
const AI_TIMEOUT = 30000; // 30s default

// ============================================================================
// HTTP CLIENT
// ============================================================================

async function aiRequest(method, path, body = null, options = {}) {
  const url = `${AI_BASE_URL}${path}`;
  const timeout = options.timeout || AI_TIMEOUT;

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);

  try {
    const fetchOptions = {
      method,
      headers: {
        "X-Internal-API-Key": AI_INTERNAL_KEY,
        "Content-Type": "application/json",
        "X-Request-Id": options.requestId || "",
      },
      signal: controller.signal,
    };

    if (body) {
      fetchOptions.body = JSON.stringify(body);
    }

    const response = await fetch(url, fetchOptions);

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`AI service error [${response.status}]: ${error}`);
    }

    return response.json();
  } catch (err) {
    if (err.name === "AbortError") {
      log.error("AI request timeout", { path, timeout });
      throw new Error(`AI service timeout after ${timeout}ms`);
    }
    log.error("AI request failed", { path, error: err.message });
    throw err;
  } finally {
    clearTimeout(timeoutId);
  }
}

async function aiMultipartRequest(path, formData, options = {}) {
  const url = `${AI_BASE_URL}${path}`;
  const timeout = options.timeout || AI_TIMEOUT;

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);

  try {
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "X-Internal-API-Key": AI_INTERNAL_KEY,
        "X-Request-Id": options.requestId || "",
      },
      body: formData,
      signal: controller.signal,
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`AI service error [${response.status}]: ${error}`);
    }

    return response.json();
  } catch (err) {
    if (err.name === "AbortError") {
      throw new Error(`AI service timeout after ${timeout}ms`);
    }
    throw err;
  } finally {
    clearTimeout(timeoutId);
  }
}

// ============================================================================
// SPEECH INTELLIGENCE
// ============================================================================

export async function transcribeAudio(audioBuffer, meetingId, participantId, language = null) {
  const formData = new FormData();
  formData.append("audio", new Blob([audioBuffer]), "audio.wav");
  formData.append("meeting_id", meetingId);
  if (participantId) formData.append("participant_id", participantId);
  if (language) formData.append("language", language);

  return aiMultipartRequest("/speech/transcribe", formData, { timeout: 60000 });
}

export async function getTranscript(meetingId) {
  return aiRequest("GET", `/speech/transcript/${meetingId}`);
}

export async function analyzeSpeech(meetingId, participantId) {
  const formData = new FormData();
  formData.append("meeting_id", meetingId);
  formData.append("participant_id", participantId);
  return aiMultipartRequest("/speech/analyze", formData);
}

// ============================================================================
// COMPUTER VISION
// ============================================================================

export async function analyzeVideoFrame(frameBuffer, meetingId, participantId, width = 640, height = 480) {
  const formData = new FormData();
  formData.append("frame", new Blob([frameBuffer]), "frame.jpg");
  formData.append("meeting_id", meetingId);
  formData.append("participant_id", participantId);
  formData.append("width", width.toString());
  formData.append("height", height.toString());

  return aiMultipartRequest("/cv/analyze-frame", formData, { timeout: 10000 });
}

// ============================================================================
// EMOTION ANALYSIS
// ============================================================================

export async function analyzeEmotion({ meetingId, participantId, voiceFeatures, faceAnalysis, recentText, responseLatencyMs }) {
  return aiRequest("POST", "/emotion/analyze", {
    meeting_id: meetingId,
    participant_id: participantId,
    voice_features: voiceFeatures,
    face_analysis: faceAnalysis,
    recent_text: recentText,
    response_latency_ms: responseLatencyMs,
  });
}

export async function getMeetingEmotions(meetingId) {
  return aiRequest("GET", `/emotion/meeting/${meetingId}`);
}

// ============================================================================
// COPILOT
// ============================================================================

export async function getCopilotSuggestions({ meetingId, recentTranscript, emotionSignals, meetingContext, memoryContext }) {
  return aiRequest("POST", "/copilot/suggestions", {
    meeting_id: meetingId,
    recent_transcript: recentTranscript,
    emotion_signals: emotionSignals,
    meeting_context: meetingContext,
    memory_context: memoryContext,
  });
}

export async function getCoachingReport({ meetingId, participantId, speechAnalysis, emotionHistory, cvAnalysisHistory }) {
  return aiRequest("POST", "/copilot/coaching-report", {
    meeting_id: meetingId,
    participant_id: participantId,
    speech_analysis: speechAnalysis,
    emotion_history: emotionHistory,
    cv_analysis_history: cvAnalysisHistory,
  });
}

export async function predictOutcome({ meetingId, transcript, emotionData, meetingType }) {
  return aiRequest("POST", "/copilot/predict-outcome", {
    meeting_id: meetingId,
    transcript: transcript,
    emotion_data: emotionData,
    meeting_type: meetingType,
  });
}

// ============================================================================
// MEETING MEMORY
// ============================================================================

export async function generateMeetingSummary({ meetingId, transcript, participantNames, meetingTitle, durationMinutes, participantCount }) {
  return aiRequest("POST", "/memory/summary", {
    meeting_id: meetingId,
    transcript: transcript,
    participant_names: participantNames,
    meeting_title: meetingTitle,
    duration_minutes: durationMinutes,
    participant_count: participantCount,
  }, { timeout: 120000 }); // 2min for long meetings
}

export async function queryMeetingMemory({ userId, query, meetingIds, timeRangeDays, limit }) {
  return aiRequest("POST", "/memory/query", {
    user_id: userId,
    query: query,
    meeting_ids: meetingIds,
    time_range_days: timeRangeDays,
    limit: limit,
  });
}

export async function generateMeetingReplay({ meetingId, transcript, durationSeconds }) {
  return aiRequest("POST", "/memory/replay", {
    meeting_id: meetingId,
    transcript: transcript,
    duration_seconds: durationSeconds,
  }, { timeout: 120000 });
}

export async function getRelationship(userId, targetUserId) {
  return aiRequest("GET", `/memory/relationship/${userId}/${targetUserId}`);
}

// ============================================================================
// AGENT ORCHESTRATOR
// ============================================================================

export async function triggerLiveAnalysis({ meetingId, participantIds, transcript, transcriptSegments, cvData, meetingTitle, meetingType, iteration }) {
  return aiRequest("POST", "/agents/live-analysis", {
    meeting_id: meetingId,
    participant_ids: participantIds,
    transcript: transcript,
    transcript_segments: transcriptSegments || [],
    cv_data: cvData,
    meeting_title: meetingTitle,
    meeting_type: meetingType || "general",
    iteration: iteration || 0,
  }, { timeout: 60000 });
}

export async function triggerPostMeetingAnalysis({ meetingId, participantIds, transcript, transcriptSegments, meetingTitle }) {
  return aiRequest("POST", "/agents/post-meeting", {
    meeting_id: meetingId,
    participant_ids: participantIds,
    transcript: transcript,
    transcript_segments: transcriptSegments || [],
    meeting_title: meetingTitle,
  }, { timeout: 180000 }); // 3min for heavy processing
}

export async function getAgentState(meetingId) {
  return aiRequest("GET", `/agents/state/${meetingId}`);
}

// ============================================================================
// VOICE ASSISTANT
// ============================================================================

export async function processVoiceCommand({ text, userId, meetingId }) {
  return aiRequest("POST", "/assistant/voice-command", {
    text,
    user_id: userId,
    meeting_id: meetingId,
  });
}

export async function confirmVoiceCommand({ userId, meetingId, parsedCommand }) {
  return aiRequest("POST", "/assistant/voice-command/confirm", {
    user_id: userId,
    meeting_id: meetingId,
    parsed_command: parsedCommand,
  });
}

export async function setAssistantMeetingContext({ meetingId, context }) {
  return aiRequest("POST", "/assistant/meeting-context", {
    meeting_id: meetingId,
    context,
  });
}

// ============================================================================
// MCP TOOLS
// ============================================================================

export async function getToolsSchema() {
  return aiRequest("GET", "/tools/schema");
}

export async function executeTool({ toolName, parameters }) {
  return aiRequest("POST", "/tools/execute", {
    tool_name: toolName,
    parameters,
  }, { timeout: 60000 });
}

// ============================================================================
// WORKFLOW AUTOMATION
// ============================================================================

export async function runPostMeetingWorkflow({ meetingId, userId, summary, actionItems, decisions, attendees, config }) {
  return aiRequest("POST", "/workflow/post-meeting", {
    meeting_id: meetingId,
    user_id: userId,
    summary,
    action_items: actionItems || [],
    decisions: decisions || [],
    attendees: attendees || [],
    config,
  }, { timeout: 300000 }); // 5min for complex workflows
}

export async function runPreMeetingPrep({ meetingId, userId, attendees, meetingTitle, agenda }) {
  return aiRequest("POST", "/workflow/pre-meeting", {
    meeting_id: meetingId,
    user_id: userId,
    attendees,
    meeting_title: meetingTitle,
    agenda,
  }, { timeout: 120000 });
}

export async function getWorkflowStatus(workflowId) {
  return aiRequest("GET", `/workflow/status/${workflowId}`);
}

// ============================================================================
// HEALTH CHECK
// ============================================================================

export async function checkAIHealth() {
  try {
    const result = await aiRequest("GET", "/health/ready", null, { timeout: 5000 });
    return { available: true, ...result };
  } catch {
    return { available: false, status: "unreachable" };
  }
}

export default {
  // Speech
  transcribeAudio,
  getTranscript,
  analyzeSpeech,
  // CV
  analyzeVideoFrame,
  // Emotion
  analyzeEmotion,
  getMeetingEmotions,
  // Copilot
  getCopilotSuggestions,
  getCoachingReport,
  predictOutcome,
  // Memory
  generateMeetingSummary,
  queryMeetingMemory,
  generateMeetingReplay,
  getRelationship,
  // Agents
  triggerLiveAnalysis,
  triggerPostMeetingAnalysis,
  getAgentState,
  // Voice Assistant
  processVoiceCommand,
  confirmVoiceCommand,
  setAssistantMeetingContext,
  // MCP Tools
  getToolsSchema,
  executeTool,
  // Workflow
  runPostMeetingWorkflow,
  runPreMeetingPrep,
  getWorkflowStatus,
  // Health
  checkAIHealth,
};
