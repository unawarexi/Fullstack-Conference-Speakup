# SpeakUp AI — Security & Auth middleware
from __future__ import annotations

import hmac

from fastapi import Depends, Header, Request
from app.core.config import Settings, get_settings
from app.core.exceptions import AuthenticationError


async def verify_internal_api_key(
    x_internal_api_key: str = Header(..., alias="X-Internal-API-Key"),
    settings: Settings = Depends(get_settings),
) -> bool:
    """Verify requests from Express backend using shared secret."""
    if not settings.EXPRESS_INTERNAL_API_KEY:
        raise AuthenticationError()
    if not hmac.compare_digest(x_internal_api_key, settings.EXPRESS_INTERNAL_API_KEY):
        raise AuthenticationError()
    return True


async def verify_service_token(
    request: Request,
    settings: Settings = Depends(get_settings),
) -> dict:
    """Verify JWT token forwarded from Express backend."""
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        raise AuthenticationError()

    token = auth_header[7:]
    # The Express backend validates Firebase tokens and forwards a signed service token
    # We verify the shared HMAC signature attached by Express
    x_signature = request.headers.get("X-Service-Signature", "")
    expected = hmac.new(
        settings.SECRET_KEY.encode(),
        token.encode(),
        "sha256",
    ).hexdigest()

    if not hmac.compare_digest(x_signature, expected):
        raise AuthenticationError()

    # Express passes user context as JSON in X-User-Context header
    import orjson
    user_ctx = request.headers.get("X-User-Context", "")
    if not user_ctx:
        raise AuthenticationError()

    return orjson.loads(user_ctx)
