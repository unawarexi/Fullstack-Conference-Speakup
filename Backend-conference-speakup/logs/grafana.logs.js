
// ============================================================================
// SpeakUp — Grafana Dashboard Config & Health Endpoints
// Dashboard provisioning and detailed system health checks
// ============================================================================

import os from "os";
import { getRedisClient } from "../services/redis.service.js";
import { createLogger } from "./logger.js";

const log = createLogger("Health");

// ============================================================================
// HEALTH CHECK ENDPOINT
// ============================================================================

export async function healthCheckEndpoint(_req, res) {
  const startTime = Date.now();
  const services = {};

  // --- Redis Health ---
  try {
    const redis = getRedisClient();
    const redisStart = Date.now();
    await redis.ping();
    services.redis = { status: "up", latencyMs: Date.now() - redisStart };
  } catch {
    services.redis = { status: "down" };
  }

  // --- Database Health (Prisma) ---
  try {
    const { default: prisma } = await import("../config/prisma.js");
    const dbStart = Date.now();
    await prisma.$queryRaw`SELECT 1`;
    services.database = { status: "up", latencyMs: Date.now() - dbStart };
  } catch {
    services.database = { status: "down" };
  }

  // --- System Info ---
  const mem = process.memoryUsage();
  const system = {
    nodeVersion: process.version,
    platform: os.platform(),
    arch: os.arch(),
    cpuCount: os.cpus().length,
    memoryUsage: {
      heapUsedMB: (mem.heapUsed / 1024 / 1024).toFixed(2),
      heapTotalMB: (mem.heapTotal / 1024 / 1024).toFixed(2),
      rssMB: (mem.rss / 1024 / 1024).toFixed(2),
      externalMB: (mem.external / 1024 / 1024).toFixed(2),
      percentUsed: ((mem.heapUsed / mem.heapTotal) * 100).toFixed(1),
    },
    loadAverage: os.loadavg().map((v) => parseFloat(v.toFixed(2))),
    freeMemoryMB: (os.freemem() / 1024 / 1024).toFixed(2),
    totalMemoryMB: (os.totalmem() / 1024 / 1024).toFixed(2),
  };

  // --- Overall Status ---
  const serviceValues = Object.values(services);
  const allUp = serviceValues.every((s) => s.status === "up");
  const anyDown = serviceValues.some((s) => s.status === "down");

  const overallStatus = allUp ? "healthy" : anyDown ? "unhealthy" : "degraded";

  const healthResponse = {
    status: overallStatus,
    timestamp: new Date().toISOString(),
    uptime: Math.floor(process.uptime()),
    version: process.env.npm_package_version || "0.0.0",
    environment: process.env.NODE_ENV || "development",
    services,
    system,
  };

  const statusCode = overallStatus === "healthy" ? 200 : 503;
  res.status(statusCode).json(healthResponse);

  log.debug("Health check completed", { duration: `${Date.now() - startTime}ms`, status: overallStatus });
}

// ============================================================================
// K8S PROBES
// ============================================================================

export function livenessProbe(_req, res) {
  res.status(200).json({ status: "alive", uptime: Math.floor(process.uptime()) });
}

export async function readinessProbe(_req, res) {
  try {
    const redis = getRedisClient();
    const pong = await redis.ping();
    if (pong === "PONG") {
      res.status(200).json({ status: "ready" });
    } else {
      res.status(503).json({ status: "not ready", reason: "Redis not responding" });
    }
  } catch {
    res.status(503).json({ status: "not ready" });
  }
}

// ============================================================================
// GRAFANA DASHBOARD PROVISIONING CONFIG
// ============================================================================

export function getGrafanaDashboardConfig() {
  return {
    dashboard: {
      id: null,
      uid: "speakup-api-overview",
      title: "SpeakUp — API Overview",
      tags: ["speakup", "api", "production"],
      timezone: "browser",
      refresh: "30s",
      time: { from: "now-1h", to: "now" },
      panels: [
        // Row 1: HTTP Overview
        {
          title: "Request Rate (req/s)",
          type: "timeseries",
          gridPos: { h: 8, w: 8, x: 0, y: 0 },
          targets: [{ expr: 'rate(speakup_http_requests_total[5m])', legendFormat: "{{method}} {{route}}" }],
        },
        {
          title: "Response Time (p95)",
          type: "timeseries",
          gridPos: { h: 8, w: 8, x: 8, y: 0 },
          targets: [{ expr: 'histogram_quantile(0.95, rate(speakup_http_request_duration_seconds_bucket[5m]))', legendFormat: "p95" }],
        },
        {
          title: "Error Rate",
          type: "stat",
          gridPos: { h: 8, w: 8, x: 16, y: 0 },
          targets: [{ expr: 'rate(speakup_http_requests_total{status_code=~"5.."}[5m]) / rate(speakup_http_requests_total[5m]) * 100', legendFormat: "Error %" }],
        },
        // Row 2: Meetings
        {
          title: "Active Meetings",
          type: "gauge",
          gridPos: { h: 8, w: 6, x: 0, y: 8 },
          targets: [{ expr: "speakup_meetings_active", legendFormat: "active" }],
        },
        {
          title: "Meetings Created vs Ended",
          type: "timeseries",
          gridPos: { h: 8, w: 10, x: 6, y: 8 },
          targets: [
            { expr: 'rate(speakup_meetings_created_total[5m])', legendFormat: "Created" },
            { expr: 'rate(speakup_meetings_ended_total[5m])', legendFormat: "Ended" },
          ],
        },
        {
          title: "WebSocket Connections",
          type: "gauge",
          gridPos: { h: 8, w: 8, x: 16, y: 8 },
          targets: [{ expr: "speakup_ws_connections", legendFormat: "connections" }],
        },
        // Row 3: System
        {
          title: "Memory Usage (MB)",
          type: "timeseries",
          gridPos: { h: 8, w: 12, x: 0, y: 16 },
          targets: [
            { expr: "speakup_process_resident_memory_bytes / 1024 / 1024", legendFormat: "RSS" },
            { expr: "speakup_nodejs_heap_size_used_bytes / 1024 / 1024", legendFormat: "Heap Used" },
          ],
        },
        {
          title: "Chat Messages / min",
          type: "stat",
          gridPos: { h: 8, w: 6, x: 12, y: 16 },
          targets: [{ expr: "rate(speakup_chat_messages_sent_total[1m]) * 60", legendFormat: "msg/min" }],
        },
        {
          title: "Event Loop Lag (ms)",
          type: "timeseries",
          gridPos: { h: 8, w: 6, x: 18, y: 16 },
          targets: [{ expr: "speakup_nodejs_eventloop_lag_seconds * 1000", legendFormat: "lag" }],
        },
      ],
    },
    overwrite: true,
  };
}

export default {
  healthCheckEndpoint,
  livenessProbe,
  readinessProbe,
  getGrafanaDashboardConfig,
};
