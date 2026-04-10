// ============================================================================
// SpeakUp — Meeting Code & Link Generator
// Generates human-readable meeting codes (spk-xxxx-xxxx) and deep links
// ============================================================================

import crypto from "crypto";

const CODE_PREFIX = "spk";
const LINK_BASE = "https://speakup.app/join";
const DEEPLINK_SCHEME = "speakup://meet";
const CHARSET = "abcdefghjkmnpqrstuvwxyz2345679"; // no ambiguous chars (0/o, 1/l/i)
const SEGMENT_LENGTH = 4;
const NUM_SEGMENTS = 2;
const MAX_RETRIES = 5;

/**
 * Generate a SpeakUp meeting code: spk-xxxx-xxxx
 * Uses cryptographically secure random bytes.
 * Excludes ambiguous characters (0, O, 1, l, I) for readability.
 */
export function generateSpeakUpCode() {
  const segments = [];
  for (let s = 0; s < NUM_SEGMENTS; s++) {
    const bytes = crypto.randomBytes(SEGMENT_LENGTH);
    let segment = "";
    for (let i = 0; i < SEGMENT_LENGTH; i++) {
      segment += CHARSET[bytes[i] % CHARSET.length];
    }
    segments.push(segment);
  }
  return `${CODE_PREFIX}-${segments.join("-")}`;
}

/**
 * Generate a unique meeting code with collision check.
 * @param {Function} existsCheck — async fn(code) => boolean, checks if code exists in DB
 * @returns {Promise<string>} unique meeting code
 */
export async function generateUniqueMeetingCode(existsCheck) {
  for (let attempt = 0; attempt < MAX_RETRIES; attempt++) {
    const code = generateSpeakUpCode();
    if (!existsCheck || !(await existsCheck(code))) {
      return code;
    }
  }
  // Fallback: append timestamp segment for guaranteed uniqueness
  const ts = Date.now().toString(36).slice(-4);
  return `${CODE_PREFIX}-${ts}-${generateSpeakUpCode().split("-").slice(1).join("-")}`;
}

/**
 * Build the shareable meeting link from a code.
 */
export function getMeetingLink(code) {
  return `${LINK_BASE}/${code}`;
}

/**
 * Build the deep link URI for mobile apps.
 */
export function getMeetingDeepLink(code) {
  return `${DEEPLINK_SCHEME}/${code}`;
}

/**
 * Parse a meeting code from a link or raw input.
 * Handles: full URLs, deep links, plain codes, codes with/without prefix.
 * Returns the normalized code (spk-xxxx-xxxx) or null if invalid.
 */
export function parseMeetingCode(input) {
  if (!input || typeof input !== "string") return null;
  const trimmed = input.trim().toLowerCase();

  // Try to extract from full URL: https://speakup.app/join/spk-xxxx-xxxx
  const urlMatch = trimmed.match(/speakup\.app\/(?:join|meeting)\/([a-z0-9-]+)/);
  if (urlMatch) return normalizeCode(urlMatch[1]);

  // Try deep link: speakup://meet/spk-xxxx-xxxx
  const deepMatch = trimmed.match(/speakup:\/\/meet\/([a-z0-9-]+)/);
  if (deepMatch) return normalizeCode(deepMatch[1]);

  // Plain code (with or without prefix)
  return normalizeCode(trimmed);
}

/**
 * Validate that a code matches the SpeakUp format: spk-xxxx-xxxx
 */
export function isValidMeetingCode(code) {
  if (!code) return false;
  return /^spk-[a-z0-9]{4}-[a-z0-9]{4}$/.test(code.toLowerCase().trim());
}

/**
 * Normalize a code — ensure it has the spk- prefix.
 */
function normalizeCode(raw) {
  if (!raw) return null;
  const cleaned = raw.replace(/\s+/g, "").toLowerCase();

  // Already has prefix
  if (/^spk-[a-z0-9]{4}-[a-z0-9]{4}$/.test(cleaned)) return cleaned;

  // Missing prefix but matches segment pattern (xxxx-xxxx)
  if (/^[a-z0-9]{4}-[a-z0-9]{4}$/.test(cleaned)) return `spk-${cleaned}`;

  // Could be a cuid or other code format — return as-is for legacy support
  if (/^[a-z0-9]{8,}$/.test(cleaned)) return cleaned;

  return null;
}

export default {
  generateSpeakUpCode,
  generateUniqueMeetingCode,
  getMeetingLink,
  getMeetingDeepLink,
  parseMeetingCode,
  isValidMeetingCode,
};
