// ============================================================================
// SpeakUp — Firebase Auth Middleware
// Verify Firebase ID tokens and sync user to PostgreSQL
// ============================================================================

import admin from "../config/firebase-admin.config.js";
import { prisma } from "../config/prisma.js";
import { HttpStatus, ErrorCodes } from "../config/constants.js";
import { createLogger } from "../logs/logger.js";

const log = createLogger("Auth");

// ============================================================================
// AUTHENTICATE — Verify Firebase token, upsert user in DB
// ============================================================================

export async function authenticate(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(HttpStatus.UNAUTHORIZED).json({
        success: false,
        error: { code: ErrorCodes.UNAUTHORIZED, message: "Missing or invalid authorization header" },
      });
    }

    const idToken = authHeader.split("Bearer ")[1];

    // Verify the Firebase ID token
    const decodedToken = await admin.auth().verifyIdToken(idToken);

    // Find or create user in PostgreSQL
    let user = await prisma.user.findUnique({
      where: { firebaseUid: decodedToken.uid },
      include: { accounts: true },
    });

    if (!user) {
      // First-time login — create user + account
      const provider = decodedToken.firebase?.sign_in_provider === "github.com" ? "GITHUB" : "GOOGLE";

      user = await prisma.user.create({
        data: {
          firebaseUid: decodedToken.uid,
          email: decodedToken.email,
          fullName: decodedToken.name || decodedToken.email?.split("@")[0] || "User",
          avatar: decodedToken.picture || null,
          accounts: {
            create: {
              provider,
              providerId: decodedToken.uid,
              email: decodedToken.email,
            },
          },
        },
        include: { accounts: true },
      });

      log.info("New user created from Firebase", { userId: user.id, provider });
    }

    // Attach user to request
    req.user = user;
    req.firebaseUser = decodedToken;

    next();
  } catch (error) {
    if (error.code === "auth/id-token-expired") {
      return res.status(HttpStatus.UNAUTHORIZED).json({
        success: false,
        error: { code: ErrorCodes.TOKEN_EXPIRED, message: "Token expired. Please sign in again." },
      });
    }

    if (error.code === "auth/id-token-revoked") {
      return res.status(HttpStatus.UNAUTHORIZED).json({
        success: false,
        error: { code: ErrorCodes.TOKEN_INVALID, message: "Token revoked. Please sign in again." },
      });
    }

    if (error.code?.startsWith("auth/")) {
      return res.status(HttpStatus.UNAUTHORIZED).json({
        success: false,
        error: { code: ErrorCodes.FIREBASE_AUTH_FAILED, message: "Authentication failed" },
      });
    }

    log.error("Auth middleware error", { error });
    next(error);
  }
}

// ============================================================================
// OPTIONAL AUTH — Attach user if token present, continue if not
// ============================================================================

export async function optionalAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return next();
  }

  try {
    const idToken = authHeader.split("Bearer ")[1];
    const decodedToken = await admin.auth().verifyIdToken(idToken);

    const user = await prisma.user.findUnique({
      where: { firebaseUid: decodedToken.uid },
    });

    if (user) {
      req.user = user;
      req.firebaseUser = decodedToken;
    }
  } catch {
    // Silently continue without auth
  }

  next();
}

// ============================================================================
// REQUIRE ROLE — Authorize by user role
// ============================================================================

export function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(HttpStatus.UNAUTHORIZED).json({
        success: false,
        error: { code: ErrorCodes.UNAUTHORIZED, message: "Authentication required" },
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(HttpStatus.FORBIDDEN).json({
        success: false,
        error: { code: ErrorCodes.FORBIDDEN, message: "Insufficient permissions" },
      });
    }

    next();
  };
}

export default { authenticate, optionalAuth, requireRole };
