// ============================================================================
// SpeakUp — BullMQ Workers
// Email, notification, recording, and cleanup job processors
// ============================================================================

import { registerWorker, initQueues } from "../services/bullmq.service.js";
import { sendEmail } from "../services/mailer.service.js";
import emailContent from "../core/mail/mail-content.js";
import { render } from "../core/mail/mail-render.js";
import { createLogger } from "../logs/logger.js";

const log = createLogger("Workers");

// ============================================================================
// EMAIL WORKER
// ============================================================================

async function processEmailJob(job) {
  const { type, to, data } = job.data;

  let content;
  switch (type) {
    case "welcome":
      content = emailContent.welcomeEmail(data);
      break;
    case "meeting-invite":
      content = emailContent.meetingInvite(data);
      break;
    case "meeting-reminder":
      content = emailContent.meetingReminder(data);
      break;
    case "recording-ready":
      content = emailContent.recordingReady(data);
      break;
    case "subscription-confirmed":
      content = emailContent.subscriptionConfirmed(data);
      break;
    case "payment-receipt":
      content = emailContent.paymentReceipt(data);
      break;
    case "goodbye":
      content = emailContent.goodbyeEmail(data);
      break;
    default:
      throw new Error(`Unknown email type: ${type}`);
  }

  const html = render(content);

  await sendEmail({
    to,
    subject: content.EMAIL_TITLE,
    html,
  });

  log.info("Email sent via worker", { type, to, jobId: job.id });
}

// ============================================================================
// NOTIFICATION WORKER
// ============================================================================

async function processNotificationJob(job) {
  const { type, userId, title, body, data } = job.data;

  // Import dynamically to avoid circular deps
  const { createNotification } = await import("../modules/notification/notification.service.js");
  await createNotification(userId, { type, title, body, data: data || {} });

  log.info("Notification processed", { type, userId, jobId: job.id });
}

// ============================================================================
// REGISTER ALL WORKERS
// ============================================================================

export function startWorkers() {
  initQueues();

  registerWorker("EMAIL", processEmailJob, { concurrency: 10 });
  registerWorker("NOTIFICATION", processNotificationJob, { concurrency: 10 });

  log.success("All workers started");
}

// ============================================================================
// HELPER — Queue an email job
// ============================================================================

export async function queueEmail(type, to, data, options = {}) {
  const { addJob } = await import("../services/bullmq.service.js");
  return addJob("EMAIL", `email:${type}`, { type, to, data }, {
    priority: options.priority || 3,
    delay: options.delay || 0,
    ...options,
  });
}

// ============================================================================
// HELPER — Queue a notification job
// ============================================================================

export async function queueNotification(userId, type, title, body, data = {}, options = {}) {
  const { addJob } = await import("../services/bullmq.service.js");
  return addJob("NOTIFICATION", `notification:${type}`, { userId, type, title, body, data }, {
    priority: options.priority || 2,
    ...options,
  });
}

export default { startWorkers, queueEmail, queueNotification };
