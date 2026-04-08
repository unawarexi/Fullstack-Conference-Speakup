# ============================================================================
# SpeakUp AI — FastAPI Application Entry Point
# AI Intelligence Plane for the SpeakUp video conferencing platform
# ============================================================================
from __future__ import annotations

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware

from app.api.v1.router import api_router
from app.core.config import get_settings
from app.core.logging import get_logger, setup_logging
from app.middleware.request_logging import RequestLoggingMiddleware


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application startup and shutdown lifecycle."""
    settings = get_settings()
    log = get_logger("startup")

    # ── Startup ──
    log.info("Starting SpeakUp AI", env=settings.APP_ENV, debug=settings.DEBUG)

    # 1. Initialize infrastructure
    from infrastructure.redis.client import init_redis
    await init_redis()
    log.info("Redis connected")

    from infrastructure.kafka.producer import init_kafka_producer
    await init_kafka_producer()
    log.info("Kafka producer connected")

    try:
        from infrastructure.qdrant.client import init_qdrant
        await init_qdrant()
        log.info("Qdrant connected")
    except Exception as e:
        log.warning("Qdrant unavailable (non-fatal)", error=str(e))

    try:
        from infrastructure.neo4j.client import init_neo4j
        await init_neo4j()
        log.info("Neo4j connected")
    except Exception as e:
        log.warning("Neo4j unavailable (non-fatal)", error=str(e))

    # 2. Load AI models
    try:
        from app.services.speech.transcription import load_models as load_speech_models
        await load_speech_models()
        log.info("Speech models loaded")
    except Exception as e:
        log.warning("Speech models failed to load (non-fatal)", error=str(e))

    try:
        from app.services.cv.vision import load_models as load_cv_models
        await load_cv_models()
        log.info("CV models loaded")
    except Exception as e:
        log.warning("CV models failed to load (non-fatal)", error=str(e))

    # 3. Start Kafka consumers
    try:
        from infrastructure.kafka.consumers import start_all_consumers
        # Import event handlers to register @on_topic decorators
        import app.workers.event_handlers  # noqa: F401
        await start_all_consumers()
        log.info("Kafka consumers started")
    except Exception as e:
        log.warning("Kafka consumers failed (non-fatal)", error=str(e))

    # 4. Initialize multi-LLM provider system
    try:
        from app.services.llm.providers import init_providers
        providers = init_providers()
        log.info("LLM providers initialized", count=len(providers))
    except Exception as e:
        log.warning("LLM providers init failed (non-fatal)", error=str(e))

    # 5. Load MCP tool registry
    try:
        import app.services.mcp.tools.email_tool  # noqa: F401
        import app.services.mcp.tools.slack_tool  # noqa: F401
        import app.services.mcp.tools.calendar_tool  # noqa: F401
        import app.services.mcp.tools.github_tool  # noqa: F401
        import app.services.mcp.tools.jira_tool  # noqa: F401
        import app.services.mcp.tools.notion_tool  # noqa: F401
        import app.services.mcp.tools.integrations_tool  # noqa: F401
        from app.services.mcp.registry import get_tools_schema
        tools = get_tools_schema()
        log.info("MCP tools registered", count=len(tools))
    except Exception as e:
        log.warning("MCP tools registration failed (non-fatal)", error=str(e))

    # 6. Check OpenClaw connectivity
    try:
        from app.services.openclaw.bridge import get_openclaw_bridge
        bridge = get_openclaw_bridge()
        if bridge.is_configured:
            healthy = await bridge.check_health()
            log.info("OpenClaw bridge", configured=True, healthy=healthy)
        else:
            log.info("OpenClaw not configured (optional)")
    except Exception as e:
        log.warning("OpenClaw check failed (non-fatal)", error=str(e))

    # 7. Sentry
    if settings.SENTRY_DSN:
        import sentry_sdk
        sentry_sdk.init(
            dsn=settings.SENTRY_DSN,
            environment=settings.APP_ENV,
            traces_sample_rate=0.1 if settings.is_production else 1.0,
        )
        log.info("Sentry initialized")

    log.info("SpeakUp AI started successfully")

    yield

    # ── Shutdown ──
    log.info("Shutting down SpeakUp AI")

    # Shutdown LLM providers
    try:
        from app.services.llm.providers import shutdown_providers
        await shutdown_providers()
    except Exception:
        pass

    # Shutdown OpenClaw bridge
    try:
        from app.services.openclaw.bridge import shutdown_openclaw
        await shutdown_openclaw()
    except Exception:
        pass

    from infrastructure.kafka.producer import shutdown_kafka
    await shutdown_kafka()

    from infrastructure.redis.client import shutdown_redis
    await shutdown_redis()

    try:
        from infrastructure.qdrant.client import shutdown_qdrant
        await shutdown_qdrant()
    except Exception:
        pass

    try:
        from infrastructure.neo4j.client import shutdown_neo4j
        await shutdown_neo4j()
    except Exception:
        pass

    log.info("SpeakUp AI shutdown complete")


def create_app() -> FastAPI:
    """Application factory."""
    settings = get_settings()
    setup_logging()

    app = FastAPI(
        title="SpeakUp AI — Intelligence Plane",
        description=(
            "AI inference & agent orchestration services for the SpeakUp video conferencing platform. "
            "Handles speech transcription, computer vision, emotion analysis, "
            "LangGraph agent orchestration, meeting memory, and real-time copilot suggestions."
        ),
        version="1.0.0",
        docs_url="/docs" if settings.DEBUG else None,
        redoc_url="/redoc" if settings.DEBUG else None,
        openapi_url="/openapi.json" if settings.DEBUG else None,
        lifespan=lifespan,
    )

    # ── Middleware ──
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.ALLOWED_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.add_middleware(GZipMiddleware, minimum_size=1000)
    app.add_middleware(RequestLoggingMiddleware)

    # ── Routes ──
    app.include_router(api_router, prefix=settings.API_V1_PREFIX)

    return app


# The ASGI application
app = create_app()
