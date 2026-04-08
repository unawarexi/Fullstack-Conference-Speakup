# SpeakUp AI — LangGraph Agent Orchestrator
# Stateful multi-agent pipeline for real-time meeting intelligence
from __future__ import annotations

import time
from typing import Annotated, Any, TypedDict

from langgraph.graph import END, StateGraph
from langgraph.graph.message import add_messages

from app.core.constants import KafkaTopics, MeetingAIState, RedisKeys
from app.core.logging import get_logger
from app.services.copilot.suggestions import (
    detect_knowledge_gaps,
    generate_live_suggestions,
    predict_outcome,
)
from app.services.emotion.analyzer import analyze_multimodal_emotion
from app.services.memory.meeting_memory import (
    generate_meeting_summary,
    store_meeting_memory,
)
from app.services.speech.transcription import analyze_speech, get_meeting_transcript
from infrastructure.kafka.producer import publish_event
from infrastructure.redis.client import get_cache, publish, set_cache

log = get_logger("agent_orchestrator")


# ============================================================================
# Agent State
# ============================================================================


class MeetingAgentState(TypedDict):
    """State shared across all agent nodes in the graph."""
    meeting_id: str
    participant_ids: list[str]
    meeting_title: str | None
    meeting_type: str
    status: str  # MeetingAIState

    # Accumulated data
    transcript: str
    transcript_segments: list[dict]
    emotion_signals: dict[str, Any]
    cv_data: dict[str, Any]
    speech_analyses: dict[str, Any]  # per participant

    # Outputs
    suggestions: list[dict]
    coaching_hints: list[dict]
    knowledge_gaps: list[dict]
    outcome_prediction: dict | None
    summary: dict | None
    errors: list[str]

    # Control
    messages: Annotated[list, add_messages]
    iteration: int


# ============================================================================
# Agent Nodes
# ============================================================================


async def transcription_analysis_node(state: MeetingAgentState) -> dict:
    """Analyze transcript for speech patterns per participant."""
    try:
        from app.schemas.ai_schemas import TranscriptionSegment

        speech_analyses = {}
        for pid in state["participant_ids"]:
            segments = [
                TranscriptionSegment(**s)
                for s in state.get("transcript_segments", [])
                if s.get("speaker") == pid
            ]
            if segments:
                analysis = await analyze_speech(
                    segments, state["meeting_id"], pid,
                )
                speech_analyses[pid] = analysis.model_dump()

        return {"speech_analyses": speech_analyses}
    except Exception as e:
        log.exception("Transcription analysis error", meeting_id=state["meeting_id"])
        return {"errors": state.get("errors", []) + [f"transcription_analysis: {e}"]}


async def emotion_fusion_node(state: MeetingAgentState) -> dict:
    """Fuse multimodal signals for each participant."""
    try:
        emotion_signals = {}
        for pid in state["participant_ids"]:
            speech_data = state.get("speech_analyses", {}).get(pid, {})
            cv_data = state.get("cv_data", {}).get(pid, {})

            voice_features = {}
            if speech_data:
                voice_features = {
                    "speaking_speed_wpm": speech_data.get("speaking_speed_wpm", 0),
                    "pitch_variance": speech_data.get("confidence_score", 0.5),
                    "pause_ratio": speech_data.get("silence_ratio", 0),
                }

            face_analysis = cv_data.get("face") if cv_data else None

            result = await analyze_multimodal_emotion(
                meeting_id=state["meeting_id"],
                participant_id=pid,
                voice_features=voice_features or None,
                face_analysis=face_analysis,
            )
            emotion_signals[pid] = result.model_dump()

        return {"emotion_signals": emotion_signals}
    except Exception as e:
        log.exception("Emotion fusion error", meeting_id=state["meeting_id"])
        return {"errors": state.get("errors", []) + [f"emotion_fusion: {e}"]}


async def copilot_node(state: MeetingAgentState) -> dict:
    """Generate real-time copilot suggestions."""
    try:
        transcript = state.get("transcript", "")
        if len(transcript) < 50:
            return {"suggestions": []}

        result = await generate_live_suggestions(
            meeting_id=state["meeting_id"],
            recent_transcript=transcript[-3000:],
            emotion_signals=state.get("emotion_signals"),
            meeting_context={
                "title": state.get("meeting_title"),
                "type": state.get("meeting_type"),
                "participants": state.get("participant_ids"),
            },
        )
        return {"suggestions": [s.model_dump() for s in result.suggestions]}
    except Exception as e:
        log.exception("Copilot node error", meeting_id=state["meeting_id"])
        return {"errors": state.get("errors", []) + [f"copilot: {e}"]}


async def knowledge_gap_node(state: MeetingAgentState) -> dict:
    """Detect unexplained topics."""
    try:
        transcript = state.get("transcript", "")
        if len(transcript) < 200:
            return {"knowledge_gaps": []}

        gaps = await detect_knowledge_gaps(state["meeting_id"], transcript)
        return {"knowledge_gaps": [g.model_dump() for g in gaps]}
    except Exception as e:
        log.exception("Knowledge gap error", meeting_id=state["meeting_id"])
        return {"errors": state.get("errors", []) + [f"knowledge_gaps: {e}"]}


async def outcome_prediction_node(state: MeetingAgentState) -> dict:
    """Predict meeting outcome."""
    try:
        transcript = state.get("transcript", "")
        if len(transcript) < 500:
            return {"outcome_prediction": None}

        result = await predict_outcome(
            meeting_id=state["meeting_id"],
            transcript=transcript,
            emotion_data=state.get("emotion_signals", {}),
            meeting_type=state.get("meeting_type", "general"),
        )
        return {"outcome_prediction": result.model_dump()}
    except Exception as e:
        log.exception("Outcome prediction error", meeting_id=state["meeting_id"])
        return {"errors": state.get("errors", []) + [f"outcome_prediction: {e}"]}


async def summary_node(state: MeetingAgentState) -> dict:
    """Generate final meeting summary (called when meeting ends)."""
    try:
        transcript = state.get("transcript", "")
        if not transcript:
            return {"summary": None}

        summary = await generate_meeting_summary(
            meeting_id=state["meeting_id"],
            transcript=transcript,
            participant_names=state.get("participant_ids"),
            meeting_title=state.get("meeting_title"),
            duration_minutes=0,
            participant_count=len(state.get("participant_ids", [])),
        )

        # Store in memory graph
        await store_meeting_memory(
            meeting_id=state["meeting_id"],
            summary=summary,
            participant_ids=state.get("participant_ids", []),
        )

        return {"summary": summary.model_dump(), "status": MeetingAIState.COMPLETED}
    except Exception as e:
        log.exception("Summary generation error", meeting_id=state["meeting_id"])
        return {"errors": state.get("errors", []) + [f"summary: {e}"], "status": MeetingAIState.ERROR}


# ============================================================================
# Routing Logic
# ============================================================================


def should_generate_summary(state: MeetingAgentState) -> str:
    """Route: if meeting ended, go to summary; otherwise continue live analysis."""
    if state.get("status") == MeetingAIState.SUMMARIZING:
        return "summary"
    return "continue"


def should_predict_outcome(state: MeetingAgentState) -> str:
    """Only predict if enough data accumulated."""
    transcript = state.get("transcript", "")
    iteration = state.get("iteration", 0)
    if len(transcript) > 500 and iteration % 5 == 0:
        return "predict"
    return "skip"


# ============================================================================
# Graph Construction
# ============================================================================


def build_live_analysis_graph() -> StateGraph:
    """Build the real-time meeting analysis agent graph."""
    graph = StateGraph(MeetingAgentState)

    # Add nodes
    graph.add_node("transcription_analysis", transcription_analysis_node)
    graph.add_node("emotion_fusion", emotion_fusion_node)
    graph.add_node("copilot", copilot_node)
    graph.add_node("knowledge_gaps", knowledge_gap_node)
    graph.add_node("outcome_prediction", outcome_prediction_node)
    graph.add_node("summary", summary_node)

    # Entry point
    graph.set_entry_point("transcription_analysis")

    # Flow: transcription → emotion → copilot + knowledge gaps (parallel)
    graph.add_edge("transcription_analysis", "emotion_fusion")

    # After emotion, conditionally route
    graph.add_conditional_edges(
        "emotion_fusion",
        should_generate_summary,
        {
            "summary": "summary",
            "continue": "copilot",
        },
    )

    graph.add_edge("copilot", "knowledge_gaps")

    graph.add_conditional_edges(
        "knowledge_gaps",
        should_predict_outcome,
        {
            "predict": "outcome_prediction",
            "skip": END,
        },
    )

    graph.add_edge("outcome_prediction", END)
    graph.add_edge("summary", END)

    return graph


def build_post_meeting_graph() -> StateGraph:
    """Build the post-meeting processing graph (summary + memory storage)."""
    graph = StateGraph(MeetingAgentState)

    graph.add_node("summary", summary_node)
    graph.set_entry_point("summary")
    graph.add_edge("summary", END)

    return graph


# ============================================================================
# Compiled Graphs (singletons)
# ============================================================================

_live_graph = None
_post_meeting_graph = None


def get_live_graph():
    global _live_graph
    if _live_graph is None:
        _live_graph = build_live_analysis_graph().compile()
    return _live_graph


def get_post_meeting_graph():
    global _post_meeting_graph
    if _post_meeting_graph is None:
        _post_meeting_graph = build_post_meeting_graph().compile()
    return _post_meeting_graph


# ============================================================================
# High-Level Orchestration API
# ============================================================================


async def run_live_analysis(
    meeting_id: str,
    participant_ids: list[str],
    transcript: str,
    transcript_segments: list[dict],
    cv_data: dict[str, Any] | None = None,
    meeting_title: str | None = None,
    meeting_type: str = "general",
    iteration: int = 0,
) -> dict[str, Any]:
    """Run the live analysis graph once with current meeting state."""

    # Update AI state
    await set_cache(
        RedisKeys.MEETING_AI_STATE.format(meeting_id=meeting_id),
        {"status": MeetingAIState.PROCESSING, "iteration": iteration},
        ttl_seconds=600,
    )

    graph = get_live_graph()
    state = MeetingAgentState(
        meeting_id=meeting_id,
        participant_ids=participant_ids,
        meeting_title=meeting_title,
        meeting_type=meeting_type,
        status=MeetingAIState.LISTENING,
        transcript=transcript,
        transcript_segments=transcript_segments,
        emotion_signals={},
        cv_data=cv_data or {},
        speech_analyses={},
        suggestions=[],
        coaching_hints=[],
        knowledge_gaps=[],
        outcome_prediction=None,
        summary=None,
        errors=[],
        messages=[],
        iteration=iteration,
    )

    result = await graph.ainvoke(state)

    # Publish live insights aggregate
    await publish_event(
        KafkaTopics.AI_LIVE_INSIGHTS,
        key=meeting_id,
        value={
            "meeting_id": meeting_id,
            "iteration": iteration,
            "suggestions": result.get("suggestions", []),
            "emotion_signals": result.get("emotion_signals", {}),
            "knowledge_gaps": result.get("knowledge_gaps", []),
            "outcome_prediction": result.get("outcome_prediction"),
            "errors": result.get("errors", []),
        },
    )

    # Push to real-time channel
    await publish(
        RedisKeys.CHANNEL_AI_INSIGHTS.format(meeting_id=meeting_id),
        {
            "type": "live_insights",
            "iteration": iteration,
            "suggestions": result.get("suggestions", []),
            "emotion_signals": result.get("emotion_signals", {}),
        },
    )

    log.info(
        "Live analysis complete",
        meeting_id=meeting_id,
        iteration=iteration,
        suggestions=len(result.get("suggestions", [])),
    )

    return result


async def run_post_meeting_analysis(
    meeting_id: str,
    participant_ids: list[str],
    transcript: str,
    transcript_segments: list[dict],
    meeting_title: str | None = None,
) -> dict[str, Any]:
    """Run post-meeting summary + memory storage."""

    await set_cache(
        RedisKeys.MEETING_AI_STATE.format(meeting_id=meeting_id),
        {"status": MeetingAIState.SUMMARIZING},
        ttl_seconds=600,
    )

    graph = get_post_meeting_graph()
    state = MeetingAgentState(
        meeting_id=meeting_id,
        participant_ids=participant_ids,
        meeting_title=meeting_title,
        meeting_type="general",
        status=MeetingAIState.SUMMARIZING,
        transcript=transcript,
        transcript_segments=transcript_segments,
        emotion_signals={},
        cv_data={},
        speech_analyses={},
        suggestions=[],
        coaching_hints=[],
        knowledge_gaps=[],
        outcome_prediction=None,
        summary=None,
        errors=[],
        messages=[],
        iteration=0,
    )

    result = await graph.ainvoke(state)

    await set_cache(
        RedisKeys.MEETING_AI_STATE.format(meeting_id=meeting_id),
        {"status": result.get("status", MeetingAIState.COMPLETED)},
        ttl_seconds=86400,
    )

    log.info("Post-meeting analysis complete", meeting_id=meeting_id)
    return result
