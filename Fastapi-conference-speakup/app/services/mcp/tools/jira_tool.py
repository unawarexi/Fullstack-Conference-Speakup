# SpeakUp AI — Jira / Linear MCP Tool
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

log = get_logger("mcp_jira")


@register_tool(
    name="jira_create_ticket",
    description="Create a Jira ticket from meeting action items. Supports Story, Task, Bug types.",
    category=ToolCategory.PROJECT_MANAGEMENT,
    parameters=[
        ToolParameter("project_key", "string", "Jira project key (e.g., 'SPEAK')"),
        ToolParameter("summary", "string", "Ticket summary"),
        ToolParameter("description", "string", "Ticket description"),
        ToolParameter("issue_type", "string", "Issue type: Task, Story, Bug, Epic", required=False, default="Task"),
        ToolParameter("assignee", "string", "Assignee account ID or email", required=False),
        ToolParameter("priority", "string", "Priority: Highest, High, Medium, Low, Lowest", required=False, default="Medium"),
        ToolParameter("labels", "string", "Comma-separated labels", required=False),
    ],
)
async def jira_create_ticket(
    project_key: str, summary: str, description: str,
    issue_type: str = "Task", assignee: str = "", priority: str = "Medium", labels: str = "",
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    settings = get_settings()
    if not settings.JIRA_BASE_URL or not settings.JIRA_API_TOKEN:
        return ToolResult(success=False, error="Jira is not configured")

    fields: dict[str, Any] = {
        "project": {"key": project_key},
        "summary": summary,
        "description": {"type": "doc", "version": 1, "content": [{"type": "paragraph", "content": [{"type": "text", "text": description}]}]},
        "issuetype": {"name": issue_type},
        "priority": {"name": priority},
    }
    if assignee:
        fields["assignee"] = {"accountId": assignee}
    if labels:
        fields["labels"] = [l.strip() for l in labels.split(",")]

    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.post(
            f"{settings.JIRA_BASE_URL}/rest/api/3/issue",
            json={"fields": fields},
            headers={"Authorization": f"Basic {settings.JIRA_API_TOKEN}", "Content-Type": "application/json"},
        )
        if resp.status_code == 201:
            data = resp.json()
            return ToolResult(success=True, data={"key": data["key"], "id": data["id"], "url": f"{settings.JIRA_BASE_URL}/browse/{data['key']}"})
        return ToolResult(success=False, error=f"Jira API error ({resp.status_code}): {resp.text[:300]}")


@register_tool(
    name="jira_search",
    description="Search Jira issues using JQL (Jira Query Language).",
    category=ToolCategory.PROJECT_MANAGEMENT,
    parameters=[
        ToolParameter("jql", "string", "JQL query string"),
        ToolParameter("max_results", "integer", "Max results", required=False, default=10),
    ],
)
async def jira_search(
    jql: str, max_results: int = 10,
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    settings = get_settings()
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.get(
            f"{settings.JIRA_BASE_URL}/rest/api/3/search",
            params={"jql": jql, "maxResults": max_results, "fields": "summary,status,assignee,priority"},
            headers={"Authorization": f"Basic {settings.JIRA_API_TOKEN}"},
        )
        if resp.status_code != 200:
            return ToolResult(success=False, error=f"Jira search failed: {resp.text[:300]}")
        issues = resp.json().get("issues", [])
        return ToolResult(success=True, data={"issues": [
            {"key": i["key"], "summary": i["fields"]["summary"], "status": i["fields"]["status"]["name"], "assignee": (i["fields"].get("assignee") or {}).get("displayName")}
            for i in issues
        ]})


# ============================================================================
# Linear Integration
# ============================================================================


@register_tool(
    name="linear_create_issue",
    description="Create a Linear issue from meeting action items.",
    category=ToolCategory.PROJECT_MANAGEMENT,
    parameters=[
        ToolParameter("team_id", "string", "Linear team ID"),
        ToolParameter("title", "string", "Issue title"),
        ToolParameter("description", "string", "Issue description (markdown)"),
        ToolParameter("priority", "integer", "Priority 0-4 (0=none, 1=urgent, 4=low)", required=False, default=3),
        ToolParameter("assignee_id", "string", "Linear user ID to assign", required=False),
    ],
)
async def linear_create_issue(
    team_id: str, title: str, description: str, priority: int = 3, assignee_id: str = "",
    _user_id: str | None = None, **kwargs: Any,
) -> ToolResult:
    settings = get_settings()
    if not settings.LINEAR_API_KEY:
        return ToolResult(success=False, error="Linear is not configured")

    mutation = """
    mutation CreateIssue($input: IssueCreateInput!) {
        issueCreate(input: $input) {
            success
            issue { id identifier title url }
        }
    }
    """
    variables: dict[str, Any] = {"input": {"teamId": team_id, "title": title, "description": description, "priority": priority}}
    if assignee_id:
        variables["input"]["assigneeId"] = assignee_id

    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.post(
            "https://api.linear.app/graphql",
            json={"query": mutation, "variables": variables},
            headers={"Authorization": settings.LINEAR_API_KEY, "Content-Type": "application/json"},
        )
        data = resp.json()
    result = data.get("data", {}).get("issueCreate", {})
    if result.get("success"):
        issue = result["issue"]
        return ToolResult(success=True, data={"id": issue["id"], "identifier": issue["identifier"], "url": issue["url"]})
    return ToolResult(success=False, error=f"Linear API error: {data.get('errors', 'Unknown')}")
