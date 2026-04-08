# SpeakUp AI — GitHub MCP Tool
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

log = get_logger("mcp_github")

GH_API = "https://api.github.com"


async def _gh_request(method: str, path: str, body: dict | None = None) -> tuple[int, dict]:
    settings = get_settings()
    async with httpx.AsyncClient(timeout=30.0) as client:
        headers = {
            "Authorization": f"Bearer {settings.GITHUB_TOKEN}",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
        }
        if method == "GET":
            resp = await client.get(f"{GH_API}{path}", headers=headers)
        elif method == "POST":
            resp = await client.post(f"{GH_API}{path}", json=body or {}, headers=headers)
        elif method == "PATCH":
            resp = await client.patch(f"{GH_API}{path}", json=body or {}, headers=headers)
        else:
            resp = await client.request(method, f"{GH_API}{path}", json=body, headers=headers)
        return resp.status_code, resp.json() if resp.content else {}


@register_tool(
    name="github_create_issue",
    description="Create a GitHub issue in a repository. Use for creating action items, bug reports, or feature requests from meetings.",
    category=ToolCategory.CODE,
    parameters=[
        ToolParameter("repo", "string", "Repository in 'owner/repo' format"),
        ToolParameter("title", "string", "Issue title"),
        ToolParameter("body", "string", "Issue description (markdown supported)"),
        ToolParameter("labels", "string", "Comma-separated labels", required=False),
        ToolParameter("assignees", "string", "Comma-separated GitHub usernames", required=False),
    ],
)
async def create_issue(
    repo: str, title: str, body: str, labels: str = "", assignees: str = "",
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    payload: dict[str, Any] = {"title": title, "body": body}
    if labels:
        payload["labels"] = [l.strip() for l in labels.split(",")]
    if assignees:
        payload["assignees"] = [a.strip() for a in assignees.split(",")]

    status, data = await _gh_request("POST", f"/repos/{repo}/issues", payload)
    if status == 201:
        return ToolResult(success=True, data={"number": data["number"], "url": data["html_url"]})
    return ToolResult(success=False, error=f"GitHub API error ({status}): {data.get('message')}")


@register_tool(
    name="github_search_issues",
    description="Search GitHub issues and PRs across repositories.",
    category=ToolCategory.CODE,
    parameters=[
        ToolParameter("query", "string", "GitHub search query (e.g., 'repo:owner/repo is:open')"),
    ],
)
async def search_issues(
    query: str,
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    settings = get_settings()
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.get(
            f"{GH_API}/search/issues",
            params={"q": query, "per_page": 10},
            headers={"Authorization": f"Bearer {settings.GITHUB_TOKEN}", "Accept": "application/vnd.github+json"},
        )
        data = resp.json()
    items = data.get("items", [])
    return ToolResult(success=True, data={"issues": [
        {"number": i["number"], "title": i["title"], "state": i["state"], "url": i["html_url"], "assignee": (i.get("assignee") or {}).get("login")}
        for i in items
    ]})


@register_tool(
    name="github_create_pr_comment",
    description="Add a comment to a GitHub pull request or issue.",
    category=ToolCategory.CODE,
    parameters=[
        ToolParameter("repo", "string", "Repository in 'owner/repo' format"),
        ToolParameter("issue_number", "integer", "Issue or PR number"),
        ToolParameter("body", "string", "Comment body (markdown supported)"),
    ],
)
async def create_pr_comment(
    repo: str, issue_number: int, body: str,
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    status, data = await _gh_request("POST", f"/repos/{repo}/issues/{issue_number}/comments", {"body": body})
    if status == 201:
        return ToolResult(success=True, data={"id": data["id"], "url": data["html_url"]})
    return ToolResult(success=False, error=f"GitHub API error ({status}): {data.get('message')}")
