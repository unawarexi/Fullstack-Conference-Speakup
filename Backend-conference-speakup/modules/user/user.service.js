// ============================================================================
// SpeakUp — User Service
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { getCache, setCache, deleteCache } from "../../services/redis.service.js";
import { uploadBuffer, deleteFromCloudinary } from "../../services/cloudinary.service.js";
import { emitToUser } from "../../services/websocket.service.js";
import { CacheTTL, SocketEvents } from "../../config/constants.js";

export async function getUserById(userId) {
  const cached = await getCache(`user:${userId}`);
  if (cached) return cached;

  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: { subscriptions: true },
  });

  if (user) {
    const sanitized = sanitize(user);
    await setCache(`user:${userId}`, sanitized, CacheTTL.USER_PROFILE);
    return sanitized;
  }
  return null;
}

export async function updateUser(userId, data) {
  const user = await prisma.user.update({
    where: { id: userId },
    data: { fullName: data.fullName, bio: data.bio },
  });
  await deleteCache(`user:${userId}`);
  return sanitize(user);
}

export async function updateUserAvatar(userId, fileBuffer) {
  const current = await prisma.user.findUnique({ where: { id: userId }, select: { avatar: true } });

  // Delete old avatar from Cloudinary if exists
  if (current?.avatar && current.avatar.includes("cloudinary")) {
    const publicId = current.avatar.split("/").pop()?.split(".")[0];
    if (publicId) await deleteFromCloudinary(`speakup/avatars/${publicId}`).catch(() => {});
  }

  const result = await uploadBuffer(fileBuffer, {
    folder: "speakup/avatars",
    transformation: [{ width: 256, height: 256, crop: "fill", gravity: "face", quality: "auto:good" }],
  });

  const user = await prisma.user.update({
    where: { id: userId },
    data: { avatar: result.url },
  });

  await deleteCache(`user:${userId}`);
  return sanitize(user);
}

export async function getUserDevices(userId) {
  return prisma.device.findMany({
    where: { userId },
    orderBy: { updatedAt: "desc" },
  });
}

export async function registerUserDevice(userId, { fcmToken, platform }) {
  return prisma.device.upsert({
    where: { userId_fcmToken: { userId, fcmToken } },
    update: { platform, updatedAt: new Date() },
    create: { userId, fcmToken, platform },
  });
}

export async function removeUserDevice(userId, deviceId) {
  return prisma.device.deleteMany({ where: { id: deviceId, userId } });
}

export async function setOnlineStatus(userId, isOnline) {
  await prisma.user.update({
    where: { id: userId },
    data: { isOnline, lastSeenAt: new Date() },
  });

  emitToUser(userId, isOnline ? SocketEvents.USER_ONLINE : SocketEvents.USER_OFFLINE, { userId });
  await deleteCache(`user:${userId}`);
}

function sanitize(user) {
  const { firebaseUid, ...rest } = user;
  return { ...rest, subscription: rest.subscriptions || null, subscriptions: undefined };
}
