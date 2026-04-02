// ============================================================================
// SpeakUp — Sentry Error Tracking & Performance Monitoring
// ============================================================================

import * as Sentry from "@sentry/node";
import { nodeProfilingIntegration } from "@sentry/profiling-node";
import { env, isProduction } from "../config/env.config.js";
import { createLogger } from "./logger.js";

const log = createLogger("Sentry");

// ============================================================================
// INITIALIZATION
// ============================================================================

export function initializeSentry() {
  if (!env.SENTRY_DSN) {
    log.warn("SENTRY_DSN not set — Sentry disabled");
    return;
  }

  Sentry.init({
    dsn: env.SENTRY_DSN,
    environment: env.NODE_ENV,
    release: process.env.npm_package_version || "0.0.0",
    serverName: "speakup-api",

    integrations: [
      // HTTP tracing
      Sentry.httpIntegration(),
      // Express middleware tracing
      Sentry.expressIntegration(),
      // Profiling
      nodeProfilingIntegration(),
      // Prisma integration
      Sentry.prismaIntegration(),
    ],

    // Performance sampling
    tracesSampleRate: isProduction() ? 0.2 : 1.0,
    profilesSampleRate: isProduction() ? 0.1 : 1.0,

    // Only send errors in production & staging
    enabled: env.NODE_ENV !== "test",

    // Filter out noisy errors
    beforeSend(event, hint) {
      const error = hint?.originalException;

      // Don't send 4xx client errors to Sentry
      if (error && typeof error === "object" && "statusCode" in error) {
        const statusCode = error.statusCode;
        if (statusCode >= 400 && statusCode < 500) {
          return null;
        }
      }

      return event;
    },

    // Breadcrumb filtering
    beforeBreadcrumb(breadcrumb) {
      // Filter out health check noise
      if (
        breadcrumb.category === "http" &&
        breadcrumb.data?.url?.includes("/health")
      ) {
        return null;
      }
      if (
        breadcrumb.category === "http" &&
        breadcrumb.data?.url?.includes("/metrics")
      ) {
        return null;
      }
      return breadcrumb;
    },
  });

  log.success("Sentry initialized", { environment: env.NODE_ENV });
}

// ============================================================================
// EXPRESS ERROR HANDLER (Sentry v10)
// ============================================================================

export function setupSentryExpress(app) {
  Sentry.setupExpressErrorHandler(app);
}

// ============================================================================
// HELPERS
// ============================================================================

export function captureException(error, context) {
  Sentry.withScope((scope) => {
    if (context?.userId) scope.setUser({ id: context.userId });
    if (context?.meetingId) scope.setTag("meetingId", context.meetingId);
    if (context?.roomId) scope.setTag("roomId", context.roomId);
    if (context?.action) scope.setTag("action", context.action);
    if (context?.extra) scope.setExtras(context.extra);

    Sentry.captureException(error);
  });
}

export function captureMessage(message, level = "info", tags) {
  Sentry.withScope((scope) => {
    if (tags) {
      Object.entries(tags).forEach(([k, v]) => scope.setTag(k, v));
    }
    Sentry.captureMessage(message, level);
  });
}

export function setUserContext(userId, email, role) {
  Sentry.setUser({ id: userId, email, role });
}

export function addBreadcrumb(category, message, data, level = "info") {
  Sentry.addBreadcrumb({ category, message, data, level });
}

export async function flushSentry(timeoutMs = 2000) {
  await Sentry.flush(timeoutMs);
}

export default Sentry;