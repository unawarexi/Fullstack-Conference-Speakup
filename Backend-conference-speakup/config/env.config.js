// ============================================================================
// SpeakUp — Environment Configuration
// ============================================================================

import dotenv from "dotenv";
import path from "path";

dotenv.config({ path: path.resolve(process.cwd(), ".env") });

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

function getEnvString(key, defaultValue) {
  const value = process.env[key];
  if (value === undefined) {
    if (defaultValue !== undefined) return defaultValue;
    console.warn(`[Config] Missing environment variable: ${key}`);
    return "";
  }
  return value;
}

function getEnvNumber(key, defaultValue) {
  const value = process.env[key];
  if (value === undefined) {
    if (defaultValue !== undefined) return defaultValue;
    console.warn(`[Config] Missing environment variable: ${key}`);
    return 0;
  }
  const parsed = parseInt(value, 10);
  if (isNaN(parsed)) {
    console.warn(`[Config] Environment variable ${key} must be a number, got: ${value}`);
    return defaultValue || 0;
  }
  return parsed;
}

function getEnvBoolean(key, defaultValue = false) {
  const value = process.env[key];
  if (value === undefined) return defaultValue;
  return value === "true" || value === "1";
}

// ============================================================================
// CONFIGURATION OBJECT
// ============================================================================

export const env = {
  // --------------------------------------------------------------------------
  // App
  // --------------------------------------------------------------------------
  NODE_ENV: getEnvString("NODE_ENV", "development"),
  PORT: getEnvNumber("PORT", 3000),
  HOST: getEnvString("HOST", "0.0.0.0"),
  BASE_URL: getEnvString("BASE_URL", "http://localhost:3000"),

  // --------------------------------------------------------------------------
  // Security
  // --------------------------------------------------------------------------
  FRONTEND_URL: getEnvString("FRONTEND_URL", ""),
  CORS_ORIGINS: process.env.CORS_ORIGINS
    ? process.env.CORS_ORIGINS.split(",").map((s) => s.trim())
    : [],
  TRUST_PROXY: process.env.TRUST_PROXY === "true" || process.env.NODE_ENV === "production",
  DISABLE_HELMET: process.env.DISABLE_HELMET === "true",

  // --------------------------------------------------------------------------
  // Database (PostgreSQL via Prisma)
  // --------------------------------------------------------------------------
  DATABASE_URL: getEnvString("DATABASE_URL", ""),

  // --------------------------------------------------------------------------
  // Firebase Admin SDK
  // --------------------------------------------------------------------------
  FIREBASE_SERVICE_ACCOUNT: getEnvString("FIREBASE_SERVICE_ACCOUNT", ""),

  // --------------------------------------------------------------------------
  // LiveKit (WebRTC SFU)
  // --------------------------------------------------------------------------
  LIVEKIT_API_KEY: getEnvString("LIVEKIT_API_KEY", ""),
  LIVEKIT_API_SECRET: getEnvString("LIVEKIT_API_SECRET", ""),
  LIVEKIT_HOST: getEnvString("LIVEKIT_HOST", ""),

  // --------------------------------------------------------------------------
  // Redis
  // --------------------------------------------------------------------------
  REDIS_URL: getEnvString("REDIS_URL", ""),
  REDIS_HOST: getEnvString("REDIS_HOST", "localhost"),
  REDIS_PORT: getEnvNumber("REDIS_PORT", 6379),
  REDIS_PASSWORD: getEnvString("REDIS_PASSWORD", ""),
  REDIS_DB: getEnvNumber("REDIS_DB", 0),

  // --------------------------------------------------------------------------
  // Kafka
  // --------------------------------------------------------------------------
  KAFKA_BROKERS: getEnvString("KAFKA_BROKERS", "localhost:9092"),
  KAFKA_CLIENT_ID: getEnvString("KAFKA_CLIENT_ID", "speakup-api"),
  KAFKA_GROUP_ID: getEnvString("KAFKA_GROUP_ID", "speakup-consumer"),
  KAFKA_SSL: getEnvBoolean("KAFKA_SSL", false),
  KAFKA_SASL_USERNAME: getEnvString("KAFKA_SASL_USERNAME", ""),
  KAFKA_SASL_PASSWORD: getEnvString("KAFKA_SASL_PASSWORD", ""),

  // --------------------------------------------------------------------------
  // BullMQ
  // --------------------------------------------------------------------------
  BULLMQ_REDIS_URL: getEnvString("BULLMQ_REDIS_URL", ""),

  // --------------------------------------------------------------------------
  // AWS S3 (Recordings / Uploads)
  // --------------------------------------------------------------------------
  AWS_REGION: getEnvString("AWS_REGION", "us-east-1"),
  AWS_ACCESS_KEY_ID: getEnvString("AWS_ACCESS_KEY_ID", ""),
  AWS_SECRET_ACCESS_KEY: getEnvString("AWS_SECRET_ACCESS_KEY", ""),
  AWS_S3_BUCKET: getEnvString("AWS_S3_BUCKET", ""),

  // --------------------------------------------------------------------------
  // Cloudinary (Avatars / Images)
  // --------------------------------------------------------------------------
  CLOUDINARY_CLOUD_NAME: getEnvString("CLOUDINARY_CLOUD_NAME", ""),
  CLOUDINARY_API_KEY: getEnvString("CLOUDINARY_API_KEY", ""),
  CLOUDINARY_API_SECRET: getEnvString("CLOUDINARY_API_SECRET", ""),

  // --------------------------------------------------------------------------
  // Stripe (Billing)
  // --------------------------------------------------------------------------
  STRIPE_SECRET_KEY: getEnvString("STRIPE_SECRET_KEY", ""),
  STRIPE_WEBHOOK_SECRET: getEnvString("STRIPE_WEBHOOK_SECRET", ""),
  STRIPE_PRO_PRICE_ID: getEnvString("STRIPE_PRO_PRICE_ID", ""),
  STRIPE_ENTERPRISE_PRICE_ID: getEnvString("STRIPE_ENTERPRISE_PRICE_ID", ""),

  // --------------------------------------------------------------------------
  // SMTP / Email
  // --------------------------------------------------------------------------
  SMTP_HOST: getEnvString("SMTP_HOST", ""),
  SMTP_PORT: getEnvNumber("SMTP_PORT", 587),
  SMTP_USER: getEnvString("SMTP_USER", ""),
  SMTP_PASS: getEnvString("SMTP_PASS", ""),
  SMTP_FROM: getEnvString("SMTP_FROM", "noreply@speakup.app"),

  // --------------------------------------------------------------------------
  // Observability
  // --------------------------------------------------------------------------
  LOG_LEVEL: getEnvString("LOG_LEVEL", "info"),
  SENTRY_DSN: getEnvString("SENTRY_DSN", ""),
  PROMETHEUS_METRICS_ENABLED: getEnvBoolean("PROMETHEUS_METRICS_ENABLED", true),

  // --------------------------------------------------------------------------
  // WebRTC (TURN/STUN)
  // --------------------------------------------------------------------------
  TURN_SERVER_URL: getEnvString("TURN_SERVER_URL", ""),
  TURN_SERVER_USERNAME: getEnvString("TURN_SERVER_USERNAME", ""),
  TURN_SERVER_PASSWORD: getEnvString("TURN_SERVER_PASSWORD", ""),

  // --------------------------------------------------------------------------
  // Cloudflare
  // --------------------------------------------------------------------------
  CLOUDFLARE_ZONE_ID: getEnvString("CLOUDFLARE_ZONE_ID", ""),
  CLOUDFLARE_API_TOKEN: getEnvString("CLOUDFLARE_API_TOKEN", ""),

  // --------------------------------------------------------------------------
  // AI Service (FastAPI Intelligence Plane)
  // --------------------------------------------------------------------------
  AI_SERVICE_URL: getEnvString("AI_SERVICE_URL", "http://localhost:8000/api/v1"),
  AI_INTERNAL_API_KEY: getEnvString("AI_INTERNAL_API_KEY", ""),
};

// ============================================================================
// ENVIRONMENT CHECKS
// ============================================================================

export function isProduction() {
  return env.NODE_ENV === "production";
}

export function isDevelopment() {
  return env.NODE_ENV === "development";
}

export function isTest() {
  return env.NODE_ENV === "test";
}

export function validateEnv() {
  const required = ["DATABASE_URL"];
  const recommended = ["FIREBASE_SERVICE_ACCOUNT", "REDIS_HOST", "LIVEKIT_API_KEY"];
  const missing = required.filter((key) => !process.env[key]);
  const missingRecommended = recommended.filter((key) => !process.env[key]);

  if (missing.length > 0) {
    console.error(`[Config] Missing REQUIRED env vars: ${missing.join(", ")}`);
  }

  if (missingRecommended.length > 0 && env.NODE_ENV === "production") {
    console.warn(`[Config] Missing recommended env vars: ${missingRecommended.join(", ")}`);
  }

  return { valid: missing.length === 0, missing };
}

export default env;