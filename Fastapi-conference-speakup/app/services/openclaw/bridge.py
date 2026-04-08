# SpeakUp AI — OpenClaw Integration Bridge
# Connects to OpenClaw for browser automation, system actions, and long-running workflows
# OpenClaw acts as the privileged automation runtime (email, browser, shell, MCP skills)
from __future__ import annotations

import asyncio
from typing import Any

import httpx

from app.core.config import get_settings
from app.core.logging import get_logger

log = get_logger("openclaw_bridge")


class OpenClawBridge:
    """
    Bridge to an OpenClaw instance for automation tasks.

    OpenClaw runs as a separate service (on user's machine or cloud) and provides:
    - Browser automation (fill forms, scrape data, navigate sites)
    - System actions (file management, shell commands)
    - MCP skill execution (community skills for any task)
    - Long-running background workflows
    - Chat integration (WhatsApp, Telegram, Slack, Discord)

    Communication: REST API to OpenClaw's HTTP server.
    """

    def __init__(self) -> None:
        self._client: httpx.AsyncClient | None = None
        self._healthy: bool = False

    @property
    def base_url(self) -> str:
        return get_settings().OPENCLAW_URL

    @property
    def api_key(self) -> str:
        return get_settings().OPENCLAW_API_KEY

    @property
    def is_configured(self) -> bool:
        return bool(self.base_url and self.api_key)

    async def _get_client(self) -> httpx.AsyncClient:
        if self._client is None or self._client.is_closed:
            self._client = httpx.AsyncClient(
                timeout=120.0,
                headers={
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json",
                    "X-Service": "speakup-ai",
                },
            )
        return self._client

    async def check_health(self) -> bool:
        if not self.is_configured:
            return False
        try:
            client = await self._get_client()
            resp = await client.get(f"{self.base_url}/health", timeout=10.0)
            self._healthy = resp.status_code == 200
            return self._healthy
        except Exception:
            self._healthy = False
            return False

    # ====================================================================
    # Core Message API — Send tasks to OpenClaw as natural language
    # ====================================================================

    async def send_message(self, message: str, context: dict[str, Any] | None = None) -> dict[str, Any]:
        """
        Send a natural language instruction to OpenClaw.
        OpenClaw will figure out what tools/skills to use.
        """
        if not self.is_configured:
            return {"success": False, "error": "OpenClaw not configured"}

        client = await self._get_client()
        body: dict[str, Any] = {"message": message}
        if context:
            body["context"] = context

        try:
            resp = await client.post(f"{self.base_url}/api/message", json=body)
            resp.raise_for_status()
            return resp.json()
        except Exception as e:
            log.exception("OpenClaw message failed", error=str(e))
            return {"success": False, "error": str(e)}

    # ====================================================================
    # Pre-Meeting Preparation
    # ====================================================================

    async def prepare_meeting(
        self,
        meeting_id: str,
        attendee_emails: list[str],
        agenda: str | None = None,
        context: str | None = None,
    ) -> dict[str, Any]:
        """
        Trigger OpenClaw pre-meeting preparation workflow:
        - Fetch recent email threads with attendees
        - Parse any shared docs/links
        - Gather LinkedIn/company research on attendees
        - Collect previous meeting notes
        - Fetch relevant Jira/Linear tickets
        - Prepare talking points
        """
        prompt = f"""Prepare for an upcoming meeting (ID: {meeting_id}).

Attendees: {', '.join(attendee_emails)}
{"Agenda: " + agenda if agenda else "No agenda provided."}
{"Additional context: " + context if context else ""}

Please:
1. Search my recent emails for threads with these attendees
2. Look up any shared documents or links related to the agenda
3. Check for any open tickets or issues related to the attendees or topics
4. Summarize previous interactions with these people
5. Prepare 5-10 smart talking points
6. Identify any potential risks or blockers to discuss
7. Create a brief attendee profile for each participant

Return a structured JSON report with all findings."""

        return await self.send_message(prompt, context={
            "meeting_id": meeting_id,
            "workflow": "pre_meeting_prep",
            "attendees": attendee_emails,
        })

    # ====================================================================
    # Post-Meeting Automation
    # ====================================================================

    async def execute_post_meeting_actions(
        self,
        meeting_id: str,
        summary: str,
        action_items: list[dict[str, Any]],
        decisions: list[dict[str, Any]],
        attendee_emails: list[str],
    ) -> dict[str, Any]:
        """
        Trigger OpenClaw post-meeting automation:
        - Send recap email to all attendees
        - Create Jira/Linear tickets for action items
        - Update Notion/docs with meeting notes
        - Update CRM with meeting outcomes
        - Schedule follow-up meetings if needed
        - Post summary to designated Slack channel
        """
        import orjson

        prompt = f"""Post-meeting automation for meeting {meeting_id}.

Summary: {summary}

Action Items: {orjson.dumps(action_items).decode()}

Decisions: {orjson.dumps(decisions).decode()}

Attendees: {', '.join(attendee_emails)}

Please execute these post-meeting tasks:
1. Draft and prepare a recap email for all attendees (show me before sending)
2. Create tickets for each action item in the project tracker
3. Update the meeting notes document
4. If there are unresolved items, suggest scheduling a follow-up
5. Post a summary to the team Slack channel

Return results for each action taken."""

        return await self.send_message(prompt, context={
            "meeting_id": meeting_id,
            "workflow": "post_meeting_automation",
        })

    # ====================================================================
    # Voice Command Execution
    # ====================================================================

    async def execute_voice_command(
        self,
        command: str,
        user_id: str,
        meeting_id: str | None = None,
    ) -> dict[str, Any]:
        """
        Execute a user's voice command via OpenClaw.
        Examples:
        - "Find the architecture document John mentioned"
        - "Search my emails for the proposal from last week"
        - "Create a ticket for the Redis caching issue"
        - "Schedule a follow-up with Sarah next Tuesday"
        - "Post the meeting summary to #engineering"
        """
        context_info = f"User {user_id}"
        if meeting_id:
            context_info += f" is in meeting {meeting_id}"

        return await self.send_message(
            f"[Voice Command from {context_info}]: {command}",
            context={"user_id": user_id, "meeting_id": meeting_id, "source": "voice_command"},
        )

    # ====================================================================
    # Browser Automation
    # ====================================================================

    async def browse_and_extract(self, url: str, instruction: str) -> dict[str, Any]:
        """Navigate to a URL and extract information per instruction."""
        return await self.send_message(
            f"Browse to {url} and {instruction}. Return the extracted information as structured data.",
            context={"workflow": "browser_automation"},
        )

    # ====================================================================
    # Skill Management
    # ====================================================================

    async def list_skills(self) -> dict[str, Any]:
        """List available OpenClaw skills."""
        if not self.is_configured:
            return {"success": False, "error": "OpenClaw not configured"}
        try:
            client = await self._get_client()
            resp = await client.get(f"{self.base_url}/api/skills")
            resp.raise_for_status()
            return resp.json()
        except Exception as e:
            return {"success": False, "error": str(e)}

    async def install_skill(self, skill_name: str) -> dict[str, Any]:
        """Install a skill from ClawHub."""
        return await self.send_message(
            f"Install the skill '{skill_name}' from ClawHub and confirm it's working.",
            context={"workflow": "skill_install"},
        )

    # ====================================================================
    # Lifecycle
    # ====================================================================

    async def close(self) -> None:
        if self._client and not self._client.is_closed:
            await self._client.aclose()


# Singleton
_bridge: OpenClawBridge | None = None


def get_openclaw_bridge() -> OpenClawBridge:
    global _bridge
    if _bridge is None:
        _bridge = OpenClawBridge()
    return _bridge


async def shutdown_openclaw() -> None:
    global _bridge
    if _bridge:
        await _bridge.close()
        _bridge = None
