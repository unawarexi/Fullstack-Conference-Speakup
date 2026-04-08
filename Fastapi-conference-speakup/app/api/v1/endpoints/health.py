# SpeakUp AI — Health & Observability Endpoints
from __future__ import annotations

import time
from typing import Any

from fastapi import APIRouter
from prometheus_client import CONTENT_TYPE_LATEST, generate_latest

from app.core.config import get_settings
from app.core.logging import get_logger
from app.schemas.ai_schemas import HealthStatus

router = APIRouter(tags=["Health"])

_start_time = time.time()
log = get_logger("health")


@router.get("/health")
async def health_check():
    """Liveness probe."""
    return {"status": "ok", "service": "speakup-ai"}


@router.get("/health/ready")
async def readiness_check():
    """Readiness probe — check all dependencies."""
    checks: dict[str, bool] = {}

    # Redis
    try:
        from infrastructure.redis.client import get_redis
        await get_redis().ping()
        checks["redis"] = True
    except Exception:
        checks["redis"] = False

    # Kafka
    try:
        from infrastructure.kafka.producer import get_producer
        get_producer()  # Just check it exists
        checks["kafka"] = True
    except Exception:
        checks["kafka"] = False

    # Qdrant
    try:
        from infrastructure.qdrant.client import get_qdrant
        await get_qdrant().get_collections()
        checks["qdrant"] = True
    except Exception:
        checks["qdrant"] = False

    # Neo4j
    try:
        from infrastructure.neo4j.client import execute_query
        await execute_query("RETURN 1")
        checks["neo4j"] = True
    except Exception:
        checks["neo4j"] = False

    all_healthy = all(checks.values())
    status = "ok" if all_healthy else "degraded"

    return {
        "status": status,
        "service": "speakup-ai",
        "checks": checks,
        "uptime_seconds": round(time.time() - _start_time, 2),
    }


@router.get("/health/detailed", response_model=HealthStatus)
async def detailed_health():
    """Detailed health with model status."""
    models_loaded = []

    try:
        from app.services.speech.transcription import _whisper_model, _vad_model
        if _whisper_model:
            models_loaded.append("whisper")
        if _vad_model:
            models_loaded.append("silero_vad")
    except Exception:
        pass

    try:
        from app.services.cv.vision import _face_mesh, _pose_detector
        if _face_mesh:
            models_loaded.append("mediapipe_face_mesh")
        if _pose_detector:
            models_loaded.append("mediapipe_pose")
    except Exception:
        pass

    return HealthStatus(
        status="ok",
        service="speakup-ai",
        uptime_seconds=round(time.time() - _start_time, 2),
        models_loaded=models_loaded,
        connections={},
    )


@router.get("/metrics")
async def prometheus_metrics():
    """Prometheus metrics endpoint."""
    from fastapi.responses import Response
    return Response(
        content=generate_latest(),
        media_type=CONTENT_TYPE_LATEST,
    )
