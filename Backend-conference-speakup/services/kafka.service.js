// ============================================================================
// SpeakUp — Kafka Service
// Producer/consumer with topic management and health checks
// ============================================================================

import { Kafka, logLevel } from "kafkajs";
import { env } from "../config/env.config.js";
import { KafkaTopics } from "../config/constants.js";
import { createLogger } from "../logs/logger.js";

const log = createLogger("Kafka");

let kafka = null;
let producer = null;
let consumer = null;
let isConnected = false;

// ============================================================================
// INITIALIZATION
// ============================================================================

export async function initKafka() {
  const brokers = env.KAFKA_BROKERS.split(",").map((b) => b.trim());

  const config = {
    clientId: env.KAFKA_CLIENT_ID,
    brokers,
    logLevel: logLevel.WARN,
    retry: { initialRetryTime: 300, retries: 10 },
  };

  if (env.KAFKA_SSL) {
    config.ssl = true;
  }

  if (env.KAFKA_SASL_USERNAME && env.KAFKA_SASL_PASSWORD) {
    config.sasl = {
      mechanism: "plain",
      username: env.KAFKA_SASL_USERNAME,
      password: env.KAFKA_SASL_PASSWORD,
    };
  }

  kafka = new Kafka(config);
  producer = kafka.producer();
  consumer = kafka.consumer({ groupId: env.KAFKA_GROUP_ID });

  await producer.connect();
  isConnected = true;

  log.success("Kafka producer connected", { brokers, clientId: env.KAFKA_CLIENT_ID });
  return { kafka, producer, consumer };
}

// ============================================================================
// PRODUCER
// ============================================================================

export async function publishEvent(topic, key, value) {
  if (!producer) throw new Error("Kafka producer not initialized");

  await producer.send({
    topic,
    messages: [
      {
        key: typeof key === "string" ? key : JSON.stringify(key),
        value: typeof value === "string" ? value : JSON.stringify(value),
        timestamp: Date.now().toString(),
      },
    ],
  });
}

export async function publishBatch(topic, messages) {
  if (!producer) throw new Error("Kafka producer not initialized");

  await producer.send({
    topic,
    messages: messages.map((msg) => ({
      key: typeof msg.key === "string" ? msg.key : JSON.stringify(msg.key),
      value: typeof msg.value === "string" ? msg.value : JSON.stringify(msg.value),
      timestamp: Date.now().toString(),
    })),
  });
}

// ============================================================================
// CONSUMER
// ============================================================================

export async function subscribeToTopics(topics, handler) {
  if (!consumer) throw new Error("Kafka consumer not initialized");

  for (const topic of topics) {
    await consumer.subscribe({ topic, fromBeginning: false });
  }

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      try {
        const key = message.key?.toString();
        const value = JSON.parse(message.value.toString());
        await handler({ topic, partition, key, value, timestamp: message.timestamp });
      } catch (err) {
        log.error("Kafka message processing error", { error: err, topic });
      }
    },
  });

  log.info("Kafka consumer subscribed", { topics });
}

// ============================================================================
// TOPIC MANAGEMENT
// ============================================================================

export async function createTopics() {
  if (!kafka) throw new Error("Kafka not initialized");

  const admin = kafka.admin();
  await admin.connect();

  const topics = Object.values(KafkaTopics).map((topic) => ({
    topic,
    numPartitions: 3,
    replicationFactor: 1,
  }));

  await admin.createTopics({ topics, waitForLeaders: true });
  await admin.disconnect();

  log.info("Kafka topics created", { count: topics.length });
}

// ============================================================================
// HEALTH CHECK
// ============================================================================

export async function healthCheck() {
  if (!kafka) return { connected: false, brokers: 0, topics: [] };

  const admin = kafka.admin();
  await admin.connect();
  const topics = await admin.listTopics();
  const cluster = await admin.describeCluster();
  await admin.disconnect();

  return {
    connected: isConnected,
    brokers: cluster.brokers.length,
    topics,
  };
}

// ============================================================================
// DISCONNECT
// ============================================================================

export async function disconnectKafka() {
  if (producer) await producer.disconnect();
  if (consumer) await consumer.disconnect();
  isConnected = false;
  log.info("Kafka disconnected");
}

export default {
  initKafka,
  publishEvent,
  publishBatch,
  subscribeToTopics,
  createTopics,
  healthCheck,
  disconnectKafka,
};
