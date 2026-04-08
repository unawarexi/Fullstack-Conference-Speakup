# SpeakUp AI — Memory API Endpoints
from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Depends
from pydantic import BaseModel

from app.core.security import verify_internal_api_key
from app.schemas.ai_schemas import (
    MeetingMemoryQuery,
    MeetingMemoryResult,
    MeetingReplay,
    MeetingSummary,
    RelationshipProfile,
)
from app.services.memory.meeting_memory import (
    generate_meeting_replay,
    generate_meeting_summary,
    get_relationship_profile,
    query_meeting_memory,
    store_meeting_memory,
)

router = APIRouter(prefix="/memory", tags=["Meeting Memory"])


class SummaryRequest(BaseModel):
    meeting_id: str
    transcript: str
    participant_names: list[str] | None = None
    meeting_title: str | None = None
    duration_minutes: float = 0
    participant_count: int = 0


class StoreMemoryRequest(BaseModel):
    meeting_id: str
    summary: dict[str, Any]
    participant_ids: list[str]


class ReplayRequest(BaseModel):
    meeting_id: str
    transcript: str
    duration_seconds: float


@router.post("/summary", response_model=MeetingSummary)
async def create_summary(
    request: SummaryRequest,
    _auth: bool = Depends(verify_internal_api_key),
):
    """Generate meeting summary from transcript. Called by Express when meeting ends."""
    return await generate_meeting_summary(
        meeting_id=request.meeting_id,
        transcript=request.transcript,
        participant_names=request.participant_names,
        meeting_title=request.meeting_title,
        duration_minutes=request.duration_minutes,
        participant_count=request.participant_count,
    )


@router.post("/store")
async def store_memory(
    request: StoreMemoryRequest,
    _auth: bool = Depends(verify_internal_api_key),
):
    """Store meeting in vector + graph memory. Called after summary generation."""
    summary = MeetingSummary(**request.summary)
    await store_meeting_memory(request.meeting_id, summary, request.participant_ids)
    return {"status": "stored", "meeting_id": request.meeting_id}


@router.post("/query", response_model=MeetingMemoryResult)
async def search_memory(
    query: MeetingMemoryQuery,
    _auth: bool = Depends(verify_internal_api_key),
):
    """Semantic search across meeting history."""
    return await query_meeting_memory(query)


@router.post("/replay", response_model=MeetingReplay)
async def create_replay(
    request: ReplayRequest,
    _auth: bool = Depends(verify_internal_api_key),
):
    """Generate chapter markers for meeting replay."""
    return await generate_meeting_replay(
        meeting_id=request.meeting_id,
        transcript=request.transcript,
        duration_seconds=request.duration_seconds,
    )


@router.get("/relationship/{user_id}/{target_user_id}", response_model=RelationshipProfile)
async def get_relationship(
    user_id: str,
    target_user_id: str,
    _auth: bool = Depends(verify_internal_api_key),
):
    """Get relationship intelligence between two users."""
    return await get_relationship_profile(user_id, target_user_id)
