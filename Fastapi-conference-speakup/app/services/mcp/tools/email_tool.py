# SpeakUp AI — Email MCP Tool (Gmail / Outlook / SMTP)
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

log = get_logger("mcp_email")


# ============================================================================
# Gmail API Tools
# ============================================================================


@register_tool(
    name="email_send",
    description="Send an email via Gmail or SMTP. Supports HTML body, CC, BCC, and attachments.",
    category=ToolCategory.EMAIL,
    parameters=[
        ToolParameter("to", "string", "Recipient email address"),
        ToolParameter("subject", "string", "Email subject line"),
        ToolParameter("body", "string", "Email body (HTML supported)"),
        ToolParameter("cc", "string", "CC recipients (comma-separated)", required=False),
        ToolParameter("bcc", "string", "BCC recipients (comma-separated)", required=False),
        ToolParameter("reply_to", "string", "Message ID to reply to", required=False),
    ],
)
async def send_email(
    to: str, subject: str, body: str,
    cc: str = "", bcc: str = "", reply_to: str = "",
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    settings = get_settings()
    if not settings.GOOGLE_CLIENT_ID:
        # Fallback to Express backend's SMTP mailer
        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.post(
                f"{settings.EXPRESS_BACKEND_URL}/api/v1/internal/send-email",
                json={"to": to, "subject": subject, "body": body, "cc": cc, "bcc": bcc},
                headers={"X-Internal-API-Key": settings.EXPRESS_INTERNAL_API_KEY},
            )
            if resp.status_code == 200:
                return ToolResult(success=True, data={"message_id": resp.json().get("id")})
            return ToolResult(success=False, error=f"SMTP send failed: {resp.text}")

    # Gmail API path (OAuth2)
    async with httpx.AsyncClient(timeout=30.0) as client:
        import base64
        from email.mime.text import MIMEText

        msg = MIMEText(body, "html")
        msg["to"] = to
        msg["subject"] = subject
        if cc:
            msg["cc"] = cc
        raw = base64.urlsafe_b64encode(msg.as_bytes()).decode()

        resp = await client.post(
            "https://gmail.googleapis.com/gmail/v1/users/me/messages/send",
            json={"raw": raw},
            headers={"Authorization": f"Bearer {settings.GOOGLE_ACCESS_TOKEN}"},
        )
        if resp.status_code in (200, 202):
            return ToolResult(success=True, data=resp.json())
        return ToolResult(success=False, error=f"Gmail API error: {resp.text}")


@register_tool(
    name="email_search",
    description="Search emails in inbox using Gmail query syntax (e.g., 'from:user@example.com after:2024/01/01').",
    category=ToolCategory.EMAIL,
    parameters=[
        ToolParameter("query", "string", "Gmail search query"),
        ToolParameter("max_results", "integer", "Maximum results to return", required=False, default=10),
    ],
)
async def search_email(
    query: str, max_results: int = 10,
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    settings = get_settings()
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.get(
            "https://gmail.googleapis.com/gmail/v1/users/me/messages",
            params={"q": query, "maxResults": max_results},
            headers={"Authorization": f"Bearer {settings.GOOGLE_ACCESS_TOKEN}"},
        )
        if resp.status_code != 200:
            return ToolResult(success=False, error=f"Gmail search failed: {resp.text}")

        messages = resp.json().get("messages", [])
        # Fetch message details
        results = []
        for msg in messages[:max_results]:
            detail = await client.get(
                f"https://gmail.googleapis.com/gmail/v1/users/me/messages/{msg['id']}",
                params={"format": "metadata", "metadataHeaders": ["Subject", "From", "Date"]},
                headers={"Authorization": f"Bearer {settings.GOOGLE_ACCESS_TOKEN}"},
            )
            if detail.status_code == 200:
                headers = {h["name"]: h["value"] for h in detail.json().get("payload", {}).get("headers", [])}
                results.append({"id": msg["id"], "subject": headers.get("Subject"), "from": headers.get("From"), "date": headers.get("Date")})

        return ToolResult(success=True, data={"emails": results, "count": len(results)})


@register_tool(
    name="email_read",
    description="Read a specific email by message ID.",
    category=ToolCategory.EMAIL,
    parameters=[
        ToolParameter("message_id", "string", "Gmail message ID"),
    ],
)
async def read_email(
    message_id: str,
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    settings = get_settings()
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.get(
            f"https://gmail.googleapis.com/gmail/v1/users/me/messages/{message_id}",
            params={"format": "full"},
            headers={"Authorization": f"Bearer {settings.GOOGLE_ACCESS_TOKEN}"},
        )
        if resp.status_code != 200:
            return ToolResult(success=False, error=f"Failed to read email: {resp.text}")
        return ToolResult(success=True, data=resp.json())


@register_tool(
    name="email_draft_recap",
    description="Draft a meeting recap email using AI-generated summary. Does not send — returns draft for review.",
    category=ToolCategory.EMAIL,
    parameters=[
        ToolParameter("meeting_id", "string", "Meeting ID to generate recap for"),
        ToolParameter("recipients", "string", "Comma-separated recipient emails"),
        ToolParameter("summary", "string", "Meeting summary text"),
        ToolParameter("action_items", "string", "JSON array of action items"),
    ],
)
async def draft_recap_email(
    meeting_id: str, recipients: str, summary: str, action_items: str = "[]",
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    from app.services.llm.router import TaskType, get_llm_router

    router = get_llm_router()
    response = await router.chat(
        messages=[
            {"role": "system", "content": "Generate a professional meeting recap email. Use clear formatting with sections for Summary, Key Decisions, Action Items, and Next Steps. Be concise but thorough."},
            {"role": "user", "content": f"Meeting summary:\n{summary}\n\nAction items:\n{action_items}\n\nGenerate the email body."},
        ],
        task=TaskType.RECAP_EMAIL,
    )

    return ToolResult(success=True, data={
        "draft": {
            "to": recipients,
            "subject": f"Meeting Recap - {meeting_id[:8]}",
            "body": response.content,
        },
        "model_used": response.model,
        "provider": response.provider.value,
    })
