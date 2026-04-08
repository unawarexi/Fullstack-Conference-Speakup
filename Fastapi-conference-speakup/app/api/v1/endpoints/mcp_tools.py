# SpeakUp AI — MCP Tools API Endpoints
from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field

from app.core.security import verify_internal_api_key

router = APIRouter(prefix="/tools", tags=["mcp-tools"], dependencies=[Depends(verify_internal_api_key)])


class ExecuteToolRequest(BaseModel):
    tool_name: str
    parameters: dict[str, Any] = Field(default_factory=dict)


class ExecuteMultipleRequest(BaseModel):
    tools: list[ExecuteToolRequest]


@router.get("/schema")
async def get_tools_schema():
    """Return all available MCP tools in OpenAI function-calling format."""
    from app.services.mcp.registry import get_tools_schema, ToolCategory

    schema = get_tools_schema()
    return {"tools": schema, "count": len(schema), "categories": [c.value for c in ToolCategory]}


@router.post("/execute")
async def execute_tool(req: ExecuteToolRequest):
    """Execute a single MCP tool."""
    from app.services.mcp.registry import execute_tool as exec_tool

    result = await exec_tool(req.tool_name, req.parameters)
    return {
        "success": result.success,
        "data": result.data,
        "error": result.error,
        "execution_time_ms": result.execution_time_ms,
    }


@router.post("/execute-multiple")
async def execute_multiple_tools(req: ExecuteMultipleRequest):
    """Execute multiple MCP tools in parallel."""
    from app.services.mcp.registry import execute_tools_parallel

    calls = [(t.tool_name, t.parameters) for t in req.tools]
    results = await execute_tools_parallel(calls)
    return {
        "results": [
            {
                "success": r.success,
                "data": r.data,
                "error": r.error,
                "execution_time_ms": r.execution_time_ms,
            }
            for r in results
        ],
        "total": len(results),
        "successful": sum(1 for r in results if r.success),
    }
