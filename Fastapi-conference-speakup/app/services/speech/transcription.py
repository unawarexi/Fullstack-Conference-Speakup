# SpeakUp AI — Speech Intelligence Service
# Real-time transcription, diarization, speech analysis
from __future__ import annotations

import asyncio
import io
import time
from typing import Any

import numpy as np

from app.core.config import get_settings
from app.core.constants import KafkaTopics, RedisKeys
from app.core.logging import get_logger
from app.schemas.ai_schemas import (
    DiarizationResult,
    SpeechAnalysis,
    TranscriptionResult,
    TranscriptionSegment,
)
from infrastructure.kafka.producer import publish_event
from infrastructure.redis.client import get_cache, publish, set_cache

log = get_logger("speech_service")

# ── Model singletons ──
_whisper_model = None
_vad_model = None

FILLER_WORDS = {"um", "uh", "like", "you know", "basically", "actually", "literally", "so", "right", "okay"}


async def load_models() -> None:
    """Load speech models on startup (runs in thread to avoid blocking)."""
    global _whisper_model, _vad_model

    settings = get_settings()
    loop = asyncio.get_event_loop()

    def _load():
        global _whisper_model, _vad_model
        from faster_whisper import WhisperModel

        _whisper_model = WhisperModel(
            settings.WHISPER_MODEL_SIZE,
            device=settings.WHISPER_DEVICE,
            compute_type=settings.WHISPER_COMPUTE_TYPE,
        )
        log.info("Whisper model loaded", size=settings.WHISPER_MODEL_SIZE, device=settings.WHISPER_DEVICE)

        import silero_vad
        _vad_model = silero_vad.load_silero_vad()
        log.info("Silero VAD model loaded")

    await loop.run_in_executor(None, _load)


def get_whisper_model():
    if _whisper_model is None:
        raise RuntimeError("Whisper model not loaded. Call load_models() first.")
    return _whisper_model


async def transcribe_audio(
    audio_data: bytes,
    meeting_id: str,
    participant_id: str | None = None,
    language: str | None = None,
) -> TranscriptionResult:
    """Transcribe audio bytes using faster-whisper."""
    loop = asyncio.get_event_loop()
    start_time = time.monotonic()

    def _transcribe():
        model = get_whisper_model()
        audio_file = io.BytesIO(audio_data)

        segments_iter, info = model.transcribe(
            audio_file,
            language=language,
            beam_size=5,
            best_of=5,
            vad_filter=True,
            vad_parameters=dict(
                min_silence_duration_ms=500,
                speech_pad_ms=300,
            ),
        )

        segments = []
        full_text_parts = []
        for seg in segments_iter:
            segments.append(
                TranscriptionSegment(
                    start=seg.start,
                    end=seg.end,
                    text=seg.text.strip(),
                    confidence=seg.avg_logprob,
                    language=info.language,
                    speaker=participant_id,
                )
            )
            full_text_parts.append(seg.text.strip())

        return segments, " ".join(full_text_parts), info.language, info.duration

    segments, full_text, lang, duration = await loop.run_in_executor(None, _transcribe)
    elapsed = time.monotonic() - start_time

    result = TranscriptionResult(
        meeting_id=meeting_id,
        segments=segments,
        full_text=full_text,
        language=lang,
        duration_seconds=duration,
    )

    # Cache the transcript
    cache_key = RedisKeys.MEETING_TRANSCRIPT.format(meeting_id=meeting_id)
    existing = await get_cache(cache_key) or {"segments": [], "full_text": ""}
    existing["segments"].extend([s.model_dump() for s in segments])
    existing["full_text"] += " " + full_text
    await set_cache(cache_key, existing, ttl_seconds=7200)

    # Publish to Kafka for downstream consumers
    await publish_event(
        KafkaTopics.AI_TRANSCRIPTION,
        key=meeting_id,
        value={
            "meeting_id": meeting_id,
            "participant_id": participant_id,
            "segments": [s.model_dump() for s in segments],
            "full_text": full_text,
            "language": lang,
            "inference_time_ms": round(elapsed * 1000, 2),
        },
    )

    log.info(
        "Transcription complete",
        meeting_id=meeting_id,
        segments=len(segments),
        duration=round(duration, 2),
        inference_ms=round(elapsed * 1000, 2),
    )
    return result


async def detect_voice_activity(
    audio_data: bytes,
    sample_rate: int = 16000,
) -> list[dict[str, float]]:
    """Detect speech segments using Silero VAD."""
    loop = asyncio.get_event_loop()

    def _vad():
        import torch
        import silero_vad

        audio_tensor = torch.frombuffer(audio_data, dtype=torch.int16).float() / 32768.0
        timestamps = silero_vad.get_speech_timestamps(
            audio_tensor,
            _vad_model,
            sampling_rate=sample_rate,
            threshold=0.5,
            min_speech_duration_ms=250,
            min_silence_duration_ms=300,
        )
        return [
            {"start": ts["start"] / sample_rate, "end": ts["end"] / sample_rate}
            for ts in timestamps
        ]

    return await loop.run_in_executor(None, _vad)


async def analyze_speech(
    transcript_segments: list[TranscriptionSegment],
    meeting_id: str,
    participant_id: str,
) -> SpeechAnalysis:
    """Analyze speech patterns — speed, filler words, interruptions."""
    total_words = 0
    total_duration = 0.0
    filler_counts: dict[str, int] = {}

    for seg in transcript_segments:
        if seg.speaker == participant_id or participant_id is None:
            words = seg.text.lower().split()
            total_words += len(words)
            total_duration += seg.end - seg.start

            for word in words:
                if word in FILLER_WORDS:
                    filler_counts[word] = filler_counts.get(word, 0) + 1

    wpm = (total_words / (total_duration / 60)) if total_duration > 0 else 0
    total_filler = sum(filler_counts.values())

    # Confidence heuristic: high WPM + low fillers = high confidence
    confidence = min(1.0, max(0.0, 1.0 - (total_filler / max(total_words, 1)) * 5))

    analysis = SpeechAnalysis(
        meeting_id=meeting_id,
        participant_id=participant_id,
        speaking_speed_wpm=round(wpm, 1),
        filler_word_count=total_filler,
        filler_words=filler_counts,
        confidence_score=round(confidence, 3),
    )

    # Publish coaching hints based on analysis
    coaching_hints = []
    if wpm > 180:
        coaching_hints.append({"category": "pace", "message": "Slow down — you're speaking too fast", "severity": "warning"})
    elif wpm < 100 and total_words > 20:
        coaching_hints.append({"category": "pace", "message": "Try to speak a bit faster to maintain engagement", "severity": "info"})

    if total_filler > 10:
        coaching_hints.append({"category": "clarity", "message": f"You've used {total_filler} filler words. Try pausing instead.", "severity": "warning"})

    if coaching_hints:
        await publish_event(
            KafkaTopics.AI_COACHING_HINTS,
            key=meeting_id,
            value={
                "meeting_id": meeting_id,
                "participant_id": participant_id,
                "hints": coaching_hints,
            },
        )
        await publish(
            RedisKeys.CHANNEL_AI_COACHING.format(meeting_id=meeting_id),
            {"participant_id": participant_id, "hints": coaching_hints},
        )

    return analysis


async def get_meeting_transcript(meeting_id: str) -> dict[str, Any]:
    """Retrieve full transcript from cache."""
    cache_key = RedisKeys.MEETING_TRANSCRIPT.format(meeting_id=meeting_id)
    return await get_cache(cache_key) or {"segments": [], "full_text": ""}
