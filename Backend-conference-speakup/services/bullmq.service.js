// ============================================================================
// SpeakUp — BullMQ Service
// Job queues for emails, notifications, recordings, analytics, cleanup
// ============================================================================

import { Queue, Worker } from "bullmq";
import { env } from "../config/env.config.js";
import { BullQueues } from "../config/constants.js";
import { createLogger } from "../logs/logger.js";

const log = createLogger("BullMQ");

const queues = {};
const workers = {};

// ============================================================================
// REDIS CONNECTION FOR BULLMQ
// ============================================================================

function getConnection() {
  if (env.BULLMQ_REDIS_URL) {
    return { url: env.BULLMQ_REDIS_URL };
  }
  return {
    host: env.REDIS_HOST,
    port: env.REDIS_PORT,
    password: env.REDIS_PASSWORD || undefined,
    db: env.REDIS_DB,
  };
}

// ============================================================================
// INITIALIZATION
// ============================================================================

export function initQueues() {
  const connection = getConnection();

  for (const [name, queueName] of Object.entries(BullQueues)) {
    queues[name] = new Queue(queueName, {
      connection,
      defaultJobOptions: {
        removeOnComplete: { age: 3600, count: 1000 },
        removeOnFail: { age: 86400, count: 5000 },
        attempts: 3,
        backoff: { type: "exponential", delay: 1000 },
      },
    });
  }

  log.success("BullMQ queues initialized", { queues: Object.keys(BullQueues) });
  return queues;
}

// ============================================================================
// ADD JOB
// ============================================================================

export async function addJob(queueName, jobName, data, options = {}) {
  const queue = queues[queueName];
  if (!queue) throw new Error(`Queue ${queueName} not found`);

  const job = await queue.add(jobName, data, options);
  log.debug(`Job added: ${queueName}/${jobName}`, { jobId: job.id });
  return job;
}

// ============================================================================
// REGISTER WORKER
// ============================================================================

export function registerWorker(queueName, processor, options = {}) {
  const connection = getConnection();
  const bullQueueName = BullQueues[queueName];
  if (!bullQueueName) throw new Error(`Queue ${queueName} not found`);

  const worker = new Worker(bullQueueName, processor, {
    connection,
    concurrency: options.concurrency || 5,
    ...options,
  });

  worker.on("completed", (job) => {
    log.debug(`Job completed: ${bullQueueName}/${job.name}`, { jobId: job.id });
  });

  worker.on("failed", (job, err) => {
    log.error(`Job failed: ${bullQueueName}/${job?.name}`, { jobId: job?.id, error: err });
  });

  workers[queueName] = worker;
  log.info(`Worker registered: ${bullQueueName}`);
  return worker;
}

// ============================================================================
// GETTERS
// ============================================================================

export function getQueue(name) {
  return queues[name];
}

// ============================================================================
// DISCONNECT
// ============================================================================

export async function disconnectBullMQ() {
  for (const worker of Object.values(workers)) {
    await worker.close();
  }
  for (const queue of Object.values(queues)) {
    await queue.close();
  }
  log.info("BullMQ disconnected");
}

export default {
  initQueues,
  addJob,
  registerWorker,
  getQueue,
  disconnectBullMQ,
};
