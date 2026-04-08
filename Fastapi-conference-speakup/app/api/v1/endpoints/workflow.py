# SpeakUp AI — Workflow Automation API Endpoints
from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field

from app.core.security import verify_internal_api_key

router = APIRouter(prefix="/workflow", tags=["workflow"], dependencies=[Depends(verify_internal_api_key)])


class PostMeetingWorkflowRequest(BaseModel):
    meeting_id: str
    user_id: str
    summary: str
    action_items: list[dict[str, Any]] = Field(default_factory=list)
    decisions: list[dict[str, Any]] = Field(default_factory=list)
    attendees: list[str] = Field(default_factory=list)
    config: dict[str, Any] | None = None


class PreMeetingPrepRequest(BaseModel):
    meeting_id: str
    user_id: str
    attendees: list[str]
    meeting_title: str | None = None
    agenda: str | None = None


@router.post("/post-meeting")
async def run_post_meeting_workflow(req: PostMeetingWorkflowRequest):
    """Execute the full post-meeting automation workflow."""
    from app.services.workflow.automation import get_workflow_engine

    engine = get_workflow_engine()
    workflow = engine.build_post_meeting_workflow(
        meeting_id=req.meeting_id,
        user_id=req.user_id,
        summary=req.summary,
        action_items=req.action_items,
        decisions=req.decisions,
        attendees=req.attendees,
        config=req.config,
    )
    result = await engine.execute_workflow(workflow)
    return {
        "workflow_id": result.id,
        "status": result.status.value,
        "summary": result.results_summary,
        "steps": [
            {"name": s.name, "status": s.status.value, "retries": s.retry_count}
            for s in result.steps
        ],
    }


@router.post("/pre-meeting")
async def run_pre_meeting_prep(req: PreMeetingPrepRequest):
    """Execute pre-meeting preparation workflow."""
    from app.services.workflow.automation import get_workflow_engine

    engine = get_workflow_engine()
    workflow = engine.build_pre_meeting_workflow(
        meeting_id=req.meeting_id,
        user_id=req.user_id,
        attendees=req.attendees,
        meeting_title=req.meeting_title,
        agenda=req.agenda,
    )
    result = await engine.execute_workflow(workflow)
    return {
        "workflow_id": result.id,
        "status": result.status.value,
        "summary": result.results_summary,
        "steps": [
            {"name": s.name, "status": s.status.value, "retries": s.retry_count}
            for s in result.steps
        ],
    }


@router.get("/status/{workflow_id}")
async def get_workflow_status(workflow_id: str):
    """Get status of a running workflow."""
    from app.services.workflow.automation import get_workflow_engine

    engine = get_workflow_engine()
    workflow = engine.get_workflow(workflow_id)
    if not workflow:
        return {"error": "Workflow not found"}
    return {
        "workflow_id": workflow.id,
        "status": workflow.status.value,
        "summary": workflow.results_summary,
        "created_at": workflow.created_at.isoformat(),
        "completed_at": workflow.completed_at.isoformat() if workflow.completed_at else None,
    }


@router.get("/active")
async def list_active_workflows(meeting_id: str | None = None):
    """List all active workflows, optionally filtered by meeting."""
    from app.services.workflow.automation import get_workflow_engine

    engine = get_workflow_engine()
    workflows = engine.get_active_workflows(meeting_id)
    return {
        "workflows": [
            {
                "workflow_id": w.id,
                "type": w.type.value,
                "status": w.status.value,
                "meeting_id": w.meeting_id,
                "created_at": w.created_at.isoformat(),
            }
            for w in workflows
        ],
    }
