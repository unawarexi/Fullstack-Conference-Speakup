# SpeakUp AI — Live Conversation Copilot Service
# Real-time AI suggestions during meetings using LLM
from __future__ import annotations

import time
from typing import Any

from app.core.config import get_settings
from app.core.constants import KafkaTopics, RedisKeys
from app.core.logging import get_logger
from app.services.llm.router import TaskType, get_llm_router
from app.schemas.ai_schemas import (
    CopilotStreamResponse,
    CopilotSuggestion,
    CoachingHint,
    CoachingReport,
    KnowledgeGap,
    OutcomePrediction,
    SuggestionType,
)
from infrastructure.kafka.producer import publish_event
from infrastructure.redis.client import get_cache, publish, set_cache

log = get_logger("copilot_service")

COPILOT_SYSTEM_PROMPT = """You are the real-time Conversation Copilot for SpeakUp, an AI-native video calling platform.

Your role: analyze the ongoing conversation and provide HIGH-VALUE, ACTIONABLE suggestions.

RULES:
- Output JSON array of suggestions only
- Each suggestion: {"type": "<type>", "content": "<actionable text>", "reasoning": "<why>", "priority": <0-1>}
- Types: question, clarification, empathy, negotiation, technical, agenda, conflict, phrasing, coaching
- Maximum 3 suggestions per analysis
- Only surface suggestions with priority >= 0.5
- Never infer race, ethnicity, or nationality
- Use probabilistic language for emotion cues
- Avoid interrupting during high-focus discussion segments
- Be concise — each suggestion should be 1-2 sentences max

CONTEXT you receive:
- Recent transcript segments
- Emotion signals for participants
- Meeting metadata (type, agenda, participants)
- Historical context from memory graph (if available)

RESPOND with a JSON array. Nothing else."""

COACHING_SYSTEM_PROMPT = """You are a Communication Coach for SpeakUp video calls.
Analyze participant behavior metrics and provide constructive coaching hints.
Be encouraging but honest. Focus on actionable improvements.
Output JSON: {"hints": [...], "strengths": [...], "improvements": [...], "overall_score": <0-100>}"""

OUTCOME_SYSTEM_PROMPT = """You are a Meeting Outcome Predictor.
Based on conversation dynamics, sentiment, and engagement patterns, predict meeting outcomes.
Use probabilistic language. Be calibrated — don't overstate confidence.
Output JSON: {"prediction_type": "...", "probability": 0-1, "confidence": 0-1, "reasoning": "...", "risk_factors": [...], "positive_signals": [...]}"""

KNOWLEDGE_GAP_PROMPT = """You are a Knowledge Gap Detector for technical meetings.
Identify topics that were mentioned but not fully explained, or areas where participants seem confused.
Suggest clarifying questions.
Output JSON array: [{"topic": "...", "description": "...", "suggested_question": "...", "severity": "info|warning"}]"""


def _get_router():
    return get_llm_router()


async def generate_live_suggestions(
    meeting_id: str,
    recent_transcript: str,
    emotion_signals: dict[str, Any] | None = None,
    meeting_context: dict[str, Any] | None = None,
    memory_context: str | None = None,
) -> CopilotStreamResponse:
    """Generate real-time copilot suggestions for the meeting."""
    router = _get_router()

    context_parts = [f"## Recent Transcript\n{recent_transcript}"]
    if emotion_signals:
        context_parts.append(f"## Emotion Signals\n{emotion_signals}")
    if meeting_context:
        context_parts.append(f"## Meeting Context\n{meeting_context}")
    if memory_context:
        context_parts.append(f"## Historical Memory\n{memory_context}")

    user_content = "\n\n".join(context_parts)

    response = await router.chat(
        [{"role": "system", "content": COPILOT_SYSTEM_PROMPT}, {"role": "user", "content": user_content}],
        task_type=TaskType.COPILOT_SUGGESTIONS,
    )

    # Parse LLM response
    import orjson
    try:
        raw_suggestions = orjson.loads(response.content)
        if isinstance(raw_suggestions, dict) and "suggestions" in raw_suggestions:
            raw_suggestions = raw_suggestions["suggestions"]
    except Exception:
        log.warning("Failed to parse copilot response", raw=response.content[:200])
        raw_suggestions = []

    suggestions = []
    for s in raw_suggestions[:3]:
        try:
            suggestions.append(CopilotSuggestion(
                type=SuggestionType(s.get("type", "question")),
                content=s.get("content", ""),
                reasoning=s.get("reasoning", ""),
                priority=float(s.get("priority", 0.5)),
                target_participant=s.get("target_participant"),
            ))
        except (ValueError, KeyError):
            continue

    # Filter low-priority suggestions
    suggestions = [s for s in suggestions if s.priority >= 0.5]

    result = CopilotStreamResponse(
        meeting_id=meeting_id,
        timestamp=time.time(),
        suggestions=suggestions,
    )

    # Publish suggestions
    if suggestions:
        await publish_event(
            KafkaTopics.AI_COPILOT_SUGGESTIONS,
            key=meeting_id,
            value=result.model_dump(),
        )
        await publish(
            RedisKeys.CHANNEL_AI_COPILOT.format(meeting_id=meeting_id),
            result.model_dump(),
        )

    log.info("Copilot suggestions generated", meeting_id=meeting_id, count=len(suggestions))
    return result


async def generate_coaching_report(
    meeting_id: str,
    participant_id: str,
    speech_analysis: dict[str, Any],
    emotion_history: list[dict[str, Any]],
    cv_analysis_history: list[dict[str, Any]],
) -> CoachingReport:
    """Generate post-meeting coaching report for a participant."""
    router = _get_router()

    user_content = f"""## Participant Metrics
Speech Analysis: {speech_analysis}
Emotion History: {emotion_history[-20:]}
CV Analysis History: {cv_analysis_history[-20:]}
"""

    response = await router.chat(
        [{"role": "system", "content": COACHING_SYSTEM_PROMPT}, {"role": "user", "content": user_content}],
        task_type=TaskType.COACHING_REPORT,
    )

    import orjson
    try:
        data = orjson.loads(response.content)
    except Exception:
        data = {"hints": [], "strengths": [], "improvements": [], "overall_score": 50}

    hints = [
        CoachingHint(
            category=h.get("category", "general"),
            message=h.get("message", ""),
            severity=h.get("severity", "info"),
            participant_id=participant_id,
        )
        for h in data.get("hints", [])
    ]

    return CoachingReport(
        meeting_id=meeting_id,
        participant_id=participant_id,
        hints=hints,
        overall_score=data.get("overall_score", 50),
        strengths=data.get("strengths", []),
        improvements=data.get("improvements", []),
    )


async def predict_outcome(
    meeting_id: str,
    transcript: str,
    emotion_data: dict[str, Any],
    meeting_type: str = "general",
) -> OutcomePrediction:
    """Predict meeting outcome probability."""
    router = _get_router()

    user_content = f"""Meeting type: {meeting_type}
Transcript (last 2000 chars): {transcript[-2000:]}
Emotion signals: {emotion_data}
"""

    response = await router.chat(
        [{"role": "system", "content": OUTCOME_SYSTEM_PROMPT}, {"role": "user", "content": user_content}],
        task_type=TaskType.OUTCOME_PREDICTION,
    )

    import orjson
    try:
        data = orjson.loads(response.content)
    except Exception:
        data = {}

    return OutcomePrediction(
        meeting_id=meeting_id,
        prediction_type=data.get("prediction_type", "alignment"),
        probability=data.get("probability", 0.5),
        confidence=data.get("confidence", 0.3),
        reasoning=data.get("reasoning", "Insufficient data"),
        risk_factors=data.get("risk_factors", []),
        positive_signals=data.get("positive_signals", []),
    )


async def detect_knowledge_gaps(
    meeting_id: str,
    transcript: str,
) -> list[KnowledgeGap]:
    """Detect unexplained topics in technical discussions."""
    router = _get_router()

    response = await router.chat(
        [{"role": "system", "content": KNOWLEDGE_GAP_PROMPT}, {"role": "user", "content": f"Transcript:\n{transcript[-3000:]}"}],
        task_type=TaskType.KNOWLEDGE_GAP,
    )

    import orjson
    try:
        data = orjson.loads(response.content)
        if isinstance(data, dict) and "gaps" in data:
            data = data["gaps"]
    except Exception:
        data = []

    return [
        KnowledgeGap(
            topic=g.get("topic", ""),
            mentioned_at=0.0,
            description=g.get("description", ""),
            suggested_question=g.get("suggested_question", ""),
            severity=g.get("severity", "info"),
        )
        for g in data[:5]
    ]
