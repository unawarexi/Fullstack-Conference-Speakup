// ============================================================================
// SpeakUp — Security Middleware
// Helmet, CORS, XSS protection
// ============================================================================

import helmet from "helmet";
import cors from "cors";
import { env } from "../config/env.config.js";

// ============================================================================
// HELMET CONFIGURATION
// ============================================================================

/**
 * Configure Helmet security headers
 * @returns {import('express').RequestHandler}
 */
export function securityHeaders() {
  if (env.DISABLE_HELMET) {
    return (req, res, next) => next();
  }

  return helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", "data:", "https:"],
        connectSrc: ["'self'", env.FRONTEND_URL],
        fontSrc: ["'self'", "https:", "data:"],
        objectSrc: ["'none'"],
        mediaSrc: ["'self'"],
        frameSrc: ["'none'"],
      },
    },
    crossOriginEmbedderPolicy: false,
    crossOriginOpenerPolicy: { policy: "same-origin-allow-popups" },
    crossOriginResourcePolicy: { policy: "cross-origin" },
    dnsPrefetchControl: { allow: false },
    frameguard: { action: "deny" },
    hsts: {
      maxAge: 31536000,
      includeSubDomains: true,
      preload: true,
    },
    ieNoOpen: true,
    noSniff: true,
    originAgentCluster: true,
    permittedCrossDomainPolicies: { permittedPolicies: "none" },
    referrerPolicy: { policy: "strict-origin-when-cross-origin" },
    xssFilter: true,
  });
}

// ============================================================================
// CORS CONFIGURATION
// ============================================================================

/**
 * Configure CORS
 * @returns {import('express').RequestHandler}
 */
export function corsConfig() {
  // Normalize origins (remove trailing slashes)
  const normalizeOrigin = (url) => (url ? url.replace(/\/$/, "") : "");

  const allowedOrigins = [
    normalizeOrigin(env.FRONTEND_URL),
    ...(env.CORS_ORIGINS || []).map(normalizeOrigin),
  ].filter(Boolean);

  return cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (mobile apps, Postman, etc.)
      if (!origin) return callback(null, true);

      if (allowedOrigins.includes(origin)) {
        callback(null, true);
      } else if (env.NODE_ENV === "development") {
        // Allow all origins in development
        callback(null, true);
      } else {
        callback(new Error("Not allowed by CORS"));
      }
    },
    credentials: true,
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: [
      "Content-Type",
      "Authorization",
      "X-Requested-With",
      "Accept",
      "Origin",
      "X-Request-ID",
    ],
    exposedHeaders: [
      "X-Request-ID",
      "X-RateLimit-Limit",
      "X-RateLimit-Remaining",
      "X-RateLimit-Reset",
      "X-Response-Time",
    ],
    maxAge: 86400, // 24 hours
  });
}

// ============================================================================
// TRUST PROXY
// ============================================================================

/**
 * Configure trust proxy for reverse proxy setups
 * @param {import('express').Application} app
 */
export function configureTrustProxy(app) {
  if (env.TRUST_PROXY) {
    app.set("trust proxy", 1);
  }
}

// ============================================================================
// XSS PROTECTION
// ============================================================================

/**
 * Simple XSS protection middleware
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
export function xssProtection(req, res, next) {
  // Basic XSS prevention for string fields
  if (req.body && typeof req.body === "object") {
    sanitizeObject(req.body);
  }
  if (req.query && typeof req.query === "object") {
    sanitizeObject(req.query);
  }
  next();
}

/**
 * Sanitize object by escaping HTML entities
 * @param {Record<string, any>} obj
 */
function sanitizeObject(obj) {
  for (const key in obj) {
    if (typeof obj[key] === "string") {
      obj[key] = obj[key]
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#x27;")
        .replace(/\//g, "&#x2F;");
    } else if (typeof obj[key] === "object" && obj[key] !== null) {
      sanitizeObject(obj[key]);
    }
  }
}

// ============================================================================
// NO CACHE FOR API
// ============================================================================

/**
 * Disable caching for API responses
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
export function noCache(req, res, next) {
  res.set(
    "Cache-Control",
    "no-store, no-cache, must-revalidate, proxy-revalidate",
  );
  res.set("Pragma", "no-cache");
  res.set("Expires", "0");
  res.set("Surrogate-Control", "no-store");
  next();
}

export default {
  securityHeaders,
  corsConfig,
  configureTrustProxy,
  xssProtection,
  noCache,
};