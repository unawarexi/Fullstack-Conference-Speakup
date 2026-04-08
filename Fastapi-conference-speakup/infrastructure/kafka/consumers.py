# SpeakUp AI — Kafka Consumer Workers
from __future__ import annotations

import asyncio
from collections.abc import Callable, Coroutine
from typing import Any

from aiokafka import AIOKafkaConsumer

from app.core.constants import KafkaTopics
from app.core.logging import get_logger
from infrastructure.kafka.producer import create_consumer

log = get_logger("kafka.consumers")

# Registry of topic handlers
_handlers: dict[str, list[Callable[..., Coroutine[Any, Any, None]]]] = {}


def on_topic(topic: str):
    """Decorator to register a handler for a Kafka topic."""
    def decorator(func: Callable[..., Coroutine[Any, Any, None]]):
        _handlers.setdefault(topic, []).append(func)
        return func
    return decorator


async def _process_messages(consumer: AIOKafkaConsumer) -> None:
    """Core message processing loop."""
    async for message in consumer:
        topic = message.topic
        handlers = _handlers.get(topic, [])
        for handler in handlers:
            try:
                await handler(
                    key=message.key,
                    value=message.value,
                    topic=topic,
                    partition=message.partition,
                    offset=message.offset,
                    timestamp=message.timestamp,
                )
            except Exception:
                log.exception(
                    "Handler error",
                    topic=topic,
                    handler=handler.__name__,
                    offset=message.offset,
                )


async def start_meeting_event_consumer() -> None:
    """Consume meeting lifecycle events from Express backend."""
    consumer = await create_consumer(
        group_id="speakup-ai-meeting-events",
        topics=[
            KafkaTopics.MEETING_EVENTS,
            KafkaTopics.PARTICIPANT_EVENTS,
            KafkaTopics.RECORDING_EVENTS,
        ],
    )
    asyncio.create_task(_process_messages(consumer))
    log.info("Meeting event consumer started")


async def start_media_consumer() -> None:
    """Consume audio/video media chunks for real-time inference."""
    consumer = await create_consumer(
        group_id="speakup-ai-media",
        topics=[
            KafkaTopics.MEDIA_AUDIO_CHUNKS,
            KafkaTopics.MEDIA_VIDEO_FRAMES,
        ],
    )
    asyncio.create_task(_process_messages(consumer))
    log.info("Media consumer started")


async def start_chat_consumer() -> None:
    """Consume chat messages for NLP analysis."""
    consumer = await create_consumer(
        group_id="speakup-ai-chat",
        topics=[KafkaTopics.CHAT_MESSAGES],
    )
    asyncio.create_task(_process_messages(consumer))
    log.info("Chat consumer started")


async def start_all_consumers() -> None:
    """Start all Kafka consumer workers."""
    await start_meeting_event_consumer()
    await start_media_consumer()
    await start_chat_consumer()
    log.info("All Kafka consumers started")
