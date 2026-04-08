# SpeakUp AI — Kafka Producer/Consumer
from __future__ import annotations

import orjson
from aiokafka import AIOKafkaConsumer, AIOKafkaProducer

from app.core.config import get_settings
from app.core.logging import get_logger

log = get_logger("kafka")

_producer: AIOKafkaProducer | None = None
_consumers: dict[str, AIOKafkaConsumer] = {}


async def init_kafka_producer() -> AIOKafkaProducer:
    global _producer
    if _producer is not None:
        return _producer

    settings = get_settings()
    _producer = AIOKafkaProducer(
        bootstrap_servers=settings.kafka_broker_list,
        client_id=settings.KAFKA_CLIENT_ID,
        value_serializer=lambda v: orjson.dumps(v),
        key_serializer=lambda k: k.encode() if isinstance(k, str) else orjson.dumps(k),
        compression_type="snappy",
        acks="all",
        max_batch_size=32768,
        linger_ms=10,
    )
    await _producer.start()
    log.info("Kafka producer started", brokers=settings.KAFKA_BROKERS)
    return _producer


async def publish_event(topic: str, key: str, value: dict) -> None:
    if _producer is None:
        raise RuntimeError("Kafka producer not initialized")
    await _producer.send_and_wait(topic, value=value, key=key)


async def publish_batch(topic: str, messages: list[dict]) -> None:
    if _producer is None:
        raise RuntimeError("Kafka producer not initialized")
    batch = _producer.create_batch()
    for msg in messages:
        key = msg.get("key", "").encode() if isinstance(msg.get("key"), str) else b""
        value = orjson.dumps(msg.get("value", msg))
        batch.append(key=key, value=value, timestamp=None)
    await _producer.send_batch(batch, topic, partition=0)


async def create_consumer(
    group_id: str,
    topics: list[str],
    auto_offset_reset: str = "latest",
) -> AIOKafkaConsumer:
    settings = get_settings()
    consumer = AIOKafkaConsumer(
        *topics,
        bootstrap_servers=settings.kafka_broker_list,
        group_id=group_id,
        auto_offset_reset=auto_offset_reset,
        value_deserializer=lambda v: orjson.loads(v),
        key_deserializer=lambda k: k.decode() if k else None,
        enable_auto_commit=True,
        auto_commit_interval_ms=5000,
        max_poll_records=100,
    )
    await consumer.start()
    consumer_key = f"{group_id}:{','.join(topics)}"
    _consumers[consumer_key] = consumer
    log.info("Kafka consumer started", group_id=group_id, topics=topics)
    return consumer


async def shutdown_kafka() -> None:
    global _producer
    if _producer:
        await _producer.stop()
        _producer = None
        log.info("Kafka producer stopped")

    for key, consumer in _consumers.items():
        await consumer.stop()
        log.info("Kafka consumer stopped", consumer=key)
    _consumers.clear()


def get_producer() -> AIOKafkaProducer:
    if _producer is None:
        raise RuntimeError("Kafka producer not initialized")
    return _producer
