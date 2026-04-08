# SpeakUp AI — Emotion / Multimodal API Endpoints
from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Depends
from pydantic import BaseModel

from app.core.security import verify_internal_api_key
from app.schemas.ai_schemas import MultimodalEmotionResult
from app.services.emotion.analyzer import analyze_multimodal_emotion, get_meeting_emotions

router = APIRouter(prefix="/emotion", tags=["Emotion Analysis"])


class EmotionAnalysisRequest(BaseModel):
    meeting_id: str
    participant_id: str
    voice_features: dict[str, float] | None = None
    face_analysis: dict[str, Any] | None = None
    recent_text: str | None = None
    response_latency_ms: float | None = None


@router.post("/analyze", response_model=MultimodalEmotionResult)
async def analyze_emotion(
    request: EmotionAnalysisRequest,
    _auth: bool = Depends(verify_internal_api_key),
):
    """Analyze multimodal emotion signals for a participant."""
    return await analyze_multimodal_emotion(
        meeting_id=request.meeting_id,
        participant_id=request.participant_id,
        voice_features=request.voice_features,
        face_analysis=request.face_analysis,
        recent_text=request.recent_text,
        response_latency_ms=request.response_latency_ms,
    )


@router.get("/meeting/{meeting_id}")
async def get_emotions(
    meeting_id: str,
    _auth: bool = Depends(verify_internal_api_key),
):
    """Get current emotion state for all participants in a meeting."""
    return await get_meeting_emotions(meeting_id)
