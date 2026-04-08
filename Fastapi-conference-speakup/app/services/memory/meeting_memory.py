# SpeakUp AI — Meeting Memory Service
# Vector embeddings + Graph memory for cross-meeting intelligence
from __future__ import annotations

import time
import uuid
from typing import Any

from app.core.config import get_settings
from app.core.constants import KafkaTopics
from app.core.logging import get_logger
from app.services.llm.router import TaskType, get_llm_router
from app.schemas.ai_schemas import (
    ActionItem,
    Decision,
    MeetingMemoryQuery,
    MeetingMemoryResult,
    MeetingReplay,
    MeetingSummary,
    MemoryGraphNode,
    RelationshipProfile,
    ReplayChapter,
)
from infrastructure.kafka.producer import publish_event
from infrastructure.neo4j.client import execute_query
from infrastructure.qdrant.client import search_vectors, upsert_vectors

log = get_logger("memory_service")

SUMMARY_SYSTEM_PROMPT = """You are the Meeting Intelligence Engine for SpeakUp.
Generate a comprehensive meeting summary from the transcript.

Output JSON with these exact fields:
{
  "summary": "2-3 paragraph summary",
  "key_points": ["..."],
  "decisions": [{"description": "...", "made_by": "...", "context": "..."}],
  "action_items": [{"description": "...", "assignee": "...", "deadline": "...", "priority": "high|medium|low"}],
  "unresolved_questions": ["..."],
  "follow_up_suggestions": ["..."],
  "risks_identified": ["..."],
  "contradiction_flags": ["..."],
  "compliance_flags": ["..."],
  "topics_discussed": ["..."]
}

Rules:
- Be precise and factual
- Only extract what's actually in the transcript
- Attribute decisions and actions to specific people when possible
- Flag contradictions where participants said opposing things
- Identify compliance-relevant statements (promises, commitments, legal mentions)"""

REPLAY_SYSTEM_PROMPT = """You are the Meeting Replay Generator for SpeakUp.
Create chapter markers for a meeting recording replay.
Output JSON: {"chapters": [{"title": "...", "start_time": float, "end_time": float, "summary": "...", "highlights": [...], "is_key_moment": bool}]}"""


def _get_router():
    return get_llm_router()


async def generate_meeting_summary(
    meeting_id: str,
    transcript: str,
    participant_names: list[str] | None = None,
    meeting_title: str | None = None,
    duration_minutes: float = 0,
    participant_count: int = 0,
) -> MeetingSummary:
    """Generate comprehensive meeting summary from transcript."""
    router = _get_router()

    user_content = f"""Meeting: {meeting_title or 'Untitled'}
Participants: {', '.join(participant_names or [])}
Duration: {duration_minutes:.1f} minutes

Transcript:
{transcript[:12000]}"""

    response = await router.chat(
        [{"role": "system", "content": SUMMARY_SYSTEM_PROMPT}, {"role": "user", "content": user_content}],
        task_type=TaskType.MEETING_SUMMARY,
    )

    import orjson
    try:
        data = orjson.loads(response.content)
    except Exception:
        log.warning("Failed to parse summary response", raw=response.content[:300])
        data = {"summary": response.content, "key_points": [], "decisions": [], "action_items": []}

    decisions = [
        Decision(
            id=str(uuid.uuid4()),
            description=d.get("description", ""),
            made_by=d.get("made_by"),
            context=d.get("context"),
        )
        for d in data.get("decisions", [])
    ]

    action_items = [
        ActionItem(
            id=str(uuid.uuid4()),
            description=a.get("description", ""),
            assignee=a.get("assignee"),
            deadline=a.get("deadline"),
            priority=a.get("priority", "medium"),
        )
        for a in data.get("action_items", [])
    ]

    summary = MeetingSummary(
        meeting_id=meeting_id,
        title=meeting_title,
        summary=data.get("summary", ""),
        key_points=data.get("key_points", []),
        decisions=decisions,
        action_items=action_items,
        unresolved_questions=data.get("unresolved_questions", []),
        follow_up_suggestions=data.get("follow_up_suggestions", []),
        risks_identified=data.get("risks_identified", []),
        contradiction_flags=data.get("contradiction_flags", []),
        compliance_flags=data.get("compliance_flags", []),
        sentiment_timeline=[],
        duration_minutes=duration_minutes,
        participant_count=participant_count,
        topics_discussed=data.get("topics_discussed", []),
    )

    # Publish summary
    await publish_event(
        KafkaTopics.AI_MEETING_SUMMARY,
        key=meeting_id,
        value=summary.model_dump(),
    )

    # Publish action items separately for Express to create tasks
    if action_items:
        await publish_event(
            KafkaTopics.AI_ACTION_ITEMS,
            key=meeting_id,
            value={
                "meeting_id": meeting_id,
                "action_items": [a.model_dump() for a in action_items],
            },
        )

    log.info(
        "Meeting summary generated",
        meeting_id=meeting_id,
        decisions=len(decisions),
        action_items=len(action_items),
    )

    return summary


async def store_meeting_memory(
    meeting_id: str,
    summary: MeetingSummary,
    participant_ids: list[str],
) -> None:
    """Store meeting in vector DB + graph DB for cross-meeting intelligence."""
    router = _get_router()

    # ── Vector Storage (Qdrant) ──
    # Embed the summary for semantic search
    texts_to_embed = [
        summary.summary,
        *summary.key_points,
        *[d.description for d in summary.decisions],
        *[a.description for a in summary.action_items],
    ]

    vectors = []
    for text in texts_to_embed:
        embed_resp = await router.embed(text)
        vectors.append(embed_resp.embedding)

    points = []
    for i, (text, vector) in enumerate(zip(texts_to_embed, vectors)):
        points.append({
            "id": str(uuid.uuid4()),
            "vector": vector,
            "payload": {
                "meeting_id": meeting_id,
                "text": text,
                "type": "summary" if i == 0 else "key_point" if i <= len(summary.key_points) else "decision_or_action",
                "timestamp": time.time(),
                "participants": participant_ids,
                "topics": summary.topics_discussed,
            },
        })

    settings = get_settings()
    await upsert_vectors(settings.QDRANT_COLLECTION_MEETINGS, points)

    # ── Graph Storage (Neo4j) — Meeting Memory Graph ──
    # Create meeting node
    await execute_query(
        """
        MERGE (m:Meeting {meeting_id: $meeting_id})
        SET m.title = $title,
            m.summary = $summary,
            m.timestamp = $timestamp,
            m.duration_minutes = $duration,
            m.topics = $topics
        """,
        {
            "meeting_id": meeting_id,
            "title": summary.title or "Untitled",
            "summary": summary.summary[:500],
            "timestamp": time.time(),
            "duration": summary.duration_minutes,
            "topics": summary.topics_discussed,
        },
    )

    # Link participants
    for pid in participant_ids:
        await execute_query(
            """
            MERGE (p:Person {user_id: $user_id})
            MERGE (m:Meeting {meeting_id: $meeting_id})
            MERGE (p)-[:ATTENDED]->(m)
            """,
            {"user_id": pid, "meeting_id": meeting_id},
        )

    # Store decisions as nodes
    for decision in summary.decisions:
        await execute_query(
            """
            MERGE (d:Decision {id: $id})
            SET d.description = $description, d.made_by = $made_by
            MERGE (m:Meeting {meeting_id: $meeting_id})
            MERGE (d)-[:DECIDED_IN]->(m)
            """,
            {
                "id": decision.id,
                "description": decision.description,
                "made_by": decision.made_by or "unknown",
                "meeting_id": meeting_id,
            },
        )

    # Store action items
    for action in summary.action_items:
        await execute_query(
            """
            MERGE (a:ActionItem {id: $id})
            SET a.description = $description, a.assignee = $assignee,
                a.deadline = $deadline, a.priority = $priority, a.status = 'open'
            MERGE (m:Meeting {meeting_id: $meeting_id})
            MERGE (a)-[:ASSIGNED_IN]->(m)
            """,
            {
                "id": action.id,
                "description": action.description,
                "assignee": action.assignee or "unassigned",
                "deadline": action.deadline or "",
                "priority": action.priority,
                "meeting_id": meeting_id,
            },
        )

    # Store topics
    for topic in summary.topics_discussed:
        await execute_query(
            """
            MERGE (t:Topic {name: $name})
            MERGE (m:Meeting {meeting_id: $meeting_id})
            MERGE (t)-[:DISCUSSED_IN]->(m)
            """,
            {"name": topic, "meeting_id": meeting_id},
        )

    # Store risks
    for risk_desc in summary.risks_identified:
        risk_id = str(uuid.uuid4())
        await execute_query(
            """
            CREATE (r:Risk {id: $id, description: $description})
            WITH r
            MATCH (m:Meeting {meeting_id: $meeting_id})
            CREATE (r)-[:IDENTIFIED_IN]->(m)
            """,
            {"id": risk_id, "description": risk_desc, "meeting_id": meeting_id},
        )

    # Publish memory update
    await publish_event(
        KafkaTopics.AI_MEMORY_UPDATES,
        key=meeting_id,
        value={
            "meeting_id": meeting_id,
            "vectors_stored": len(points),
            "graph_nodes_created": len(summary.decisions) + len(summary.action_items) + len(summary.topics_discussed),
        },
    )

    log.info("Meeting memory stored", meeting_id=meeting_id, vectors=len(points))


async def query_meeting_memory(query: MeetingMemoryQuery) -> MeetingMemoryResult:
    """Semantic search across meeting history using vector + graph."""
    router = _get_router()
    settings = get_settings()

    # Vector search
    query_embed_resp = await router.embed(query.query)
    query_vector = query_embed_resp.embedding
    vector_results = await search_vectors(
        collection=settings.QDRANT_COLLECTION_MEETINGS,
        query_vector=query_vector,
        limit=query.limit,
        score_threshold=0.65,
    )

    # Graph search for related entities
    graph_results = await execute_query(
        """
        MATCH (m:Meeting)-[:ATTENDED]-(p:Person {user_id: $user_id})
        OPTIONAL MATCH (m)<-[:DECIDED_IN]-(d:Decision)
        OPTIONAL MATCH (m)<-[:ASSIGNED_IN]-(a:ActionItem)
        RETURN m.meeting_id as meeting_id, m.title as title, m.summary as summary,
               collect(DISTINCT d.description) as decisions,
               collect(DISTINCT {description: a.description, assignee: a.assignee, status: a.status}) as actions
        ORDER BY m.timestamp DESC
        LIMIT $limit
        """,
        {"user_id": query.user_id, "limit": query.limit},
    )

    related_meetings = list({r.get("meeting_id", "") for r in graph_results if r.get("meeting_id")})
    related_actions = []
    for r in graph_results:
        for a in r.get("actions", []):
            if a.get("description"):
                related_actions.append(ActionItem(
                    description=a["description"],
                    assignee=a.get("assignee"),
                    status=a.get("status", "open"),
                ))

    return MeetingMemoryResult(
        query=query.query,
        results=vector_results,
        related_meetings=related_meetings,
        related_people=[],
        related_action_items=related_actions[:10],
    )


async def generate_meeting_replay(
    meeting_id: str,
    transcript: str,
    duration_seconds: float,
) -> MeetingReplay:
    """Generate chapter markers for meeting replay."""
    router = _get_router()

    response = await router.chat(
        [{"role": "system", "content": REPLAY_SYSTEM_PROMPT}, {"role": "user", "content": f"Duration: {duration_seconds}s\n\nTranscript:\n{transcript[:8000]}"}],
        task_type=TaskType.MEETING_REPLAY,
    )

    import orjson
    try:
        data = orjson.loads(response.content)
    except Exception:
        data = {"chapters": []}

    chapters = [
        ReplayChapter(
            title=c.get("title", ""),
            start_time=c.get("start_time", 0),
            end_time=c.get("end_time", 0),
            summary=c.get("summary", ""),
            highlights=c.get("highlights", []),
            is_key_moment=c.get("is_key_moment", False),
        )
        for c in data.get("chapters", [])
    ]

    return MeetingReplay(
        meeting_id=meeting_id,
        chapters=chapters,
        key_clips=[],
        conflict_highlights=[],
        best_moments=[],
        promises=[],
    )


async def get_relationship_profile(
    user_id: str,
    target_user_id: str,
) -> RelationshipProfile:
    """Get relationship intelligence between two users from graph."""
    results = await execute_query(
        """
        MATCH (p1:Person {user_id: $user_id})-[:ATTENDED]->(m:Meeting)<-[:ATTENDED]-(p2:Person {user_id: $target_user_id})
        RETURN count(m) as meeting_count, collect(m.meeting_id) as meetings
        """,
        {"user_id": user_id, "target_user_id": target_user_id},
    )

    interaction_count = results[0].get("meeting_count", 0) if results else 0

    return RelationshipProfile(
        user_id=user_id,
        target_user_id=target_user_id,
        interaction_count=interaction_count,
    )
