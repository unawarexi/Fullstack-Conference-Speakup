# SpeakUp AI — Kafka Event Handlers
# Wires Express backend events to AI processing pipelines
from __future__ import annotations

from typing import Any

from app.core.constants import KafkaTopics, MeetingAIState, RedisKeys
from app.core.logging import get_logger
from app.services.agents.orchestrator import run_live_analysis, run_post_meeting_analysis
from app.services.speech.transcription import transcribe_audio
from infrastructure.kafka.consumers import on_topic
from infrastructure.redis.client import delete_pattern, get_cache, set_cache

log = get_logger("event_handlers")


# ============================================================================
# Meeting Lifecycle Events (from Express)
# ============================================================================


@on_topic(KafkaTopics.MEETING_EVENTS)
async def handle_meeting_event(key: str, value: dict, **kwargs: Any) -> None:
    """React to meeting lifecycle from Express backend."""
    event_type = value.get("type") or value.get("event")
    meeting_id = value.get("meeting_id") or key

    if event_type == "meeting.started":
        log.info("Meeting started — initializing AI pipeline", meeting_id=meeting_id)
        await set_cache(
            RedisKeys.MEETING_AI_STATE.format(meeting_id=meeting_id),
            {
                "status": MeetingAIState.LISTENING,
                "started_at": value.get("timestamp"),
                "participants": value.get("participant_ids", []),
                "title": value.get("title"),
                "iteration": 0,
            },
            ttl_seconds=28800,  # 8h max meeting
        )

    elif event_type == "meeting.ended":
        log.info("Meeting ended — triggering post-meeting analysis", meeting_id=meeting_id)

        # Get accumulated transcript
        transcript_data = await get_cache(
            RedisKeys.MEETING_TRANSCRIPT.format(meeting_id=meeting_id)
        ) or {}

        meeting_state = await get_cache(
            RedisKeys.MEETING_AI_STATE.format(meeting_id=meeting_id)
        ) or {}

        if transcript_data.get("full_text"):
            await run_post_meeting_analysis(
                meeting_id=meeting_id,
                participant_ids=meeting_state.get("participants", []),
                transcript=transcript_data["full_text"],
                transcript_segments=transcript_data.get("segments", []),
                meeting_title=meeting_state.get("title"),
            )

    elif event_type == "meeting.updated":
        # Update cached meeting context
        meeting_state = await get_cache(
            RedisKeys.MEETING_AI_STATE.format(meeting_id=meeting_id)
        ) or {}
        meeting_state.update({
            "title": value.get("title", meeting_state.get("title")),
        })
        await set_cache(
            RedisKeys.MEETING_AI_STATE.format(meeting_id=meeting_id),
            meeting_state,
            ttl_seconds=28800,
        )


# ============================================================================
# Participant Events
# ============================================================================


@on_topic(KafkaTopics.PARTICIPANT_EVENTS)
async def handle_participant_event(key: str, value: dict, **kwargs: Any) -> None:
    """Track participant join/leave for AI context."""
    event_type = value.get("type") or value.get("event")
    meeting_id = value.get("meeting_id") or key
    user_id = value.get("user_id")

    meeting_state = await get_cache(
        RedisKeys.MEETING_AI_STATE.format(meeting_id=meeting_id)
    ) or {}

    participants = meeting_state.get("participants", [])

    if event_type == "participant.joined" and user_id and user_id not in participants:
        participants.append(user_id)
        meeting_state["participants"] = participants
        await set_cache(
            RedisKeys.MEETING_AI_STATE.format(meeting_id=meeting_id),
            meeting_state,
            ttl_seconds=28800,
        )
        log.debug("Participant joined AI tracking", meeting_id=meeting_id, user_id=user_id)

    elif event_type == "participant.left" and user_id and user_id in participants:
        # Don't remove — keep for summary context
        log.debug("Participant left", meeting_id=meeting_id, user_id=user_id)


# ============================================================================
# Media Stream Events (audio chunks → transcription → analysis)
# ============================================================================


@on_topic(KafkaTopics.MEDIA_AUDIO_CHUNKS)
async def handle_audio_chunk(key: str, value: dict, **kwargs: Any) -> None:
    """Process incoming audio chunks for real-time transcription."""
    meeting_id = value.get("meeting_id") or key
    participant_id = value.get("participant_id")
    audio_b64 = value.get("audio_data")

    if not audio_b64:
        return

    import base64
    audio_bytes = base64.b64decode(audio_b64)

    # Transcribe
    result = await transcribe_audio(
        audio_data=audio_bytes,
        meeting_id=meeting_id,
        participant_id=participant_id,
    )

    # Periodically run full live analysis
    meeting_state = await get_cache(
        RedisKeys.MEETING_AI_STATE.format(meeting_id=meeting_id)
    ) or {}

    iteration = meeting_state.get("iteration", 0) + 1
    meeting_state["iteration"] = iteration

    # Run full analysis every 5 audio chunks (roughly every 30-60 seconds)
    if iteration % 5 == 0:
        transcript_data = await get_cache(
            RedisKeys.MEETING_TRANSCRIPT.format(meeting_id=meeting_id)
        ) or {}

        await run_live_analysis(
            meeting_id=meeting_id,
            participant_ids=meeting_state.get("participants", []),
            transcript=transcript_data.get("full_text", ""),
            transcript_segments=transcript_data.get("segments", []),
            meeting_title=meeting_state.get("title"),
            iteration=iteration,
        )

    await set_cache(
        RedisKeys.MEETING_AI_STATE.format(meeting_id=meeting_id),
        meeting_state,
        ttl_seconds=28800,
    )


# ============================================================================
# Video Frame Events
# ============================================================================


@on_topic(KafkaTopics.MEDIA_VIDEO_FRAMES)
async def handle_video_frame(key: str, value: dict, **kwargs: Any) -> None:
    """Process video frames for CV analysis."""
    from app.services.cv.vision import analyze_frame
    import base64

    meeting_id = value.get("meeting_id") or key
    participant_id = value.get("participant_id")
    frame_b64 = value.get("frame_data")

    if not frame_b64 or not participant_id:
        return

    frame_bytes = base64.b64decode(frame_b64)

    await analyze_frame(
        frame_bytes=frame_bytes,
        meeting_id=meeting_id,
        participant_id=participant_id,
        width=value.get("width", 640),
        height=value.get("height", 480),
    )


# ============================================================================
# Chat Messages
# ============================================================================


@on_topic(KafkaTopics.CHAT_MESSAGES)
async def handle_chat_message(key: str, value: dict, **kwargs: Any) -> None:
    """Analyze chat messages for sentiment and context."""
    meeting_id = value.get("meeting_id") or key
    content = value.get("content", "")
    sender_id = value.get("sender_id")

    if not content or not sender_id:
        return

    # Update emotion analysis with text signal
    from app.services.emotion.analyzer import analyze_multimodal_emotion
    await analyze_multimodal_emotion(
        meeting_id=meeting_id,
        participant_id=sender_id,
        recent_text=content,
    )
