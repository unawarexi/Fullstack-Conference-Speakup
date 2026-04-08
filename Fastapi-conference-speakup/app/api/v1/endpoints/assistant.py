# SpeakUp AI — Voice Assistant API Endpoints
from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field

from app.core.security import verify_internal_api_key

router = APIRouter(prefix="/assistant", tags=["assistant"], dependencies=[Depends(verify_internal_api_key)])


class VoiceCommandRequest(BaseModel):
    text: str = Field(..., description="Transcribed voice command text")
    user_id: str
    meeting_id: str | None = None


class CommandConfirmRequest(BaseModel):
    user_id: str
    meeting_id: str | None = None
    parsed_command: dict[str, Any]


class SetMeetingContextRequest(BaseModel):
    meeting_id: str
    context: dict[str, Any]


@router.post("/voice-command")
async def process_voice_command(req: VoiceCommandRequest):
    """Process a voice command from a meeting participant."""
    from app.services.assistant.voice_commands import get_voice_assistant

    assistant = get_voice_assistant()
    result = assistant.detect_command(req.text)
    if not result[0]:
        return {"is_command": False, "text": req.text}

    parsed = await assistant.parse_command(result[1], req.user_id, req.meeting_id)

    if parsed.requires_confirmation:
        return {
            "is_command": True,
            "awaiting_confirmation": True,
            "intent": parsed.intent,
            "tools": parsed.tools,
            "confidence": parsed.confidence,
            "category": parsed.category.value,
        }

    cmd_result = await assistant.execute_command(parsed, req.user_id, req.meeting_id)
    return {
        "is_command": True,
        "success": cmd_result.success,
        "message": cmd_result.message,
        "data": cmd_result.data,
        "follow_up": cmd_result.follow_up_suggestion,
    }


@router.post("/voice-command/confirm")
async def confirm_and_execute(req: CommandConfirmRequest):
    """Execute a previously confirmed voice command."""
    from app.services.assistant.voice_commands import get_voice_assistant, ParsedCommand, CommandCategory

    assistant = get_voice_assistant()
    parsed = ParsedCommand(
        category=CommandCategory(req.parsed_command.get("category", "general")),
        intent=req.parsed_command.get("intent", ""),
        tools=req.parsed_command.get("tools", []),
        parameters=req.parsed_command.get("parameters", {}),
        confidence=req.parsed_command.get("confidence", 1.0),
        original_text=req.parsed_command.get("intent", ""),
        requires_confirmation=False,
    )

    cmd_result = await assistant.execute_command(parsed, req.user_id, req.meeting_id)
    return {
        "success": cmd_result.success,
        "message": cmd_result.message,
        "data": cmd_result.data,
        "follow_up": cmd_result.follow_up_suggestion,
    }


@router.post("/meeting-context")
async def set_meeting_context(req: SetMeetingContextRequest):
    """Set meeting context for better command resolution."""
    from app.services.assistant.voice_commands import get_voice_assistant

    assistant = get_voice_assistant()
    assistant.set_meeting_context(req.meeting_id, req.context)
    return {"ok": True}
