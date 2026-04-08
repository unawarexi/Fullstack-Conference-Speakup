# SpeakUp AI — Speech API Endpoints
from __future__ import annotations

from fastapi import APIRouter, Depends, File, Form, UploadFile

from app.core.security import verify_internal_api_key
from app.services.speech.transcription import (
    analyze_speech,
    detect_voice_activity,
    get_meeting_transcript,
    transcribe_audio,
)
from app.schemas.ai_schemas import TranscriptionResult, SpeechAnalysis, TranscriptionSegment

router = APIRouter(prefix="/speech", tags=["Speech Intelligence"])


@router.post("/transcribe", response_model=TranscriptionResult)
async def transcribe(
    audio: UploadFile = File(...),
    meeting_id: str = Form(...),
    participant_id: str = Form(None),
    language: str = Form(None),
    _auth: bool = Depends(verify_internal_api_key),
):
    """Transcribe audio chunk using Whisper. Called by Express when audio arrives."""
    audio_bytes = await audio.read()
    return await transcribe_audio(
        audio_data=audio_bytes,
        meeting_id=meeting_id,
        participant_id=participant_id,
        language=language,
    )


@router.post("/vad")
async def voice_activity_detection(
    audio: UploadFile = File(...),
    sample_rate: int = Form(16000),
    _auth: bool = Depends(verify_internal_api_key),
):
    """Detect speech segments in audio."""
    audio_bytes = await audio.read()
    segments = await detect_voice_activity(audio_bytes, sample_rate)
    return {"segments": segments, "count": len(segments)}


@router.get("/transcript/{meeting_id}")
async def get_transcript(
    meeting_id: str,
    _auth: bool = Depends(verify_internal_api_key),
):
    """Get accumulated transcript for a meeting."""
    return await get_meeting_transcript(meeting_id)


@router.post("/analyze", response_model=SpeechAnalysis)
async def analyze_speech_endpoint(
    meeting_id: str = Form(...),
    participant_id: str = Form(...),
    _auth: bool = Depends(verify_internal_api_key),
):
    """Analyze speech patterns for a participant (uses cached transcript)."""
    transcript_data = await get_meeting_transcript(meeting_id)
    segments = [
        TranscriptionSegment(**s) for s in transcript_data.get("segments", [])
        if s.get("speaker") == participant_id
    ]
    return await analyze_speech(segments, meeting_id, participant_id)
