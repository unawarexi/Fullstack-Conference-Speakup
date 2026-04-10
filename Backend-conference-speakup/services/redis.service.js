// ============================================================================
// SpeakUp — Redis Service
// Singleton ioredis client with pub/sub, caching, and health checks
// ============================================================================

import Redis from "ioredis";
import { env } from "../config/env.config.js";
import { createLogger } from "../logs/logger.js";
import { createRetryStrategy } from "../core/network/retry.js";

const log = createLogger("Redis");

let client = null;
let subscriber = null;
let isConnected = false;

// ============================================================================
// CONNECTION
// ============================================================================

function createRedisClient(name = "main") {
  const commonOptions = {
    maxRetriesPerRequest: 3,
    retryStrategy: createRetryStrategy({ maxRetries: 10, baseDelay: 200, maxDelay: 5000 }),
    lazyConnect: true,
    enableReadyCheck: true,
  };

  const redis = env.REDIS_URL
    ? new Redis(env.REDIS_URL, commonOptions)
    : new Redis({
        host: env.REDIS_HOST,
        port: env.REDIS_PORT,
        password: env.REDIS_PASSWORD || undefined,
        db: env.REDIS_DB,
        ...commonOptions,
      });

  redis.on("connect", () => log.info(`Redis [${name}] connected`));
  redis.on("ready", () => log.success(`Redis [${name}] ready`));
  redis.on("error", (err) => log.error(`Redis [${name}] error`, { error: err }));
  redis.on("close", () => {
    log.warn(`Redis [${name}] connection closed`);
    if (name === "main") isConnected = false;
  });

  return redis;
}

export async function initRedis() {
  if (client) return client;

  client = createRedisClient("main");
  subscriber = createRedisClient("subscriber");

  await Promise.all([client.connect(), subscriber.connect()]);
  isConnected = true;

  log.success("Redis initialized (main + subscriber)");
  return client;
}

// ============================================================================
// GETTERS
// ============================================================================

export function getRedisClient() {
  if (!client) throw new Error("Redis not initialized. Call initRedis() first.");
  return client;
}

export function getRedisSubscriber() {
  if (!subscriber) throw new Error("Redis subscriber not initialized.");
  return subscriber;
}

export function getIsConnected() {
  return isConnected;
}

// ============================================================================
// CACHE HELPERS
// ============================================================================

export async function getCache(key) {
  const data = await client.get(key);
  return data ? JSON.parse(data) : null;
}

export async function setCache(key, value, ttlSeconds) {
  const serialized = JSON.stringify(value);
  if (ttlSeconds) {
    await client.set(key, serialized, "EX", ttlSeconds);
  } else {
    await client.set(key, serialized);
  }
}

export async function deleteCache(key) {
  await client.del(key);
}

export async function deleteCachePattern(pattern) {
  const keys = await client.keys(pattern);
  if (keys.length > 0) {
    await client.del(...keys);
  }
}

// ============================================================================
// RATE LIMIT HELPER
// ============================================================================

export async function checkRateLimit(identifier, limit, windowMs) {
  const key = `ratelimit:${identifier}`;
  const current = await client.incr(key);

  if (current === 1) {
    await client.pexpire(key, windowMs);
  }

  return {
    allowed: current <= limit,
    remaining: Math.max(0, limit - current),
    current,
  };
}

// ============================================================================
// HEALTH CHECK
// ============================================================================

export async function healthCheck() {
  const start = Date.now();
  await client.ping();
  const latencyMs = Date.now() - start;

  const info = await client.info("memory");
  const memoryMatch = info.match(/used_memory_human:(\S+)/);
  const clientsInfo = await client.info("clients");
  const clientsMatch = clientsInfo.match(/connected_clients:(\d+)/);

  return {
    connected: isConnected,
    latencyMs,
    memoryUsedMB: memoryMatch?.[1] || "unknown",
    connectedClients: clientsMatch ? parseInt(clientsMatch[1]) : 0,
  };
}

// ============================================================================
// DISCONNECT
// ============================================================================

export async function disconnectRedis() {
  if (client) await client.quit();
  if (subscriber) await subscriber.quit();
  isConnected = false;
  log.info("Redis disconnected");
}

export default {
  initRedis,
  getRedisClient,
  getRedisSubscriber,
  getIsConnected,
  getCache,
  setCache,
  deleteCache,
  deleteCachePattern,
  checkRateLimit,
  healthCheck,
  disconnectRedis,
};
