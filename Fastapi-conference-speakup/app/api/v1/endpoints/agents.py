# SpeakUp AI — Agent Orchestrator API Endpoints
from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Depends
from pydantic import BaseModel

from app.core.constants import RedisKeys
from app.core.security import verify_internal_api_key
from app.services.agents.orchestrator import run_live_analysis, run_post_meeting_analysis
from infrastructure.redis.client import get_cache

router = APIRouter(prefix="/agents", tags=["Agent Orchestrator"])


class LiveAnalysisRequest(BaseModel):
    meeting_id: str
    participant_ids: list[str]
    transcript: str
    transcript_segments: list[dict] = []
    cv_data: dict[str, Any] | None = None
    meeting_title: str | None = None
    meeting_type: str = "general"
    iteration: int = 0


class PostMeetingRequest(BaseModel):
    meeting_id: str
    participant_ids: list[str]
    transcript: str
    transcript_segments: list[dict] = []
    meeting_title: str | None = None


@router.post("/live-analysis")
async def trigger_live_analysis(
    request: LiveAnalysisRequest,
    _auth: bool = Depends(verify_internal_api_key),
):
    """Trigger full LangGraph live analysis pipeline. Express calls this periodically."""
    result = await run_live_analysis(
        meeting_id=request.meeting_id,
        participant_ids=request.participant_ids,
        transcript=request.transcript,
        transcript_segments=request.transcript_segments,
        cv_data=request.cv_data,
        meeting_title=request.meeting_title,
        meeting_type=request.meeting_type,
        iteration=request.iteration,
    )
    return {
        "meeting_id": request.meeting_id,
        "suggestions": result.get("suggestions", []),
        "emotion_signals": result.get("emotion_signals", {}),
        "knowledge_gaps": result.get("knowledge_gaps", []),
        "outcome_prediction": result.get("outcome_prediction"),
        "errors": result.get("errors", []),
    }


@router.post("/post-meeting")
async def trigger_post_meeting(
    request: PostMeetingRequest,
    _auth: bool = Depends(verify_internal_api_key),
):
    """Trigger post-meeting summary + memory storage pipeline."""
    result = await run_post_meeting_analysis(
        meeting_id=request.meeting_id,
        participant_ids=request.participant_ids,
        transcript=request.transcript,
        transcript_segments=request.transcript_segments,
        meeting_title=request.meeting_title,
    )
    return {
        "meeting_id": request.meeting_id,
        "summary": result.get("summary"),
        "status": result.get("status"),
        "errors": result.get("errors", []),
    }


@router.get("/state/{meeting_id}")
async def get_agent_state(
    meeting_id: str,
    _auth: bool = Depends(verify_internal_api_key),
):
    """Get current AI agent state for a meeting."""
    state = await get_cache(RedisKeys.MEETING_AI_STATE.format(meeting_id=meeting_id))
    return state or {"status": "idle", "meeting_id": meeting_id}
