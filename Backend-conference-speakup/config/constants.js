// ============================================================================
// SpeakUp — Application Constants
// ============================================================================

// ============================================================================
// HTTP STATUS CODES
// ============================================================================

export const HttpStatus = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  UNPROCESSABLE_ENTITY: 422,
  TOO_MANY_REQUESTS: 429,
  INTERNAL_SERVER_ERROR: 500,
  SERVICE_UNAVAILABLE: 503,
};

// ============================================================================
// ERROR CODES
// ============================================================================

export const ErrorCodes = {
  // Auth
  UNAUTHORIZED: "E1001",
  TOKEN_INVALID: "E1002",
  FORBIDDEN: "E1003",
  TOKEN_EXPIRED: "E1004",
  ACCOUNT_SUSPENDED: "E1005",
  ACCOUNT_DEACTIVATED: "E1006",
  FIREBASE_AUTH_FAILED: "E1007",

  // Validation
  VALIDATION_ERROR: "E2001",
  INVALID_INPUT: "E2002",
  MISSING_FIELD: "E2003",

  // Resources
  USER_NOT_FOUND: "E3001",
  USER_ALREADY_EXISTS: "E3002",
  MEETING_NOT_FOUND: "E3003",
  ROOM_NOT_FOUND: "E3004",
  RECORDING_NOT_FOUND: "E3005",
  MESSAGE_NOT_FOUND: "E3006",
  NOTIFICATION_NOT_FOUND: "E3007",
  SUBSCRIPTION_NOT_FOUND: "E3008",

  // Business Logic
  MEETING_FULL: "E4001",
  MEETING_ALREADY_ENDED: "E4002",
  MEETING_PASSWORD_REQUIRED: "E4003",
  MEETING_PASSWORD_INCORRECT: "E4004",
  NOT_MEETING_HOST: "E4005",
  ALREADY_IN_MEETING: "E4006",
  RECORDING_IN_PROGRESS: "E4007",
  RECORDING_NOT_STARTED: "E4008",
  SUBSCRIPTION_EXPIRED: "E4009",

  // Rate Limiting
  RATE_LIMIT_EXCEEDED: "E8001",

  // Server
  INTERNAL_ERROR: "E9001",
  SERVICE_UNAVAILABLE: "E9002",
};

// ============================================================================
// MEETING CONFIGURATION
// ============================================================================

export const MeetingConfig = {
  DEFAULT_MAX_PARTICIPANTS: 100,
  MAX_PARTICIPANTS_FREE: 50,
  MAX_PARTICIPANTS_PRO: 300,
  MAX_PARTICIPANTS_ENTERPRISE: 1000,
  CODE_LENGTH: 10,
  SCHEDULED_ADVANCE_MINUTES: 15,
  MAX_DURATION_FREE_MINUTES: 60,
  MAX_DURATION_PRO_MINUTES: 480,
  INACTIVITY_TIMEOUT_MINUTES: 5,
};

// ============================================================================
// RATE LIMITING
// ============================================================================

export const RateLimits = {
  API: { windowMs: 15 * 60 * 1000, max: 100 },
  AUTH: { windowMs: 15 * 60 * 1000, max: 30 },
  MEETING_CREATE: { windowMs: 60 * 1000, max: 10 },
  MEETING_JOIN: { windowMs: 60 * 1000, max: 30 },
  CHAT_MESSAGE: { windowMs: 60 * 1000, max: 60 },
  RECORDING: { windowMs: 60 * 1000, max: 5 },
  UPLOAD: { windowMs: 60 * 1000, max: 20 },
  BILLING: { windowMs: 60 * 1000, max: 10 },
  NOTIFICATION: { windowMs: 60 * 1000, max: 30 },
};

// ============================================================================
// CACHE TTL (in seconds)
// ============================================================================

export const CacheTTL = {
  USER_PROFILE: 300,       // 5 min
  MEETING_DETAILS: 30,     // 30 sec (near real-time)
  MEETING_LIST: 60,        // 1 min
  PARTICIPANTS: 10,        // 10 sec (real-time)
  ROOM_STATE: 5,           // 5 sec
  CHAT_MESSAGES: 60,       // 1 min
  NOTIFICATIONS: 120,      // 2 min
  SUBSCRIPTION: 3600,      // 1 hour
  ANALYTICS: 300,           // 5 min
  APP_SETTINGS: 3600,      // 1 hour
};

// ============================================================================
// SOCKET EVENTS
// ============================================================================

export const SocketEvents = {
  // Connection
  CONNECTION: "connection",
  DISCONNECT: "disconnect",
  ERROR: "error",

  // Room management
  JOIN_ROOM: "room:join",
  LEAVE_ROOM: "room:leave",
  ROOM_STATE: "room:state",

  // Meeting flow
  MEETING_CREATED: "meeting:created",
  MEETING_STARTED: "meeting:started",
  MEETING_ENDED: "meeting:ended",
  MEETING_UPDATED: "meeting:updated",
  MEETING_LOCKED: "meeting:locked",
  MEETING_UNLOCKED: "meeting:unlocked",

  // Participant events
  PARTICIPANT_JOINED: "participant:joined",
  PARTICIPANT_LEFT: "participant:left",
  PARTICIPANT_MUTED: "participant:muted",
  PARTICIPANT_UNMUTED: "participant:unmuted",
  PARTICIPANT_VIDEO_ON: "participant:video_on",
  PARTICIPANT_VIDEO_OFF: "participant:video_off",
  PARTICIPANT_SCREEN_SHARE_ON: "participant:screen_share_on",
  PARTICIPANT_SCREEN_SHARE_OFF: "participant:screen_share_off",
  PARTICIPANT_HAND_RAISED: "participant:hand_raised",
  PARTICIPANT_HAND_LOWERED: "participant:hand_lowered",
  PARTICIPANT_ROLE_CHANGED: "participant:role_changed",
  PARTICIPANT_KICKED: "participant:kicked",

  // Chat
  CHAT_MESSAGE: "chat:message",
  CHAT_MESSAGE_DELETED: "chat:message_deleted",
  CHAT_TYPING: "chat:typing",
  CHAT_STOP_TYPING: "chat:stop_typing",

  // Recording
  RECORDING_STARTED: "recording:started",
  RECORDING_STOPPED: "recording:stopped",
  RECORDING_READY: "recording:ready",

  // Notifications
  NOTIFICATION: "notification:received",
  NOTIFICATION_READ: "notification:read",

  // Room settings
  ROOM_SETTINGS_UPDATED: "room:settings_updated",
  ALL_MUTED: "room:all_muted",

  // Presence
  USER_ONLINE: "user:online",
  USER_OFFLINE: "user:offline",
};

// ============================================================================
// KAFKA TOPICS
// ============================================================================

export const KafkaTopics = {
  MEETING_EVENTS: "speakup.meeting.events",
  PARTICIPANT_EVENTS: "speakup.participant.events",
  CHAT_MESSAGES: "speakup.chat.messages",
  RECORDING_EVENTS: "speakup.recording.events",
  NOTIFICATION_EVENTS: "speakup.notification.events",
  ANALYTICS_EVENTS: "speakup.analytics.events",
  USER_EVENTS: "speakup.user.events",
};

// ============================================================================
// BULLMQ QUEUES
// ============================================================================

export const BullQueues = {
  EMAIL: "speakup:email",
  NOTIFICATION: "speakup:notification",
  RECORDING: "speakup:recording",
  ANALYTICS: "speakup:analytics",
  CLEANUP: "speakup:cleanup",
};

// ============================================================================
// PAGINATION DEFAULTS
// ============================================================================

export const Pagination = {
  DEFAULT_PAGE: 1,
  DEFAULT_LIMIT: 20,
  MAX_LIMIT: 100,
};

// ============================================================================
// HEADERS
// ============================================================================

export const Headers = {
  REQUEST_ID: "x-request-id",
  USER_AGENT: "user-agent",
  PLATFORM: "x-platform",
};

export default {
  HttpStatus,
  ErrorCodes,
  MeetingConfig,
  RateLimits,
  CacheTTL,
  SocketEvents,
  KafkaTopics,
  BullQueues,
  Pagination,
  Headers,
};