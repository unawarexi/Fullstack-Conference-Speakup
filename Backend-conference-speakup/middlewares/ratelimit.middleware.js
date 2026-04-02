// ============================================================================
// SpeakUp — Rate Limiter Middleware
// Production-grade rate limiting with Redis support
// ============================================================================

import rateLimit from "express-rate-limit";
import { RateLimits, HttpStatus, ErrorCodes } from "../config/constants.js";
import { checkRateLimit, getIsConnected } from "../services/redis.service.js";

// ============================================================================
// RATE LIMITER FACTORY
// ============================================================================

export function createRateLimiter({ windowMs, max, message }) {
  return rateLimit({
    windowMs,
    max,
    standardHeaders: true,
    legacyHeaders: false,
    message: {
      success: false,
      error: {
        code: ErrorCodes.RATE_LIMIT_EXCEEDED,
        message: message || "Too many requests, please try again later.",
      },
    },
    skip: () => process.env.NODE_ENV === "test",
    handler: (_req, res) => {
      res.status(HttpStatus.TOO_MANY_REQUESTS).json({
        success: false,
        error: {
          code: ErrorCodes.RATE_LIMIT_EXCEEDED,
          message: message || "Too many requests, please try again later.",
        },
      });
    },
  });
}

// ============================================================================
// PRESET RATE LIMITERS
// ============================================================================

export const apiLimiter = createRateLimiter({
  ...RateLimits.API,
  message: "Too many API requests, please try again later.",
});

export const authLimiter = createRateLimiter({
  ...RateLimits.AUTH,
  message: "Too many authentication attempts, please try again later.",
});

export const meetingCreateLimiter = createRateLimiter({
  ...RateLimits.MEETING_CREATE,
  message: "Too many meeting requests. Please wait before creating another.",
});

export const meetingJoinLimiter = createRateLimiter({
  ...RateLimits.MEETING_JOIN,
  message: "Too many join attempts. Please slow down.",
});

export const chatMessageLimiter = createRateLimiter({
  ...RateLimits.CHAT_MESSAGE,
  message: "Too many messages. Please slow down.",
});

export const recordingLimiter = createRateLimiter({
  ...RateLimits.RECORDING,
  message: "Too many recording requests. Please try again later.",
});

export const uploadLimiter = createRateLimiter({
  ...RateLimits.UPLOAD,
  message: "Too many file uploads. Please try again later.",
});

export const billingLimiter = createRateLimiter({
  ...RateLimits.BILLING,
  message: "Too many billing requests. Please try again shortly.",
});

// ============================================================================
// REDIS-BACKED RATE LIMITER (Custom)
// ============================================================================

export function redisRateLimiter({ limit, windowMs, keyPrefix, message }) {
  return async (req, res, next) => {
    try {
      if (!getIsConnected()) return next(); // Fail open

      const userId = req.user?.id;
      const ip = req.ip || req.headers["x-forwarded-for"] || "unknown";
      const identifier = `${keyPrefix}:${userId || ip}`;

      const result = await checkRateLimit(identifier, limit, windowMs);

      res.set("X-RateLimit-Limit", String(limit));
      res.set("X-RateLimit-Remaining", String(result.remaining));

      if (!result.allowed) {
        return res.status(HttpStatus.TOO_MANY_REQUESTS).json({
          success: false,
          error: {
            code: ErrorCodes.RATE_LIMIT_EXCEEDED,
            message: message || "Rate limit exceeded. Please try again later.",
          },
        });
      }

      next();
    } catch {
      next(); // Fail open
    }
  };
}

export default {
  createRateLimiter,
  apiLimiter,
  authLimiter,
  meetingCreateLimiter,
  meetingJoinLimiter,
  chatMessageLimiter,
  recordingLimiter,
  uploadLimiter,
  billingLimiter,
  redisRateLimiter,
};