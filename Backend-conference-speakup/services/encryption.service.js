// ============================================================================
// SpeakUp — Encryption Service
// Crypto utilities for meeting passwords, codes, and tokens
// ============================================================================

import crypto from "crypto";
import { createLogger } from "../logs/logger.js";

const log = createLogger("Encryption");

const ALGORITHM = "aes-256-gcm";
const IV_LENGTH = 16;
const TAG_LENGTH = 16;
const SALT_LENGTH = 64;
const KEY_LENGTH = 32;
const ITERATIONS = 100000;

// ============================================================================
// MEETING CODE GENERATION
// ============================================================================

export function generateMeetingCode(length = 10) {
  const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
  let code = "";
  const randomBytes = crypto.randomBytes(length);
  for (let i = 0; i < length; i++) {
    code += chars[randomBytes[i] % chars.length];
  }
  // Format: xxx-xxxx-xxx
  return `${code.slice(0, 3)}-${code.slice(3, 7)}-${code.slice(7)}`;
}

// ============================================================================
// PASSWORD HASHING (for meeting passwords)
// ============================================================================

export async function hashPassword(password) {
  const salt = crypto.randomBytes(SALT_LENGTH);
  return new Promise((resolve, reject) => {
    crypto.pbkdf2(password, salt, ITERATIONS, KEY_LENGTH, "sha512", (err, derivedKey) => {
      if (err) return reject(err);
      resolve(`${salt.toString("hex")}:${derivedKey.toString("hex")}`);
    });
  });
}

export async function verifyPassword(password, hash) {
  const [saltHex, keyHex] = hash.split(":");
  const salt = Buffer.from(saltHex, "hex");
  return new Promise((resolve, reject) => {
    crypto.pbkdf2(password, salt, ITERATIONS, KEY_LENGTH, "sha512", (err, derivedKey) => {
      if (err) return reject(err);
      resolve(crypto.timingSafeEqual(derivedKey, Buffer.from(keyHex, "hex")));
    });
  });
}

// ============================================================================
// SYMMETRIC ENCRYPTION (for sensitive data at rest)
// ============================================================================

export function encrypt(text, secretKey) {
  const iv = crypto.randomBytes(IV_LENGTH);
  const key = crypto.scryptSync(secretKey, "speakup-salt", KEY_LENGTH);
  const cipher = crypto.createCipheriv(ALGORITHM, key, iv);

  let encrypted = cipher.update(text, "utf8", "hex");
  encrypted += cipher.final("hex");
  const authTag = cipher.getAuthTag();

  return `${iv.toString("hex")}:${authTag.toString("hex")}:${encrypted}`;
}

export function decrypt(encryptedData, secretKey) {
  const [ivHex, authTagHex, encrypted] = encryptedData.split(":");
  const iv = Buffer.from(ivHex, "hex");
  const authTag = Buffer.from(authTagHex, "hex");
  const key = crypto.scryptSync(secretKey, "speakup-salt", KEY_LENGTH);

  const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
  decipher.setAuthTag(authTag);

  let decrypted = decipher.update(encrypted, "hex", "utf8");
  decrypted += decipher.final("utf8");
  return decrypted;
}

// ============================================================================
// TOKEN GENERATION
// ============================================================================

export function generateToken(length = 32) {
  return crypto.randomBytes(length).toString("hex");
}

export function generateUUID() {
  return crypto.randomUUID();
}

export default {
  generateMeetingCode,
  hashPassword,
  verifyPassword,
  encrypt,
  decrypt,
  generateToken,
  generateUUID,
};
