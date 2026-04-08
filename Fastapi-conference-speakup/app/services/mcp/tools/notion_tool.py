# SpeakUp AI — Notion MCP Tool
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

log = get_logger("mcp_notion")

NOTION_API = "https://api.notion.com/v1"


async def _notion_request(method: str, path: str, body: dict | None = None) -> tuple[int, dict]:
    settings = get_settings()
    headers = {
        "Authorization": f"Bearer {settings.NOTION_API_KEY}",
        "Notion-Version": "2022-06-28",
        "Content-Type": "application/json",
    }
    async with httpx.AsyncClient(timeout=30.0) as client:
        if method == "GET":
            resp = await client.get(f"{NOTION_API}{path}", headers=headers)
        elif method == "POST":
            resp = await client.post(f"{NOTION_API}{path}", json=body or {}, headers=headers)
        else:
            resp = await client.patch(f"{NOTION_API}{path}", json=body or {}, headers=headers)
        return resp.status_code, resp.json() if resp.content else {}


@register_tool(
    name="notion_create_page",
    description="Create a new Notion page or meeting notes document.",
    category=ToolCategory.DOCUMENTATION,
    parameters=[
        ToolParameter("parent_id", "string", "Parent page or database ID"),
        ToolParameter("title", "string", "Page title"),
        ToolParameter("content", "string", "Page content in markdown"),
        ToolParameter("is_database", "boolean", "Whether parent is a database", required=False, default=False),
    ],
)
async def notion_create_page(
    parent_id: str, title: str, content: str, is_database: bool = False,
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    parent = {"database_id": parent_id} if is_database else {"page_id": parent_id}
    properties = {"title": {"title": [{"text": {"content": title}}]}} if not is_database else {"Name": {"title": [{"text": {"content": title}}]}}

    # Split content into blocks (Notion has 2000 char limit per block)
    children = []
    for para in content.split("\n\n"):
        if not para.strip():
            continue
        if para.startswith("# "):
            children.append({"object": "block", "type": "heading_1", "heading_1": {"rich_text": [{"text": {"content": para[2:].strip()[:2000]}}]}})
        elif para.startswith("## "):
            children.append({"object": "block", "type": "heading_2", "heading_2": {"rich_text": [{"text": {"content": para[3:].strip()[:2000]}}]}})
        elif para.startswith("- ") or para.startswith("• "):
            for line in para.split("\n"):
                text = line.lstrip("-•").strip()
                if text:
                    children.append({"object": "block", "type": "bulleted_list_item", "bulleted_list_item": {"rich_text": [{"text": {"content": text[:2000]}}]}})
        else:
            children.append({"object": "block", "type": "paragraph", "paragraph": {"rich_text": [{"text": {"content": para.strip()[:2000]}}]}})

    status, data = await _notion_request("POST", "/pages", {"parent": parent, "properties": properties, "children": children[:100]})
    if status == 200:
        return ToolResult(success=True, data={"id": data["id"], "url": data.get("url")})
    return ToolResult(success=False, error=f"Notion API error ({status}): {data.get('message')}")


@register_tool(
    name="notion_search",
    description="Search Notion workspace for pages and databases.",
    category=ToolCategory.DOCUMENTATION,
    parameters=[
        ToolParameter("query", "string", "Search query"),
    ],
)
async def notion_search(
    query: str,
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    status, data = await _notion_request("POST", "/search", {"query": query, "page_size": 10})
    if status != 200:
        return ToolResult(success=False, error=f"Notion search failed: {data.get('message')}")

    results = []
    for item in data.get("results", []):
        title = ""
        props = item.get("properties", {})
        for prop in props.values():
            if prop.get("type") == "title":
                title = "".join(t.get("plain_text", "") for t in prop.get("title", []))
                break
        results.append({"id": item["id"], "type": item["object"], "title": title, "url": item.get("url")})

    return ToolResult(success=True, data={"results": results})


@register_tool(
    name="notion_update_meeting_notes",
    description="Append meeting notes, decisions, and action items to an existing Notion page.",
    category=ToolCategory.DOCUMENTATION,
    parameters=[
        ToolParameter("page_id", "string", "Notion page ID to append to"),
        ToolParameter("meeting_summary", "string", "Meeting summary text"),
        ToolParameter("action_items", "string", "JSON array of action item strings"),
        ToolParameter("decisions", "string", "JSON array of decision strings"),
    ],
)
async def notion_update_meeting_notes(
    page_id: str, meeting_summary: str, action_items: str = "[]", decisions: str = "[]",
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    import orjson
    items = orjson.loads(action_items) if action_items != "[]" else []
    decs = orjson.loads(decisions) if decisions != "[]" else []

    children = [
        {"object": "block", "type": "divider", "divider": {}},
        {"object": "block", "type": "heading_2", "heading_2": {"rich_text": [{"text": {"content": "Meeting Notes (AI Generated)"}}]}},
        {"object": "block", "type": "paragraph", "paragraph": {"rich_text": [{"text": {"content": meeting_summary[:2000]}}]}},
    ]
    if decs:
        children.append({"object": "block", "type": "heading_3", "heading_3": {"rich_text": [{"text": {"content": "Decisions"}}]}})
        for d in decs:
            text = d.get("description", d) if isinstance(d, dict) else str(d)
            children.append({"object": "block", "type": "bulleted_list_item", "bulleted_list_item": {"rich_text": [{"text": {"content": text[:2000]}}]}})
    if items:
        children.append({"object": "block", "type": "heading_3", "heading_3": {"rich_text": [{"text": {"content": "Action Items"}}]}})
        for a in items:
            text = a.get("description", a) if isinstance(a, dict) else str(a)
            children.append({"object": "block", "type": "to_do", "to_do": {"rich_text": [{"text": {"content": text[:2000]}}], "checked": False}})

    status, data = await _notion_request("PATCH", f"/blocks/{page_id}/children", {"children": children})
    if status == 200:
        return ToolResult(success=True, data={"block_count": len(children)})
    return ToolResult(success=False, error=f"Notion update failed ({status}): {data.get('message')}")
