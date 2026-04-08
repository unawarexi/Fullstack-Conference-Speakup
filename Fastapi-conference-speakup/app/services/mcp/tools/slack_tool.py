# SpeakUp AI — Slack MCP Tool
from __future__ import annotations

from typing import Any

import httpx

from app.core.config import get_settings
from app.core.logging import get_logger
from app.services.mcp.registry import (
    ToolCategory,
    ToolParameter,
    ToolResult,
    register_tool,
)

log = get_logger("mcp_slack")

SLACK_API = "https://slack.com/api"


async def _slack_request(method: str, params: dict[str, Any]) -> dict:
    settings = get_settings()
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.post(
            f"{SLACK_API}/{method}",
            json=params,
            headers={"Authorization": f"Bearer {settings.SLACK_BOT_TOKEN}", "Content-Type": "application/json"},
        )
        resp.raise_for_status()
        return resp.json()


@register_tool(
    name="slack_send_message",
    description="Send a message to a Slack channel or user. Supports markdown formatting and blocks.",
    category=ToolCategory.MESSAGING,
    parameters=[
        ToolParameter("channel", "string", "Channel ID or user ID"),
        ToolParameter("text", "string", "Message text (supports Slack markdown)"),
        ToolParameter("thread_ts", "string", "Thread timestamp to reply to", required=False),
    ],
)
async def slack_send_message(
    channel: str, text: str, thread_ts: str = "",
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    body: dict[str, Any] = {"channel": channel, "text": text}
    if thread_ts:
        body["thread_ts"] = thread_ts
    data = await _slack_request("chat.postMessage", body)
    if data.get("ok"):
        return ToolResult(success=True, data={"ts": data.get("ts"), "channel": data.get("channel")})
    return ToolResult(success=False, error=data.get("error", "Unknown Slack error"))


@register_tool(
    name="slack_search_messages",
    description="Search Slack messages across all channels the bot has access to.",
    category=ToolCategory.MESSAGING,
    parameters=[
        ToolParameter("query", "string", "Search query"),
        ToolParameter("count", "integer", "Number of results", required=False, default=10),
    ],
)
async def slack_search_messages(
    query: str, count: int = 10,
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    settings = get_settings()
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.get(
            f"{SLACK_API}/search.messages",
            params={"query": query, "count": count},
            headers={"Authorization": f"Bearer {settings.SLACK_USER_TOKEN}"},
        )
        data = resp.json()
    if data.get("ok"):
        matches = data.get("messages", {}).get("matches", [])
        return ToolResult(success=True, data={"messages": [
            {"text": m.get("text", "")[:500], "user": m.get("user"), "channel": m.get("channel", {}).get("name"), "ts": m.get("ts")}
            for m in matches
        ]})
    return ToolResult(success=False, error=data.get("error", "Search failed"))


@register_tool(
    name="slack_list_channels",
    description="List Slack channels the bot can access.",
    category=ToolCategory.MESSAGING,
    parameters=[
        ToolParameter("limit", "integer", "Max channels to return", required=False, default=50),
    ],
)
async def slack_list_channels(
    limit: int = 50,
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    data = await _slack_request("conversations.list", {"limit": limit, "types": "public_channel,private_channel"})
    if data.get("ok"):
        channels = [{"id": c["id"], "name": c["name"], "topic": c.get("topic", {}).get("value", "")} for c in data.get("channels", [])]
        return ToolResult(success=True, data={"channels": channels})
    return ToolResult(success=False, error=data.get("error"))


@register_tool(
    name="slack_post_meeting_summary",
    description="Post AI meeting summary to a Slack channel with formatted blocks.",
    category=ToolCategory.MESSAGING,
    parameters=[
        ToolParameter("channel", "string", "Slack channel ID"),
        ToolParameter("meeting_title", "string", "Meeting title"),
        ToolParameter("summary", "string", "Meeting summary"),
        ToolParameter("action_items", "string", "JSON array of action items"),
        ToolParameter("decisions", "string", "JSON array of decisions"),
    ],
)
async def slack_post_meeting_summary(
    channel: str, meeting_title: str, summary: str,
    action_items: str = "[]", decisions: str = "[]",
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    import orjson
    items = orjson.loads(action_items) if action_items != "[]" else []
    decs = orjson.loads(decisions) if decisions != "[]" else []

    blocks = [
        {"type": "header", "text": {"type": "plain_text", "text": f"Meeting Recap: {meeting_title}"}},
        {"type": "section", "text": {"type": "mrkdwn", "text": summary[:3000]}},
        {"type": "divider"},
    ]
    if decs:
        blocks.append({"type": "section", "text": {"type": "mrkdwn", "text": "*Decisions:*\n" + "\n".join(f"• {d.get('description', d) if isinstance(d, dict) else d}" for d in decs[:10])}})
    if items:
        blocks.append({"type": "section", "text": {"type": "mrkdwn", "text": "*Action Items:*\n" + "\n".join(f"• {a.get('description', a) if isinstance(a, dict) else a} → _{a.get('assignee', 'TBD') if isinstance(a, dict) else 'TBD'}_" for a in items[:10])}})

    body = {"channel": channel, "text": f"Meeting Recap: {meeting_title}", "blocks": blocks}
    data = await _slack_request("chat.postMessage", body)
    if data.get("ok"):
        return ToolResult(success=True, data={"ts": data.get("ts")})
    return ToolResult(success=False, error=data.get("error"))
