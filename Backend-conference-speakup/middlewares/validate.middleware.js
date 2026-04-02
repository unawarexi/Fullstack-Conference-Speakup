// ============================================================================
// SpeakUp — Validation Middleware
// Zod schema validation for request body, query, and params
// ============================================================================

import { HttpStatus, ErrorCodes } from "../config/constants.js";

export function validateBody(schema) {
  return (req, res, next) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      return res.status(HttpStatus.BAD_REQUEST).json({
        success: false,
        error: {
          code: ErrorCodes.VALIDATION_ERROR,
          message: "Validation failed",
          details: result.error.issues.map((i) => ({ path: i.path.join("."), message: i.message })),
        },
      });
    }
    req.body = result.data;
    next();
  };
}

export function validateQuery(schema) {
  return (req, res, next) => {
    const result = schema.safeParse(req.query);
    if (!result.success) {
      return res.status(HttpStatus.BAD_REQUEST).json({
        success: false,
        error: {
          code: ErrorCodes.VALIDATION_ERROR,
          message: "Invalid query parameters",
          details: result.error.issues.map((i) => ({ path: i.path.join("."), message: i.message })),
        },
      });
    }
    req.query = result.data;
    next();
  };
}

export function validateParams(schema) {
  return (req, res, next) => {
    const result = schema.safeParse(req.params);
    if (!result.success) {
      return res.status(HttpStatus.BAD_REQUEST).json({
        success: false,
        error: {
          code: ErrorCodes.VALIDATION_ERROR,
          message: "Invalid URL parameters",
          details: result.error.issues.map((i) => ({ path: i.path.join("."), message: i.message })),
        },
      });
    }
    req.params = result.data;
    next();
  };
}
