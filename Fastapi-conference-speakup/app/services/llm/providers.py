# SpeakUp AI — Multi-LLM Provider System
# Supports OpenAI, Anthropic, Gemini, HuggingFace, OpenRouter with automatic fallback
from __future__ import annotations

import asyncio
import time
from abc import ABC, abstractmethod
from enum import Enum
from typing import Any

import httpx

from app.core.config import get_settings
from app.core.logging import get_logger

log = get_logger("llm_providers")


# ============================================================================
# Provider Registry
# ============================================================================


class ProviderName(str, Enum):
    OPENAI = "openai"
    ANTHROPIC = "anthropic"
    GEMINI = "gemini"
    HUGGINGFACE = "huggingface"
    OPENROUTER = "openrouter"


class LLMResponse:
    """Unified response from any LLM provider."""

    __slots__ = ("content", "model", "provider", "usage", "latency_ms", "finish_reason")

    def __init__(
        self,
        content: str,
        model: str,
        provider: ProviderName,
        usage: dict[str, int] | None = None,
        latency_ms: float = 0.0,
        finish_reason: str = "stop",
    ):
        self.content = content
        self.model = model
        self.provider = provider
        self.usage = usage or {}
        self.latency_ms = latency_ms
        self.finish_reason = finish_reason

    def to_dict(self) -> dict:
        return {
            "content": self.content,
            "model": self.model,
            "provider": self.provider.value,
            "usage": self.usage,
            "latency_ms": self.latency_ms,
        }


# ============================================================================
# Abstract Base Provider
# ============================================================================


class BaseLLMProvider(ABC):
    """Base class for all LLM providers."""

    name: ProviderName
    _client: httpx.AsyncClient | None = None

    def __init__(self, api_key: str, base_url: str | None = None):
        self.api_key = api_key
        self.base_url = base_url
        self._healthy = True
        self._last_failure: float = 0
        self._failure_count: int = 0
        self._cooldown_seconds: float = 30.0

    @property
    def is_available(self) -> bool:
        if not self.api_key:
            return False
        if not self._healthy:
            # Check if cooldown has passed
            if time.time() - self._last_failure > self._cooldown_seconds:
                self._healthy = True
                self._failure_count = 0
            return False
        return True

    def _mark_failure(self) -> None:
        self._failure_count += 1
        self._last_failure = time.time()
        # Exponential backoff: 30s, 60s, 120s, max 300s
        self._cooldown_seconds = min(30 * (2 ** (self._failure_count - 1)), 300)
        if self._failure_count >= 3:
            self._healthy = False
            log.warning(
                "Provider marked unhealthy",
                provider=self.name.value,
                failures=self._failure_count,
                cooldown=self._cooldown_seconds,
            )

    def _mark_success(self) -> None:
        self._failure_count = 0
        self._healthy = True

    async def _get_client(self) -> httpx.AsyncClient:
        if self._client is None or self._client.is_closed:
            self._client = httpx.AsyncClient(timeout=60.0)
        return self._client

    @abstractmethod
    async def chat(
        self,
        messages: list[dict[str, str]],
        model: str | None = None,
        temperature: float = 0.3,
        max_tokens: int = 2000,
        response_format: dict | None = None,
        **kwargs: Any,
    ) -> LLMResponse:
        ...

    @abstractmethod
    async def embed(self, texts: list[str], model: str | None = None) -> list[list[float]]:
        ...

    async def close(self) -> None:
        if self._client and not self._client.is_closed:
            await self._client.aclose()


# ============================================================================
# OpenAI Provider
# ============================================================================


class OpenAIProvider(BaseLLMProvider):
    name = ProviderName.OPENAI

    def __init__(self, api_key: str):
        super().__init__(api_key, "https://api.openai.com/v1")

    async def chat(
        self,
        messages: list[dict[str, str]],
        model: str | None = None,
        temperature: float = 0.3,
        max_tokens: int = 2000,
        response_format: dict | None = None,
        **kwargs: Any,
    ) -> LLMResponse:
        client = await self._get_client()
        model = model or "gpt-4o"
        start = time.monotonic()

        body: dict[str, Any] = {
            "model": model,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens,
        }
        if response_format:
            body["response_format"] = response_format

        resp = await client.post(
            f"{self.base_url}/chat/completions",
            json=body,
            headers={"Authorization": f"Bearer {self.api_key}"},
        )
        resp.raise_for_status()
        data = resp.json()

        self._mark_success()
        return LLMResponse(
            content=data["choices"][0]["message"]["content"],
            model=model,
            provider=self.name,
            usage=data.get("usage", {}),
            latency_ms=(time.monotonic() - start) * 1000,
            finish_reason=data["choices"][0].get("finish_reason", "stop"),
        )

    async def embed(self, texts: list[str], model: str | None = None) -> list[list[float]]:
        client = await self._get_client()
        model = model or "text-embedding-3-small"

        resp = await client.post(
            f"{self.base_url}/embeddings",
            json={"model": model, "input": texts},
            headers={"Authorization": f"Bearer {self.api_key}"},
        )
        resp.raise_for_status()
        data = resp.json()

        self._mark_success()
        return [item["embedding"] for item in data["data"]]


# ============================================================================
# Anthropic Provider
# ============================================================================


class AnthropicProvider(BaseLLMProvider):
    name = ProviderName.ANTHROPIC

    def __init__(self, api_key: str):
        super().__init__(api_key, "https://api.anthropic.com/v1")

    async def chat(
        self,
        messages: list[dict[str, str]],
        model: str | None = None,
        temperature: float = 0.3,
        max_tokens: int = 2000,
        response_format: dict | None = None,
        **kwargs: Any,
    ) -> LLMResponse:
        client = await self._get_client()
        model = model or "claude-sonnet-4-20250514"
        start = time.monotonic()

        # Anthropic uses system as a separate field
        system_msg = ""
        user_messages = []
        for m in messages:
            if m["role"] == "system":
                system_msg += m["content"] + "\n"
            else:
                user_messages.append({"role": m["role"], "content": m["content"]})

        body: dict[str, Any] = {
            "model": model,
            "messages": user_messages,
            "max_tokens": max_tokens,
            "temperature": temperature,
        }
        if system_msg.strip():
            body["system"] = system_msg.strip()

        resp = await client.post(
            f"{self.base_url}/messages",
            json=body,
            headers={
                "x-api-key": self.api_key,
                "anthropic-version": "2024-01-01",
                "content-type": "application/json",
            },
        )
        resp.raise_for_status()
        data = resp.json()

        content = ""
        for block in data.get("content", []):
            if block.get("type") == "text":
                content += block.get("text", "")

        self._mark_success()
        return LLMResponse(
            content=content,
            model=model,
            provider=self.name,
            usage=data.get("usage", {}),
            latency_ms=(time.monotonic() - start) * 1000,
            finish_reason=data.get("stop_reason", "end_turn"),
        )

    async def embed(self, texts: list[str], model: str | None = None) -> list[list[float]]:
        # Anthropic doesn't have a native embeddings API — fallback to OpenAI or Voyage
        raise NotImplementedError("Anthropic does not support embeddings natively")


# ============================================================================
# Gemini Provider (Google)
# ============================================================================


class GeminiProvider(BaseLLMProvider):
    name = ProviderName.GEMINI

    def __init__(self, api_key: str):
        super().__init__(api_key, "https://generativelanguage.googleapis.com/v1beta")

    async def chat(
        self,
        messages: list[dict[str, str]],
        model: str | None = None,
        temperature: float = 0.3,
        max_tokens: int = 2000,
        response_format: dict | None = None,
        **kwargs: Any,
    ) -> LLMResponse:
        client = await self._get_client()
        model = model or "gemini-2.5-flash"
        start = time.monotonic()

        # Convert messages to Gemini format
        system_instruction = ""
        contents = []
        for m in messages:
            if m["role"] == "system":
                system_instruction += m["content"] + "\n"
            else:
                role = "user" if m["role"] == "user" else "model"
                contents.append({"role": role, "parts": [{"text": m["content"]}]})

        body: dict[str, Any] = {
            "contents": contents,
            "generationConfig": {
                "temperature": temperature,
                "maxOutputTokens": max_tokens,
            },
        }
        if system_instruction.strip():
            body["systemInstruction"] = {"parts": [{"text": system_instruction.strip()}]}
        if response_format and response_format.get("type") == "json_object":
            body["generationConfig"]["responseMimeType"] = "application/json"

        resp = await client.post(
            f"{self.base_url}/models/{model}:generateContent?key={self.api_key}",
            json=body,
        )
        resp.raise_for_status()
        data = resp.json()

        content = ""
        candidates = data.get("candidates", [])
        if candidates:
            parts = candidates[0].get("content", {}).get("parts", [])
            content = "".join(p.get("text", "") for p in parts)

        usage = data.get("usageMetadata", {})

        self._mark_success()
        return LLMResponse(
            content=content,
            model=model,
            provider=self.name,
            usage={
                "prompt_tokens": usage.get("promptTokenCount", 0),
                "completion_tokens": usage.get("candidatesTokenCount", 0),
                "total_tokens": usage.get("totalTokenCount", 0),
            },
            latency_ms=(time.monotonic() - start) * 1000,
        )

    async def embed(self, texts: list[str], model: str | None = None) -> list[list[float]]:
        client = await self._get_client()
        model = model or "text-embedding-004"

        results = []
        for text in texts:
            resp = await client.post(
                f"{self.base_url}/models/{model}:embedContent?key={self.api_key}",
                json={"model": f"models/{model}", "content": {"parts": [{"text": text}]}},
            )
            resp.raise_for_status()
            data = resp.json()
            results.append(data["embedding"]["values"])

        self._mark_success()
        return results


# ============================================================================
# HuggingFace Inference API Provider
# ============================================================================


class HuggingFaceProvider(BaseLLMProvider):
    name = ProviderName.HUGGINGFACE

    def __init__(self, api_key: str):
        super().__init__(api_key, "https://api-inference.huggingface.co/models")

    async def chat(
        self,
        messages: list[dict[str, str]],
        model: str | None = None,
        temperature: float = 0.3,
        max_tokens: int = 2000,
        response_format: dict | None = None,
        **kwargs: Any,
    ) -> LLMResponse:
        client = await self._get_client()
        model = model or "meta-llama/Llama-3.3-70B-Instruct"
        start = time.monotonic()

        # Use HF's chat completions (OpenAI-compatible) endpoint
        resp = await client.post(
            f"https://api-inference.huggingface.co/v1/chat/completions",
            json={
                "model": model,
                "messages": messages,
                "temperature": temperature,
                "max_tokens": max_tokens,
            },
            headers={"Authorization": f"Bearer {self.api_key}"},
            timeout=90.0,
        )
        resp.raise_for_status()
        data = resp.json()

        self._mark_success()
        return LLMResponse(
            content=data["choices"][0]["message"]["content"],
            model=model,
            provider=self.name,
            usage=data.get("usage", {}),
            latency_ms=(time.monotonic() - start) * 1000,
        )

    async def embed(self, texts: list[str], model: str | None = None) -> list[list[float]]:
        client = await self._get_client()
        model = model or "BAAI/bge-large-en-v1.5"

        resp = await client.post(
            f"{self.base_url}/{model}",
            json={"inputs": texts},
            headers={"Authorization": f"Bearer {self.api_key}"},
        )
        resp.raise_for_status()
        self._mark_success()
        return resp.json()


# ============================================================================
# OpenRouter Provider (Access to ALL major LLMs)
# ============================================================================


class OpenRouterProvider(BaseLLMProvider):
    name = ProviderName.OPENROUTER

    def __init__(self, api_key: str):
        super().__init__(api_key, "https://openrouter.ai/api/v1")

    async def chat(
        self,
        messages: list[dict[str, str]],
        model: str | None = None,
        temperature: float = 0.3,
        max_tokens: int = 2000,
        response_format: dict | None = None,
        **kwargs: Any,
    ) -> LLMResponse:
        client = await self._get_client()
        # OpenRouter model format: "provider/model"
        model = model or "openai/gpt-4o"
        start = time.monotonic()

        body: dict[str, Any] = {
            "model": model,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens,
        }
        if response_format:
            body["response_format"] = response_format

        resp = await client.post(
            f"{self.base_url}/chat/completions",
            json=body,
            headers={
                "Authorization": f"Bearer {self.api_key}",
                "HTTP-Referer": "https://speakup.app",
                "X-Title": "SpeakUp AI",
            },
        )
        resp.raise_for_status()
        data = resp.json()

        self._mark_success()
        return LLMResponse(
            content=data["choices"][0]["message"]["content"],
            model=model,
            provider=self.name,
            usage=data.get("usage", {}),
            latency_ms=(time.monotonic() - start) * 1000,
        )

    async def embed(self, texts: list[str], model: str | None = None) -> list[list[float]]:
        # OpenRouter supports embeddings via OpenAI-compatible API
        client = await self._get_client()
        model = model or "openai/text-embedding-3-small"

        resp = await client.post(
            f"{self.base_url}/embeddings",
            json={"model": model, "input": texts},
            headers={
                "Authorization": f"Bearer {self.api_key}",
                "HTTP-Referer": "https://speakup.app",
            },
        )
        resp.raise_for_status()
        data = resp.json()
        self._mark_success()
        return [item["embedding"] for item in data["data"]]


# ============================================================================
# Provider Factory
# ============================================================================

_providers: dict[ProviderName, BaseLLMProvider] = {}


def init_providers() -> dict[ProviderName, BaseLLMProvider]:
    """Initialize all configured LLM providers."""
    global _providers
    settings = get_settings()

    if settings.OPENAI_API_KEY:
        _providers[ProviderName.OPENAI] = OpenAIProvider(settings.OPENAI_API_KEY)
    if settings.ANTHROPIC_API_KEY:
        _providers[ProviderName.ANTHROPIC] = AnthropicProvider(settings.ANTHROPIC_API_KEY)
    if settings.GEMINI_API_KEY:
        _providers[ProviderName.GEMINI] = GeminiProvider(settings.GEMINI_API_KEY)
    if settings.HUGGINGFACE_API_KEY:
        _providers[ProviderName.HUGGINGFACE] = HuggingFaceProvider(settings.HUGGINGFACE_API_KEY)
    if settings.OPENROUTER_API_KEY:
        _providers[ProviderName.OPENROUTER] = OpenRouterProvider(settings.OPENROUTER_API_KEY)

    log.info("LLM providers initialized", providers=[p.value for p in _providers])
    return _providers


def get_provider(name: ProviderName) -> BaseLLMProvider | None:
    return _providers.get(name)


def get_available_providers() -> list[BaseLLMProvider]:
    return [p for p in _providers.values() if p.is_available]


async def shutdown_providers() -> None:
    for provider in _providers.values():
        await provider.close()
    _providers.clear()
