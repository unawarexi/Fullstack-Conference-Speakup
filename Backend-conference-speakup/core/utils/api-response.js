
import { HttpStatus } from "../../config/constants.js";

// ============================================================================
// SUCCESS RESPONSES
// ============================================================================

export function success(
  res,
  data,
  message = "Success",
  statusCode = HttpStatus.OK,
) {
  res.status(statusCode).json({
    success: true,
    message,
    data,
  });
}

export function created(res, data, message = "Created successfully") {
  success(res, data, message, HttpStatus.CREATED);
}

export function noContent(res) {
  res.status(HttpStatus.NO_CONTENT).send();
}

// ============================================================================
// PAGINATED RESPONSE
// ============================================================================

export function paginated(
  res,
  { data, page, limit, total, message = "Success" },
) {
  const totalPages = Math.ceil(total / limit);
  const hasNextPage = page < totalPages;
  const hasPrevPage = page > 1;

  res.status(HttpStatus.OK).json({
    success: true,
    message,
    data,
    pagination: {
      page,
      limit,
      total,
      totalPages,
      hasNextPage,
      hasPrevPage,
    },
  });
}

// ============================================================================
// ERROR RESPONSES
// ============================================================================

export function error(
  res,
  message,
  statusCode = HttpStatus.INTERNAL_SERVER_ERROR,
  code,
  details,
) {
  const response = {
    success: false,
    error: {
      message,
    },
  };

  if (code) {
    response.error.code = code;
  }

  if (details) {
    response.error.details = details;
  }

  res.status(statusCode).json(response);
}

export function badRequest(res, message, details) {
  error(res, message, HttpStatus.BAD_REQUEST, "E2001", details);
}

export function unauthorized(res, message = "Unauthorized") {
  error(res, message, HttpStatus.UNAUTHORIZED, "E1004");
}

export function forbidden(res, message = "Forbidden") {
  error(res, message, HttpStatus.FORBIDDEN, "E1005");
}

export function notFound(res, resource = "Resource") {
  error(res, `${resource} not found`, HttpStatus.NOT_FOUND, "E3001");
}

export function conflict(res, message) {
  error(res, message, HttpStatus.CONFLICT, "E3002");
}

export function serverError(res, message = "Internal server error") {
  error(res, message, HttpStatus.INTERNAL_SERVER_ERROR, "E9001");
}

export default {
  success,
  created,
  noContent,
  paginated,
  error,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  serverError,
};
