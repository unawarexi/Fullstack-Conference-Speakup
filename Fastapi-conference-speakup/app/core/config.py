# SpeakUp AI — Configuration
from __future__ import annotations

from functools import lru_cache
from typing import Literal

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # ── Application ──
    APP_NAME: str = "speakup-ai"
    APP_ENV: Literal["development", "staging", "production"] = "development"
    DEBUG: bool = True
    LOG_LEVEL: str = "INFO"
    API_V1_PREFIX: str = "/api/v1"
    SECRET_KEY: str = "change-me"
    ALLOWED_ORIGINS: list[str] = Field(default_factory=lambda: ["http://localhost:3000", "http://localhost:5000"])

    # ── Server ──
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    WORKERS: int = 4
    RELOAD: bool = True

    # ── PostgreSQL ──
    DATABASE_URL: str = "postgresql+asyncpg://speakup:speakup_dev@localhost:5432/speakup_ai"
    DATABASE_POOL_SIZE: int = 20
    DATABASE_MAX_OVERFLOW: int = 10

    # ── Redis ──
    REDIS_URL: str = "redis://localhost:6379/1"
    REDIS_MAX_CONNECTIONS: int = 50

    # ── Kafka ──
    KAFKA_BROKERS: str = "localhost:9092"
    KAFKA_CLIENT_ID: str = "speakup-ai"
    KAFKA_GROUP_ID: str = "speakup-ai-consumers"
    KAFKA_SSL: bool = False
    KAFKA_SASL_USERNAME: str = ""
    KAFKA_SASL_PASSWORD: str = ""

    # ── Qdrant ──
    QDRANT_HOST: str = "localhost"
    QDRANT_PORT: int = 6333
    QDRANT_API_KEY: str = ""
    QDRANT_COLLECTION_MEETINGS: str = "meeting_memories"
    QDRANT_COLLECTION_KNOWLEDGE: str = "knowledge_base"

    # ── Neo4j ──
    NEO4J_URI: str = "bolt://localhost:7687"
    NEO4J_USERNAME: str = "neo4j"
    NEO4J_PASSWORD: str = "speakup_dev"

    # ── OpenAI ──
    OPENAI_API_KEY: str = ""
    OPENAI_MODEL: str = "gpt-4o"
    OPENAI_EMBEDDING_MODEL: str = "text-embedding-3-small"

    # ── Anthropic ──
    ANTHROPIC_API_KEY: str = ""
    ANTHROPIC_MODEL: str = "claude-sonnet-4-20250514"

    # ── Google Gemini ──
    GEMINI_API_KEY: str = ""
    GEMINI_MODEL: str = "gemini-2.5-flash"
    GEMINI_PRO_MODEL: str = "gemini-2.5-pro"

    # ── HuggingFace ──
    HUGGINGFACE_API_KEY: str = ""
    HUGGINGFACE_MODEL: str = "meta-llama/Llama-3.3-70B-Instruct"

    # ── OpenRouter (fallback gateway to all LLMs) ──
    OPENROUTER_API_KEY: str = ""
    OPENROUTER_DEFAULT_MODEL: str = "openai/gpt-4o"

    # ── LLM Routing ──
    LLM_FALLBACK_ENABLED: bool = True
    LLM_CIRCUIT_BREAKER_THRESHOLD: int = 3
    LLM_CIRCUIT_BREAKER_TIMEOUT: int = 30

    # ── LangSmith ──
    LANGCHAIN_TRACING_V2: bool = False
    LANGCHAIN_API_KEY: str = ""
    LANGCHAIN_PROJECT: str = "speakup-ai"

    # ── MCP Tool Integrations ──
    # Slack
    SLACK_BOT_TOKEN: str = ""
    SLACK_USER_TOKEN: str = ""
    SLACK_DEFAULT_CHANNEL: str = ""

    # Google (Gmail + Calendar)
    GOOGLE_CLIENT_ID: str = ""
    GOOGLE_CLIENT_SECRET: str = ""
    GOOGLE_ACCESS_TOKEN: str = ""
    GOOGLE_REFRESH_TOKEN: str = ""

    # SMTP fallback for email
    SMTP_HOST: str = ""
    SMTP_PORT: int = 587
    SMTP_USERNAME: str = ""
    SMTP_PASSWORD: str = ""
    SMTP_FROM_EMAIL: str = ""

    # GitHub
    GITHUB_TOKEN: str = ""
    GITHUB_DEFAULT_OWNER: str = ""
    GITHUB_DEFAULT_REPO: str = ""

    # Jira
    JIRA_BASE_URL: str = ""
    JIRA_EMAIL: str = ""
    JIRA_API_TOKEN: str = ""
    JIRA_DEFAULT_PROJECT: str = ""

    # Linear
    LINEAR_API_KEY: str = ""
    LINEAR_DEFAULT_TEAM_ID: str = ""

    # Notion
    NOTION_API_KEY: str = ""

    # Tavily (web search)
    TAVILY_API_KEY: str = ""

    # Salesforce CRM
    SALESFORCE_INSTANCE_URL: str = ""
    SALESFORCE_ACCESS_TOKEN: str = ""

    # Twitter / X
    TWITTER_BEARER_TOKEN: str = ""

    # Microsoft Graph (Teams + Outlook)
    MICROSOFT_GRAPH_TOKEN: str = ""

    # ── OpenClaw ──
    OPENCLAW_URL: str = ""
    OPENCLAW_API_KEY: str = ""

    # ── LiveKit ──
    LIVEKIT_HOST: str = "http://localhost:7880"
    LIVEKIT_API_KEY: str = "devkey"
    LIVEKIT_API_SECRET: str = "secret"

    # ── Sentry ──
    SENTRY_DSN: str = ""

    # ── Express Backend ──
    EXPRESS_BACKEND_URL: str = "http://localhost:5000"
    EXPRESS_INTERNAL_API_KEY: str = ""

    # ── Celery ──
    CELERY_BROKER_URL: str = "redis://localhost:6379/2"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/3"

    # ── Model Paths ──
    WHISPER_MODEL_SIZE: str = "base"
    WHISPER_DEVICE: str = "cpu"
    WHISPER_COMPUTE_TYPE: str = "int8"
    MEDIAPIPE_MODEL_PATH: str = "./models/mediapipe"

    @field_validator("ALLOWED_ORIGINS", mode="before")
    @classmethod
    def parse_origins(cls, v: str | list[str]) -> list[str]:
        if isinstance(v, str):
            return [o.strip() for o in v.split(",") if o.strip()]
        return v

    @field_validator("KAFKA_BROKERS", mode="before")
    @classmethod
    def parse_brokers(cls, v: str) -> str:
        return v

    @property
    def kafka_broker_list(self) -> list[str]:
        return [b.strip() for b in self.KAFKA_BROKERS.split(",")]

    @property
    def is_production(self) -> bool:
        return self.APP_ENV == "production"


@lru_cache
def get_settings() -> Settings:
    return Settings()
