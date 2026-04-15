# SpeakUp Backend — AI Skills Reference

> **Purpose**: Complete codebase map for AI assistants. Use this to locate files, understand data flow, and navigate the architecture without guessing.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Runtime | Node.js 22 (ES Modules) |
| Framework | Express.js 5.2 |
| Database | PostgreSQL 16 + Prisma ORM 7.6 |
| Cache / Pub-Sub | Redis (ioredis 5.10) |
| Event Streaming | Kafka (KafkaJS 2.2) |
| Job Queue | BullMQ 5.71 (Redis-backed) |
| Auth | Firebase Admin SDK 13 (OAuth only, no passwords) |
| WebRTC | LiveKit Server SDK 2.9 |
| Real-time | Socket.IO 4.8 with Redis adapter |
| File Storage | Cloudinary 2.9 (avatars, materials) + AWS S3 (recordings) |
| Billing | Stripe 17.7 |
| Email | Nodemailer 8 |
| Validation | Zod 4.3 |
| Logging | Pino 10.3 |
| Monitoring | Prometheus (prom-client 15.1), Sentry 10.47 |
| Security | Helmet 8.1, CORS 2.8, rate-limiter-flexible 10 |

---

## Directory Map

```
Backend-conference-speakup/
├── index.js                    # Entry point — boots Express, mounts middleware + routes, inits services
├── package.json                # Dependencies & scripts
├── Makefile                    # dev, start, lint, test, db, docker, k8s commands
├── Dockerfile                  # 3-stage build (deps → prisma generate → production)
├── docker-compose.yaml         # Local stack: postgres, redis, kafka, livekit, mailhog
├── prisma.config.ts            # Prisma config
│
├── config/
│   ├── env.config.js           # All env vars (50+), validated at startup
│   ├── constants.js            # HTTP codes, error codes, meeting config, rate limits, Kafka topics, socket events, cache TTLs
│   ├── prisma.js               # Prisma client singleton (pg pool: max 20, idle 30s, timeout 10s)
│   └── firebase-admin.config.js # Firebase Admin init from env or JSON file
│
├── middlewares/
│   ├── security.middleware.js   # Helmet, CORS, XSS headers
│   ├── auth.middleware.js       # authenticate() — Firebase token → req.user
│   ├── request-logger.middleware.js # Request UUID + structured HTTP logging
│   ├── ratelimit.middleware.js  # apiLimiter, authLimiter, meetingCreateLimiter, chatLimiter, recordingLimiter
│   ├── validate.middleware.js   # validateBody(), validateQuery(), validateParams() — Zod
│   ├── errorhandler.middleware.js # AppError class, globalErrorHandler(), Prisma error mapping
│   ├── helper.middleware.js     # Utility middleware helpers
│   └── index.js                # Barrel export
│
├── modules/                    # 11 feature modules (each: routes + controller + service + validator)
│   ├── auth/                   # Sign in/out, get me, delete account
│   ├── user/                   # Profile, avatar, devices, online status
│   ├── meeting/                # CRUD, join/leave, lock, kick, tokens, invites, materials
│   ├── room/                   # Active room state, settings, mute-all
│   ├── chat/                   # Chat rooms, messages, DMs
│   ├── notification/           # Notifications, preferences, mark read
│   ├── recording/              # Start/stop, list, download (S3), webhook
│   ├── analytics/              # Dashboard stats, usage, per-meeting analytics
│   ├── billing/                # Stripe checkout, portal, subscription, webhook
│   ├── search/                 # Global search, users, meetings (full-text)
│   └── legal/                  # Terms, privacy (public, no auth)
│
├── services/
│   ├── redis.service.js        # initRedis(), getCache(), setCache(), deleteCache(), pub/sub
│   ├── kafka.service.js        # initKafka(), publishEvent(topic, key, value)
│   ├── bullmq.service.js       # initQueues(), getQueue(), registerWorker()
│   ├── websocket.service.js    # initWebSocket(server), emitToMeeting(), emitToUser()
│   ├── livekit.service.js      # generateToken(), listRooms(), deleteRoom(), removeParticipant()
│   ├── ai-gateway.service.js   # aiRequest(method, path, body) — HTTP bridge to FastAPI
│   ├── encryption.service.js   # generateMeetingCode(), hashPassword(), verifyPassword() (PBKDF2 + AES-256)
│   ├── cloudinary.service.js   # uploadToCloudinary(), deleteFromCloudinary(), multer
│   ├── mailer.service.js       # sendEmail(), verifyConnection()
│   ├── billing.service.js      # Stripe: createCustomer(), createSubscription(), createCheckoutSession()
│   ├── ai-consumer.service.js  # Kafka consumer: listens AI results → relays via WebSocket
│   └── workers.js              # BullMQ processors: email, notification, recording, analytics jobs
│
├── core/
│   ├── algos/                  # Placeholder for algorithms
│   ├── data/                   # Placeholder for data utilities
│   ├── mail/
│   │   ├── mail-content.js     # Email template generators (invite, reminder, digest)
│   │   ├── mail-render.js      # HTML email rendering engine
│   │   └── template/           # MJML / Handlebars email templates
│   ├── network/
│   │   └── retry.js            # Exponential backoff, retry strategies
│   └── utils/
│       ├── api-response.js     # success(), created(), error(), paginated() response helpers
│       ├── extentions.js       # MIME types, allowed file extensions
│       └── meeting-code.js     # xxx-xxxx-xxx code generation, URL helpers
│
├── logs/
│   ├── logger.js               # Pino logger factory: createLogger(context)
│   ├── sentry.logs.js          # Sentry init + error capture
│   ├── prometheus.logs.js      # /metrics endpoint, request histograms
│   └── grafana.logs.js         # /health, /health/ready liveness/readiness probes
│
├── prisma/
│   ├── schema.prisma           # Full database schema (models, enums, relations)
│   └── migrations/             # Auto-generated migration files
│
├── k8s/                        # Kubernetes manifests
│   ├── namespace.yaml          # speakup namespace
│   ├── deployment.yaml         # 3 replicas, rolling update, probes
│   ├── service.yaml            # LoadBalancer/ClusterIP
│   ├── configmap.yaml          # Non-secret config
│   └── secrets.yaml            # Encrypted secrets
│
├── nginx/
│   ├── default.conf            # Reverse proxy rules
│   └── nginx.conf              # Worker config, SSL
│
├── terraform/                  # Infrastructure as code (AWS, Cloudflare)
├── doc/                        # Documentation
└── skills/                     # Product vision docs
```

---

## Module Pattern

Every module in `modules/` follows this 4-file pattern:

| File | Role | Example |
|------|------|---------|
| `<name>.routes.js` | Express Router — defines endpoints, applies middleware | `router.post('/', authenticate, validateBody(schema), controller.create)` |
| `<name>.controller.js` | Request handler — extracts input, calls service, sends response | `const result = await service.create(req.body); success(res, result)` |
| `<name>.service.js` | Business logic — Prisma queries, cache, events, external APIs | `await prisma.meeting.create(...)` |
| `<name>.validator.js` | Zod schemas — body, query, params validation | `export const createSchema = z.object({...})` |

---

## API Routes

All routes are mounted at `/api/v1`.

### Auth — `modules/auth/auth.routes.js`
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/auth/signin` | No | Firebase token → create or login user |
| POST | `/auth/signout` | Yes | Mark offline, clear cache |
| GET | `/auth/me` | Yes | Current user profile |
| DELETE | `/auth/account` | Yes | Hard delete user + Firebase |

### User — `modules/user/user.routes.js`
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/users/profile` | Yes | Get profile |
| PUT | `/users/profile` | Yes | Update name, bio |
| PUT | `/users/avatar` | Yes | Upload avatar (Cloudinary, 5MB) |
| GET | `/users/devices` | Yes | List push devices |
| POST | `/users/devices` | Yes | Register FCM token |
| DELETE | `/users/devices/:deviceId` | Yes | Unregister device |
| PUT | `/users/online-status` | Yes | Update isOnline + lastSeenAt |

### Meeting — `modules/meeting/meeting.routes.js`
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/meetings` | Yes | Create meeting |
| GET | `/meetings` | Yes | List user's meetings (paginated) |
| GET | `/meetings/:id` | Yes | Get single meeting |
| PUT | `/meetings/:id` | Yes | Update title, description |
| DELETE | `/meetings/:id` | Yes | Delete meeting |
| POST | `/meetings/:id/join` | Yes | Join by ID + optional password |
| GET | `/meetings/join/:code` | Yes | Join by shareable code |
| POST | `/meetings/:id/leave` | Yes | Leave meeting |
| POST | `/meetings/:id/end` | Yes | End meeting (host only, LiveKit) |
| POST | `/meetings/:id/lock` | Yes | Lock meeting (host only) |
| POST | `/meetings/:id/unlock` | Yes | Unlock meeting |
| GET | `/meetings/:id/participants` | Yes | List active participants |
| POST | `/meetings/:id/kick/:participantId` | Yes | Remove participant (host only) |
| GET | `/meetings/:id/token` | Yes | Generate LiveKit JWT token |
| GET | `/meetings/:id/invites` | Yes | List pending invites |
| POST | `/meetings/invite/:token/respond` | Yes | Accept/decline invite |
| POST | `/meetings/:id/materials` | Yes | Upload file (Cloudinary) |
| GET | `/meetings/:id/materials` | Yes | List meeting materials |
| GET | `/meetings/materials/:materialId` | Yes | Download material |
| DELETE | `/meetings/materials/:materialId` | Yes | Delete material |

### Room — `modules/room/room.routes.js`
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/rooms/active` | Yes | Active room states (cached) |
| GET | `/rooms/:id` | Yes | Room config + participant positions |
| PUT | `/rooms/:id/settings` | Yes | Update room settings |
| POST | `/rooms/:id/mute-all` | Yes | Mute all except host |

### Chat — `modules/chat/chat.routes.js`
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/chat/rooms` | Yes | List user's chat rooms |
| GET | `/chat/meeting/:meetingId` | Yes | Get/create meeting chat room |
| GET | `/chat/:chatRoomId/messages` | Yes | Paginated messages (newest first) |
| POST | `/chat/:chatRoomId/messages` | Yes | Send message (text, image, file) |
| DELETE | `/chat/messages/:messageId` | Yes | Soft delete message |

### Notification — `modules/notification/notification.routes.js`
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/notifications` | Yes | User's notifications |
| GET | `/notifications/unread-count` | Yes | Count unread |
| GET | `/notifications/preferences` | Yes | Notification preferences |
| PUT | `/notifications/preferences` | Yes | Update preferences |
| PUT | `/notifications/read-all` | Yes | Mark all as read |
| PUT | `/notifications/:id/read` | Yes | Mark one as read |
| DELETE | `/notifications/:id` | Yes | Delete notification |

### Recording — `modules/recording/recording.routes.js`
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/recordings/webhook/complete` | No* | LiveKit callback (internal) |
| GET | `/recordings` | Yes | List user's recordings |
| GET | `/recordings/:id` | Yes | Recording metadata |
| GET | `/recordings/:id/download` | Yes | Pre-signed S3 URL |
| DELETE | `/recordings/:id` | Yes | Delete recording |
| POST | `/recordings/meeting/:meetingId/start` | Yes | Start recording |
| POST | `/recordings/meeting/:meetingId/stop` | Yes | Stop recording |

### Analytics — `modules/analytics/analytics.routes.js`
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/analytics/dashboard` | Yes | Aggregate user stats |
| GET | `/analytics/usage` | Yes | Usage over time |
| GET | `/analytics/meeting/:meetingId` | Yes | Per-meeting analytics |

### Billing — `modules/billing/billing.routes.js`
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/billing/webhook` | No* | Stripe webhook (raw body) |
| GET | `/billing/subscription` | Yes | Current subscription |
| POST | `/billing/checkout` | Yes | Create Stripe checkout session |
| POST | `/billing/portal` | Yes | Stripe customer portal URL |
| POST | `/billing/cancel` | Yes | Cancel subscription |

### Search — `modules/search/search.routes.js`
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/search?q=&type=` | Yes | Global search (all, users, meetings) |
| GET | `/search/users?q=` | Yes | Search users by name/email |
| GET | `/search/meetings?q=` | Yes | Search meetings by title |

### Legal — `modules/legal/legal.routes.js`
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/legal/terms` | No | Terms of Service |
| GET | `/legal/privacy` | No | Privacy Policy |
| GET | `/legal/all` | No | All legal docs |

---

## Database Schema

### Enums
```
UserRole        = USER | ADMIN | MODERATOR
AuthProvider    = GOOGLE | GITHUB
DevicePlatform  = IOS | ANDROID | WEB | MACOS | WINDOWS | LINUX
MeetingType     = INSTANT | SCHEDULED | RECURRING
MeetingStatus   = SCHEDULED | LIVE | ENDED | CANCELLED
ParticipantRole = HOST | CO_HOST | ATTENDEE
InviteStatus    = PENDING | ACCEPTED | DECLINED | EXPIRED
MessageType     = TEXT | IMAGE | FILE | SYSTEM
RecordingStatus = PROCESSING | READY | FAILED
SubscriptionPlan   = FREE | PRO | ENTERPRISE
SubscriptionStatus = ACTIVE | CANCELLED | PAST_DUE | TRIALING
NotificationType   = MEETING_INVITE | MEETING_REMINDER | CHAT_MESSAGE | RECORDING_READY | SYSTEM
```

### Models & Relations
```
User ──────┬── hostedMeetings[]  (Meeting.hostId)
           ├── participants[]     (Participant.userId)
           ├── chatMembers[]      (ChatMember.userId)
           ├── messages[]         (Message.senderId)
           ├── recordings[]       (Recording.userId)
           ├── notifications[]    (Notification.userId)
           ├── subscription       (Subscription.userId, 1:1)
           ├── devices[]          (Device.userId)
           ├── accounts[]         (Account.userId)
           └── notificationPref   (NotificationPreference.userId, 1:1)

Meeting ───┬── host              (User)
           ├── participants[]     (Participant)
           ├── recordings[]       (Recording)
           ├── chatRoom           (ChatRoom.meetingId, 1:1)
           ├── invites[]          (MeetingInvite)
           └── materials[]        (MeetingMaterial)

ChatRoom ──┬── members[]         (ChatMember)
           └── messages[]         (Message)

Message ───┬── replyTo           (self-reference for threading)
           └── replies[]
```

### Key Fields

**User**: `id, firebaseUid (unique), email (unique), fullName, avatar, bio, isOnline, lastSeenAt, role, createdAt, updatedAt`

**Meeting**: `id, code (unique), title, description, hostId, type, status, scheduledAt, startedAt, endedAt, maxParticipants, isRecording, password (hashed), settings (JSON: muteOnJoin, cameraOffOnJoin, waitingRoom, autoRecord)`

**Participant**: `id, meetingId, userId, role, joinedAt, leftAt, isMuted, isCameraOff, isScreenSharing, isHandRaised` — Unique on `[meetingId, userId]`

**Subscription**: `id, userId (unique), plan, status, stripeCustomerId, stripeSubId, currentPeriodStart, currentPeriodEnd, canceledAt`

---

## Middleware Execution Order

Applied in `index.js` in this exact sequence:

```
1. Trust Proxy
2. Sentry init
3. Helmet (CSP, HSTS, X-Frame-Options)
4. CORS (whitelisted origins)
5. XSS Protection
6. Body Parser (JSON + URL-encoded, 10MB limit)
7. Compression (gzip)
8. Request ID (UUID per request)
9. Prometheus metrics collection
10. Request Logger (method, duration, IP)
11. Global Rate Limiter (100 req / 15 min per IP)
12. ── API ROUTES ──
13. Sentry error handler
14. 404 catch-all
15. Global error handler (normalizes errors, maps Prisma codes)
```

Per-route middleware (applied in route files):
```
authenticate       → Firebase token verification → attaches req.user
validateBody(schema)  → Zod validation on req.body
validateQuery(schema) → Zod validation on req.query
validateParams(schema)→ Zod validation on req.params
authLimiter        → 30 req / 15 min
meetingCreateLimiter → 10 req / 1 min
chatLimiter        → 60 req / 1 min
recordingLimiter   → 5 req / 1 min
```

---

## Authentication Flow

```
Client → Authorization: Bearer <Firebase_ID_Token>
  ↓
authenticate() middleware:
  1. Extract token from "Bearer X"
  2. admin.auth().verifyIdToken(token, checkRevoked=true)
  3. prisma.user.findUnique({ where: { firebaseUid } })
  4. Not found → 404 "Account not found"
  5. Found → req.user = user record
  ↓
Controller has req.user.id, req.user.email, etc.
```

---

## Request → Response Flow

```
Client HTTP Request
  → Nginx (TLS termination, reverse proxy)
  → Express middleware stack (security, auth, validation, rate limit)
  → Router → Controller (extracts input)
    → Service (business logic)
      → Prisma (PostgreSQL queries)
      → Redis (cache check/set)
      → Kafka (publish events)
      → WebSocket (real-time emit)
      → LiveKit (WebRTC tokens/rooms)
      → Cloudinary (file uploads)
      → BullMQ (async jobs: email, notifications)
      → Stripe (billing)
    ← Service returns result
  ← Controller sends JSON via api-response helpers
  → Logging (Pino) + Metrics (Prometheus) + Errors (Sentry)
Client HTTP Response
```

---

## Service Initialization (index.js startup)

```
1. validateEnv()        — Ensure DATABASE_URL is set
2. Sentry.init()        — Before Express middleware
3. Mount middleware      — Security → body parser → logger → rate limiter
4. Mount routes          — 11 modules at /api/v1
5. Mount error handlers  — Sentry → 404 → global
6. server.listen(PORT)
7. Parallel init:
   ├── Redis connect
   ├── Kafka producer connect (if KAFKA_BROKERS set)
   ├── BullMQ queues + workers
   ├── WebSocket (Socket.IO with Redis adapter)
   ├── AI Consumer (Kafka listener)
   ├── LiveKit verify
   ├── Stripe verify
   └── SMTP verify (non-blocking)
```

Graceful shutdown (SIGTERM/SIGINT): Server → Prisma → Redis → AI Consumer → Kafka → BullMQ

---

## Real-time (WebSocket)

**Socket.IO events** (defined in `config/constants.js` as `SocketEvents`):
```
auth:register              → socket.join(user:${userId})
meeting:join               → socket.join(meeting:${meetingId})
meeting:participant_joined → broadcast to meeting room
meeting:participant_left   → broadcast to meeting room
meeting:participant_muted  → broadcast to meeting room
chat:message_new           → broadcast to chat room
notifications:new          → emit to specific user
meeting:recording_started  → broadcast to meeting room
```

Redis adapter enables horizontal scaling across multiple Node instances.

---

## Kafka Topics

Defined in `config/constants.js` as `KafkaTopics`:
```
meeting-events    → meeting.created, meeting.started, meeting.ended, meeting.locked
chat-events       → message.sent, room.created
recording-events  → recording.started, recording.completed, recording.failed
user-events       → user.online, user.offline, user.updated
billing-events    → subscription.created, subscription.cancelled
analytics-events  → aggregated stats for dashboards
```

---

## Billing Plans

| Feature | FREE | PRO | ENTERPRISE |
|---------|------|-----|-----------|
| Max participants | 50 | 300 | 1,000 |
| Max duration | 60 min | 8 hrs | Unlimited |
| Recordings | None | Included | Included |
| Priority support | No | No | Yes |

Stripe integration: `services/billing.service.js`
Price IDs: `STRIPE_PRO_PRICE_ID`, `STRIPE_ENTERPRISE_PRICE_ID`

---

## Environment Variables

| Category | Variables |
|----------|-----------|
| App | `NODE_ENV`, `PORT`, `HOST`, `BASE_URL` |
| Security | `FRONTEND_URL`, `CORS_ORIGINS`, `TRUST_PROXY` |
| Database | `DATABASE_URL` (PostgreSQL connection string) |
| Firebase | `FIREBASE_SERVICE_ACCOUNT` (JSON string or file path) |
| LiveKit | `LIVEKIT_API_KEY`, `LIVEKIT_API_SECRET`, `LIVEKIT_HOST` |
| Redis | `REDIS_URL` or `REDIS_HOST` + `REDIS_PORT` + `REDIS_PASSWORD` |
| Kafka | `KAFKA_BROKERS`, `KAFKA_CLIENT_ID`, `KAFKA_GROUP_ID`, `KAFKA_SSL`, `KAFKA_SASL_*` |
| BullMQ | `BULLMQ_REDIS_URL` |
| AWS S3 | `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_S3_BUCKET` |
| Cloudinary | `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET` |
| Stripe | `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `STRIPE_PRO_PRICE_ID`, `STRIPE_ENTERPRISE_PRICE_ID` |
| SMTP | `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`, `SMTP_FROM` |
| Observability | `LOG_LEVEL`, `SENTRY_DSN`, `PROMETHEUS_METRICS_ENABLED` |
| TURN/STUN | `TURN_SERVER_URL`, `TURN_SERVER_USERNAME`, `TURN_SERVER_PASSWORD` |
| AI | `AI_SERVICE_URL`, `AI_INTERNAL_API_KEY` |

---

## Key Commands

```bash
# Development
make dev                    # Nodemon watch mode
make start                  # Production start

# Database
make db:generate            # Regenerate Prisma client
make db:push                # Push schema (no migration)
make db:migrate             # Create + apply migration
make db:studio              # Prisma Studio GUI

# Quality
make lint                   # ESLint check
make lint-fix               # Auto-fix
make test                   # Vitest watch
make test:run               # Vitest once (CI)

# Docker
make docker-up              # Start full local stack
make docker-rebuild         # Rebuild app container

# Kubernetes
make k8s-apply              # Deploy to cluster
```

---

## Error Handling Pattern

All errors use `AppError` class from `middlewares/errorhandler.middleware.js`:
```javascript
throw new AppError("Meeting not found", 404, "E3001");
```

Error codes follow ranges defined in `config/constants.js`:
- `E1xxx` — Auth errors
- `E2xxx` — User errors
- `E3xxx` — Meeting errors
- `E4xxx` — Chat errors
- `E5xxx` — Recording errors
- `E9xxx` — System errors

Prisma errors (P2001, P2002, etc.) are auto-mapped to HTTP status codes by `globalErrorHandler()`.

---

## Cache Strategy

TTLs defined in `config/constants.js` as `CacheTTL`:
```
USER_PROFILE  → 3600s  (1 hour)
MEETING       → 1800s  (30 min)
ROOM_STATE    → 300s   (5 min)
```

Pattern: Check Redis → miss → query PostgreSQL → cache result → return.
Invalidation: On write operations, delete the cache key.

---

## File Naming Convention

- Routes: `<module>.routes.js`
- Controllers: `<module>.controller.js`
- Services: `<module>.service.js` (module) or `<name>.service.js` (shared service)
- Validators: `<module>.validator.js`
- Middleware: `<name>.middleware.js`
- Config: `<name>.config.js`
- All ES Modules (import/export), no CommonJS
