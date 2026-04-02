// ============================================================================
// SpeakUp — Mailer Service
// Nodemailer SMTP transport with BullMQ queue integration
// ============================================================================

import nodemailer from "nodemailer";
import { env } from "../config/env.config.js";
import { createLogger } from "../logs/logger.js";

const log = createLogger("Mailer");

let transporter = null;

// ============================================================================
// INITIALIZATION
// ============================================================================

export function initMailer() {
  transporter = nodemailer.createTransport({
    host: env.SMTP_HOST,
    port: env.SMTP_PORT,
    secure: env.SMTP_PORT === 465,
    auth: {
      user: env.SMTP_USER,
      pass: env.SMTP_PASS,
    },
    pool: true,
    maxConnections: 5,
    maxMessages: 100,
    rateLimit: 10,
  });

  log.success("Mailer initialized", { host: env.SMTP_HOST, port: env.SMTP_PORT });
  return transporter;
}

// ============================================================================
// SEND EMAIL
// ============================================================================

export async function sendEmail({ to, subject, html, text, attachments }) {
  if (!transporter) initMailer();

  const mailOptions = {
    from: env.SMTP_FROM,
    to,
    subject,
    html,
    text,
    attachments,
  };

  const info = await transporter.sendMail(mailOptions);
  log.info("Email sent", { to, subject, messageId: info.messageId });
  return info;
}

// ============================================================================
// VERIFY CONNECTION
// ============================================================================

export async function verifyMailer() {
  if (!transporter) initMailer();
  await transporter.verify();
  log.success("SMTP connection verified");
  return true;
}

// ============================================================================
// DISCONNECT
// ============================================================================

export function disconnectMailer() {
  if (transporter) {
    transporter.close();
    log.info("Mailer disconnected");
  }
}

export default {
  initMailer,
  sendEmail,
  verifyMailer,
  disconnectMailer,
};
