# SpeakUp AI — Copilot API Endpoints
from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Depends
from pydantic import BaseModel

from app.core.security import verify_internal_api_key
from app.schemas.ai_schemas import (
    CoachingReport,
    CopilotStreamResponse,
    KnowledgeGap,
    OutcomePrediction,
)
from app.services.copilot.suggestions import (
    detect_knowledge_gaps,
    generate_coaching_report,
    generate_live_suggestions,
    predict_outcome,
)

router = APIRouter(prefix="/copilot", tags=["AI Copilot"])


class CopilotRequest(BaseModel):
    meeting_id: str
    recent_transcript: str
    emotion_signals: dict[str, Any] | None = None
    meeting_context: dict[str, Any] | None = None
    memory_context: str | None = None


class CoachingRequest(BaseModel):
    meeting_id: str
    participant_id: str
    speech_analysis: dict[str, Any]
    emotion_history: list[dict[str, Any]] = []
    cv_analysis_history: list[dict[str, Any]] = []


class OutcomeRequest(BaseModel):
    meeting_id: str
    transcript: str
    emotion_data: dict[str, Any] = {}
    meeting_type: str = "general"


@router.post("/suggestions", response_model=CopilotStreamResponse)
async def get_suggestions(
    request: CopilotRequest,
    _auth: bool = Depends(verify_internal_api_key),
):
    """Generate real-time copilot suggestions. Express calls this periodically."""
    return await generate_live_suggestions(
        meeting_id=request.meeting_id,
        recent_transcript=request.recent_transcript,
        emotion_signals=request.emotion_signals,
        meeting_context=request.meeting_context,
        memory_context=request.memory_context,
    )


@router.post("/coaching-report", response_model=CoachingReport)
async def get_coaching_report(
    request: CoachingRequest,
    _auth: bool = Depends(verify_internal_api_key),
):
    """Generate post-meeting coaching report for a participant."""
    return await generate_coaching_report(
        meeting_id=request.meeting_id,
        participant_id=request.participant_id,
        speech_analysis=request.speech_analysis,
        emotion_history=request.emotion_history,
        cv_analysis_history=request.cv_analysis_history,
    )


@router.post("/predict-outcome", response_model=OutcomePrediction)
async def get_outcome_prediction(
    request: OutcomeRequest,
    _auth: bool = Depends(verify_internal_api_key),
):
    """Predict meeting outcome probability."""
    return await predict_outcome(
        meeting_id=request.meeting_id,
        transcript=request.transcript,
        emotion_data=request.emotion_data,
        meeting_type=request.meeting_type,
    )


@router.post("/knowledge-gaps", response_model=list[KnowledgeGap])
async def get_knowledge_gaps(
    meeting_id: str,
    transcript: str,
    _auth: bool = Depends(verify_internal_api_key),
):
    """Detect knowledge gaps in technical discussions."""
    return await detect_knowledge_gaps(meeting_id, transcript)
