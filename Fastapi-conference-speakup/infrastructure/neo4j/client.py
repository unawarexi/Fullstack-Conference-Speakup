# SpeakUp AI — Neo4j Graph DB Client (Meeting Memory Graph)
from __future__ import annotations

from neo4j import AsyncGraphDatabase, AsyncDriver

from app.core.config import get_settings
from app.core.logging import get_logger

log = get_logger("neo4j")

_driver: AsyncDriver | None = None


async def init_neo4j() -> AsyncDriver:
    global _driver
    if _driver is not None:
        return _driver

    settings = get_settings()
    _driver = AsyncGraphDatabase.driver(
        settings.NEO4J_URI,
        auth=(settings.NEO4J_USERNAME, settings.NEO4J_PASSWORD),
        max_connection_pool_size=50,
    )

    # Verify connectivity
    async with _driver.session() as session:
        await session.run("RETURN 1")

    # Create indexes
    await _create_indexes()

    log.info("Neo4j connected", uri=settings.NEO4J_URI)
    return _driver


async def _create_indexes() -> None:
    assert _driver is not None
    async with _driver.session() as session:
        # Meeting Memory Graph indexes
        await session.run("CREATE INDEX IF NOT EXISTS FOR (m:Meeting) ON (m.meeting_id)")
        await session.run("CREATE INDEX IF NOT EXISTS FOR (p:Person) ON (p.user_id)")
        await session.run("CREATE INDEX IF NOT EXISTS FOR (a:ActionItem) ON (a.id)")
        await session.run("CREATE INDEX IF NOT EXISTS FOR (d:Decision) ON (d.id)")
        await session.run("CREATE INDEX IF NOT EXISTS FOR (t:Topic) ON (t.name)")
        await session.run("CREATE INDEX IF NOT EXISTS FOR (r:Risk) ON (r.id)")
    log.info("Neo4j indexes ensured")


def get_neo4j() -> AsyncDriver:
    if _driver is None:
        raise RuntimeError("Neo4j not initialized")
    return _driver


async def execute_query(query: str, parameters: dict | None = None) -> list[dict]:
    async with get_neo4j().session() as session:
        result = await session.run(query, parameters or {})
        return [record.data() async for record in result]


async def shutdown_neo4j() -> None:
    global _driver
    if _driver:
        await _driver.close()
        _driver = None
        log.info("Neo4j connection closed")
