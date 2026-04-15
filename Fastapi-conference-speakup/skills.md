# SpeakUp AI — FastAPI Intelligence Plane — AI Skills Reference

> **Purpose**: Complete codebase map for AI assistants. Use this to locate files, understand data flow, and navigate the architecture without guessing.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Runtime | Python 3.11 |
| Framework | FastAPI + Uvicorn / Gunicorn |
| LLM Orchestration | LangGraph + LangChain |
| LLM Providers | OpenAI, Anthropic, Gemini, HuggingFace, OpenRouter (5 providers) |
| Vector DB | Qdrant (cosine similarity, 1536-dim embeddings) |
| Graph DB | Neo4j 5.25 Community |
| SQL DB | PostgreSQL 16 + SQLAlchemy async + Alembic |
| Cache / Pub-Sub | Redis 7 (ioredis, hiredis) |
| Event Streaming | Kafka (AIOKafka) via Confluent Platform 7.6 |
| Task Queue | Celery (Redis broker) |
| Speech | faster-whisper + Silero VAD |
| Computer Vision | MediaPipe (face mesh, pose, face detection) + OpenCV |
| MCP Tools | 27 tools across 11 categories |
| Monitoring | Prometheus + Sentry + structlog |
| Validation | Pydantic v2 + pydantic-settings |

---

## Directory Map

```
Fastapi-conference-speakup/
├── app/
│   ├── main.py                        # FastAPI app factory + lifespan (startup/shutdown)
│   ├── __init__.py
│   │
│   ├── api/
│   │   └── v1/
│   │       ├── router.py              # Aggregates all 11 endpoint routers
│   │       └── endpoints/
│   │           ├── agents.py          # /agents/* — LangGraph orchestrator endpoints
│   │           ├── assistant.py       # /assistant/* — Voice command processing
│   │           ├── copilot.py         # /copilot/* — Live AI suggestions
│   │           ├── cv.py              # /cv/* — Computer vision analysis
│   │           ├── emotion.py         # /emotion/* — Multimodal emotion signals
│   │           ├── health.py          # /health*, /metrics — Liveness/readiness/prometheus
│   │           ├── mcp_tools.py       # /tools/* — MCP tool execution
│   │           ├── memory.py          # /memory/* — Meeting memory + vector search
│   │           ├── speech.py          # /speech/* — Transcription + speech analysis
│   │           └── workflow.py        # /workflow/* — Post/pre meeting automation
│   │
│   ├── core/
│   │   ├── config.py                  # Settings class (60+ env vars via pydantic-settings)
│   │   ├── constants.py               # KafkaTopics, RedisKeys, AIServiceType, EmotionSignals, CoachingCategory
│   │   ├── exceptions.py              # 7 custom HTTP exception classes
│   │   ├── logging.py                 # structlog setup (JSON in prod, console in dev)
│   │   └── security.py               # Auth: verify_internal_api_key, verify_service_token
│   │
│   ├── middleware/
│   │   └── request_logging.py         # RequestLoggingMiddleware (timing, request ID, structlog)
│   │
│   ├── models/                        # Empty — uses Prisma from Express, Qdrant + Neo4j directly
│   │
│   ├── schemas/
│   │   └── ai_schemas.py             # 30+ Pydantic models for all AI request/response types
│   │
│   ├── services/
│   │   ├── agents/
│   │   │   └── orchestrator.py        # LangGraph stateful agent pipeline (6 nodes)
│   │   ├── assistant/
│   │   │   └── voice_commands.py      # VoiceCommandAssistant (regex + LLM parsing)
│   │   ├── copilot/
│   │   │   └── suggestions.py         # Live copilot, coaching reports, outcome prediction
│   │   ├── cv/
│   │   │   └── vision.py             # MediaPipe face mesh + pose + gaze + smile detection
│   │   ├── emotion/
│   │   │   └── analyzer.py           # Multimodal emotion fusion (voice + face + text)
│   │   ├── llm/
│   │   │   ├── providers.py           # 5 LLM providers + circuit breaker + factory
│   │   │   └── router.py             # Intelligent task-based LLM router (17 task types)
│   │   ├── mcp/
│   │   │   ├── registry.py           # @register_tool decorator, execute_tool, parallel execution
│   │   │   └── tools/
│   │   │       ├── calendar_tool.py   # 3 tools: list_events, create_event, schedule_followup
│   │   │       ├── email_tool.py      # 4 tools: send, search, read, draft_recap
│   │   │       ├── github_tool.py     # 3 tools: create_issue, search_issues, create_pr_comment
│   │   │       ├── integrations_tool.py # 7 tools: web_search, crm_*, file_search, social, ms_teams, ms_outlook
│   │   │       ├── jira_tool.py       # 3 tools: jira_create_ticket, jira_search, linear_create_issue
│   │   │       ├── notion_tool.py     # 3 tools: create_page, search, update_meeting_notes
│   │   │       └── slack_tool.py      # 4 tools: send_message, search, list_channels, post_summary
│   │   ├── memory/
│   │   │   └── meeting_memory.py      # Summary gen, vector+graph storage, semantic search, replay
│   │   ├── openclaw/
│   │   │   └── bridge.py             # REST bridge to OpenClaw for browser automation
│   │   ├── speech/
│   │   │   └── transcription.py       # faster-whisper transcription + Silero VAD + speech analysis
│   │   └── workflow/
│   │       └── automation.py          # WorkflowEngine: dependency-aware parallel step execution
│   │
│   └── workers/
│       ├── celery_app.py              # Celery config + 3 heavy async tasks
│       └── event_handlers.py          # 5 Kafka @on_topic handlers
│
├── infrastructure/
│   ├── kafka/
│   │   ├── consumers.py               # Kafka consumer workers + @on_topic decorator registry
│   │   └── producer.py               # AIOKafka producer/consumer factory + publish helpers
│   ├── neo4j/
│   │   └── client.py                 # Async Neo4j driver + index creation + execute_query
│   ├── qdrant/
│   │   └── client.py                 # Async Qdrant client + upsert_vectors + search_vectors
│   └── redis/
│       └── client.py                 # Async Redis + cache helpers + pub/sub
│
├── alembic/
│   ├── env.py                         # Async Alembic env (async_engine_from_config)
│   └── versions/                      # Migration files (empty — no migrations yet)
│
├── tests/
│   ├── unit/                          # Unit tests (empty)
│   ├── integration/                   # Integration tests (empty)
│   └── e2e/                           # End-to-end tests (empty)
│
├── .github/workflows/ci.yml          # CI/CD: lint → security → test → docker → deploy
├── .pre-commit-config.yaml            # ruff, mypy, gitleaks pre-commit hooks
├── Dockerfile                         # Multi-stage: base → deps → development → production
├── docker-compose.yaml                # 8 services: api, celery, qdrant, neo4j, redis, kafka, zk, pg
├── Makefile                           # 20+ commands
├── pyproject.toml                     # 80+ dependencies, hatch build system
├── requirements.txt                   # Mirrored from pyproject.toml
├── alembic.ini                        # DB migration config (asyncpg)
└── ochestration.md                    # Architecture design doc (Express ↔ FastAPI split)
```

---

## Role in the System

This is the **AI intelligence plane**. It does NOT handle user auth, billing, or CRUD — that's the Express backend. This service:

1. **Receives** media streams (audio chunks, video frames, chat messages) via Kafka from Express
2. **Processes** them through ML models (Whisper, MediaPipe, LLMs)
3. **Produces** AI insights (transcriptions, emotions, suggestions, summaries) back via Kafka + Redis pub/sub
4. **Express** relays those insights to clients via WebSocket

All endpoints are internal — authenticated via `X-Internal-API-Key` header, not user tokens.

---

## API Routes

All routes at `/api/v1`. Auth is `X-Internal-API-Key` unless noted.

### Speech — `endpoints/speech.py`
| Method | Path | Description |
|--------|------|-------------|
| POST | `/speech/transcribe` | Transcribe audio chunk via Whisper (multipart: audio + meeting_id + participant_id + language) |
| POST | `/speech/vad` | Voice activity detection using Silero VAD |
| GET | `/speech/transcript/{meeting_id}` | Get accumulated transcript from Redis cache |
| POST | `/speech/analyze` | Analyze speech patterns (WPM, filler words, confidence) |

### Computer Vision — `endpoints/cv.py`
| Method | Path | Description |
|--------|------|-------------|
| POST | `/cv/analyze-frame` | Analyze single video frame: face + posture + gaze (multipart: frame + params) |
| POST | `/cv/analyze-batch` | Batch frame analysis (redirects to Kafka) |

### Emotion — `endpoints/emotion.py`
| Method | Path | Description |
|--------|------|-------------|
| POST | `/emotion/analyze` | Multimodal emotion fusion (voice + face + text → soft signals) |
| GET | `/emotion/meeting/{meeting_id}` | Current emotion state for all participants |

### AI Copilot — `endpoints/copilot.py`
| Method | Path | Description |
|--------|------|-------------|
| POST | `/copilot/suggestions` | Real-time copilot suggestions (max 3 per call) |
| POST | `/copilot/coaching-report` | Post-meeting coaching report (strengths + improvements + score 0-100) |
| POST | `/copilot/predict-outcome` | Meeting outcome probability + risk factors |
| POST | `/copilot/knowledge-gaps` | Detect unexplained topics in technical discussions |

### Meeting Memory — `endpoints/memory.py`
| Method | Path | Description |
|--------|------|-------------|
| POST | `/memory/summary` | Generate meeting summary from transcript (LLM) |
| POST | `/memory/store` | Store in Qdrant vectors + Neo4j graph |
| POST | `/memory/query` | Semantic search across meeting history |
| POST | `/memory/replay` | Generate chapter markers for meeting replay |
| GET | `/memory/relationship/{user_id}/{target_user_id}` | Relationship intelligence between two users |

### Agent Orchestrator — `endpoints/agents.py`
| Method | Path | Description |
|--------|------|-------------|
| POST | `/agents/live-analysis` | Run full LangGraph live analysis pipeline (6 nodes) |
| POST | `/agents/post-meeting` | Run post-meeting summary + memory storage pipeline |
| GET | `/agents/state/{meeting_id}` | Get current AI agent state from Redis |

### Voice Assistant — `endpoints/assistant.py`
| Method | Path | Description |
|--------|------|-------------|
| POST | `/assistant/voice-command` | Process voice command (detect → parse → optionally execute) |
| POST | `/assistant/voice-command/confirm` | Execute a previously confirmed command |
| POST | `/assistant/meeting-context` | Set meeting context for better command resolution |

### MCP Tools — `endpoints/mcp_tools.py`
| Method | Path | Description |
|--------|------|-------------|
| GET | `/tools/schema` | Returns all 27 tools in OpenAI function-calling schema |
| POST | `/tools/execute` | Execute a single MCP tool by name |
| POST | `/tools/execute-multiple` | Execute multiple tools in parallel |

### Workflow — `endpoints/workflow.py`
| Method | Path | Description |
|--------|------|-------------|
| POST | `/workflow/post-meeting` | Multi-step post-meeting workflow |
| POST | `/workflow/pre-meeting` | Pre-meeting preparation workflow |
| GET | `/workflow/status/{workflow_id}` | Check workflow execution status |
| GET | `/workflow/active` | List active workflows |

### Health & Metrics — `endpoints/health.py` (no auth)
| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Liveness probe |
| GET | `/health/ready` | Readiness probe (Redis, Kafka, Qdrant, Neo4j) |
| GET | `/health/detailed` | Models loaded + connection status |
| GET | `/metrics` | Prometheus metrics endpoint |

---

## Multi-LLM System

### Providers — `services/llm/providers.py`

| Provider | Model | Strengths |
|----------|-------|-----------|
| OpenAI | gpt-4o | Best all-rounder, function calling, embeddings (text-embedding-3-small) |
| Anthropic | claude-sonnet-4-20250514 | Complex reasoning, long context |
| Gemini | gemini-2.5-flash / gemini-2.5-pro | Fast, multimodal, cost-effective |
| HuggingFace | Llama-3.3-70B-Instruct | Open-source fallback, embeddings |
| OpenRouter | Any model | Universal gateway, last-resort fallback |

Each provider has a **circuit breaker**: 5 failures → open (30s → 60s → 120s → 300s exponential backoff).

### Task-Based Router — `services/llm/router.py`

**17 Task Types** (enum `TaskType`):

| Category | Tasks |
|----------|-------|
| Real-time | `COPILOT_SUGGESTIONS`, `COACHING_HINTS`, `LIVE_INSIGHTS`, `KNOWLEDGE_GAP`, `EMOTION_ANALYSIS` |
| Heavy | `MEETING_SUMMARY`, `OUTCOME_PREDICTION`, `COACHING_REPORT`, `MEETING_REPLAY` |
| Agent | `AGENT_REASONING`, `TOOL_SELECTION`, `WORKFLOW_PLANNING` |
| Content | `RECAP_EMAIL`, `ACTION_ITEMS`, `TICKET_CREATION` |
| Embedding | `EMBEDDING` |
| General | `GENERAL` |

**Fallback chain**: Best provider for task → next best → all providers for task → OpenRouter → HuggingFace → try all remaining → RuntimeError.

---

## MCP Tool Registry — 27 Tools

### `services/mcp/registry.py` — `@register_tool` decorator pattern

| # | Tool Name | Category | File | Description |
|---|-----------|----------|------|-------------|
| 1 | `email_send` | EMAIL | email_tool.py | Send email via Gmail API or Express SMTP fallback |
| 2 | `email_search` | EMAIL | email_tool.py | Search inbox (Gmail query syntax) |
| 3 | `email_read` | EMAIL | email_tool.py | Read specific email by message ID |
| 4 | `email_draft_recap` | EMAIL | email_tool.py | AI-draft meeting recap email (uses LLM) |
| 5 | `slack_send_message` | MESSAGING | slack_tool.py | Send Slack message to channel/DM |
| 6 | `slack_search_messages` | MESSAGING | slack_tool.py | Search Slack messages |
| 7 | `slack_list_channels` | MESSAGING | slack_tool.py | List accessible Slack channels |
| 8 | `slack_post_meeting_summary` | MESSAGING | slack_tool.py | Post formatted meeting recap blocks |
| 9 | `calendar_list_events` | CALENDAR | calendar_tool.py | List Google Calendar events |
| 10 | `calendar_create_event` | CALENDAR | calendar_tool.py | Create event with attendees |
| 11 | `calendar_schedule_followup` | CALENDAR | calendar_tool.py | AI-scheduled follow-up (next business day) |
| 12 | `github_create_issue` | CODE | github_tool.py | Create GitHub issue from action items |
| 13 | `github_search_issues` | CODE | github_tool.py | Search issues/PRs across repos |
| 14 | `github_create_pr_comment` | CODE | github_tool.py | Comment on PR or issue |
| 15 | `jira_create_ticket` | PROJECT_MGMT | jira_tool.py | Create Jira ticket (Task/Story/Bug/Epic) |
| 16 | `jira_search` | PROJECT_MGMT | jira_tool.py | Search Jira via JQL |
| 17 | `linear_create_issue` | PROJECT_MGMT | jira_tool.py | Create Linear issue (GraphQL) |
| 18 | `notion_create_page` | DOCS | notion_tool.py | Create Notion page/meeting notes |
| 19 | `notion_search` | DOCS | notion_tool.py | Search Notion workspace |
| 20 | `notion_update_meeting_notes` | DOCS | notion_tool.py | Append to existing Notion page |
| 21 | `web_search` | SEARCH | integrations_tool.py | Tavily AI web search |
| 22 | `crm_search_contacts` | CRM | integrations_tool.py | Search Salesforce contacts |
| 23 | `crm_create_note` | CRM | integrations_tool.py | Create Salesforce CRM note |
| 24 | `file_search` | FILE_MGMT | integrations_tool.py | Search SpeakUp workspace files (via Express) |
| 25 | `social_post_update` | SOCIAL | integrations_tool.py | Post to Twitter/X |
| 26 | `ms_teams_send_message` | MESSAGING | integrations_tool.py | Send Microsoft Teams message |
| 27 | `ms_outlook_send_email` | EMAIL | integrations_tool.py | Send via Outlook Graph API |

**11 Categories**: EMAIL, CALENDAR, MESSAGING, PROJECT_MANAGEMENT, DOCUMENTATION, CODE, CRM, SEARCH, FILE_MANAGEMENT, SOCIAL, AUTOMATION

---

## LangGraph Agent Pipeline — `services/agents/orchestrator.py`

**State**: `MeetingAgentState(TypedDict)` — 16 fields (meeting data, transcript, emotions, outputs)

### 6 Nodes

| Node | Service | Output |
|------|---------|--------|
| `transcription_analysis` | speech/transcription.py | Per-participant speech patterns |
| `emotion_fusion` | emotion/analyzer.py | Per-participant multimodal emotions |
| `copilot` | copilot/suggestions.py | Real-time suggestions (max 3) |
| `knowledge_gaps` | copilot/suggestions.py | Unexplained topics |
| `outcome_prediction` | copilot/suggestions.py | Meeting outcome probability (every 5th iteration) |
| `summary` | memory/meeting_memory.py | Full summary + memory storage |

### Graph Flow

**Live analysis** (called every ~10 seconds during meeting):
```
transcription_analysis → emotion_fusion → copilot → knowledge_gaps → [every 5th: outcome_prediction] → END
```

**Post-meeting**:
```
summary → END
```

Publishes results to Kafka `AI_LIVE_INSIGHTS` + Redis pub/sub `ai:insights:{meeting_id}`.

---

## Kafka Integration

### Consumed from Express (6 topics)

| Topic | Consumer Group | Handler | Trigger |
|-------|---------------|---------|---------|
| `speakup.meeting.events` | speakup-ai-meeting-events | `handle_meeting_event` | meeting.started / ended / updated |
| `speakup.participant.events` | speakup-ai-meeting-events | `handle_participant_event` | joined / left |
| `speakup.recording.events` | speakup-ai-meeting-events | (available) | recording started / completed |
| `speakup.media.audio_chunks` | speakup-ai-media | `handle_audio_chunk` | Every audio chunk → transcribe → every 5th: full live analysis |
| `speakup.media.video_frames` | speakup-ai-media | `handle_video_frame` | Per video frame → CV analysis |
| `speakup.chat.messages` | speakup-ai-chat | `handle_chat_message` | Per chat message → text emotion analysis |

### Produced by FastAPI (9 topics)

| Topic | Producer | Content |
|-------|----------|---------|
| `speakup.ai.transcription` | speech service | Transcription segments + full text |
| `speakup.ai.live_insights` | agent orchestrator | Aggregated suggestions + emotions + gaps |
| `speakup.ai.emotion_signals` | emotion analyzer | Per-participant multimodal emotion |
| `speakup.ai.coaching_hints` | speech analysis | Pace/clarity coaching hints |
| `speakup.ai.copilot_suggestions` | copilot service | Real-time AI suggestions |
| `speakup.ai.meeting_summary` | memory service | Full meeting summary |
| `speakup.ai.action_items` | memory service | Extracted action items for Express |
| `speakup.ai.memory_updates` | memory service | Vector + graph storage confirmation |
| `speakup.ai.cv_analysis` | CV service | Per-frame face + posture |

---

## Redis Usage

### Cache Keys
| Key Pattern | TTL | Usage |
|-------------|-----|-------|
| `ai:meeting:{meeting_id}:state` | 8 hours | Meeting AI pipeline state |
| `ai:meeting:{meeting_id}:transcript` | 2 hours | Accumulated transcript segments + full text |
| `ai:meeting:{meeting_id}:emotions` | 5 min | Per-participant emotion signals |
| `ai:meeting:{meeting_id}:insights` | — | Cached insights |
| `ai:model_cache:{model}:{hash}` | — | Model inference cache |
| `ai:rate_limit:{user_id}:{action}` | — | Rate limiting |

### Pub/Sub Channels (real-time push)
| Channel | Publisher | Content |
|---------|----------|---------|
| `ai:insights:{meeting_id}` | CV, emotion, agent | Analysis results → Express AI Consumer → WebSocket |
| `ai:coaching:{meeting_id}` | speech service | Coaching hints |
| `ai:copilot:{meeting_id}` | copilot service | Real-time suggestions |

---

## Database Layer

### Qdrant (Vector DB)
- **Collections**: `meeting_memories`, `knowledge_base`
- **Embedding dim**: 1536 (OpenAI text-embedding-3-small)
- **Distance**: Cosine, score threshold 0.65
- **Client**: `infrastructure/qdrant/client.py` — `upsert_vectors()`, `search_vectors()`

### Neo4j (Graph DB)
**Node types** (with unique indexes):
- `:Meeting {meeting_id}` — title, summary, timestamp, duration, topics
- `:Person {user_id}`
- `:Decision {id}` — description, made_by
- `:ActionItem {id}` — description, assignee, deadline, priority, status
- `:Topic {name}`
- `:Risk {id}` — description

**Relationships**:
```
(Person)-[:ATTENDED]->(Meeting)
(Decision)-[:DECIDED_IN]->(Meeting)
(ActionItem)-[:ASSIGNED_IN]->(Meeting)
(Topic)-[:DISCUSSED_IN]->(Meeting)
(Risk)-[:IDENTIFIED_IN]->(Meeting)
```

**Client**: `infrastructure/neo4j/client.py` — `execute_query()`

### PostgreSQL
- Connection: `postgresql+asyncpg://` via Alembic
- Pool: configurable `DATABASE_POOL_SIZE` + `DATABASE_MAX_OVERFLOW`
- No SQLAlchemy models yet — Express owns the user/meeting data via Prisma

---

## Celery Workers — `workers/celery_app.py`

**Broker**: Redis DB 2 | **Backend**: Redis DB 3

| Task | Queue | Description | Max Retries |
|------|-------|-------------|-------------|
| `ai.generate_meeting_summary` | speakup-ai-summary | Full post-meeting summary + memory | 3 |
| `ai.store_meeting_memory` | speakup-ai-memory | Store embeddings + graph nodes | 3 |
| `ai.batch_transcribe` | speakup-ai-inference | Transcribe full recording audio | 2 |

**4 Queues**: speakup-ai-default, speakup-ai-summary, speakup-ai-memory, speakup-ai-inference

---

## Voice Assistant — `services/assistant/voice_commands.py`

**Trigger detection**: Prefixes (`hey speakup`, `assistant`, `ai please`...) + imperative verb detection (`send`, `email`, `create`, `schedule`...)

**2-phase parsing**:
1. **Quick regex** (11 patterns, no LLM): `send recap email to (.+)` → email_draft_recap + email_send
2. **LLM parsing** (TaskType.TOOL_SELECTION, temp 0.1): For complex commands

**8 command categories**: email, messaging, calendar, tickets, documentation, search, browser, meeting_control

Routes to MCP tools or falls back to OpenClaw bridge.

---

## Workflow Automation — `services/workflow/automation.py`

### Post-Meeting Workflow (6 steps)
| Step | Tool | Depends On | Optional |
|------|------|-----------|----------|
| 1 | `email_draft_recap` | — | No |
| 2 | `email_send` | Step 1 | No |
| 3 | `slack_post_meeting_summary` | — | Yes |
| 4 | `jira_create_ticket` / `linear_create_issue` (per action item) | — | Yes |
| 5 | `notion_update_meeting_notes` | — | Yes |
| 6 | `calendar_schedule_followup` | — | Yes |

### Pre-Meeting Workflow (5 steps, all parallel)
| Step | Tool | Description |
|------|------|-------------|
| 1 | `email_search` | Search emails per attendee |
| 2 | `slack_search_messages` | Search Slack for attendee mentions |
| 3 | `calendar_list_events` | Check next 7 days |
| 4 | `jira_search` | Search tickets related to agenda |
| 5 | `web_search` | Research meeting title |

Dependency-aware parallel execution. Retries (max 2) with exponential backoff. Optional steps don't block.

---

## Emotion Analysis — `services/emotion/analyzer.py`

### Multimodal Fusion (3 inputs)
| Modality | Signals | Source |
|----------|---------|--------|
| Voice | pitch variance, speaking speed, pause ratio, volume | Speech analysis |
| Face | eye contact, smile score | CV analysis |
| Text | keyword sentiment (8 positive + 8 negative markers) | Chat messages |
| + Response latency | > 3000ms → hesitation | Timing |

### 8 Emotion Signals (soft labels)
`possible_confusion`, `engagement_drop`, `hesitation`, `high_confidence`, `possible_frustration`, `calm_focused`, `excitement`, `fatigue`

---

## Pydantic Schemas — `schemas/ai_schemas.py`

| Schema | Purpose |
|--------|---------|
| `AIResponse` | Standard wrapper (success, service, meeting_id, timestamp, data) |
| `HealthStatus` | Service health (status, uptime, models, connections) |
| `TranscriptionResult` | meeting_id, segments, full_text, language, duration |
| `SpeechAnalysis` | WPM, filler_word_count, filler_words, silence_ratio, confidence |
| `CVAnalysisResult` | face (gaze, eye_contact, smile, head_pose) + posture (score, confidence) |
| `MultimodalEmotionResult` | signals, dominant_signal, engagement_score, modalities_used |
| `CopilotSuggestion` | type, content, reasoning, priority (0-1), target_participant |
| `MeetingSummary` | Full summary: key_points, decisions, action_items, risks, topics, compliance_flags |
| `ActionItem` | description, assignee, deadline, priority, status |
| `Decision` | description, made_by, context, timestamp |
| `CoachingReport` | hints, overall_score (0-100), strengths, improvements |
| `OutcomePrediction` | type, probability, confidence, risk_factors, positive_signals |
| `MeetingReplay` | chapters, key_clips, conflict_highlights, best_moments, promises |
| `RelationshipProfile` | communication_style, preferred_pace, conflict_triggers, interaction_count |
| `KnowledgeGap` | topic, mentioned_at, description, suggested_question, severity |
| `MeetingMemoryQuery` | user_id, query, meeting_ids, time_range_days, limit |
| `MeetingMemoryResult` | results, related_meetings, related_people, related_action_items |
| `CoachingHint` | category, message, severity, participant_id, metric_value |
| `EmotionSignal` | signal_type, confidence (0-1), description |
| `SuggestionType(Enum)` | QUESTION, CLARIFICATION, EMPATHY, NEGOTIATION, TECHNICAL, AGENDA, CONFLICT, PHRASING, COACHING |

---

## Startup Sequence — `app/main.py`

### `create_app()`:
```
1. Load Settings (pydantic-settings from .env)
2. Setup structlog logging
3. Create FastAPI instance (conditional docs)
4. Add middleware: CORS → GZip → RequestLogging
5. Mount router: api_router at /api/v1
```

### Lifespan startup:
```
1. Redis connect
2. Kafka producer connect
3. Qdrant init (non-fatal)
4. Neo4j init (non-fatal)
5. Load Whisper + Silero VAD (non-fatal)
6. Load MediaPipe models (non-fatal)
7. Start Kafka consumers (3 groups)
8. Init LLM providers (5 providers)
9. Load MCP tool registry (27 tools)
10. Check OpenClaw connectivity (optional)
11. Init Sentry (if DSN set)
```

### Graceful shutdown:
```
LLM providers → OpenClaw → Kafka → Redis → Qdrant → Neo4j
```

---

## Request Flow Architecture

### Real-time (every ~10 seconds during meeting)
```
Client → Express (WebRTC + Socket.IO) → Kafka (audio/video chunks)
  ↓
FastAPI Kafka Consumer → transcribe_audio() → cache in Redis
  ↓ (every 5 chunks)
run_live_analysis() → LangGraph:
  transcription → emotion_fusion → copilot → knowledge_gaps → [outcome_prediction]
  ↓
Kafka (AI_LIVE_INSIGHTS) + Redis Pub/Sub
  ↓
Express AI Consumer → WebSocket → Client UI
```

### Post-meeting
```
Express sends meeting.ended → Kafka
  ↓
handle_meeting_event() → run_post_meeting_analysis()
  → generate_meeting_summary() (LLM)
  → store_meeting_memory() (Qdrant + Neo4j)
  → Kafka AI_MEETING_SUMMARY + AI_ACTION_ITEMS
  ↓
Express AI Consumer → Prisma DB → Notify users
```

### Voice command
```
User speaks → Express transcription → Kafka → FastAPI
  detect_command() → parse_command() → [confirm?] → execute_command()
    → MCP tool(s) OR OpenClaw bridge
  → Kafka/WebSocket → Express → Client
```

---

## Middleware & Security

### Stack order
1. **CORSMiddleware** — Configurable origins, credentials
2. **GZipMiddleware** — Compress > 1000 bytes
3. **RequestLoggingMiddleware** — Request ID (X-Request-Id), timing, structlog

### Auth (`core/security.py`)
- `verify_internal_api_key` — HMAC compare of `X-Internal-API-Key` vs `EXPRESS_INTERNAL_API_KEY`
- `verify_service_token` — Bearer token + `X-Service-Signature` HMAC + `X-User-Context` JSON header

### Custom Exceptions (`core/exceptions.py`)
`AIServiceError`, `ModelNotLoadedError`, `InferenceTimeoutError`, `KafkaPublishError`, `MeetingNotActiveError`, `RateLimitExceededError`, `InvalidMediaError`, `AuthenticationError`

---

## Environment Variables

| Category | Variables |
|----------|-----------|
| App | `APP_NAME`, `APP_ENV`, `DEBUG`, `LOG_LEVEL`, `API_V1_PREFIX`, `SECRET_KEY`, `ALLOWED_ORIGINS` |
| Server | `HOST`, `PORT`, `WORKERS`, `RELOAD` |
| PostgreSQL | `DATABASE_URL`, `DATABASE_POOL_SIZE`, `DATABASE_MAX_OVERFLOW` |
| Redis | `REDIS_URL`, `REDIS_MAX_CONNECTIONS` |
| Kafka | `KAFKA_BROKERS`, `KAFKA_CLIENT_ID`, `KAFKA_GROUP_ID`, `KAFKA_SSL`, `KAFKA_SASL_USERNAME`, `KAFKA_SASL_PASSWORD` |
| Qdrant | `QDRANT_HOST`, `QDRANT_PORT`, `QDRANT_API_KEY`, `QDRANT_COLLECTION_MEETINGS`, `QDRANT_COLLECTION_KNOWLEDGE` |
| Neo4j | `NEO4J_URI`, `NEO4J_USERNAME`, `NEO4J_PASSWORD` |
| OpenAI | `OPENAI_API_KEY`, `OPENAI_MODEL`, `OPENAI_EMBEDDING_MODEL` |
| Anthropic | `ANTHROPIC_API_KEY`, `ANTHROPIC_MODEL` |
| Gemini | `GEMINI_API_KEY`, `GEMINI_MODEL`, `GEMINI_PRO_MODEL` |
| HuggingFace | `HUGGINGFACE_API_KEY`, `HUGGINGFACE_MODEL` |
| OpenRouter | `OPENROUTER_API_KEY`, `OPENROUTER_DEFAULT_MODEL` |
| LLM Routing | `LLM_FALLBACK_ENABLED`, `LLM_CIRCUIT_BREAKER_THRESHOLD`, `LLM_CIRCUIT_BREAKER_TIMEOUT` |
| LangSmith | `LANGCHAIN_TRACING_V2`, `LANGCHAIN_API_KEY`, `LANGCHAIN_PROJECT` |
| Slack | `SLACK_BOT_TOKEN`, `SLACK_USER_TOKEN`, `SLACK_DEFAULT_CHANNEL` |
| Google OAuth | `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GOOGLE_ACCESS_TOKEN`, `GOOGLE_REFRESH_TOKEN` |
| SMTP | `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_FROM_EMAIL` |
| GitHub | `GITHUB_TOKEN`, `GITHUB_DEFAULT_OWNER`, `GITHUB_DEFAULT_REPO` |
| Jira | `JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN`, `JIRA_DEFAULT_PROJECT` |
| Linear | `LINEAR_API_KEY`, `LINEAR_DEFAULT_TEAM_ID` |
| Notion | `NOTION_API_KEY` |
| Tavily | `TAVILY_API_KEY` |
| Salesforce | `SALESFORCE_INSTANCE_URL`, `SALESFORCE_ACCESS_TOKEN` |
| Twitter | `TWITTER_BEARER_TOKEN` |
| Microsoft | `MICROSOFT_GRAPH_TOKEN` |
| OpenClaw | `OPENCLAW_URL`, `OPENCLAW_API_KEY` |
| LiveKit | `LIVEKIT_HOST`, `LIVEKIT_API_KEY`, `LIVEKIT_API_SECRET` |
| Sentry | `SENTRY_DSN` |
| Express | `EXPRESS_BACKEND_URL`, `EXPRESS_INTERNAL_API_KEY` |
| Celery | `CELERY_BROKER_URL`, `CELERY_RESULT_BACKEND` |
| ML Models | `WHISPER_MODEL_SIZE`, `WHISPER_DEVICE`, `WHISPER_COMPUTE_TYPE`, `MEDIAPIPE_MODEL_PATH` |

---

## Docker — `docker-compose.yaml`

| Service | Image | Ports |
|---------|-------|-------|
| speakup-ai | Custom build | 8000 |
| celery-worker | Custom build | — |
| qdrant | qdrant/qdrant:v1.12.4 | 6333, 6334 |
| neo4j | neo4j:5.25-community | 7474, 7687 |
| redis | redis:7-alpine | 6380→6379 |
| kafka | confluentinc/cp-kafka:7.6.0 | 9093→9092 |
| zookeeper | confluentinc/cp-zookeeper:7.6.0 | — |
| postgres | postgres:16-alpine | 5433→5432 |

---

## Key Commands

```bash
# Development
make dev                # Uvicorn with reload
make prod               # Gunicorn production (4 workers)
make celery             # Start Celery worker
make celery-beat        # Start Celery beat scheduler

# Database
make migrate            # Apply Alembic migrations
make migrate-create     # Create new migration
make migrate-down       # Rollback last migration

# Docker
make docker-up          # Start full local stack (8 services)
make docker-down        # Stop stack

# Quality
make lint               # Ruff linter
make format             # Ruff formatter
make typecheck          # mypy type checking
make security           # bandit + safety + gitleaks

# Testing
make test               # Full test suite
make test-cov           # With coverage
make test-unit          # Unit tests only
make test-integration   # Integration tests only

# Setup
make install            # pip install from pyproject.toml
make install-gpu        # With GPU/CUDA deps
make hooks-install      # Pre-commit hooks
make clean              # Remove caches, __pycache__, .pyc
```

---

## CI/CD Pipeline — `.github/workflows/ci.yml`

```
Lint (ruff + mypy) → Security (bandit + safety + gitleaks) → Tests → Docker Build → Deploy
```

---

## File Naming Convention

- Endpoints: `app/api/v1/endpoints/<feature>.py`
- Services: `app/services/<feature>/<specific>.py`
- Infrastructure: `infrastructure/<technology>/client.py`
- Schemas: `app/schemas/ai_schemas.py` (single file)
- Workers: `app/workers/<name>.py`
- Config: `app/core/<name>.py`
