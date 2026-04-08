# SpeakUp AI — MCP Tool Registry
# Central registry for all MCP tools (email, Slack, calendar, GitHub, Jira, etc.)
from __future__ import annotations

import asyncio
import time
from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Callable, Coroutine

from app.core.logging import get_logger

log = get_logger("mcp_registry")


class ToolCategory(str, Enum):
    EMAIL = "email"
    CALENDAR = "calendar"
    MESSAGING = "messaging"
    PROJECT_MANAGEMENT = "project_management"
    DOCUMENTATION = "documentation"
    CODE = "code"
    CRM = "crm"
    SEARCH = "search"
    FILE_MANAGEMENT = "file_management"
    SOCIAL = "social"
    AUTOMATION = "automation"


@dataclass
class ToolParameter:
    name: str
    type: str  # "string", "integer", "boolean", "array", "object"
    description: str
    required: bool = True
    default: Any = None


@dataclass
class ToolResult:
    success: bool
    data: Any = None
    error: str | None = None
    tool_name: str = ""
    execution_time_ms: float = 0.0

    def to_dict(self) -> dict:
        return {
            "success": self.success,
            "data": self.data,
            "error": self.error,
            "tool_name": self.tool_name,
            "execution_time_ms": self.execution_time_ms,
        }


@dataclass
class MCPTool:
    name: str
    description: str
    category: ToolCategory
    parameters: list[ToolParameter] = field(default_factory=list)
    handler: Callable[..., Coroutine[Any, Any, ToolResult]] | None = None
    requires_auth: bool = True
    enabled: bool = True


# ============================================================================
# Registry
# ============================================================================

_tools: dict[str, MCPTool] = {}


def register_tool(
    name: str,
    description: str,
    category: ToolCategory,
    parameters: list[ToolParameter] | None = None,
    requires_auth: bool = True,
) -> Callable:
    """Decorator to register an MCP tool handler."""
    def decorator(func: Callable[..., Coroutine[Any, Any, ToolResult]]) -> Callable:
        tool = MCPTool(
            name=name,
            description=description,
            category=category,
            parameters=parameters or [],
            handler=func,
            requires_auth=requires_auth,
        )
        _tools[name] = tool
        log.debug("Tool registered", tool=name, category=category.value)
        return func
    return decorator


def get_tool(name: str) -> MCPTool | None:
    return _tools.get(name)


def list_tools(category: ToolCategory | None = None) -> list[MCPTool]:
    if category:
        return [t for t in _tools.values() if t.category == category and t.enabled]
    return [t for t in _tools.values() if t.enabled]


def get_tools_schema() -> list[dict]:
    """Return OpenAI function-calling compatible schema for all tools."""
    schemas = []
    for tool in _tools.values():
        if not tool.enabled:
            continue
        properties = {}
        required = []
        for param in tool.parameters:
            properties[param.name] = {
                "type": param.type,
                "description": param.description,
            }
            if param.default is not None:
                properties[param.name]["default"] = param.default
            if param.required:
                required.append(param.name)

        schemas.append({
            "type": "function",
            "function": {
                "name": tool.name,
                "description": tool.description,
                "parameters": {
                    "type": "object",
                    "properties": properties,
                    "required": required,
                },
            },
        })
    return schemas


async def execute_tool(name: str, params: dict[str, Any], user_id: str | None = None) -> ToolResult:
    """Execute a registered MCP tool."""
    tool = _tools.get(name)
    if not tool:
        return ToolResult(success=False, error=f"Tool '{name}' not found", tool_name=name)
    if not tool.enabled:
        return ToolResult(success=False, error=f"Tool '{name}' is disabled", tool_name=name)
    if not tool.handler:
        return ToolResult(success=False, error=f"Tool '{name}' has no handler", tool_name=name)

    start = time.monotonic()
    try:
        result = await tool.handler(**params, _user_id=user_id)
        result.tool_name = name
        result.execution_time_ms = (time.monotonic() - start) * 1000
        log.info("Tool executed", tool=name, success=result.success, ms=f"{result.execution_time_ms:.1f}")
        return result
    except Exception as e:
        elapsed = (time.monotonic() - start) * 1000
        log.exception("Tool execution failed", tool=name, error=str(e))
        return ToolResult(success=False, error=str(e), tool_name=name, execution_time_ms=elapsed)


async def execute_tools_parallel(
    tool_calls: list[tuple[str, dict[str, Any]]],
    user_id: str | None = None,
) -> list[ToolResult]:
    """Execute multiple tools in parallel."""
    tasks = [execute_tool(name, params, user_id) for name, params in tool_calls]
    return await asyncio.gather(*tasks)
