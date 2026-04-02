
// ============================================================================
// SpeakUp — Request Logger Middleware
// Structured logging with request ID, timing
// ============================================================================

import { Headers } from "../config/constants.js";
import { createLogger } from "../logs/logger.js";

const log = createLogger("HTTP");

// ============================================================================
// REQUEST ID MIDDLEWARE
// ============================================================================

export function requestId(req, res, next) {
  const existingId = req.headers[Headers.REQUEST_ID];
  req.requestId = existingId || crypto.randomUUID();
  res.set(Headers.REQUEST_ID, req.requestId);
  next();
}

// ============================================================================
// REQUEST LOGGER MIDDLEWARE
// ============================================================================

export function requestLogger(req, res, next) {
  const startTime = Date.now();

  res.on("finish", () => {
    const duration = Date.now() - startTime;

    if (req.originalUrl === "/health" || req.originalUrl === "/metrics") return;

    const logData = {
      requestId: req.requestId,
      method: req.method,
      url: req.originalUrl,
      statusCode: res.statusCode,
      duration: `${duration}ms`,
      ip: req.ip || req.headers["x-forwarded-for"],
      userAgent: req.headers["user-agent"],
    };

    if (req.user) logData.userId = req.user.id;

    if (res.statusCode >= 500) {
      log.error(`${req.method} ${req.originalUrl} ${res.statusCode}`, logData);
    } else if (res.statusCode >= 400) {
      log.warn(`${req.method} ${req.originalUrl} ${res.statusCode}`, logData);
    } else {
      log.http(`${req.method} ${req.originalUrl} ${res.statusCode}`, logData);
    }
  });

  next();
}

// ============================================================================
// RESPONSE TIME HEADER
// ============================================================================

export function responseTime(req, res, next) {
  const startTime = process.hrtime();

  const originalWriteHead = res.writeHead.bind(res);
  res.writeHead = function (statusCode, ...args) {
    const [seconds, nanoseconds] = process.hrtime(startTime);
    const duration = (seconds * 1000 + nanoseconds / 1e6).toFixed(2);
    res.setHeader("X-Response-Time", `${duration}ms`);
    return originalWriteHead(statusCode, ...args);
  };

  next();
}

export default { requestId, requestLogger, responseTime };
