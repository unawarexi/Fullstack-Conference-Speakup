// ============================================================================
// SpeakUp — Structured Logger
// JSON output in production (Grafana Loki / ELK), colored in development
// ============================================================================

import { env } from "../config/env.config.js";

// ============================================================================
// LOG LEVELS
// ============================================================================

const LOG_LEVELS = {
  error: 0,
  warn: 1,
  info: 2,
  http: 3,
  debug: 4,
};

const currentLevel = LOG_LEVELS[env.LOG_LEVEL] ?? LOG_LEVELS.info;
const isProduction = env.NODE_ENV === "production";

// ============================================================================
// COLORS (development only)
// ============================================================================

const colors = {
  reset: "\x1b[0m",
  red: "\x1b[31m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  gray: "\x1b[90m",
  green: "\x1b[32m",
  cyan: "\x1b[36m",
  magenta: "\x1b[35m",
};

const levelColors = {
  ERROR: colors.red,
  WARN: colors.yellow,
  INFO: colors.blue,
  HTTP: colors.cyan,
  DEBUG: colors.gray,
  SUCCESS: colors.green,
};

// ============================================================================
// LOGGER CLASS
// ============================================================================

class Logger {
  constructor(context = "App") {
    this.context = context;
  }

  _buildEntry(level, message, data) {
    const entry = {
      timestamp: new Date().toISOString(),
      level,
      context: this.context,
      message,
    };

    if (data) {
      if (data.requestId) entry.requestId = data.requestId;
      if (data.userId) entry.userId = data.userId;
      if (data.duration) entry.duration = data.duration;
      if (data.statusCode) entry.statusCode = data.statusCode;
      if (data.method) entry.method = data.method;
      if (data.url) entry.url = data.url;

      if (data.error instanceof Error) {
        entry.error = {
          name: data.error.name,
          message: data.error.message,
          stack: isProduction ? undefined : data.error.stack,
        };
        const { error, requestId, userId, duration, statusCode, method, url, ...rest } = data;
        Object.assign(entry, rest);
      } else {
        const { requestId, userId, duration, statusCode, method, url, ...rest } = data;
        Object.assign(entry, rest);
      }
    }

    return entry;
  }

  _output(level, message, data) {
    const entry = this._buildEntry(level, message, data);

    if (isProduction) {
      const consoleMethod = level === "ERROR" ? "error" : level === "WARN" ? "warn" : "log";
      console[consoleMethod](JSON.stringify(entry));
    } else {
      const color = levelColors[level] || colors.reset;
      const ts = new Date().toLocaleTimeString();
      const prefix = `${colors.gray}${ts}${colors.reset} ${color}[${level}]${colors.reset} ${colors.magenta}[${this.context}]${colors.reset}`;

      const extras = data
        ? ` ${colors.gray}${JSON.stringify(
            Object.fromEntries(
              Object.entries(data).filter(([k]) => !["error"].includes(k))
            ),
            null,
            0
          )}${colors.reset}`
        : "";

      const consoleMethod = level === "ERROR" ? "error" : level === "WARN" ? "warn" : "log";
      console[consoleMethod](`${prefix} ${message}${extras}`);

      if (data?.error instanceof Error && data.error.stack) {
        console.error(`${colors.red}${data.error.stack}${colors.reset}`);
      }
    }
  }

  error(message, data) {
    if (currentLevel >= LOG_LEVELS.error) this._output("ERROR", message, data);
  }

  warn(message, data) {
    if (currentLevel >= LOG_LEVELS.warn) this._output("WARN", message, data);
  }

  info(message, data) {
    if (currentLevel >= LOG_LEVELS.info) this._output("INFO", message, data);
  }

  http(message, data) {
    if (currentLevel >= LOG_LEVELS.http) this._output("HTTP", message, data);
  }

  debug(message, data) {
    if (currentLevel >= LOG_LEVELS.debug) this._output("DEBUG", message, data);
  }

  success(message, data) {
    if (currentLevel >= LOG_LEVELS.info) this._output("SUCCESS", message, data);
  }

  child(context) {
    return new Logger(`${this.context}:${context}`);
  }
}

// ============================================================================
// SINGLETON & FACTORY
// ============================================================================

const logger = new Logger();

export function createLogger(context) {
  return new Logger(context);
}

export { Logger };
export default logger;