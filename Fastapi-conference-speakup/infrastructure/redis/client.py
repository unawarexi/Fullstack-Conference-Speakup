# SpeakUp AI — Redis Client (async)
from __future__ import annotations

import orjson
import redis.asyncio as aioredis

from app.core.config import get_settings
from app.core.logging import get_logger

log = get_logger("redis")

_pool: aioredis.Redis | None = None
_pubsub_client: aioredis.Redis | None = None


async def init_redis() -> aioredis.Redis:
    global _pool
    if _pool is not None:
        return _pool

    settings = get_settings()
    _pool = aioredis.from_url(
        settings.REDIS_URL,
        max_connections=settings.REDIS_MAX_CONNECTIONS,
        decode_responses=False,
        socket_connect_timeout=5,
        socket_keepalive=True,
        retry_on_timeout=True,
    )
    await _pool.ping()
    log.info("Redis connected", url=settings.REDIS_URL.split("@")[-1])
    return _pool


async def init_pubsub() -> aioredis.Redis:
    global _pubsub_client
    if _pubsub_client is not None:
        return _pubsub_client

    settings = get_settings()
    _pubsub_client = aioredis.from_url(
        settings.REDIS_URL,
        max_connections=10,
        decode_responses=False,
    )
    log.info("Redis pub/sub client connected")
    return _pubsub_client


def get_redis() -> aioredis.Redis:
    if _pool is None:
        raise RuntimeError("Redis not initialized")
    return _pool


# ── Cache Helpers ──


async def get_cache(key: str) -> dict | list | None:
    data = await get_redis().get(key)
    return orjson.loads(data) if data else None


async def set_cache(key: str, value: dict | list, ttl_seconds: int | None = None) -> None:
    serialized = orjson.dumps(value)
    if ttl_seconds:
        await get_redis().set(key, serialized, ex=ttl_seconds)
    else:
        await get_redis().set(key, serialized)


async def delete_cache(key: str) -> None:
    await get_redis().delete(key)


async def delete_pattern(pattern: str) -> None:
    r = get_redis()
    cursor = 0
    while True:
        cursor, keys = await r.scan(cursor, match=pattern, count=100)
        if keys:
            await r.delete(*keys)
        if cursor == 0:
            break


# ── Pub/Sub ──


async def publish(channel: str, data: dict) -> None:
    await get_redis().publish(channel, orjson.dumps(data))


async def subscribe(channel: str):
    client = _pubsub_client or await init_pubsub()
    pubsub = client.pubsub()
    await pubsub.subscribe(channel)
    return pubsub


# ── Shutdown ──


async def shutdown_redis() -> None:
    global _pool, _pubsub_client
    if _pool:
        await _pool.aclose()
        _pool = None
    if _pubsub_client:
        await _pubsub_client.aclose()
        _pubsub_client = None
    log.info("Redis connections closed")
