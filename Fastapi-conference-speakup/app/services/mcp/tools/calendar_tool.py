# SpeakUp AI — Calendar MCP Tool (Google Calendar / Microsoft Graph)
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

log = get_logger("mcp_calendar")


@register_tool(
    name="calendar_list_events",
    description="List upcoming calendar events for the user. Returns agenda items with times and attendees.",
    category=ToolCategory.CALENDAR,
    parameters=[
        ToolParameter("time_min", "string", "Start time in ISO 8601 format"),
        ToolParameter("time_max", "string", "End time in ISO 8601 format"),
        ToolParameter("max_results", "integer", "Max events to return", required=False, default=10),
    ],
)
async def list_events(
    time_min: str, time_max: str, max_results: int = 10,
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    settings = get_settings()
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.get(
            "https://www.googleapis.com/calendar/v3/calendars/primary/events",
            params={"timeMin": time_min, "timeMax": time_max, "maxResults": max_results, "singleEvents": True, "orderBy": "startTime"},
            headers={"Authorization": f"Bearer {settings.GOOGLE_ACCESS_TOKEN}"},
        )
        if resp.status_code != 200:
            return ToolResult(success=False, error=f"Calendar API error: {resp.text}")

        events = resp.json().get("items", [])
        return ToolResult(success=True, data={"events": [
            {
                "id": e.get("id"),
                "summary": e.get("summary"),
                "start": e.get("start", {}).get("dateTime", e.get("start", {}).get("date")),
                "end": e.get("end", {}).get("dateTime", e.get("end", {}).get("date")),
                "attendees": [a.get("email") for a in e.get("attendees", [])],
                "location": e.get("location"),
                "description": (e.get("description") or "")[:300],
            }
            for e in events
        ]})


@register_tool(
    name="calendar_create_event",
    description="Create a new calendar event with attendees and optional meeting link.",
    category=ToolCategory.CALENDAR,
    parameters=[
        ToolParameter("summary", "string", "Event title"),
        ToolParameter("start_time", "string", "Start time in ISO 8601"),
        ToolParameter("end_time", "string", "End time in ISO 8601"),
        ToolParameter("attendees", "string", "Comma-separated attendee emails", required=False),
        ToolParameter("description", "string", "Event description", required=False),
        ToolParameter("location", "string", "Event location", required=False),
    ],
)
async def create_event(
    summary: str, start_time: str, end_time: str,
    attendees: str = "", description: str = "", location: str = "",
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    settings = get_settings()
    body: dict[str, Any] = {
        "summary": summary,
        "start": {"dateTime": start_time, "timeZone": "UTC"},
        "end": {"dateTime": end_time, "timeZone": "UTC"},
    }
    if attendees:
        body["attendees"] = [{"email": e.strip()} for e in attendees.split(",")]
    if description:
        body["description"] = description
    if location:
        body["location"] = location

    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.post(
            "https://www.googleapis.com/calendar/v3/calendars/primary/events",
            json=body,
            headers={"Authorization": f"Bearer {settings.GOOGLE_ACCESS_TOKEN}"},
            params={"sendUpdates": "all"},
        )
        if resp.status_code in (200, 201):
            return ToolResult(success=True, data=resp.json())
        return ToolResult(success=False, error=f"Calendar create failed: {resp.text}")


@register_tool(
    name="calendar_schedule_followup",
    description="Schedule a follow-up meeting after current meeting ends. AI picks optimal time.",
    category=ToolCategory.CALENDAR,
    parameters=[
        ToolParameter("meeting_id", "string", "Original meeting ID for context"),
        ToolParameter("attendees", "string", "Comma-separated attendee emails"),
        ToolParameter("duration_minutes", "integer", "Meeting duration in minutes", required=False, default=30),
        ToolParameter("topic", "string", "Follow-up topic", required=False),
    ],
)
async def schedule_followup(
    meeting_id: str, attendees: str, duration_minutes: int = 30, topic: str = "",
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    from datetime import datetime, timedelta, timezone

    # Schedule for next business day at 10 AM UTC by default
    now = datetime.now(timezone.utc)
    next_day = now + timedelta(days=1)
    while next_day.weekday() >= 5:  # Skip weekends
        next_day += timedelta(days=1)
    start = next_day.replace(hour=10, minute=0, second=0, microsecond=0)
    end = start + timedelta(minutes=duration_minutes)

    return await create_event(
        summary=f"Follow-up: {topic or meeting_id[:8]}",
        start_time=start.isoformat(),
        end_time=end.isoformat(),
        attendees=attendees,
        description=f"Auto-scheduled follow-up from meeting {meeting_id}.\nTopic: {topic}",
        _user_id=_user_id,
    )
