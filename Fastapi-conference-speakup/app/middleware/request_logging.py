# SpeakUp AI — Request Middleware
from __future__ import annotations

import time
import uuid

import structlog
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

from app.core.logging import get_logger

log = get_logger("middleware")


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """Log every request with timing and request ID."""

    async def dispatch(self, request: Request, call_next):
        request_id = request.headers.get("X-Request-Id", str(uuid.uuid4()))
        start_time = time.monotonic()

        # Bind request context
        structlog.contextvars.clear_contextvars()
        structlog.contextvars.bind_contextvars(
            request_id=request_id,
            method=request.method,
            path=request.url.path,
        )

        try:
            response: Response = await call_next(request)
            duration_ms = round((time.monotonic() - start_time) * 1000, 2)

            log.info(
                "Request completed",
                status=response.status_code,
                duration_ms=duration_ms,
            )

            response.headers["X-Request-Id"] = request_id
            response.headers["X-Response-Time"] = f"{duration_ms}ms"
            return response

        except Exception:
            duration_ms = round((time.monotonic() - start_time) * 1000, 2)
            log.exception("Request failed", duration_ms=duration_ms)
            raise
