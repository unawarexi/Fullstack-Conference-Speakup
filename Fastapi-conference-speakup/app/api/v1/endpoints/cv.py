# SpeakUp AI — Computer Vision API Endpoints
from __future__ import annotations

from fastapi import APIRouter, Depends, File, Form, UploadFile

from app.core.security import verify_internal_api_key
from app.schemas.ai_schemas import CVAnalysisResult
from app.services.cv.vision import analyze_frame, analyze_frame_batch

router = APIRouter(prefix="/cv", tags=["Computer Vision"])


@router.post("/analyze-frame", response_model=CVAnalysisResult)
async def analyze_video_frame(
    frame: UploadFile = File(...),
    meeting_id: str = Form(...),
    participant_id: str = Form(...),
    width: int = Form(640),
    height: int = Form(480),
    _auth: bool = Depends(verify_internal_api_key),
):
    """Analyze a single video frame for face + posture + gaze."""
    frame_bytes = await frame.read()
    return await analyze_frame(
        frame_bytes=frame_bytes,
        meeting_id=meeting_id,
        participant_id=participant_id,
        width=width,
        height=height,
    )


@router.post("/analyze-batch")
async def analyze_frame_batch_endpoint(
    meeting_id: str = Form(...),
    _auth: bool = Depends(verify_internal_api_key),
):
    """Batch analyze frames — used for processing recorded video."""
    # Batch frames come via Kafka; this endpoint is for on-demand
    return {"status": "use_kafka_for_batch", "meeting_id": meeting_id}
