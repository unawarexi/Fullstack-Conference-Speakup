# SpeakUp AI — Voice Command Assistant
# Parses natural language voice commands from users in meetings
# and routes them to appropriate MCP tools or OpenClaw
from __future__ import annotations

import asyncio
import re
from dataclasses import dataclass, field
from enum import Enum
from typing import Any

from app.core.logging import get_logger
from app.services.llm.router import LLMRouter, TaskType, get_llm_router
from app.services.mcp.registry import execute_tool, execute_tools_parallel, get_tools_schema, ToolResult
from app.services.openclaw.bridge import get_openclaw_bridge

log = get_logger("voice_assistant")


class CommandCategory(str, Enum):
    EMAIL = "email"
    MESSAGING = "messaging"
    CALENDAR = "calendar"
    TICKETS = "tickets"
    DOCUMENTATION = "documentation"
    SEARCH = "search"
    BROWSER = "browser"
    MEETING_CONTROL = "meeting_control"
    GENERAL = "general"


@dataclass
class ParsedCommand:
    category: CommandCategory
    intent: str
    tools: list[str]
    parameters: dict[str, Any]
    confidence: float
    original_text: str
    requires_confirmation: bool = False


@dataclass
class CommandResult:
    success: bool
    message: str
    data: dict[str, Any] = field(default_factory=dict)
    tool_results: list[ToolResult] = field(default_factory=list)
    follow_up_suggestion: str | None = None


# Quick-match patterns for common commands (avoids LLM call overhead)
QUICK_PATTERNS: list[tuple[re.Pattern, CommandCategory, str, list[str]]] = [
    (re.compile(r"send (?:a |an )?(?:recap|summary) (?:email|mail) to (.+)", re.I), CommandCategory.EMAIL, "send_recap", ["email_draft_recap", "email_send"]),
    (re.compile(r"email (.+?) (?:about|regarding|with) (.+)", re.I), CommandCategory.EMAIL, "send_email", ["email_send"]),
    (re.compile(r"search (?:my )?emails? (?:for|about) (.+)", re.I), CommandCategory.EMAIL, "search_email", ["email_search"]),
    (re.compile(r"(?:post|send|share) (?:the )?(?:summary|recap|notes) (?:to|on|in) (?:#)?(\S+)", re.I), CommandCategory.MESSAGING, "post_summary", ["slack_post_meeting_summary"]),
    (re.compile(r"(?:message|send|dm|text) (.+?) (?:on|in|via) slack (?:about|saying|that) (.+)", re.I), CommandCategory.MESSAGING, "send_slack", ["slack_send_message"]),
    (re.compile(r"(?:create|make|add|open) (?:a )?(?:ticket|issue|task|bug) (?:for|about|titled?) (.+)", re.I), CommandCategory.TICKETS, "create_ticket", ["jira_create_ticket"]),
    (re.compile(r"(?:schedule|book|set up|create) (?:a )?(?:follow[ -]?up|meeting) (?:with|for) (.+)", re.I), CommandCategory.CALENDAR, "schedule_meeting", ["calendar_schedule_followup"]),
    (re.compile(r"(?:what(?:'s| is) on|check) (?:my )?calendar (?:for )?(.+)?", re.I), CommandCategory.CALENDAR, "check_calendar", ["calendar_list_events"]),
    (re.compile(r"(?:search|find|look up|google|research) (.+)", re.I), CommandCategory.SEARCH, "web_search", ["web_search"]),
    (re.compile(r"(?:update|add to|edit) (?:the )?(?:meeting )?notes? (?:with|to include|adding) (.+)", re.I), CommandCategory.DOCUMENTATION, "update_notes", ["notion_update_meeting_notes"]),
    (re.compile(r"(?:create|make) (?:a )?(?:github |gh )?(?:issue|pr comment) (?:for|about) (.+)", re.I), CommandCategory.TICKETS, "github_issue", ["github_create_issue"]),
]

# System prompt for the LLM-based command parser
COMMAND_PARSER_PROMPT = """You are SpeakUp AI's voice command parser. A user in a meeting said a command. Parse it into a structured action.

Available tools:
{tools_schema}

Respond with ONLY valid JSON:
{{
  "category": "email|messaging|calendar|tickets|documentation|search|browser|meeting_control|general",
  "intent": "brief description of what user wants",
  "tools": ["tool_name_1", "tool_name_2"],
  "parameters": {{"tool_name.param": "value"}},
  "confidence": 0.0-1.0,
  "requires_confirmation": true/false
}}

Rules:
- requires_confirmation = true for destructive/send actions (sending emails, posting, creating tickets)
- Use the most specific tool available
- If the command maps to multiple sequential tools, list them in order
- If no tool matches, set tools to [] and suggest using OpenClaw
- Extract parameter values from the command where possible
- For ambiguous references like "everyone" or "the team", flag as needs_resolution
"""


class VoiceCommandAssistant:
    """
    Processes natural language voice commands from meeting participants.

    Flow:
    1. User speaks a command during meeting (captured by transcription service)
    2. Command is detected by prefix/trigger word or AI classification
    3. This service parses the command into structured intent + parameters
    4. Executes via MCP tools or OpenClaw
    5. Returns result to user via WebSocket
    """

    def __init__(self) -> None:
        self._router: LLMRouter | None = None
        self._meeting_contexts: dict[str, dict[str, Any]] = {}  # meeting_id -> context

    @property
    def router(self) -> LLMRouter:
        if self._router is None:
            self._router = get_llm_router()
        return self._router

    # ====================================================================
    # Meeting Context (enriches command parsing)
    # ====================================================================

    def set_meeting_context(self, meeting_id: str, context: dict[str, Any]) -> None:
        """Store meeting context for better command resolution."""
        self._meeting_contexts[meeting_id] = context

    def update_meeting_context(self, meeting_id: str, updates: dict[str, Any]) -> None:
        ctx = self._meeting_contexts.get(meeting_id, {})
        ctx.update(updates)
        self._meeting_contexts[meeting_id] = ctx

    def clear_meeting_context(self, meeting_id: str) -> None:
        self._meeting_contexts.pop(meeting_id, None)

    # ====================================================================
    # Command Detection — is this a command or regular speech?
    # ====================================================================

    TRIGGER_PREFIXES = [
        "hey speakup", "speakup", "hey assistant", "assistant",
        "ai please", "ai ", "could you ", "can you ", "please ",
    ]

    def detect_command(self, text: str) -> tuple[bool, str]:
        """
        Check if transcribed text is a voice command.
        Returns (is_command, cleaned_command_text).
        """
        lower = text.lower().strip()

        for prefix in self.TRIGGER_PREFIXES:
            if lower.startswith(prefix):
                cleaned = text[len(prefix):].strip().lstrip(",").strip()
                if len(cleaned) > 3:
                    return True, cleaned

        # Imperative verbs that suggest a command
        imperative_starts = [
            "send", "email", "message", "post", "create", "make", "schedule",
            "book", "search", "find", "look up", "check", "update", "add",
            "show", "get", "list", "open", "close", "mute", "unmute",
            "share", "draft", "summarize", "remind",
        ]
        first_word = lower.split()[0] if lower.split() else ""
        if first_word in imperative_starts:
            return True, text.strip()

        return False, text.strip()

    # ====================================================================
    # Command Parsing
    # ====================================================================

    async def parse_command(
        self,
        command_text: str,
        user_id: str,
        meeting_id: str | None = None,
    ) -> ParsedCommand:
        """Parse a voice command into structured intent + tools."""

        # Phase 1: Quick pattern match (no LLM call needed)
        for pattern, category, intent, tools in QUICK_PATTERNS:
            match = pattern.search(command_text)
            if match:
                params = {}
                groups = match.groups()
                if tools and groups:
                    params["_extracted"] = [g for g in groups if g]
                return ParsedCommand(
                    category=category,
                    intent=intent,
                    tools=tools,
                    parameters=params,
                    confidence=0.85,
                    original_text=command_text,
                    requires_confirmation=category in (CommandCategory.EMAIL, CommandCategory.MESSAGING, CommandCategory.TICKETS),
                )

        # Phase 2: LLM-based parsing
        tools_schema = get_tools_schema()
        schema_summary = "\n".join(
            f"- {t['function']['name']}: {t['function']['description']}"
            for t in tools_schema[:30]
        )

        meeting_ctx = ""
        if meeting_id and meeting_id in self._meeting_contexts:
            ctx = self._meeting_contexts[meeting_id]
            meeting_ctx = f"\n\nMeeting context: {ctx.get('title', 'Unknown')}. Attendees: {', '.join(ctx.get('attendees', []))}."

        messages = [
            {"role": "system", "content": COMMAND_PARSER_PROMPT.format(tools_schema=schema_summary)},
            {"role": "user", "content": f'Voice command: "{command_text}"{meeting_ctx}'},
        ]

        try:
            result = await self.router.chat(messages, task_type=TaskType.TOOL_SELECTION)
            import orjson
            parsed = orjson.loads(result.content)
            return ParsedCommand(
                category=CommandCategory(parsed.get("category", "general")),
                intent=parsed.get("intent", command_text),
                tools=parsed.get("tools", []),
                parameters=parsed.get("parameters", {}),
                confidence=parsed.get("confidence", 0.5),
                original_text=command_text,
                requires_confirmation=parsed.get("requires_confirmation", True),
            )
        except Exception as e:
            log.warning("LLM parse failed, falling back to OpenClaw", error=str(e))
            return ParsedCommand(
                category=CommandCategory.GENERAL,
                intent=command_text,
                tools=[],
                parameters={},
                confidence=0.3,
                original_text=command_text,
                requires_confirmation=True,
            )

    # ====================================================================
    # Command Execution
    # ====================================================================

    async def execute_command(
        self,
        parsed: ParsedCommand,
        user_id: str,
        meeting_id: str | None = None,
    ) -> CommandResult:
        """Execute a parsed command via MCP tools or OpenClaw."""

        # If no tools matched, delegate to OpenClaw
        if not parsed.tools:
            return await self._execute_via_openclaw(parsed, user_id, meeting_id)

        tool_results: list[ToolResult] = []

        for tool_name in parsed.tools:
            params = self._resolve_parameters(parsed, tool_name, user_id, meeting_id)
            try:
                result = await execute_tool(tool_name, params)
                tool_results.append(result)
                if not result.success:
                    log.warning("Tool execution failed", tool=tool_name, error=result.error)
            except Exception as e:
                log.exception("Tool execution error", tool=tool_name, error=str(e))
                tool_results.append(ToolResult(success=False, data={}, error=str(e)))

        all_success = all(r.success for r in tool_results)
        summary = await self._generate_response(parsed, tool_results, user_id)

        return CommandResult(
            success=all_success,
            message=summary,
            data={"tools_executed": [t for t in parsed.tools]},
            tool_results=tool_results,
            follow_up_suggestion=self._suggest_follow_up(parsed),
        )

    async def _execute_via_openclaw(
        self, parsed: ParsedCommand, user_id: str, meeting_id: str | None
    ) -> CommandResult:
        """Fallback: execute command via OpenClaw."""
        bridge = get_openclaw_bridge()
        if not bridge.is_configured:
            return CommandResult(
                success=False,
                message="I couldn't identify the right tool for that command, and OpenClaw is not configured. Could you rephrase?",
                data={"category": parsed.category.value},
            )

        result = await bridge.execute_voice_command(parsed.original_text, user_id, meeting_id)
        return CommandResult(
            success=result.get("success", False),
            message=result.get("response", "Command sent to OpenClaw."),
            data=result,
        )

    def _resolve_parameters(
        self,
        parsed: ParsedCommand,
        tool_name: str,
        user_id: str,
        meeting_id: str | None,
    ) -> dict[str, Any]:
        """Resolve tool parameters from parsed command + context."""
        params: dict[str, Any] = {}

        # Pull tool-specific params from the parsed parameters
        for key, val in parsed.parameters.items():
            if key.startswith(f"{tool_name}."):
                params[key.split(".", 1)[1]] = val
            elif "." not in key and key != "_extracted":
                params[key] = val

        # Inject context
        if meeting_id:
            params.setdefault("meeting_id", meeting_id)
            ctx = self._meeting_contexts.get(meeting_id, {})
            if "summary" in ctx:
                params.setdefault("summary", ctx["summary"])
            if "attendees" in ctx:
                params.setdefault("attendees", ctx["attendees"])

        params.setdefault("user_id", user_id)

        # Use extracted regex groups as fallback values
        extracted = parsed.parameters.get("_extracted", [])
        if extracted and not params.get("query") and not params.get("text"):
            params["_extracted_values"] = extracted

        return params

    async def _generate_response(
        self,
        parsed: ParsedCommand,
        results: list[ToolResult],
        user_id: str,
    ) -> str:
        """Generate a human-friendly response for the command result."""
        if not results:
            return "No actions were taken."

        if len(results) == 1:
            r = results[0]
            if r.success:
                return f"Done — {parsed.intent}."
            return f"I tried to {parsed.intent}, but ran into an issue: {r.error or 'unknown error'}."

        successes = sum(1 for r in results if r.success)
        total = len(results)
        if successes == total:
            return f"All {total} actions completed successfully."
        return f"Completed {successes}/{total} actions. Some steps had issues."

    def _suggest_follow_up(self, parsed: ParsedCommand) -> str | None:
        """Suggest a logical next action."""
        suggestions = {
            "send_recap": "Want me to also post it to Slack?",
            "create_ticket": "Should I assign it to someone?",
            "schedule_meeting": "Want me to add an agenda?",
            "post_summary": "Should I also email the full notes?",
            "web_search": "Want me to save these findings to the meeting notes?",
        }
        return suggestions.get(parsed.intent)

    # ====================================================================
    # High-Level API: Process raw transcription
    # ====================================================================

    async def process_transcription(
        self,
        text: str,
        user_id: str,
        meeting_id: str | None = None,
    ) -> CommandResult | None:
        """
        Full pipeline: detect → parse → confirm/execute.
        Returns None if the text is not a command.
        """
        is_command, cleaned = self.detect_command(text)
        if not is_command:
            return None

        log.info("Voice command detected", user_id=user_id, command=cleaned[:100])

        parsed = await self.parse_command(cleaned, user_id, meeting_id)

        if parsed.requires_confirmation:
            # Return the parsed command for user confirmation (via WebSocket)
            return CommandResult(
                success=True,
                message=f'I understood: "{parsed.intent}". Should I proceed?',
                data={
                    "awaiting_confirmation": True,
                    "parsed_command": {
                        "category": parsed.category.value,
                        "intent": parsed.intent,
                        "tools": parsed.tools,
                        "confidence": parsed.confidence,
                    },
                },
            )

        return await self.execute_command(parsed, user_id, meeting_id)


# Singleton
_assistant: VoiceCommandAssistant | None = None


def get_voice_assistant() -> VoiceCommandAssistant:
    global _assistant
    if _assistant is None:
        _assistant = VoiceCommandAssistant()
    return _assistant
