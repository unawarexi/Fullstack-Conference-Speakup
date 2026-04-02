// ============================================================================
// SpeakUp — Middleware Barrel Export
// ============================================================================

export { authenticate, optionalAuth, requireRole } from "./auth.middleware.js";
export { AppError, badRequest, unauthorized, forbidden, notFound, conflict, internalError, tooManyRequests, notFoundHandler, globalErrorHandler } from "./errorhandler.middleware.js";
export { multerErrorHandler } from "./helper.middleware.js";
export { apiLimiter, authLimiter, meetingCreateLimiter, meetingJoinLimiter, chatMessageLimiter, recordingLimiter, uploadLimiter, billingLimiter, redisRateLimiter } from "./ratelimit.middleware.js";
export { requestId, requestLogger, responseTime } from "./request-logger.middleware.js";
export { securityHeaders, corsConfig, configureTrustProxy, xssProtection, noCache } from "./security.middleware.js";
