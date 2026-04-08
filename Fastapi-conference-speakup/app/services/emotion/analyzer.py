# SpeakUp AI — Emotion / Multimodal Signal Service
# Combines voice tone + facial expression + text sentiment for soft signals
from __future__ import annotations

import asyncio
import time
from typing import Any

from app.core.constants import EMOTION_SIGNALS, KafkaTopics, RedisKeys
from app.core.logging import get_logger
from app.schemas.ai_schemas import EmotionSignal, MultimodalEmotionResult
from infrastructure.kafka.producer import publish_event
from infrastructure.redis.client import get_cache, publish, set_cache

log = get_logger("emotion_service")


async def analyze_multimodal_emotion(
    meeting_id: str,
    participant_id: str,
    voice_features: dict[str, float] | None = None,
    face_analysis: dict[str, Any] | None = None,
    recent_text: str | None = None,
    response_latency_ms: float | None = None,
) -> MultimodalEmotionResult:
    """
    Fuse multimodal signals into probabilistic emotion indicators.
    
    IMPORTANT: Per README ethics guidelines, we output SOFT SIGNALS only.
    Never hard labels like "angry" or "lying".
    """
    signals: list[EmotionSignal] = []
    modalities_used: list[str] = []
    engagement_components: list[float] = []

    # ── Voice Analysis ──
    if voice_features:
        modalities_used.append("voice")
        pitch_variance = voice_features.get("pitch_variance", 0)
        speaking_speed = voice_features.get("speaking_speed_wpm", 0)
        pause_ratio = voice_features.get("pause_ratio", 0)
        volume_level = voice_features.get("volume_level", 0.5)

        # High pitch variance + fast speech → possible excitement or stress
        if pitch_variance > 0.7 and speaking_speed > 160:
            signals.append(EmotionSignal(
                signal_type="excitement",
                confidence=min(0.9, pitch_variance * 0.8),
                description=EMOTION_SIGNALS["excitement"],
            ))

        # Low volume + many pauses → possible fatigue
        if volume_level < 0.3 and pause_ratio > 0.4:
            signals.append(EmotionSignal(
                signal_type="fatigue",
                confidence=min(0.85, pause_ratio),
                description=EMOTION_SIGNALS["fatigue"],
            ))

        # Very slow + low pitch variance → disengagement
        if speaking_speed < 90 and pitch_variance < 0.2 and speaking_speed > 0:
            signals.append(EmotionSignal(
                signal_type="engagement_drop",
                confidence=0.65,
                description=EMOTION_SIGNALS["engagement_drop"],
            ))
            engagement_components.append(0.3)
        else:
            engagement_components.append(min(1.0, speaking_speed / 150))

    # ── Face Analysis ──
    if face_analysis:
        modalities_used.append("face")
        eye_contact = face_analysis.get("eye_contact_score", 0.5)
        smile_score = face_analysis.get("smile_score", 0)
        face_detected = face_analysis.get("face_detected", False)

        if face_detected:
            # Low eye contact → possible confusion or distraction
            if eye_contact < 0.3:
                signals.append(EmotionSignal(
                    signal_type="possible_confusion",
                    confidence=min(0.75, 1.0 - eye_contact),
                    description=EMOTION_SIGNALS["possible_confusion"],
                ))

            # High eye contact + smile → engaged and confident
            if eye_contact > 0.7 and smile_score > 0.4:
                signals.append(EmotionSignal(
                    signal_type="high_confidence",
                    confidence=min(0.85, (eye_contact + smile_score) / 2),
                    description=EMOTION_SIGNALS["high_confidence"],
                ))

            # Good eye contact, no other negative signals → calm/focused
            if eye_contact > 0.5 and smile_score < 0.3:
                signals.append(EmotionSignal(
                    signal_type="calm_focused",
                    confidence=eye_contact * 0.7,
                    description=EMOTION_SIGNALS["calm_focused"],
                ))

            engagement_components.append(eye_contact)

    # ── Response Latency ──
    if response_latency_ms is not None:
        # Long delay before responding → hesitation
        if response_latency_ms > 3000:
            signals.append(EmotionSignal(
                signal_type="hesitation",
                confidence=min(0.8, response_latency_ms / 10000),
                description=EMOTION_SIGNALS["hesitation"],
            ))

    # ── Text Sentiment (lightweight) ──
    if recent_text:
        modalities_used.append("text")
        # Simple keyword-based fallback (LLM-based analysis is in copilot service)
        text_lower = recent_text.lower()
        negative_markers = ["but", "however", "concerned", "issue", "problem", "disagree", "not sure", "worried"]
        positive_markers = ["great", "agree", "excellent", "perfect", "love", "happy", "excited", "amazing"]

        neg_count = sum(1 for m in negative_markers if m in text_lower)
        pos_count = sum(1 for m in positive_markers if m in text_lower)

        if neg_count > pos_count and neg_count >= 2:
            signals.append(EmotionSignal(
                signal_type="possible_frustration",
                confidence=min(0.6, neg_count * 0.15),
                description=EMOTION_SIGNALS["possible_frustration"],
            ))

    # ── Composite Engagement Score ──
    engagement_score = sum(engagement_components) / len(engagement_components) if engagement_components else 0.5

    # ── Dominant signal ──
    dominant = max(signals, key=lambda s: s.confidence).signal_type if signals else None

    result = MultimodalEmotionResult(
        meeting_id=meeting_id,
        participant_id=participant_id,
        timestamp=time.time(),
        signals=signals,
        dominant_signal=dominant,
        engagement_score=round(engagement_score, 3),
        modalities_used=modalities_used,
    )

    # Cache emotion state
    cache_key = RedisKeys.MEETING_EMOTIONS.format(meeting_id=meeting_id)
    existing_emotions = await get_cache(cache_key) or {}
    existing_emotions[participant_id] = result.model_dump()
    await set_cache(cache_key, existing_emotions, ttl_seconds=300)

    # Publish to Kafka
    await publish_event(
        KafkaTopics.AI_EMOTION_SIGNALS,
        key=meeting_id,
        value=result.model_dump(),
    )

    # Real-time push
    await publish(
        RedisKeys.CHANNEL_AI_INSIGHTS.format(meeting_id=meeting_id),
        {"type": "emotion_signals", "data": result.model_dump()},
    )

    log.debug(
        "Emotion analysis",
        meeting_id=meeting_id,
        participant_id=participant_id,
        signals=len(signals),
        engagement=engagement_score,
        dominant=dominant,
    )

    return result


async def get_meeting_emotions(meeting_id: str) -> dict[str, Any]:
    """Get current emotion state for all participants in a meeting."""
    cache_key = RedisKeys.MEETING_EMOTIONS.format(meeting_id=meeting_id)
    return await get_cache(cache_key) or {}
