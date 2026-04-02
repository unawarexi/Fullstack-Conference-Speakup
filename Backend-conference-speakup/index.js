
// ============================================================================
// SPEAKUP — MAIN ENTRY POINT
// Video conferencing platform backend
// ============================================================================

import express from "express";
import http from "http";
import compression from "compression";

// Configuration
import { env, validateEnv, isProduction } from "./config/env.config.js";
import { HttpStatus } from "./config/constants.js";
import { prisma, disconnectPrisma } from "./config/prisma.js";
import logger, { createLogger } from "./logs/logger.js";

// Observability
import { initializeSentry, setupSentryExpress } from "./logs/sentry.logs.js";
import { metricsMiddleware, metricsEndpoint } from "./logs/prometheus.logs.js";
import { healthCheckEndpoint, livenessProbe, readinessProbe } from "./logs/grafana.logs.js";

// Middleware
import {
  securityHeaders,
  corsConfig,
  configureTrustProxy,
  xssProtection,
} from "./middlewares/security.middleware.js";
import { requestId, requestLogger } from "./middlewares/request-logger.middleware.js";
import { globalErrorHandler } from "./middlewares/errorhandler.middleware.js";
import { apiLimiter } from "./middlewares/ratelimit.middleware.js";

// Services
import { initRedis, disconnectRedis } from "./services/redis.service.js";
import { initKafka, disconnectKafka } from "./services/kafka.service.js";
import { initQueues, disconnectBullMQ } from "./services/bullmq.service.js";
import { initWebSocket, disconnectWebSocket } from "./services/websocket.service.js";
import { verifyMailer } from "./services/mailer.service.js";
import { initLiveKit } from "./services/livekit.service.js";
import { initBilling } from "./services/billing.service.js";
import { startWorkers } from "./services/workers.js";

// Module routes
import authRoutes from "./modules/auth/auth.routes.js";
import userRoutes from "./modules/user/user.routes.js";
import meetingRoutes from "./modules/meeting/meeting.routes.js";
import roomRoutes from "./modules/room/room.routes.js";
import chatRoutes from "./modules/chat/chat.routes.js";
import notificationRoutes from "./modules/notification/notification.routes.js";
import recordingRoutes from "./modules/recording/recording.routes.js";
import analyticsRoutes from "./modules/analytics/analytics.routes.js";
import billingRoutes from "./modules/billing/billing.routes.js";
import searchRoutes from "./modules/search/search.routes.js";

const log = createLogger("Server");

// ============================================================================
// EXPRESS APPLICATION SETUP
// ============================================================================

const app = express();
const server = http.createServer(app);

// ============================================================================
// PRE-ROUTE MIDDLEWARE
// ============================================================================

// Trust proxy (nginx / load balancer)
configureTrustProxy(app);

// Sentry must be initialized before other middleware
initializeSentry();

// Security
app.use(securityHeaders);
app.use(corsConfig);
app.use(xssProtection);

// Body parsing
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Compression
app.use(compression());

// Request tracking
app.use(requestId);

// Prometheus metrics collection
app.use(metricsMiddleware);

// Request logging (skip in tests)
if (env.NODE_ENV !== "test") {
  app.use(requestLogger);
}

// Global rate limiter
app.use(apiLimiter);

// ============================================================================
// HEALTH & OBSERVABILITY ENDPOINTS
// ============================================================================

app.get("/health", livenessProbe);
app.get("/health/ready", readinessProbe);
app.get("/health/detailed", healthCheckEndpoint);
app.get("/metrics", metricsEndpoint);

// ============================================================================
// API ROUTES (v1)
// ============================================================================

const API = "/api/v1";

app.use(`${API}/auth`, authRoutes);
app.use(`${API}/users`, userRoutes);
app.use(`${API}/meetings`, meetingRoutes);
app.use(`${API}/rooms`, roomRoutes);
app.use(`${API}/chat`, chatRoutes);
app.use(`${API}/notifications`, notificationRoutes);
app.use(`${API}/recordings`, recordingRoutes);
app.use(`${API}/analytics`, analyticsRoutes);
app.use(`${API}/billing`, billingRoutes);
app.use(`${API}/search`, searchRoutes);

// API info
app.get(API, (_req, res) => {
  res.status(HttpStatus.OK).json({
    name: "SpeakUp API",
    version: "1.0.0",
    description: "Video Conferencing Platform API",
    endpoints: {
      auth: `${API}/auth`,
      users: `${API}/users`,
      meetings: `${API}/meetings`,
      rooms: `${API}/rooms`,
      chat: `${API}/chat`,
      notifications: `${API}/notifications`,
      recordings: `${API}/recordings`,
      analytics: `${API}/analytics`,
      billing: `${API}/billing`,
      search: `${API}/search`,
    },
    health: "/health",
    metrics: "/metrics",
  });
});

// ============================================================================
// SENTRY ERROR HANDLER (must be after routes, before custom error handler)
// ============================================================================

setupSentryExpress(app);

// ============================================================================
// 404 + GLOBAL ERROR HANDLER
// ============================================================================

app.use((_req, res) => {
  res.status(HttpStatus.NOT_FOUND).json({
    success: false,
    message: `Route not found`,
  });
});

app.use(globalErrorHandler);

// ============================================================================
// SERVER STARTUP
// ============================================================================

async function startServer() {
  try {
    validateEnv();

    // Verify database connection
    await prisma.$queryRaw`SELECT 1`;
    log.info("PostgreSQL connected");

    // Connect services
    await initRedis();
    log.info("Redis connected");

    if (env.KAFKA_BROKERS) {
      await initKafka();
      log.info("Kafka connected");
    }

    // Initialize queues & workers
    initQueues();
    startWorkers();
    log.info("BullMQ queues & workers initialized");

    // Initialize WebSocket with Socket.IO
    initWebSocket(server);
    log.info("WebSocket initialized");

    // Initialize third-party services
    initLiveKit();
    initBilling();
    log.info("LiveKit & Stripe initialized");

    // Verify SMTP (non-blocking)
    verifyMailer().catch((err) => log.warn("SMTP verification failed", { error: err }));

    // Start HTTP server
    const PORT = env.PORT || 5000;

    server.listen(PORT, () => {
      log.info("=".repeat(56));
      log.info("  SPEAKUP BACKEND SERVER");
      log.info("=".repeat(56));
      log.info(`  Environment : ${env.NODE_ENV}`);
      log.info(`  Port        : ${PORT}`);
      log.info(`  API         : /api/v1`);
      log.info(`  Health      : http://localhost:${PORT}/health`);
      log.info(`  Metrics     : http://localhost:${PORT}/metrics`);
      log.info("=".repeat(56));
    });
  } catch (error) {
    log.error("Failed to start server", { error });
    process.exit(1);
  }
}

// ============================================================================
// GRACEFUL SHUTDOWN
// ============================================================================

async function gracefulShutdown(signal) {
  log.info(`${signal} received — shutting down...`);

  server.close(() => log.info("HTTP server closed"));

  try { await disconnectPrisma(); log.info("Database disconnected"); } catch {}
  try { await disconnectRedis(); log.info("Redis disconnected"); } catch {}
  try { await disconnectKafka(); log.info("Kafka disconnected"); } catch {}
  try { await disconnectBullMQ(); log.info("BullMQ disconnected"); } catch {}
  try { await disconnectWebSocket(); log.info("WebSocket disconnected"); } catch {}

  log.info("Graceful shutdown completed");
  process.exit(0);
}

process.on("SIGTERM", () => gracefulShutdown("SIGTERM"));
process.on("SIGINT", () => gracefulShutdown("SIGINT"));

process.on("uncaughtException", (error) => {
  console.error("Uncaught Exception:", error);
  gracefulShutdown("uncaughtException");
});

process.on("unhandledRejection", (reason, promise) => {
  console.error("Unhandled Rejection at:", promise, "reason:", reason);
});

// ============================================================================
// START
// ============================================================================

startServer();

export { app, server };
