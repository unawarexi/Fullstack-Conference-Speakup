# SpeakUp AI — Intelligent LLM Router
# Task-based model selection + automatic fallback chain
from __future__ import annotations

import asyncio
from enum import Enum
from typing import Any

from app.core.logging import get_logger
from app.services.llm.providers import (
    BaseLLMProvider,
    LLMResponse,
    ProviderName,
    get_available_providers,
    get_provider,
)

log = get_logger("llm_router")


# ============================================================================
# Task Types — Each maps to optimal model configurations
# ============================================================================


class TaskType(str, Enum):
    # Real-time tasks (need speed + quality)
    COPILOT_SUGGESTIONS = "copilot_suggestions"
    COACHING_HINTS = "coaching_hints"
    LIVE_INSIGHTS = "live_insights"
    KNOWLEDGE_GAP = "knowledge_gap"
    EMOTION_ANALYSIS = "emotion_analysis"

    # Heavy tasks (need quality + large context)
    MEETING_SUMMARY = "meeting_summary"
    OUTCOME_PREDICTION = "outcome_prediction"
    COACHING_REPORT = "coaching_report"
    MEETING_REPLAY = "meeting_replay"

    # Agent orchestration
    AGENT_REASONING = "agent_reasoning"
    TOOL_SELECTION = "tool_selection"
    WORKFLOW_PLANNING = "workflow_planning"

    # Content generation
    RECAP_EMAIL = "recap_email"
    ACTION_ITEMS = "action_items"
    TICKET_CREATION = "ticket_creation"

    # Embeddings
    EMBEDDING = "embedding"

    # General
    GENERAL = "general"


# ============================================================================
# Model Configuration per Task
# ============================================================================

# Best model per task type — provider priority list + model overrides
# Format: [(provider, model_override_or_None, temperature, max_tokens)]
TASK_MODEL_MAP: dict[TaskType, list[tuple[ProviderName, str | None, float, int]]] = {
    # Real-time tasks: fast models, low tokens
    TaskType.COPILOT_SUGGESTIONS: [
        (ProviderName.GEMINI, "gemini-2.5-flash", 0.3, 1000),
        (ProviderName.OPENAI, "gpt-4o-mini", 0.3, 1000),
        (ProviderName.ANTHROPIC, "claude-sonnet-4-20250514", 0.3, 1000),
    ],
    TaskType.COACHING_HINTS: [
        (ProviderName.OPENAI, "gpt-4o-mini", 0.3, 800),
        (ProviderName.GEMINI, "gemini-2.5-flash", 0.3, 800),
        (ProviderName.ANTHROPIC, "claude-sonnet-4-20250514", 0.3, 800),
    ],
    TaskType.LIVE_INSIGHTS: [
        (ProviderName.GEMINI, "gemini-2.5-flash", 0.2, 600),
        (ProviderName.OPENAI, "gpt-4o-mini", 0.2, 600),
    ],
    TaskType.KNOWLEDGE_GAP: [
        (ProviderName.OPENAI, "gpt-4o", 0.3, 1200),
        (ProviderName.ANTHROPIC, "claude-sonnet-4-20250514", 0.3, 1200),
        (ProviderName.GEMINI, "gemini-2.5-flash", 0.3, 1200),
    ],
    TaskType.EMOTION_ANALYSIS: [
        (ProviderName.GEMINI, "gemini-2.5-flash", 0.2, 600),
        (ProviderName.OPENAI, "gpt-4o-mini", 0.2, 600),
    ],

    # Heavy tasks: best quality models, large context
    TaskType.MEETING_SUMMARY: [
        (ProviderName.ANTHROPIC, "claude-sonnet-4-20250514", 0.2, 4000),
        (ProviderName.OPENAI, "gpt-4o", 0.2, 4000),
        (ProviderName.GEMINI, "gemini-2.5-pro", 0.2, 4000),
    ],
    TaskType.OUTCOME_PREDICTION: [
        (ProviderName.OPENAI, "gpt-4o", 0.3, 1500),
        (ProviderName.ANTHROPIC, "claude-sonnet-4-20250514", 0.3, 1500),
        (ProviderName.GEMINI, "gemini-2.5-pro", 0.3, 1500),
    ],
    TaskType.COACHING_REPORT: [
        (ProviderName.ANTHROPIC, "claude-sonnet-4-20250514", 0.3, 3000),
        (ProviderName.OPENAI, "gpt-4o", 0.3, 3000),
        (ProviderName.GEMINI, "gemini-2.5-pro", 0.3, 3000),
    ],
    TaskType.MEETING_REPLAY: [
        (ProviderName.ANTHROPIC, "claude-sonnet-4-20250514", 0.2, 3000),
        (ProviderName.OPENAI, "gpt-4o", 0.2, 3000),
    ],

    # Agent tasks: strong reasoning
    TaskType.AGENT_REASONING: [
        (ProviderName.ANTHROPIC, "claude-sonnet-4-20250514", 0.4, 2000),
        (ProviderName.OPENAI, "gpt-4o", 0.4, 2000),
        (ProviderName.GEMINI, "gemini-2.5-pro", 0.4, 2000),
    ],
    TaskType.TOOL_SELECTION: [
        (ProviderName.OPENAI, "gpt-4o-mini", 0.1, 500),
        (ProviderName.GEMINI, "gemini-2.5-flash", 0.1, 500),
        (ProviderName.ANTHROPIC, "claude-sonnet-4-20250514", 0.1, 500),
    ],
    TaskType.WORKFLOW_PLANNING: [
        (ProviderName.ANTHROPIC, "claude-sonnet-4-20250514", 0.3, 2000),
        (ProviderName.OPENAI, "gpt-4o", 0.3, 2000),
    ],

    # Content tasks
    TaskType.RECAP_EMAIL: [
        (ProviderName.ANTHROPIC, "claude-sonnet-4-20250514", 0.4, 2000),
        (ProviderName.OPENAI, "gpt-4o", 0.4, 2000),
        (ProviderName.GEMINI, "gemini-2.5-pro", 0.4, 2000),
    ],
    TaskType.ACTION_ITEMS: [
        (ProviderName.OPENAI, "gpt-4o", 0.2, 1500),
        (ProviderName.ANTHROPIC, "claude-sonnet-4-20250514", 0.2, 1500),
    ],
    TaskType.TICKET_CREATION: [
        (ProviderName.OPENAI, "gpt-4o-mini", 0.2, 1000),
        (ProviderName.GEMINI, "gemini-2.5-flash", 0.2, 1000),
    ],

    # General
    TaskType.GENERAL: [
        (ProviderName.OPENAI, "gpt-4o", 0.3, 2000),
        (ProviderName.ANTHROPIC, "claude-sonnet-4-20250514", 0.3, 2000),
        (ProviderName.GEMINI, "gemini-2.5-flash", 0.3, 2000),
    ],
}

# OpenRouter fallback models per task category
OPENROUTER_FALLBACK_MAP: dict[TaskType, str] = {
    TaskType.COPILOT_SUGGESTIONS: "google/gemini-2.5-flash",
    TaskType.COACHING_HINTS: "openai/gpt-4o-mini",
    TaskType.LIVE_INSIGHTS: "google/gemini-2.5-flash",
    TaskType.KNOWLEDGE_GAP: "openai/gpt-4o",
    TaskType.EMOTION_ANALYSIS: "google/gemini-2.5-flash",
    TaskType.MEETING_SUMMARY: "anthropic/claude-sonnet-4-20250514",
    TaskType.OUTCOME_PREDICTION: "openai/gpt-4o",
    TaskType.COACHING_REPORT: "anthropic/claude-sonnet-4-20250514",
    TaskType.MEETING_REPLAY: "anthropic/claude-sonnet-4-20250514",
    TaskType.AGENT_REASONING: "anthropic/claude-sonnet-4-20250514",
    TaskType.TOOL_SELECTION: "openai/gpt-4o-mini",
    TaskType.WORKFLOW_PLANNING: "anthropic/claude-sonnet-4-20250514",
    TaskType.RECAP_EMAIL: "anthropic/claude-sonnet-4-20250514",
    TaskType.ACTION_ITEMS: "openai/gpt-4o",
    TaskType.TICKET_CREATION: "openai/gpt-4o-mini",
    TaskType.GENERAL: "openai/gpt-4o",
}

# HuggingFace fallback model (last resort before total failure)
HUGGINGFACE_FALLBACK_MODEL = "meta-llama/Llama-3.3-70B-Instruct"


# ============================================================================
# LLM Router
# ============================================================================


class LLMRouter:
    """
    Intelligent LLM router with task-based model selection and automatic fallback.

    Fallback chain per task:
    1. Best provider+model for the task (from TASK_MODEL_MAP)
    2. Next best provider+model
    3. ...all configured providers for the task
    4. OpenRouter (routes to any model)
    5. HuggingFace (open-source fallback)
    6. Try ALL remaining available providers with default models
    """

    async def chat(
        self,
        messages: list[dict[str, str]],
        task: TaskType = TaskType.GENERAL,
        temperature: float | None = None,
        max_tokens: int | None = None,
        response_format: dict | None = None,
        **kwargs: Any,
    ) -> LLMResponse:
        """Route chat to the best available model for the task with automatic fallback."""
        errors: list[str] = []
        task_config = TASK_MODEL_MAP.get(task, TASK_MODEL_MAP[TaskType.GENERAL])

        # Phase 1: Try task-specific providers in priority order
        for provider_name, model, default_temp, default_max in task_config:
            provider = get_provider(provider_name)
            if provider is None or not provider.is_available:
                continue

            try:
                return await provider.chat(
                    messages=messages,
                    model=model,
                    temperature=temperature if temperature is not None else default_temp,
                    max_tokens=max_tokens if max_tokens is not None else default_max,
                    response_format=response_format,
                    **kwargs,
                )
            except Exception as e:
                provider._mark_failure()
                errors.append(f"{provider_name.value}/{model}: {e}")
                log.warning("Provider failed, trying next", provider=provider_name.value, model=model, error=str(e))
                continue

        # Phase 2: OpenRouter fallback (can access any model)
        openrouter = get_provider(ProviderName.OPENROUTER)
        if openrouter and openrouter.is_available:
            or_model = OPENROUTER_FALLBACK_MAP.get(task, "openai/gpt-4o")
            try:
                log.info("Falling back to OpenRouter", task=task.value, model=or_model)
                return await openrouter.chat(
                    messages=messages,
                    model=or_model,
                    temperature=temperature if temperature is not None else 0.3,
                    max_tokens=max_tokens if max_tokens is not None else 2000,
                    response_format=response_format,
                    **kwargs,
                )
            except Exception as e:
                openrouter._mark_failure()
                errors.append(f"openrouter/{or_model}: {e}")
                log.warning("OpenRouter fallback failed", error=str(e))

        # Phase 3: HuggingFace fallback (open-source)
        hf = get_provider(ProviderName.HUGGINGFACE)
        if hf and hf.is_available:
            try:
                log.info("Falling back to HuggingFace", task=task.value)
                return await hf.chat(
                    messages=messages,
                    model=HUGGINGFACE_FALLBACK_MODEL,
                    temperature=temperature if temperature is not None else 0.3,
                    max_tokens=max_tokens if max_tokens is not None else 2000,
                    **kwargs,
                )
            except Exception as e:
                hf._mark_failure()
                errors.append(f"huggingface/{HUGGINGFACE_FALLBACK_MODEL}: {e}")
                log.warning("HuggingFace fallback failed", error=str(e))

        # Phase 4: Last resort — try ALL available providers with their default models
        tried_providers = {cfg[0] for cfg in task_config}
        tried_providers.add(ProviderName.OPENROUTER)
        tried_providers.add(ProviderName.HUGGINGFACE)

        for provider in get_available_providers():
            if provider.name in tried_providers:
                continue
            try:
                log.info("Last resort attempt", provider=provider.name.value)
                return await provider.chat(
                    messages=messages,
                    temperature=temperature if temperature is not None else 0.3,
                    max_tokens=max_tokens if max_tokens is not None else 2000,
                    **kwargs,
                )
            except Exception as e:
                provider._mark_failure()
                errors.append(f"{provider.name.value}/default: {e}")
                continue

        # All providers exhausted
        error_summary = "; ".join(errors[-5:])  # Last 5 errors
        raise RuntimeError(
            f"All LLM providers failed for task '{task.value}'. Errors: {error_summary}"
        )

    async def embed(
        self,
        texts: list[str],
        model: str | None = None,
    ) -> list[list[float]]:
        """Generate embeddings with automatic fallback."""
        # Priority: OpenAI → Gemini → OpenRouter → HuggingFace
        embedding_providers = [
            (ProviderName.OPENAI, "text-embedding-3-small"),
            (ProviderName.GEMINI, "text-embedding-004"),
            (ProviderName.OPENROUTER, "openai/text-embedding-3-small"),
            (ProviderName.HUGGINGFACE, "BAAI/bge-large-en-v1.5"),
        ]

        for provider_name, default_model in embedding_providers:
            provider = get_provider(provider_name)
            if provider is None or not provider.is_available:
                continue
            try:
                return await provider.embed(texts, model=model or default_model)
            except NotImplementedError:
                continue
            except Exception as e:
                provider._mark_failure()
                log.warning("Embedding provider failed", provider=provider_name.value, error=str(e))
                continue

        raise RuntimeError("All embedding providers failed")

    def get_health_status(self) -> dict[str, Any]:
        """Return health status of all providers."""
        from app.services.llm.providers import _providers
        return {
            name.value: {
                "available": p.is_available,
                "healthy": p._healthy,
                "failure_count": p._failure_count,
                "has_key": bool(p.api_key),
            }
            for name, p in _providers.items()
        }


# ============================================================================
# Singleton Router
# ============================================================================

_router: LLMRouter | None = None


def get_llm_router() -> LLMRouter:
    global _router
    if _router is None:
        _router = LLMRouter()
    return _router
