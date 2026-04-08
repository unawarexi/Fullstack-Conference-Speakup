# SpeakUp AI — Custom Exceptions
from __future__ import annotations

from fastapi import HTTPException, status


class AIServiceError(HTTPException):
    def __init__(self, detail: str = "AI service error", service: str = "unknown"):
        super().__init__(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=detail)
        self.service = service


class ModelNotLoadedError(AIServiceError):
    def __init__(self, model: str):
        super().__init__(detail=f"Model not loaded: {model}", service="model_loader")


class InferenceTimeoutError(AIServiceError):
    def __init__(self, service: str, timeout_ms: int):
        super().__init__(detail=f"Inference timeout after {timeout_ms}ms", service=service)


class KafkaPublishError(AIServiceError):
    def __init__(self, topic: str):
        super().__init__(detail=f"Failed to publish to Kafka topic: {topic}", service="kafka")


class MeetingNotActiveError(HTTPException):
    def __init__(self, meeting_id: str):
        super().__init__(status_code=status.HTTP_404_NOT_FOUND, detail=f"Meeting {meeting_id} is not active")


class RateLimitExceededError(HTTPException):
    def __init__(self):
        super().__init__(status_code=status.HTTP_429_TOO_MANY_REQUESTS, detail="AI rate limit exceeded")


class InvalidMediaError(HTTPException):
    def __init__(self, detail: str = "Invalid media input"):
        super().__init__(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=detail)


class AuthenticationError(HTTPException):
    def __init__(self):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing authentication",
            headers={"WWW-Authenticate": "Bearer"},
        )
