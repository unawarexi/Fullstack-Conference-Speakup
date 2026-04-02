
// ============================================================================
// SpeakUp — Error Handler Middleware
// Centralized error handling with Prisma + Sentry integration
// ============================================================================

import { HttpStatus, ErrorCodes } from "../config/constants.js";
import { isDevelopment } from "../config/env.config.js";
import { captureException } from "../logs/sentry.logs.js";
import { createLogger } from "../logs/logger.js";
import { errorMetrics } from "../logs/prometheus.logs.js";

const log = createLogger("ErrorHandler");

// ============================================================================
// CUSTOM ERROR CLASS
// ============================================================================

export class AppError extends Error {
  constructor(message, statusCode = 500, code = ErrorCodes.INTERNAL_ERROR, details = null) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
    this.status = `${statusCode}`.startsWith("4") ? "fail" : "error";
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

// ============================================================================
// ERROR FACTORY FUNCTIONS
// ============================================================================

export function badRequest(message, details) {
  return new AppError(message, HttpStatus.BAD_REQUEST, ErrorCodes.VALIDATION_ERROR, details);
}

export function unauthorized(message = "Unauthorized") {
  return new AppError(message, HttpStatus.UNAUTHORIZED, ErrorCodes.UNAUTHORIZED);
}

export function forbidden(message = "Forbidden") {
  return new AppError(message, HttpStatus.FORBIDDEN, ErrorCodes.FORBIDDEN);
}

export function notFound(resource = "Resource") {
  return new AppError(`${resource} not found`, HttpStatus.NOT_FOUND, ErrorCodes.USER_NOT_FOUND);
}

export function conflict(message) {
  return new AppError(message, HttpStatus.CONFLICT, ErrorCodes.USER_ALREADY_EXISTS);
}

export function internalError(message = "Internal server error") {
  return new AppError(message, HttpStatus.INTERNAL_SERVER_ERROR, ErrorCodes.INTERNAL_ERROR);
}

export function tooManyRequests(message = "Too many requests") {
  return new AppError(message, HttpStatus.TOO_MANY_REQUESTS, ErrorCodes.RATE_LIMIT_EXCEEDED);
}

// ============================================================================
// 404 HANDLER
// ============================================================================

export function notFoundHandler(req, _res, next) {
  next(new AppError(`Cannot find ${req.method} ${req.originalUrl}`, HttpStatus.NOT_FOUND));
}

// ============================================================================
// GLOBAL ERROR HANDLER
// ============================================================================

export function globalErrorHandler(err, req, res, _next) {
  let statusCode = err.statusCode || HttpStatus.INTERNAL_SERVER_ERROR;
  let message = err.message || "Something went wrong";
  let code = err.code || ErrorCodes.INTERNAL_ERROR;

  // --- Prisma Error Handling ---
  if (err.constructor?.name === "PrismaClientKnownRequestError") {
    switch (err.code) {
      case "P2002": {
        statusCode = HttpStatus.CONFLICT;
        code = ErrorCodes.USER_ALREADY_EXISTS;
        const field = err.meta?.target?.[0] || "field";
        message = `A record with this ${field} already exists`;
        break;
      }
      case "P2025":
        statusCode = HttpStatus.NOT_FOUND;
        code = ErrorCodes.USER_NOT_FOUND;
        message = "Record not found";
        break;
      case "P2003":
        statusCode = HttpStatus.BAD_REQUEST;
        code = ErrorCodes.VALIDATION_ERROR;
        message = "Related record not found";
        break;
      default:
        statusCode = HttpStatus.BAD_REQUEST;
        code = ErrorCodes.INVALID_INPUT;
        message = "Database operation failed";
    }
  } else if (err.constructor?.name === "PrismaClientValidationError") {
    statusCode = HttpStatus.BAD_REQUEST;
    code = ErrorCodes.VALIDATION_ERROR;
    message = "Invalid data provided";
  }

  // --- Prometheus Error Metric ---
  try {
    errorMetrics.total.inc({ type: err.constructor?.name || "Error", code });
  } catch { /* metrics may not be initialized */ }

  // --- Log Error ---
  const requestId = req.requestId;
  const userId = req.user?.id;

  if (statusCode >= 500) {
    log.error(message, {
      error: err,
      requestId,
      userId,
      method: req.method,
      url: req.originalUrl,
      statusCode,
    });

    try {
      captureException(err, {
        userId,
        action: `${req.method} ${req.originalUrl}`,
        extra: { requestId, statusCode, code },
      });
    } catch { /* sentry may not be initialized */ }
  } else {
    log.warn(message, { requestId, userId, method: req.method, url: req.originalUrl, statusCode, code });
  }

  // --- Response ---
  const response = {
    success: false,
    error: { code, message },
  };

  if (isDevelopment()) {
    response.error.stack = err.stack;
    if (err.details) response.error.details = err.details;
  }

  res.status(statusCode).json(response);
}

export default {
  AppError,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  internalError,
  tooManyRequests,
  notFoundHandler,
  globalErrorHandler,
};
