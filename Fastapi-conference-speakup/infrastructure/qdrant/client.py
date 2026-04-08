# SpeakUp AI — Qdrant Vector DB Client
from __future__ import annotations

from qdrant_client import AsyncQdrantClient
from qdrant_client.models import Distance, PointStruct, VectorParams

from app.core.config import get_settings
from app.core.logging import get_logger

log = get_logger("qdrant")

_client: AsyncQdrantClient | None = None

EMBEDDING_DIM = 1536  # text-embedding-3-small


async def init_qdrant() -> AsyncQdrantClient:
    global _client
    if _client is not None:
        return _client

    settings = get_settings()
    _client = AsyncQdrantClient(
        host=settings.QDRANT_HOST,
        port=settings.QDRANT_PORT,
        api_key=settings.QDRANT_API_KEY or None,
        timeout=30,
    )

    # Ensure collections exist
    await _ensure_collection(settings.QDRANT_COLLECTION_MEETINGS)
    await _ensure_collection(settings.QDRANT_COLLECTION_KNOWLEDGE)

    log.info("Qdrant connected", host=settings.QDRANT_HOST)
    return _client


async def _ensure_collection(name: str) -> None:
    assert _client is not None
    collections = await _client.get_collections()
    existing = {c.name for c in collections.collections}
    if name not in existing:
        await _client.create_collection(
            collection_name=name,
            vectors_config=VectorParams(size=EMBEDDING_DIM, distance=Distance.COSINE),
        )
        log.info("Created Qdrant collection", collection=name)


def get_qdrant() -> AsyncQdrantClient:
    if _client is None:
        raise RuntimeError("Qdrant not initialized")
    return _client


async def upsert_vectors(
    collection: str,
    points: list[dict],
) -> None:
    """Upsert embedding vectors. Each point: {id, vector, payload}."""
    await get_qdrant().upsert(
        collection_name=collection,
        points=[
            PointStruct(
                id=p["id"],
                vector=p["vector"],
                payload=p.get("payload", {}),
            )
            for p in points
        ],
    )


async def search_vectors(
    collection: str,
    query_vector: list[float],
    limit: int = 10,
    score_threshold: float = 0.7,
    filter_conditions: dict | None = None,
) -> list[dict]:
    results = await get_qdrant().search(
        collection_name=collection,
        query_vector=query_vector,
        limit=limit,
        score_threshold=score_threshold,
        query_filter=filter_conditions,
    )
    return [
        {
            "id": r.id,
            "score": r.score,
            "payload": r.payload,
        }
        for r in results
    ]


async def shutdown_qdrant() -> None:
    global _client
    if _client:
        await _client.close()
        _client = None
        log.info("Qdrant connection closed")
