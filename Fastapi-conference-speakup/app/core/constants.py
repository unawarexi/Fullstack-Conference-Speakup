# SpeakUp AI — Constants mirroring Express backend
from __future__ import annotations

# ============================================================================
# Kafka Topics — MUST match Express Backend-conference-speakup/config/constants.js
# ============================================================================


class KafkaTopics:
    # Existing Express topics (consumed by FastAPI)
    MEETING_EVENTS = "speakup.meeting.events"
    PARTICIPANT_EVENTS = "speakup.participant.events"
    CHAT_MESSAGES = "speakup.chat.messages"
    RECORDING_EVENTS = "speakup.recording.events"
    NOTIFICATION_EVENTS = "speakup.notification.events"
    ANALYTICS_EVENTS = "speakup.analytics.events"
    USER_EVENTS = "speakup.user.events"

    # AI-specific topics (produced by FastAPI, consumed by Express)
    AI_TRANSCRIPTION = "speakup.ai.transcription"
    AI_LIVE_INSIGHTS = "speakup.ai.live_insights"
    AI_EMOTION_SIGNALS = "speakup.ai.emotion_signals"
    AI_COACHING_HINTS = "speakup.ai.coaching_hints"
    AI_COPILOT_SUGGESTIONS = "speakup.ai.copilot_suggestions"
    AI_MEETING_SUMMARY = "speakup.ai.meeting_summary"
    AI_ACTION_ITEMS = "speakup.ai.action_items"
    AI_MEMORY_UPDATES = "speakup.ai.memory_updates"
    AI_CV_ANALYSIS = "speakup.ai.cv_analysis"

    # Media stream topics
    MEDIA_AUDIO_CHUNKS = "speakup.media.audio_chunks"
    MEDIA_VIDEO_FRAMES = "speakup.media.video_frames"


# ============================================================================
# Redis Keys / Channels
# ============================================================================


class RedisKeys:
    # Meeting state cache
    MEETING_AI_STATE = "ai:meeting:{meeting_id}:state"
    MEETING_TRANSCRIPT = "ai:meeting:{meeting_id}:transcript"
    MEETING_EMOTIONS = "ai:meeting:{meeting_id}:emotions"
    MEETING_INSIGHTS = "ai:meeting:{meeting_id}:insights"

    # Model inference cache
    MODEL_CACHE = "ai:model_cache:{model}:{hash}"

    # Rate limiting
    AI_RATE_LIMIT = "ai:rate_limit:{user_id}:{action}"

    # Pub/Sub channels
    CHANNEL_AI_INSIGHTS = "ai:insights:{meeting_id}"
    CHANNEL_AI_COACHING = "ai:coaching:{meeting_id}"
    CHANNEL_AI_COPILOT = "ai:copilot:{meeting_id}"


# ============================================================================
# AI Service Types
# ============================================================================


class AIServiceType:
    SPEECH = "speech"
    CV = "cv"
    EMOTION = "emotion"
    COPILOT = "copilot"
    MEMORY = "memory"
    AGENT = "agent"


# ============================================================================
# Meeting AI States
# ============================================================================


class MeetingAIState:
    IDLE = "idle"
    LISTENING = "listening"
    PROCESSING = "processing"
    SUMMARIZING = "summarizing"
    COMPLETED = "completed"
    ERROR = "error"


# ============================================================================
# Emotion Labels (soft signals only — per README ethics)
# ============================================================================

EMOTION_SIGNALS = {
    "possible_confusion": "Participant may be confused",
    "engagement_drop": "Engagement appears to be decreasing",
    "hesitation": "Tone suggests hesitation",
    "high_confidence": "Speaker appears confident",
    "possible_frustration": "Possible frustration detected",
    "calm_focused": "Participant appears calm and focused",
    "excitement": "Positive energy detected",
    "fatigue": "Possible fatigue or low energy",
}

# ============================================================================
# Coaching Hint Categories
# ============================================================================


class CoachingCategory:
    PACE = "pace"
    TONE = "tone"
    ENGAGEMENT = "engagement"
    BODY_LANGUAGE = "body_language"
    INTERRUPTION = "interruption"
    EMPATHY = "empathy"
    CLARITY = "clarity"
    CONFIDENCE = "confidence"
