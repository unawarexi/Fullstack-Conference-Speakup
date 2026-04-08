# SpeakUp AI — Celery Workers for Heavy Async Tasks
from __future__ import annotations

from celery import Celery

from app.core.config import get_settings

settings = get_settings()

celery_app = Celery(
    "speakup_ai",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_acks_late=True,
    worker_prefetch_multiplier=1,
    task_soft_time_limit=300,
    task_time_limit=600,
    task_default_queue="speakup-ai-default",
    task_queues={
        "speakup-ai-default": {"exchange": "default", "routing_key": "default"},
        "speakup-ai-summary": {"exchange": "summary", "routing_key": "summary"},
        "speakup-ai-memory": {"exchange": "memory", "routing_key": "memory"},
        "speakup-ai-inference": {"exchange": "inference", "routing_key": "inference"},
    },
)


@celery_app.task(name="ai.generate_meeting_summary", queue="speakup-ai-summary", bind=True, max_retries=3)
def task_generate_meeting_summary(self, meeting_id: str, transcript: str, participant_ids: list[str], meeting_title: str | None = None):
    """Heavy async task: generate full meeting summary + store in memory graph."""
    import asyncio
    from app.services.agents.orchestrator import run_post_meeting_analysis

    loop = asyncio.new_event_loop()
    try:
        result = loop.run_until_complete(
            run_post_meeting_analysis(
                meeting_id=meeting_id,
                participant_ids=participant_ids,
                transcript=transcript,
                transcript_segments=[],
                meeting_title=meeting_title,
            )
        )
        return {"meeting_id": meeting_id, "status": "completed", "summary": result.get("summary")}
    except Exception as exc:
        self.retry(exc=exc, countdown=30)
    finally:
        loop.close()


@celery_app.task(name="ai.store_meeting_memory", queue="speakup-ai-memory", bind=True, max_retries=3)
def task_store_meeting_memory(self, meeting_id: str, summary_data: dict, participant_ids: list[str]):
    """Store meeting embeddings and graph nodes."""
    import asyncio
    from app.schemas.ai_schemas import MeetingSummary
    from app.services.memory.meeting_memory import store_meeting_memory

    loop = asyncio.new_event_loop()
    try:
        summary = MeetingSummary(**summary_data)
        loop.run_until_complete(
            store_meeting_memory(meeting_id, summary, participant_ids)
        )
        return {"meeting_id": meeting_id, "status": "memory_stored"}
    except Exception as exc:
        self.retry(exc=exc, countdown=30)
    finally:
        loop.close()


@celery_app.task(name="ai.batch_transcribe", queue="speakup-ai-inference", bind=True, max_retries=2)
def task_batch_transcribe(self, meeting_id: str, audio_url: str, participant_id: str | None = None):
    """Transcribe full recording audio (post-meeting)."""
    import asyncio
    import httpx

    loop = asyncio.new_event_loop()
    try:
        # Download audio
        async def _run():
            async with httpx.AsyncClient() as client:
                resp = await client.get(audio_url, timeout=120)
                resp.raise_for_status()
                audio_bytes = resp.content

            from app.services.speech.transcription import transcribe_audio
            return await transcribe_audio(audio_bytes, meeting_id, participant_id)

        result = loop.run_until_complete(_run())
        return {"meeting_id": meeting_id, "status": "transcribed", "segments": len(result.segments)}
    except Exception as exc:
        self.retry(exc=exc, countdown=60)
    finally:
        loop.close()
