// ============================================================================
// SpeakUp — Prometheus Metrics
// HTTP, meeting, chat, recording, WebSocket, system metrics
// ============================================================================

import client from "prom-client";

const { Counter, Histogram, Gauge, Summary, Registry, collectDefaultMetrics } = client;

// ============================================================================
// REGISTRY
// ============================================================================

const register = new Registry();

collectDefaultMetrics({
  register,
  prefix: "speakup_",
  gcDurationBuckets: [0.001, 0.01, 0.1, 1, 2, 5],
});

// ============================================================================
// HTTP METRICS
// ============================================================================

const httpRequestDuration = new Histogram({
  name: "speakup_http_request_duration_seconds",
  help: "Duration of HTTP requests in seconds",
  labelNames: ["method", "route", "status_code"],
  buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
  registers: [register],
});

const httpRequestsTotal = new Counter({
  name: "speakup_http_requests_total",
  help: "Total number of HTTP requests",
  labelNames: ["method", "route", "status_code"],
  registers: [register],
});

const httpActiveRequests = new Gauge({
  name: "speakup_http_active_requests",
  help: "Number of currently active HTTP requests",
  registers: [register],
});

const httpRequestSize = new Summary({
  name: "speakup_http_request_size_bytes",
  help: "Size of HTTP request bodies",
  labelNames: ["method", "route"],
  registers: [register],
});

const httpResponseSize = new Summary({
  name: "speakup_http_response_size_bytes",
  help: "Size of HTTP response bodies",
  labelNames: ["method", "route"],
  registers: [register],
});

// ============================================================================
// MEETING METRICS
// ============================================================================

export const meetingMetrics = {
  created: new Counter({
    name: "speakup_meetings_created_total",
    help: "Total meetings created",
    labelNames: ["type"],
    registers: [register],
  }),
  ended: new Counter({
    name: "speakup_meetings_ended_total",
    help: "Total meetings ended",
    registers: [register],
  }),
  active: new Gauge({
    name: "speakup_meetings_active",
    help: "Currently active meetings",
    registers: [register],
  }),
  duration: new Histogram({
    name: "speakup_meeting_duration_seconds",
    help: "Duration of meetings in seconds",
    buckets: [60, 300, 900, 1800, 3600, 7200, 14400],
    registers: [register],
  }),
  participants: new Histogram({
    name: "speakup_meeting_participants_count",
    help: "Number of participants per meeting",
    buckets: [1, 2, 5, 10, 25, 50, 100, 250, 500],
    registers: [register],
  }),
};

// ============================================================================
// CHAT METRICS
// ============================================================================

export const chatMetrics = {
  messagesSent: new Counter({
    name: "speakup_chat_messages_sent_total",
    help: "Total chat messages sent",
    labelNames: ["type"],
    registers: [register],
  }),
  activeRooms: new Gauge({
    name: "speakup_chat_active_rooms",
    help: "Currently active chat rooms",
    registers: [register],
  }),
};

// ============================================================================
// RECORDING METRICS
// ============================================================================

export const recordingMetrics = {
  started: new Counter({
    name: "speakup_recordings_started_total",
    help: "Total recordings started",
    registers: [register],
  }),
  completed: new Counter({
    name: "speakup_recordings_completed_total",
    help: "Total recordings completed",
    registers: [register],
  }),
  failed: new Counter({
    name: "speakup_recordings_failed_total",
    help: "Total recordings failed",
    registers: [register],
  }),
  duration: new Histogram({
    name: "speakup_recording_duration_seconds",
    help: "Duration of recordings in seconds",
    buckets: [60, 300, 900, 1800, 3600, 7200],
    registers: [register],
  }),
};

// ============================================================================
// WEBSOCKET METRICS
// ============================================================================

export const wsMetrics = {
  connections: new Gauge({
    name: "speakup_ws_connections",
    help: "Active WebSocket connections",
    registers: [register],
  }),
  messagesIn: new Counter({
    name: "speakup_ws_messages_in_total",
    help: "Total WebSocket messages received",
    registers: [register],
  }),
  messagesOut: new Counter({
    name: "speakup_ws_messages_out_total",
    help: "Total WebSocket messages sent",
    registers: [register],
  }),
};

// ============================================================================
// AUTH METRICS
// ============================================================================

export const authMetrics = {
  signIns: new Counter({
    name: "speakup_auth_signins_total",
    help: "Total sign-ins",
    labelNames: ["provider"],
    registers: [register],
  }),
  failures: new Counter({
    name: "speakup_auth_failures_total",
    help: "Total auth failures",
    labelNames: ["reason"],
    registers: [register],
  }),
};

// ============================================================================
// ERROR METRICS
// ============================================================================

export const errorMetrics = {
  total: new Counter({
    name: "speakup_errors_total",
    help: "Total application errors",
    labelNames: ["type", "code"],
    registers: [register],
  }),
  unhandledRejections: new Counter({
    name: "speakup_unhandled_rejections_total",
    help: "Total unhandled promise rejections",
    registers: [register],
  }),
};

// ============================================================================
// DATABASE METRICS
// ============================================================================

export const dbMetrics = {
  queryDuration: new Histogram({
    name: "speakup_db_query_duration_seconds",
    help: "Database query duration in seconds",
    labelNames: ["operation", "model"],
    buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1, 5],
    registers: [register],
  }),
  queryErrors: new Counter({
    name: "speakup_db_query_errors_total",
    help: "Total database query errors",
    labelNames: ["operation", "model"],
    registers: [register],
  }),
};

// ============================================================================
// MIDDLEWARE — Record HTTP metrics
// ============================================================================

function normalizeRoute(path) {
  return path
    .replace(/\/[a-f0-9-]{36}/gi, "/:uuid")
    .replace(/\/\d+/g, "/:id")
    .replace(/\?.*$/, "");
}

export function metricsMiddleware(req, res, next) {
  if (req.path === "/metrics") return next();

  const start = process.hrtime.bigint();
  httpActiveRequests.inc();

  const contentLength = req.headers["content-length"];
  if (contentLength) {
    const route = normalizeRoute(req.route?.path || req.path);
    httpRequestSize.observe({ method: req.method, route }, parseInt(contentLength));
  }

  res.on("finish", () => {
    const durationNs = Number(process.hrtime.bigint() - start);
    const durationS = durationNs / 1e9;
    const route = normalizeRoute(req.route?.path || req.path);
    const statusCode = String(res.statusCode);

    httpRequestDuration.observe({ method: req.method, route, status_code: statusCode }, durationS);
    httpRequestsTotal.inc({ method: req.method, route, status_code: statusCode });
    httpActiveRequests.dec();

    const resContentLength = res.getHeader("content-length");
    if (resContentLength) {
      httpResponseSize.observe({ method: req.method, route }, Number(resContentLength));
    }
  });

  next();
}

// ============================================================================
// /metrics ENDPOINT
// ============================================================================

export async function metricsEndpoint(_req, res) {
  try {
    res.set("Content-Type", register.contentType);
    const metrics = await register.metrics();
    res.end(metrics);
  } catch {
    res.status(500).end("Error collecting metrics");
  }
}

// ============================================================================
// EXPORTS
// ============================================================================

export { register, client };
export default {
  register,
  metricsMiddleware,
  metricsEndpoint,
  meetingMetrics,
  chatMetrics,
  recordingMetrics,
  wsMetrics,
  authMetrics,
  errorMetrics,
  dbMetrics,
};