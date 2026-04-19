// ============================================================================
// SpeakUp — Notification Service
// Push (FCM) + in-app notifications, paginated, real-time via WebSocket
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { emitToUser } from "../../services/websocket.service.js";
import admin from "../../config/firebase-admin.config.js";
import { notFound } from "../../middlewares/errorhandler.middleware.js";
import { SocketEvents, Pagination } from "../../config/constants.js";

export async function createNotification(userId, { type, title, body, data = {} }) {
  // Respect user's notification preferences
  const enabled = await isNotificationEnabled(userId, type);
  if (!enabled) return null;

  const notification = await prisma.notification.create({
    data: { userId, type, title, body, data },
  });

  emitToUser(userId, SocketEvents.NOTIFICATION, { notification });

  // Fire-and-forget push notification
  sendPushToUser(userId, { title, body, data: { ...data, type, notificationId: notification.id } }).catch(() => {});

  return notification;
}

export async function getNotifications(userId, { page = 1, limit = 20 }) {
  const take = Math.min(parseInt(limit) || 20, Pagination.MAX_LIMIT);
  const skip = (Math.max(parseInt(page) || 1, 1) - 1) * take;

  const [notifications, total, unreadCount] = await Promise.all([
    prisma.notification.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
      take,
      skip,
    }),
    prisma.notification.count({ where: { userId } }),
    prisma.notification.count({ where: { userId, isRead: false } }),
  ]);

  return {
    notifications,
    unreadCount,
    total,
    page: Math.max(parseInt(page) || 1, 1),
    totalPages: Math.ceil(total / take),
  };
}

export async function getUnreadCount(userId) {
  return prisma.notification.count({ where: { userId, isRead: false } });
}

export async function markAsRead(notificationId, userId) {
  const notification = await prisma.notification.findUnique({ where: { id: notificationId } });
  if (!notification || notification.userId !== userId) throw notFound("Notification not found");

  return prisma.notification.update({
    where: { id: notificationId },
    data: { isRead: true },
  });
}

export async function markAllAsRead(userId) {
  const { count } = await prisma.notification.updateMany({
    where: { userId, isRead: false },
    data: { isRead: true },
  });
  return count;
}

export async function deleteNotification(notificationId, userId) {
  const notification = await prisma.notification.findUnique({ where: { id: notificationId } });
  if (!notification || notification.userId !== userId) throw notFound("Notification not found");
  await prisma.notification.delete({ where: { id: notificationId } });
}

async function sendPushToUser(userId, { title, body, data = {} }) {
  const devices = await prisma.device.findMany({
    where: { userId },
    select: { fcmToken: true },
  });

  const tokens = devices.map(d => d.fcmToken).filter(Boolean);
  if (tokens.length === 0) return;

  // Determine channel and priority based on notification type
  const type = data.type || "SYSTEM";
  const isCall = type === "MEETING_INVITE" && data.isInstant === "true";
  const isChat = type === "CHAT_MESSAGE";

  const channelId = isCall ? "incoming_calls" : isChat ? "chat_messages" : "meeting_reminders";
  const priority = isCall || isChat ? "high" : "normal";
  const sound = isCall ? "ringtone.mp3" : "default";

  const message = {
    notification: { title, body },
    data: Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])),
    android: {
      priority: "high",
      notification: {
        channelId,
        priority: isCall ? "max" : "high",
        sound,
        defaultVibrateTimings: !isCall,
        ...(isCall && { vibrateTimingsMillis: [0, 500, 200, 500, 200, 500] }),
        visibility: "PUBLIC",
      },
    },
    apns: {
      headers: { "apns-priority": "10" },
      payload: {
        aps: {
          sound: isCall ? { name: "ringtone.caf", critical: true, volume: 1.0 } : "default",
          "content-available": 1,
          "mutable-content": 1,
          ...(isCall && { "interruption-level": "critical" }),
        },
      },
    },
    tokens,
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    // Remove stale tokens
    if (response.failureCount > 0) {
      const staleTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success && resp.error?.code === "messaging/registration-token-not-registered") {
          staleTokens.push(tokens[idx]);
        }
      });
      if (staleTokens.length > 0) {
        await prisma.device.deleteMany({ where: { fcmToken: { in: staleTokens } } });
      }
    }
  } catch (_) { /* FCM failure is non-critical */ }
}

// ============================================================================
// NOTIFICATION PREFERENCES
// ============================================================================

export async function getNotificationPreference(userId) {
  let pref = await prisma.notificationPreference.findUnique({ where: { userId } });
  if (!pref) {
    pref = await prisma.notificationPreference.create({ data: { userId } });
  }
  return pref;
}

export async function updateNotificationPreference(userId, data) {
  return prisma.notificationPreference.upsert({
    where: { userId },
    update: data,
    create: { userId, ...data },
  });
}

/**
 * Check if a specific notification type is enabled for a user.
 * Used internally before sending push/email notifications.
 */
export async function isNotificationEnabled(userId, type) {
  const pref = await prisma.notificationPreference.findUnique({ where: { userId } });
  if (!pref) return true; // default = all enabled

  switch (type) {
    case "MEETING_INVITE": return pref.meetingInvites;
    case "MEETING_REMINDER": return pref.meetingReminders;
    case "CHAT_MESSAGE": return pref.chatMessages;
    case "RECORDING_READY": return pref.recordingReady;
    default: return pref.pushEnabled;
  }
}
