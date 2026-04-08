# SpeakUp AI — API Router Aggregator
from __future__ import annotations

from fastapi import APIRouter

from app.api.v1.endpoints import agents, assistant, copilot, cv, emotion, health, mcp_tools, memory, speech, workflow

api_router = APIRouter()

# AI Service endpoints (called by Express backend)
api_router.include_router(speech.router)
api_router.include_router(cv.router)
api_router.include_router(emotion.router)
api_router.include_router(copilot.router)
api_router.include_router(memory.router)
api_router.include_router(agents.router)

# Voice assistant & MCP tools
api_router.include_router(assistant.router)
api_router.include_router(mcp_tools.router)
api_router.include_router(workflow.router)

# Health (no auth required)
api_router.include_router(health.router)
