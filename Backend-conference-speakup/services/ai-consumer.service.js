// ============================================================================
// SpeakUp — AI Kafka Consumer Service
// Consumes AI result topics from FastAPI and broadcasts via WebSocket
// ============================================================================

import { Kafka, logLevel } from "kafkajs";
import { env } from "../config/env.config.js";
import { KafkaTopics, SocketEvents } from "../config/constants.js";
import { emitToMeeting, emitToUser } from "./websocket.service.js";
import { createLogger } from "../logs/logger.js";

const log = createLogger("AI-Consumer");

let consumer = null;

// Map: Kafka topic → Socket event name
const TOPIC_EVENT_MAP = {
  [KafkaTopics.AI_TRANSCRIPTION]: SocketEvents.AI_TRANSCRIPTION,
  [KafkaTopics.AI_LIVE_INSIGHTS]: SocketEvents.AI_LIVE_INSIGHTS,
  [KafkaTopics.AI_EMOTION_SIGNALS]: SocketEvents.AI_EMOTION_SIGNALS,
  [KafkaTopics.AI_COACHING_HINTS]: SocketEvents.AI_COACHING_HINTS,
  [KafkaTopics.AI_COPILOT_SUGGESTIONS]: SocketEvents.AI_COPILOT_SUGGESTIONS,
  [KafkaTopics.AI_MEETING_SUMMARY]: SocketEvents.AI_MEETING_SUMMARY,
  [KafkaTopics.AI_ACTION_ITEMS]: SocketEvents.AI_ACTION_ITEMS,
  [KafkaTopics.AI_CV_ANALYSIS]: SocketEvents.AI_CV_ANALYSIS,
};

// Topics that should only be sent to the specific user (private signals)
const PRIVATE_TOPICS = new Set([
  KafkaTopics.AI_COACHING_HINTS,
  KafkaTopics.AI_EMOTION_SIGNALS,
]);

// ============================================================================
// INITIALIZATION
// ============================================================================

export async function initAIConsumer() {
  const brokers = env.KAFKA_BROKERS.split(",").map((b) => b.trim());

  const config = {
    clientId: `${env.KAFKA_CLIENT_ID}-ai-consumer`,
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

  const kafka = new Kafka(config);
  consumer = kafka.consumer({ groupId: `${env.KAFKA_GROUP_ID}-ai-relay` });

  await consumer.connect();

  // Subscribe to all AI result topics
  const aiTopics = Object.keys(TOPIC_EVENT_MAP);
  for (const topic of aiTopics) {
    await consumer.subscribe({ topic, fromBeginning: false });
  }

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      try {
        const value = JSON.parse(message.value.toString());
        await handleAIMessage(topic, value);
      } catch (err) {
        log.error("AI message processing error", { error: err.message, topic });
      }
    },
  });

  log.success("AI Kafka consumer started", { topics: aiTopics.length });
}

// ============================================================================
// MESSAGE HANDLER
// ============================================================================

async function handleAIMessage(topic, payload) {
  const { meeting_id, user_id, ...data } = payload;
  const socketEvent = TOPIC_EVENT_MAP[topic];

  if (!socketEvent) {
    log.warn("No socket event mapped for topic", { topic });
    return;
  }

  if (!meeting_id) {
    log.warn("AI message missing meeting_id", { topic });
    return;
  }

  // Private signals (coaching, emotion) go only to the target user
  if (PRIVATE_TOPICS.has(topic) && user_id) {
    emitToUser(user_id, socketEvent, {
      meetingId: meeting_id,
      userId: user_id,
      ...data,
      timestamp: Date.now(),
    });
    log.debug("AI private signal sent", { topic, userId: user_id });
    return;
  }

  // Broadcast to entire meeting room
  emitToMeeting(meeting_id, socketEvent, {
    meetingId: meeting_id,
    ...data,
    timestamp: Date.now(),
  });

  log.debug("AI broadcast sent", { topic, meetingId: meeting_id });
}

// ============================================================================
// DISCONNECT
// ============================================================================

export async function disconnectAIConsumer() {
  if (consumer) {
    await consumer.disconnect();
    log.info("AI Kafka consumer disconnected");
  }
}

export default {
  initAIConsumer,
  disconnectAIConsumer,
};
