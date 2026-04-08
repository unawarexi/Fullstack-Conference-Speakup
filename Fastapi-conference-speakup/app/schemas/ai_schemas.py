# SpeakUp AI — Pydantic Schemas for all AI services
from __future__ import annotations

from datetime import datetime
from enum import Enum
from typing import Any

from pydantic import BaseModel, Field


# ============================================================================
# Base
# ============================================================================


class AIResponse(BaseModel):
    success: bool = True
    service: str
    meeting_id: str | None = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    data: dict[str, Any] = Field(default_factory=dict)


class HealthStatus(BaseModel):
    status: str
    service: str
    uptime_seconds: float
    models_loaded: list[str] = Field(default_factory=list)
    connections: dict[str, bool] = Field(default_factory=dict)


# ============================================================================
# Speech Intelligence
# ============================================================================


class TranscriptionSegment(BaseModel):
    start: float
    end: float
    text: str
    speaker: str | None = None
    confidence: float = 0.0
    language: str | None = None


class TranscriptionResult(BaseModel):
    meeting_id: str
    segments: list[TranscriptionSegment]
    full_text: str
    language: str
    duration_seconds: float
    speaker_count: int | None = None


class AudioChunkRequest(BaseModel):
    meeting_id: str
    participant_id: str
    chunk_index: int
    sample_rate: int = 16000
    channels: int = 1
    encoding: str = "pcm_s16le"
    # audio_data is sent as binary in multipart


class SpeechAnalysis(BaseModel):
    meeting_id: str
    participant_id: str
    speaking_speed_wpm: float
    filler_word_count: int
    filler_words: dict[str, int] = Field(default_factory=dict)  # {"um": 5, "uh": 3}
    interruption_count: int = 0
    silence_ratio: float = 0.0
    tone_analysis: dict[str, float] = Field(default_factory=dict)
    confidence_score: float = 0.0


class DiarizationResult(BaseModel):
    meeting_id: str
    speakers: list[dict[str, Any]]  # [{speaker_id, segments, total_duration, percentage}]
    total_speakers: int


# ============================================================================
# Computer Vision
# ============================================================================


class CVFrameRequest(BaseModel):
    meeting_id: str
    participant_id: str
    frame_index: int
    width: int = 640
    height: int = 480


class FaceAnalysis(BaseModel):
    participant_id: str
    face_detected: bool = False
    landmarks: list[dict[str, float]] | None = None
    gaze_direction: dict[str, float] | None = None  # {yaw, pitch}
    eye_contact_score: float = 0.0
    smile_score: float = 0.0
    head_pose: dict[str, float] | None = None  # {roll, pitch, yaw}


class PostureAnalysis(BaseModel):
    participant_id: str
    body_detected: bool = False
    posture_score: float = 0.0  # 0-1
    fidgeting_score: float = 0.0
    gesture_detected: str | None = None
    presentation_confidence: float = 0.0


class CVAnalysisResult(BaseModel):
    meeting_id: str
    participant_id: str
    timestamp: float
    face: FaceAnalysis | None = None
    posture: PostureAnalysis | None = None


# ============================================================================
# Emotion / Multimodal Signals
# ============================================================================


class EmotionSignal(BaseModel):
    signal_type: str  # from EMOTION_SIGNALS keys
    confidence: float = Field(ge=0.0, le=1.0)
    description: str


class MultimodalEmotionResult(BaseModel):
    meeting_id: str
    participant_id: str
    timestamp: float
    signals: list[EmotionSignal]
    dominant_signal: str | None = None
    engagement_score: float = Field(ge=0.0, le=1.0, default=0.5)
    # Composite from voice + face + text
    modalities_used: list[str] = Field(default_factory=list)  # ["voice", "face", "text"]


# ============================================================================
# Copilot Suggestions
# ============================================================================


class SuggestionType(str, Enum):
    QUESTION = "question"
    CLARIFICATION = "clarification"
    EMPATHY = "empathy"
    NEGOTIATION = "negotiation"
    TECHNICAL = "technical"
    AGENDA = "agenda"
    CONFLICT = "conflict"
    PHRASING = "phrasing"
    COACHING = "coaching"


class CopilotSuggestion(BaseModel):
    type: SuggestionType
    content: str
    reasoning: str
    priority: float = Field(ge=0.0, le=1.0, default=0.5)
    target_participant: str | None = None  # who should receive it


class CopilotStreamResponse(BaseModel):
    meeting_id: str
    timestamp: float
    suggestions: list[CopilotSuggestion]
    context_summary: str | None = None


# ============================================================================
# Meeting Memory
# ============================================================================


class ActionItem(BaseModel):
    id: str | None = None
    description: str
    assignee: str | None = None
    assignee_id: str | None = None
    deadline: str | None = None
    priority: str = "medium"
    status: str = "open"


class Decision(BaseModel):
    id: str | None = None
    description: str
    made_by: str | None = None
    context: str | None = None
    timestamp: float | None = None


class MeetingSummary(BaseModel):
    meeting_id: str
    title: str | None = None
    summary: str
    key_points: list[str]
    decisions: list[Decision]
    action_items: list[ActionItem]
    unresolved_questions: list[str]
    follow_up_suggestions: list[str]
    risks_identified: list[str]
    contradiction_flags: list[str]
    compliance_flags: list[str]
    sentiment_timeline: list[dict[str, Any]]  # [{timestamp, sentiment, score}]
    duration_minutes: float
    participant_count: int
    topics_discussed: list[str]


class MemoryGraphNode(BaseModel):
    node_type: str  # Meeting, Person, ActionItem, Decision, Topic, Risk
    node_id: str
    properties: dict[str, Any]
    relationships: list[dict[str, Any]] = Field(default_factory=list)


class MeetingMemoryQuery(BaseModel):
    user_id: str
    query: str
    meeting_ids: list[str] | None = None
    time_range_days: int | None = None
    limit: int = 10


class MeetingMemoryResult(BaseModel):
    query: str
    results: list[dict[str, Any]]
    related_meetings: list[str]
    related_people: list[str]
    related_action_items: list[ActionItem]


# ============================================================================
# Coaching
# ============================================================================


class CoachingHint(BaseModel):
    category: str  # from CoachingCategory
    message: str
    severity: str = "info"  # info, warning, critical
    participant_id: str | None = None
    metric_value: float | None = None


class CoachingReport(BaseModel):
    meeting_id: str
    participant_id: str
    hints: list[CoachingHint]
    overall_score: float = Field(ge=0.0, le=100.0, default=50.0)
    strengths: list[str]
    improvements: list[str]


# ============================================================================
# Outcome Predictor
# ============================================================================


class OutcomePrediction(BaseModel):
    meeting_id: str
    prediction_type: str  # "conversion", "deal_close", "interview_success", "alignment"
    probability: float = Field(ge=0.0, le=1.0)
    confidence: float = Field(ge=0.0, le=1.0)
    reasoning: str
    risk_factors: list[str]
    positive_signals: list[str]


# ============================================================================
# Meeting Replay
# ============================================================================


class ReplayChapter(BaseModel):
    title: str
    start_time: float
    end_time: float
    summary: str
    highlights: list[str]
    is_key_moment: bool = False


class MeetingReplay(BaseModel):
    meeting_id: str
    chapters: list[ReplayChapter]
    key_clips: list[dict[str, Any]]
    conflict_highlights: list[dict[str, Any]]
    best_moments: list[dict[str, Any]]
    promises: list[dict[str, Any]]


# ============================================================================
# Relationship Intelligence
# ============================================================================


class RelationshipProfile(BaseModel):
    user_id: str
    target_user_id: str
    communication_style: str | None = None
    preferred_pace: str | None = None
    conflict_triggers: list[str] = Field(default_factory=list)
    best_pitch_time: str | None = None
    historical_dynamics: str | None = None
    interaction_count: int = 0
    last_interaction: datetime | None = None


# ============================================================================
# Knowledge Gap Detection
# ============================================================================


class KnowledgeGap(BaseModel):
    topic: str
    mentioned_at: float
    description: str
    suggested_question: str
    severity: str = "info"
