// ============================================================================
// SpeakUp — WebSocket Service
// Socket.IO with Redis adapter for meeting rooms, chat, and presence
// ============================================================================

import { Server } from "socket.io";
import { createAdapter } from "@socket.io/redis-adapter";
import { getRedisClient, getRedisSubscriber } from "./redis.service.js";
import { SocketEvents } from "../config/constants.js";
import { env } from "../config/env.config.js";
import { createLogger } from "../logs/logger.js";

const log = createLogger("WebSocket");

let io = null;

// ============================================================================
// INITIALIZATION
// ============================================================================

export function initWebSocket(httpServer) {
  io = new Server(httpServer, {
    cors: {
      origin: env.CORS_ORIGINS.length > 0
        ? [env.FRONTEND_URL, ...env.CORS_ORIGINS].filter(Boolean)
        : "*",
      methods: ["GET", "POST"],
      credentials: true,
    },
    pingTimeout: 30000,
    pingInterval: 25000,
    transports: ["websocket", "polling"],
    maxHttpBufferSize: 1e6, // 1MB
  });

  // Attach Redis adapter for horizontal scaling
  try {
    const pubClient = getRedisClient();
    const subClient = getRedisSubscriber();
    io.adapter(createAdapter(pubClient, subClient));
    log.info("Socket.IO Redis adapter attached");
  } catch (err) {
    log.warn("Socket.IO running without Redis adapter (single-instance mode)", { error: err });
  }

  // Connection handler
  io.on(SocketEvents.CONNECTION, (socket) => {
    log.debug("Client connected", { socketId: socket.id });

    // Join user's personal room for notifications
    socket.on("auth:register", (userId) => {
      if (userId) {
        socket.join(`user:${userId}`);
        socket.data.userId = userId;
        log.debug("User registered", { socketId: socket.id, userId });
      }
    });

    // Meeting room management
    socket.on(SocketEvents.JOIN_ROOM, ({ meetingId, userId }) => {
      socket.join(`meeting:${meetingId}`);
      socket.data.meetingId = meetingId;
      socket.to(`meeting:${meetingId}`).emit(SocketEvents.PARTICIPANT_JOINED, { userId, socketId: socket.id });
      log.debug("Joined meeting room", { socketId: socket.id, meetingId, userId });
    });

    socket.on(SocketEvents.LEAVE_ROOM, ({ meetingId, userId }) => {
      socket.leave(`meeting:${meetingId}`);
      socket.to(`meeting:${meetingId}`).emit(SocketEvents.PARTICIPANT_LEFT, { userId, socketId: socket.id });
      log.debug("Left meeting room", { socketId: socket.id, meetingId, userId });
    });

    // Chat
    socket.on(SocketEvents.CHAT_MESSAGE, (data) => {
      const { meetingId, ...message } = data;
      socket.to(`meeting:${meetingId}`).emit(SocketEvents.CHAT_MESSAGE, message);
    });

    socket.on(SocketEvents.CHAT_TYPING, ({ meetingId, userId }) => {
      socket.to(`meeting:${meetingId}`).emit(SocketEvents.CHAT_TYPING, { userId });
    });

    // Participant media state
    socket.on(SocketEvents.PARTICIPANT_MUTED, (data) => {
      socket.to(`meeting:${data.meetingId}`).emit(SocketEvents.PARTICIPANT_MUTED, data);
    });

    socket.on(SocketEvents.PARTICIPANT_UNMUTED, (data) => {
      socket.to(`meeting:${data.meetingId}`).emit(SocketEvents.PARTICIPANT_UNMUTED, data);
    });

    socket.on(SocketEvents.PARTICIPANT_VIDEO_ON, (data) => {
      socket.to(`meeting:${data.meetingId}`).emit(SocketEvents.PARTICIPANT_VIDEO_ON, data);
    });

    socket.on(SocketEvents.PARTICIPANT_VIDEO_OFF, (data) => {
      socket.to(`meeting:${data.meetingId}`).emit(SocketEvents.PARTICIPANT_VIDEO_OFF, data);
    });

    socket.on(SocketEvents.PARTICIPANT_SCREEN_SHARE_ON, (data) => {
      socket.to(`meeting:${data.meetingId}`).emit(SocketEvents.PARTICIPANT_SCREEN_SHARE_ON, data);
    });

    socket.on(SocketEvents.PARTICIPANT_SCREEN_SHARE_OFF, (data) => {
      socket.to(`meeting:${data.meetingId}`).emit(SocketEvents.PARTICIPANT_SCREEN_SHARE_OFF, data);
    });

    socket.on(SocketEvents.PARTICIPANT_HAND_RAISED, (data) => {
      socket.to(`meeting:${data.meetingId}`).emit(SocketEvents.PARTICIPANT_HAND_RAISED, data);
    });

    socket.on(SocketEvents.PARTICIPANT_HAND_LOWERED, (data) => {
      socket.to(`meeting:${data.meetingId}`).emit(SocketEvents.PARTICIPANT_HAND_LOWERED, data);
    });

    // Disconnect
    socket.on(SocketEvents.DISCONNECT, (reason) => {
      const { meetingId, userId } = socket.data;
      if (meetingId) {
        socket.to(`meeting:${meetingId}`).emit(SocketEvents.PARTICIPANT_LEFT, { userId, socketId: socket.id, reason });
      }
      log.debug("Client disconnected", { socketId: socket.id, reason });
    });
  });

  log.success("WebSocket server initialized");
  return io;
}

// ============================================================================
// EMITTERS
// ============================================================================

export function emitToMeeting(meetingId, event, data) {
  if (!io) return;
  io.to(`meeting:${meetingId}`).emit(event, data);
}

export function emitToUser(userId, event, data) {
  if (!io) return;
  io.to(`user:${userId}`).emit(event, data);
}

export function getIO() {
  if (!io) throw new Error("WebSocket not initialized");
  return io;
}

export function getConnectedCount() {
  return io ? io.engine.clientsCount : 0;
}

// ============================================================================
// DISCONNECT
// ============================================================================

export async function disconnectWebSocket() {
  if (io) {
    io.close();
    log.info("WebSocket server closed");
  }
}

export default {
  initWebSocket,
  emitToMeeting,
  emitToUser,
  getIO,
  getConnectedCount,
  disconnectWebSocket,
};
