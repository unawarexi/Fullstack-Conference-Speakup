# SpeakUp AI — Web Search + CRM + File Management + Social MCP Tools
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

log = get_logger("mcp_tools")


# ============================================================================
# Web Search (Tavily)
# ============================================================================


@register_tool(
    name="web_search",
    description="Search the web using Tavily AI search. Returns relevant results with snippets. Great for live meeting context lookup.",
    category=ToolCategory.SEARCH,
    parameters=[
        ToolParameter("query", "string", "Search query"),
        ToolParameter("max_results", "integer", "Maximum results", required=False, default=5),
        ToolParameter("search_depth", "string", "'basic' or 'advanced'", required=False, default="basic"),
    ],
)
async def web_search(
    query: str, max_results: int = 5, search_depth: str = "basic",
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    settings = get_settings()
    if not settings.TAVILY_API_KEY:
        return ToolResult(success=False, error="Tavily not configured")

    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.post(
            "https://api.tavily.com/search",
            json={"query": query, "max_results": max_results, "search_depth": search_depth, "api_key": settings.TAVILY_API_KEY},
        )
        resp.raise_for_status()
        data = resp.json()

    return ToolResult(success=True, data={
        "results": [
            {"title": r.get("title"), "url": r.get("url"), "content": r.get("content", "")[:500]}
            for r in data.get("results", [])
        ],
        "answer": data.get("answer"),
    })


# ============================================================================
# Salesforce CRM
# ============================================================================


@register_tool(
    name="crm_search_contacts",
    description="Search Salesforce contacts by name, email, or company.",
    category=ToolCategory.CRM,
    parameters=[
        ToolParameter("query", "string", "Search term (name, email, or company)"),
    ],
)
async def crm_search_contacts(
    query: str,
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    settings = get_settings()
    if not settings.SALESFORCE_INSTANCE_URL or not settings.SALESFORCE_ACCESS_TOKEN:
        return ToolResult(success=False, error="Salesforce not configured")

    soql = f"SELECT Id, Name, Email, Company, Title, Phone FROM Contact WHERE Name LIKE '%{query}%' OR Email LIKE '%{query}%' OR Company LIKE '%{query}%' LIMIT 10"
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.get(
            f"{settings.SALESFORCE_INSTANCE_URL}/services/data/v59.0/query",
            params={"q": soql},
            headers={"Authorization": f"Bearer {settings.SALESFORCE_ACCESS_TOKEN}"},
        )
        if resp.status_code != 200:
            return ToolResult(success=False, error=f"Salesforce error: {resp.text[:300]}")
        records = resp.json().get("records", [])

    return ToolResult(success=True, data={"contacts": [
        {"id": r["Id"], "name": r.get("Name"), "email": r.get("Email"), "company": r.get("Company"), "title": r.get("Title")}
        for r in records
    ]})


@register_tool(
    name="crm_create_note",
    description="Create a CRM note/activity linked to a contact or opportunity after a meeting.",
    category=ToolCategory.CRM,
    parameters=[
        ToolParameter("related_to_id", "string", "Salesforce record ID (Contact/Opportunity)"),
        ToolParameter("subject", "string", "Note subject"),
        ToolParameter("body", "string", "Note body"),
    ],
)
async def crm_create_note(
    related_to_id: str, subject: str, body: str,
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    settings = get_settings()
    if not settings.SALESFORCE_INSTANCE_URL:
        return ToolResult(success=False, error="Salesforce not configured")

    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.post(
            f"{settings.SALESFORCE_INSTANCE_URL}/services/data/v59.0/sobjects/Task",
            json={"WhatId": related_to_id, "Subject": subject, "Description": body, "Status": "Completed", "Priority": "Normal"},
            headers={"Authorization": f"Bearer {settings.SALESFORCE_ACCESS_TOKEN}", "Content-Type": "application/json"},
        )
        if resp.status_code == 201:
            return ToolResult(success=True, data=resp.json())
        return ToolResult(success=False, error=f"Salesforce error: {resp.text[:300]}")


# ============================================================================
# File Management (S3 / Cloudinary — via Express)
# ============================================================================


@register_tool(
    name="file_search",
    description="Search uploaded files and documents in the SpeakUp workspace.",
    category=ToolCategory.FILE_MANAGEMENT,
    parameters=[
        ToolParameter("query", "string", "Search query (filename or content keywords)"),
        ToolParameter("file_type", "string", "Filter by type: document, image, recording, all", required=False, default="all"),
    ],
)
async def file_search(
    query: str, file_type: str = "all",
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    settings = get_settings()
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.get(
            f"{settings.EXPRESS_BACKEND_URL}/api/v1/search",
            params={"q": query, "type": file_type},
            headers={"X-Internal-API-Key": settings.EXPRESS_INTERNAL_API_KEY},
        )
        if resp.status_code == 200:
            return ToolResult(success=True, data=resp.json())
        return ToolResult(success=False, error=f"File search failed: {resp.status_code}")


# ============================================================================
# Social Media (Twitter/X, LinkedIn)
# ============================================================================


@register_tool(
    name="social_post_update",
    description="Post a status update to social media platforms (Twitter/X). Useful for sharing meeting highlights.",
    category=ToolCategory.SOCIAL,
    parameters=[
        ToolParameter("platform", "string", "Platform: twitter"),
        ToolParameter("content", "string", "Post content (max 280 chars for Twitter)"),
    ],
)
async def social_post_update(
    platform: str, content: str,
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    settings = get_settings()
    if platform == "twitter":
        if not settings.TWITTER_BEARER_TOKEN:
            return ToolResult(success=False, error="Twitter not configured")
        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.post(
                "https://api.twitter.com/2/tweets",
                json={"text": content[:280]},
                headers={"Authorization": f"Bearer {settings.TWITTER_BEARER_TOKEN}", "Content-Type": "application/json"},
            )
            if resp.status_code in (200, 201):
                return ToolResult(success=True, data=resp.json())
            return ToolResult(success=False, error=f"Twitter API error: {resp.text[:300]}")

    return ToolResult(success=False, error=f"Unsupported platform: {platform}")


# ============================================================================
# Microsoft Teams / Outlook (Microsoft Graph)
# ============================================================================


@register_tool(
    name="ms_teams_send_message",
    description="Send a message to a Microsoft Teams channel.",
    category=ToolCategory.MESSAGING,
    parameters=[
        ToolParameter("team_id", "string", "Teams team ID"),
        ToolParameter("channel_id", "string", "Teams channel ID"),
        ToolParameter("content", "string", "Message content (HTML supported)"),
    ],
)
async def ms_teams_send_message(
    team_id: str, channel_id: str, content: str,
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    settings = get_settings()
    if not settings.MICROSOFT_GRAPH_TOKEN:
        return ToolResult(success=False, error="Microsoft Graph not configured")

    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.post(
            f"https://graph.microsoft.com/v1.0/teams/{team_id}/channels/{channel_id}/messages",
            json={"body": {"contentType": "html", "content": content}},
            headers={"Authorization": f"Bearer {settings.MICROSOFT_GRAPH_TOKEN}", "Content-Type": "application/json"},
        )
        if resp.status_code == 201:
            return ToolResult(success=True, data=resp.json())
        return ToolResult(success=False, error=f"Teams API error: {resp.text[:300]}")


@register_tool(
    name="ms_outlook_send_email",
    description="Send an email via Microsoft Outlook / Graph API.",
    category=ToolCategory.EMAIL,
    parameters=[
        ToolParameter("to", "string", "Recipient email"),
        ToolParameter("subject", "string", "Email subject"),
        ToolParameter("body", "string", "Email body (HTML)"),
    ],
)
async def ms_outlook_send_email(
    to: str, subject: str, body: str,
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    settings = get_settings()
    if not settings.MICROSOFT_GRAPH_TOKEN:
        return ToolResult(success=False, error="Microsoft Graph not configured")

    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.post(
            "https://graph.microsoft.com/v1.0/me/sendMail",
            json={
                "message": {
                    "subject": subject,
                    "body": {"contentType": "HTML", "content": body},
                    "toRecipients": [{"emailAddress": {"address": to}}],
                },
            },
            headers={"Authorization": f"Bearer {settings.MICROSOFT_GRAPH_TOKEN}", "Content-Type": "application/json"},
        )
        if resp.status_code == 202:
            return ToolResult(success=True, data={"sent": True})
        return ToolResult(success=False, error=f"Outlook error: {resp.text[:300]}")
