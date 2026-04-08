# SpeakUp AI — Workflow Automation Service
# Orchestrates multi-step post-meeting and scheduled workflows
# Chains MCP tools + OpenClaw for complex automation sequences
from __future__ import annotations

import asyncio
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from enum import Enum
from typing import Any

from app.core.logging import get_logger
from app.services.llm.router import LLMRouter, TaskType, get_llm_router
from app.services.mcp.registry import execute_tool, ToolResult
from app.services.openclaw.bridge import get_openclaw_bridge

log = get_logger("workflow_automation")


class WorkflowStatus(str, Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    PARTIALLY_COMPLETED = "partially_completed"
    FAILED = "failed"


class WorkflowType(str, Enum):
    POST_MEETING = "post_meeting"
    PRE_MEETING = "pre_meeting"
    MEETING_FOLLOWUP = "meeting_followup"
    CUSTOM = "custom"


@dataclass
class WorkflowStep:
    name: str
    tool_name: str
    parameters: dict[str, Any]
    depends_on: list[str] = field(default_factory=list)
    status: WorkflowStatus = WorkflowStatus.PENDING
    result: ToolResult | None = None
    retry_count: int = 0
    max_retries: int = 2
    optional: bool = False  # If True, failure won't block the workflow


@dataclass
class Workflow:
    id: str
    type: WorkflowType
    meeting_id: str
    user_id: str
    steps: list[WorkflowStep]
    status: WorkflowStatus = WorkflowStatus.PENDING
    created_at: datetime = field(default_factory=datetime.utcnow)
    completed_at: datetime | None = None
    results_summary: str = ""


class WorkflowEngine:
    """
    Executes multi-step workflows with dependency resolution.
    Steps can depend on prior steps' outputs and run in parallel when possible.
    """

    def __init__(self) -> None:
        self._active_workflows: dict[str, Workflow] = {}
        self._router: LLMRouter | None = None

    @property
    def router(self) -> LLMRouter:
        if self._router is None:
            self._router = get_llm_router()
        return self._router

    # ====================================================================
    # Post-Meeting Automation Workflow Builder
    # ====================================================================

    def build_post_meeting_workflow(
        self,
        meeting_id: str,
        user_id: str,
        summary: str,
        action_items: list[dict[str, Any]],
        decisions: list[dict[str, Any]],
        attendees: list[str],
        config: dict[str, Any] | None = None,
    ) -> Workflow:
        """
        Build a post-meeting workflow based on meeting data + user preferences.
        Default workflow:
        1. Draft recap email
        2. Send recap email to attendees
        3. Post summary to Slack
        4. Create tickets for action items
        5. Update Notion meeting notes
        6. Schedule follow-up if needed
        """
        import uuid

        cfg = config or {}
        steps: list[WorkflowStep] = []

        # Step 1: Draft recap email
        if cfg.get("send_recap_email", True):
            steps.append(WorkflowStep(
                name="draft_recap",
                tool_name="email_draft_recap",
                parameters={
                    "meeting_id": meeting_id,
                    "summary": summary,
                    "action_items": action_items,
                    "decisions": decisions,
                },
            ))
            steps.append(WorkflowStep(
                name="send_recap",
                tool_name="email_send",
                parameters={
                    "to": attendees,
                    "subject": f"Meeting Recap — {cfg.get('meeting_title', 'Meeting')}",
                    "body": "{{draft_recap.result}}",  # resolved at runtime
                },
                depends_on=["draft_recap"],
            ))

        # Step 2: Post to Slack
        slack_channel = cfg.get("slack_channel")
        if slack_channel:
            steps.append(WorkflowStep(
                name="slack_summary",
                tool_name="slack_post_meeting_summary",
                parameters={
                    "channel": slack_channel,
                    "meeting_title": cfg.get("meeting_title", "Meeting"),
                    "summary": summary,
                    "action_items": action_items,
                    "decisions": [d.get("text", str(d)) for d in decisions],
                },
                optional=True,
            ))

        # Step 3: Create tickets for action items
        if cfg.get("create_tickets", True) and action_items:
            tracker = cfg.get("ticket_tracker", "jira")
            tool_name = "jira_create_ticket" if tracker == "jira" else "linear_create_issue"
            for i, item in enumerate(action_items):
                steps.append(WorkflowStep(
                    name=f"create_ticket_{i}",
                    tool_name=tool_name,
                    parameters={
                        "title": item.get("task", item.get("title", str(item))),
                        "description": (
                            f"Action item from meeting: {cfg.get('meeting_title', meeting_id)}\n\n"
                            f"Assigned to: {item.get('assignee', 'Unassigned')}\n"
                            f"Due: {item.get('deadline', 'TBD')}\n\n"
                            f"Context: {item.get('context', '')}"
                        ),
                        "assignee": item.get("assignee"),
                        "priority": item.get("priority", "medium"),
                    },
                    optional=True,
                ))

        # Step 4: Update Notion
        notion_page_id = cfg.get("notion_page_id")
        if notion_page_id:
            steps.append(WorkflowStep(
                name="update_notion",
                tool_name="notion_update_meeting_notes",
                parameters={
                    "page_id": notion_page_id,
                    "summary": summary,
                    "action_items": [
                        a.get("task", str(a)) for a in action_items
                    ],
                },
                optional=True,
            ))

        # Step 5: Schedule follow-up
        if cfg.get("schedule_followup") and attendees:
            steps.append(WorkflowStep(
                name="schedule_followup",
                tool_name="calendar_schedule_followup",
                parameters={
                    "meeting_title": f"Follow-up: {cfg.get('meeting_title', 'Meeting')}",
                    "attendee_emails": attendees,
                    "notes": f"Follow-up for meeting on {datetime.utcnow().strftime('%Y-%m-%d')}",
                },
                optional=True,
            ))

        workflow_id = f"wf-{meeting_id}-{uuid.uuid4().hex[:8]}"
        return Workflow(
            id=workflow_id,
            type=WorkflowType.POST_MEETING,
            meeting_id=meeting_id,
            user_id=user_id,
            steps=steps,
        )

    # ====================================================================
    # Pre-Meeting Preparation Workflow
    # ====================================================================

    def build_pre_meeting_workflow(
        self,
        meeting_id: str,
        user_id: str,
        attendees: list[str],
        meeting_title: str | None = None,
        agenda: str | None = None,
    ) -> Workflow:
        """Build a pre-meeting preparation workflow."""
        import uuid

        steps: list[WorkflowStep] = []

        # Search emails for context on attendees
        for i, email in enumerate(attendees[:5]):
            steps.append(WorkflowStep(
                name=f"email_search_{i}",
                tool_name="email_search",
                parameters={"query": f"from:{email} OR to:{email}", "max_results": 5},
                optional=True,
            ))

        # Search Slack for attendee mentions
        if attendees:
            steps.append(WorkflowStep(
                name="slack_search",
                tool_name="slack_search_messages",
                parameters={"query": " OR ".join(attendees[:3])},
                optional=True,
            ))

        # Check calendar for related events
        steps.append(WorkflowStep(
            name="calendar_check",
            tool_name="calendar_list_events",
            parameters={
                "time_min": datetime.utcnow().isoformat() + "Z",
                "time_max": (datetime.utcnow() + timedelta(days=7)).isoformat() + "Z",
                "max_results": 10,
            },
            optional=True,
        ))

        # Search for relevant tickets
        if agenda:
            steps.append(WorkflowStep(
                name="ticket_search",
                tool_name="jira_search",
                parameters={"jql": f'text ~ "{agenda[:50]}" ORDER BY updated DESC'},
                optional=True,
            ))

        # Web search for context
        if meeting_title:
            steps.append(WorkflowStep(
                name="web_research",
                tool_name="web_search",
                parameters={"query": meeting_title, "max_results": 3},
                optional=True,
            ))

        workflow_id = f"wf-prep-{meeting_id}-{uuid.uuid4().hex[:8]}"
        return Workflow(
            id=workflow_id,
            type=WorkflowType.PRE_MEETING,
            meeting_id=meeting_id,
            user_id=user_id,
            steps=steps,
        )

    # ====================================================================
    # Workflow Execution Engine
    # ====================================================================

    async def execute_workflow(self, workflow: Workflow) -> Workflow:
        """Execute a workflow with dependency resolution and parallel execution."""
        workflow.status = WorkflowStatus.RUNNING
        self._active_workflows[workflow.id] = workflow
        log.info("Starting workflow", workflow_id=workflow.id, type=workflow.type.value, steps=len(workflow.steps))

        completed_steps: set[str] = set()
        step_results: dict[str, Any] = {}

        while True:
            # Find steps ready to run (all deps satisfied)
            ready = [
                s for s in workflow.steps
                if s.status == WorkflowStatus.PENDING
                and all(d in completed_steps for d in s.depends_on)
            ]
            if not ready:
                break

            # Execute ready steps in parallel
            tasks = []
            for step in ready:
                step.status = WorkflowStatus.RUNNING
                resolved_params = self._resolve_step_params(step.parameters, step_results)
                tasks.append(self._execute_step(step, resolved_params))

            results = await asyncio.gather(*tasks, return_exceptions=True)

            for step, result in zip(ready, results):
                if isinstance(result, Exception):
                    step.status = WorkflowStatus.FAILED
                    step.result = ToolResult(success=False, data={}, error=str(result))
                    log.warning("Workflow step failed", step=step.name, error=str(result))
                else:
                    step.result = result
                    step.status = WorkflowStatus.COMPLETED if result.success else WorkflowStatus.FAILED
                    step_results[step.name] = result

                completed_steps.add(step.name)

        # Determine overall status
        failed_required = [
            s for s in workflow.steps
            if s.status == WorkflowStatus.FAILED and not s.optional
        ]
        all_completed = all(
            s.status in (WorkflowStatus.COMPLETED, WorkflowStatus.FAILED)
            for s in workflow.steps
        )

        if failed_required:
            workflow.status = WorkflowStatus.PARTIALLY_COMPLETED if any(
                s.status == WorkflowStatus.COMPLETED for s in workflow.steps
            ) else WorkflowStatus.FAILED
        elif all_completed:
            workflow.status = WorkflowStatus.COMPLETED
        else:
            workflow.status = WorkflowStatus.PARTIALLY_COMPLETED

        workflow.completed_at = datetime.utcnow()
        workflow.results_summary = await self._generate_summary(workflow)

        log.info(
            "Workflow finished",
            workflow_id=workflow.id,
            status=workflow.status.value,
            completed=sum(1 for s in workflow.steps if s.status == WorkflowStatus.COMPLETED),
            failed=sum(1 for s in workflow.steps if s.status == WorkflowStatus.FAILED),
        )

        return workflow

    async def _execute_step(self, step: WorkflowStep, params: dict[str, Any]) -> ToolResult:
        """Execute a single workflow step with retries."""
        for attempt in range(step.max_retries + 1):
            try:
                result = await execute_tool(step.tool_name, params)
                if result.success:
                    return result
                if attempt < step.max_retries:
                    step.retry_count += 1
                    await asyncio.sleep(1.0 * (attempt + 1))
                else:
                    return result
            except Exception as e:
                if attempt >= step.max_retries:
                    raise
                step.retry_count += 1
                await asyncio.sleep(1.0 * (attempt + 1))
        return ToolResult(success=False, data={}, error="Max retries exceeded")

    def _resolve_step_params(
        self, params: dict[str, Any], step_results: dict[str, Any]
    ) -> dict[str, Any]:
        """Resolve template references like {{step_name.result}}."""
        resolved = {}
        for key, val in params.items():
            if isinstance(val, str) and val.startswith("{{") and val.endswith("}}"):
                ref = val[2:-2].strip()
                parts = ref.split(".")
                if len(parts) >= 2:
                    step_name = parts[0]
                    if step_name in step_results:
                        r = step_results[step_name]
                        if hasattr(r, "data"):
                            resolved[key] = r.data.get(parts[1], val)
                        else:
                            resolved[key] = val
                    else:
                        resolved[key] = val
                else:
                    resolved[key] = val
            else:
                resolved[key] = val
        return resolved

    async def _generate_summary(self, workflow: Workflow) -> str:
        """Generate a human-readable summary of what happened."""
        lines = [f"Workflow '{workflow.type.value}' completed with status: {workflow.status.value}\n"]
        for step in workflow.steps:
            icon = "✓" if step.status == WorkflowStatus.COMPLETED else "✗"
            lines.append(f"  {icon} {step.name}: {step.status.value}")
            if step.result and not step.result.success and step.result.error:
                lines.append(f"    Error: {step.result.error}")
        return "\n".join(lines)

    # ====================================================================
    # Workflow Status & Management
    # ====================================================================

    def get_workflow(self, workflow_id: str) -> Workflow | None:
        return self._active_workflows.get(workflow_id)

    def get_active_workflows(self, meeting_id: str | None = None) -> list[Workflow]:
        workflows = list(self._active_workflows.values())
        if meeting_id:
            workflows = [w for w in workflows if w.meeting_id == meeting_id]
        return workflows


# Singleton
_engine: WorkflowEngine | None = None


def get_workflow_engine() -> WorkflowEngine:
    global _engine
    if _engine is None:
        _engine = WorkflowEngine()
    return _engine
