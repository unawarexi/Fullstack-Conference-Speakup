// ============================================================================
// SpeakUp — Meeting Service
// Core meeting lifecycle: create, join, leave, end, lock, kick
// Integrates LiveKit, Redis, WebSocket, Kafka, BullMQ
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { getCache, setCache, deleteCache, deleteCachePattern } from "../../services/redis.service.js";
import { generateToken as livekitToken, deleteRoom, removeParticipant as livekitRemove, listParticipants as livekitParticipants } from "../../services/livekit.service.js";
import { emitToMeeting, emitToUser } from "../../services/websocket.service.js";
import { publishEvent } from "../../services/kafka.service.js";
import { generateMeetingCode, hashPassword, verifyPassword } from "../../services/encryption.service.js";
import { CacheTTL, SocketEvents, KafkaTopics, MeetingConfig, ErrorCodes, HttpStatus } from "../../config/constants.js";
import { AppError } from "../../middlewares/errorhandler.middleware.js";
import { queueNotification, queueEmail } from "../../services/workers.js";
import { createLogger } from "../../logs/logger.js";

const log = createLogger("MeetingService");

// ── helpers ──────────────────────────────────────────────────────────────

function meetingCacheKey(id) { return `meeting:${id}`; }
function participantsCacheKey(id) { return `meeting:${id}:participants`; }

function getMaxParticipants(plan) {
  if (plan === "ENTERPRISE") return MeetingConfig.MAX_PARTICIPANTS_ENTERPRISE;
  if (plan === "PRO") return MeetingConfig.MAX_PARTICIPANTS_PRO;
  return MeetingConfig.MAX_PARTICIPANTS_FREE;
}

// ── CREATE ───────────────────────────────────────────────────────────────

export async function createMeeting(userId, data) {
  const code = generateMeetingCode();

  const meetingData = {
    title: data.title,
    description: data.description || null,
    hostId: userId,
    code,
    type: data.type || "INSTANT",
    status: data.type === "SCHEDULED" ? "SCHEDULED" : "LIVE",
    scheduledAt: data.scheduledAt ? new Date(data.scheduledAt) : null,
    startedAt: data.type !== "SCHEDULED" ? new Date() : null,
    maxParticipants: data.maxParticipants || MeetingConfig.DEFAULT_MAX_PARTICIPANTS,
    settings: data.settings || {},
  };

  if (data.password) {
    meetingData.password = await hashPassword(data.password);
  }

  const meeting = await prisma.meeting.create({
    data: meetingData,
    include: { host: { select: { id: true, fullName: true, avatar: true } } },
  });

  // Auto-join host as HOST participant for instant meetings
  if (meeting.status === "LIVE") {
    await prisma.participant.create({
      data: { meetingId: meeting.id, userId, role: "HOST" },
    });
  }

  publishEvent(KafkaTopics.MEETING_EVENTS, meeting.id, { type: "meeting.created", meetingId: meeting.id, userId }).catch(() => {});

  log.info("Meeting created", { meetingId: meeting.id, code, type: meeting.type });
  return { ...meeting, password: undefined };
}

// ── READ ─────────────────────────────────────────────────────────────────

export async function getMeetingById(meetingId, userId) {
  const cached = await getCache(meetingCacheKey(meetingId));
  if (cached) return cached;

  const meeting = await prisma.meeting.findUnique({
    where: { id: meetingId },
    include: {
      host: { select: { id: true, fullName: true, avatar: true } },
      _count: { select: { participants: { where: { leftAt: null } } } },
    },
  });

  if (!meeting) throw new AppError("Meeting not found", HttpStatus.NOT_FOUND, ErrorCodes.MEETING_NOT_FOUND);

  const result = { ...meeting, password: undefined, participantCount: meeting._count.participants };
  await setCache(meetingCacheKey(meetingId), result, CacheTTL.MEETING_DETAILS);
  return result;
}

export async function getMeetingByCode(code) {
  const meeting = await prisma.meeting.findUnique({
    where: { code },
    include: {
      host: { select: { id: true, fullName: true, avatar: true } },
      _count: { select: { participants: { where: { leftAt: null } } } },
    },
  });

  if (!meeting) throw new AppError("Meeting not found", HttpStatus.NOT_FOUND, ErrorCodes.MEETING_NOT_FOUND);
  return { ...meeting, password: undefined, participantCount: meeting._count.participants };
}

export async function listUserMeetings(userId, { page = 1, limit = 20, status }) {
  const where = {
    OR: [
      { hostId: userId },
      { participants: { some: { userId } } },
    ],
  };
  if (status) where.status = status;

  const [meetings, total] = await Promise.all([
    prisma.meeting.findMany({
      where,
      include: {
        host: { select: { id: true, fullName: true, avatar: true } },
        _count: { select: { participants: { where: { leftAt: null } } } },
      },
      orderBy: { createdAt: "desc" },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.meeting.count({ where }),
  ]);

  return {
    meetings: meetings.map((m) => ({ ...m, password: undefined, participantCount: m._count.participants })),
    total,
    page,
    limit,
  };
}

// ── UPDATE ───────────────────────────────────────────────────────────────

export async function updateMeeting(meetingId, userId, data) {
  const meeting = await prisma.meeting.findUnique({ where: { id: meetingId } });
  if (!meeting) throw new AppError("Meeting not found", HttpStatus.NOT_FOUND, ErrorCodes.MEETING_NOT_FOUND);
  if (meeting.hostId !== userId) throw new AppError("Only the host can update this meeting", HttpStatus.FORBIDDEN, ErrorCodes.NOT_MEETING_HOST);

  const updated = await prisma.meeting.update({
    where: { id: meetingId },
    data: { title: data.title, description: data.description, scheduledAt: data.scheduledAt ? new Date(data.scheduledAt) : undefined, maxParticipants: data.maxParticipants, settings: data.settings },
    include: { host: { select: { id: true, fullName: true, avatar: true } } },
  });

  await deleteCache(meetingCacheKey(meetingId));
  emitToMeeting(meetingId, SocketEvents.MEETING_UPDATED, { meeting: { ...updated, password: undefined } });

  return { ...updated, password: undefined };
}

export async function deleteMeeting(meetingId, userId) {
  const meeting = await prisma.meeting.findUnique({ where: { id: meetingId } });
  if (!meeting) throw new AppError("Meeting not found", HttpStatus.NOT_FOUND, ErrorCodes.MEETING_NOT_FOUND);
  if (meeting.hostId !== userId) throw new AppError("Only the host can delete this meeting", HttpStatus.FORBIDDEN, ErrorCodes.NOT_MEETING_HOST);

  // End the meeting in LiveKit
  await deleteRoom(meetingId).catch(() => {});

  await prisma.meeting.delete({ where: { id: meetingId } });
  await deleteCache(meetingCacheKey(meetingId));
  await deleteCachePattern(`meeting:${meetingId}:*`);

  emitToMeeting(meetingId, SocketEvents.MEETING_ENDED, { meetingId, reason: "deleted" });
}

// ── JOIN / LEAVE / END ───────────────────────────────────────────────────

export async function joinMeeting(meetingId, userId, password) {
  const meeting = await prisma.meeting.findUnique({
    where: { id: meetingId },
    include: { _count: { select: { participants: { where: { leftAt: null } } } } },
  });

  if (!meeting) throw new AppError("Meeting not found", HttpStatus.NOT_FOUND, ErrorCodes.MEETING_NOT_FOUND);
  if (meeting.status === "ENDED" || meeting.status === "CANCELLED") {
    throw new AppError("This meeting has ended", HttpStatus.BAD_REQUEST, ErrorCodes.MEETING_ALREADY_ENDED);
  }

  // Check meeting password
  if (meeting.password) {
    if (!password) throw new AppError("Password required", HttpStatus.BAD_REQUEST, ErrorCodes.MEETING_PASSWORD_REQUIRED);
    const valid = await verifyPassword(password, meeting.password);
    if (!valid) throw new AppError("Incorrect password", HttpStatus.BAD_REQUEST, ErrorCodes.MEETING_PASSWORD_INCORRECT);
  }

  // Check capacity
  if (meeting._count.participants >= meeting.maxParticipants) {
    throw new AppError("Meeting is full", HttpStatus.BAD_REQUEST, ErrorCodes.MEETING_FULL);
  }

  // Check if settings have lock
  if (meeting.settings?.locked && meeting.hostId !== userId) {
    throw new AppError("Meeting is locked", HttpStatus.FORBIDDEN, ErrorCodes.FORBIDDEN);
  }

  // Upsert participant (re-joining after leaving)
  const participant = await prisma.participant.upsert({
    where: { meetingId_userId: { meetingId, userId } },
    update: { leftAt: null, joinedAt: new Date() },
    create: { meetingId, userId, role: meeting.hostId === userId ? "HOST" : "ATTENDEE" },
    include: { user: { select: { id: true, fullName: true, avatar: true } } },
  });

  // If meeting was SCHEDULED, move to LIVE on first join
  if (meeting.status === "SCHEDULED") {
    await prisma.meeting.update({ where: { id: meetingId }, data: { status: "LIVE", startedAt: new Date() } });
  }

  await deleteCache(meetingCacheKey(meetingId));
  await deleteCache(participantsCacheKey(meetingId));

  emitToMeeting(meetingId, SocketEvents.PARTICIPANT_JOINED, {
    participant: { id: participant.id, userId, role: participant.role, user: participant.user },
  });

  publishEvent(KafkaTopics.PARTICIPANT_EVENTS, meetingId, { type: "participant.joined", meetingId, userId }).catch(() => {});

  return participant;
}

export async function leaveMeeting(meetingId, userId) {
  const participant = await prisma.participant.findUnique({
    where: { meetingId_userId: { meetingId, userId } },
  });
  if (!participant) return;

  await prisma.participant.update({
    where: { id: participant.id },
    data: { leftAt: new Date() },
  });

  await deleteCache(meetingCacheKey(meetingId));
  await deleteCache(participantsCacheKey(meetingId));

  emitToMeeting(meetingId, SocketEvents.PARTICIPANT_LEFT, { userId, meetingId });

  publishEvent(KafkaTopics.PARTICIPANT_EVENTS, meetingId, { type: "participant.left", meetingId, userId }).catch(() => {});
}

export async function endMeeting(meetingId, userId) {
  const meeting = await prisma.meeting.findUnique({ where: { id: meetingId } });
  if (!meeting) throw new AppError("Meeting not found", HttpStatus.NOT_FOUND, ErrorCodes.MEETING_NOT_FOUND);
  if (meeting.hostId !== userId) throw new AppError("Only the host can end this meeting", HttpStatus.FORBIDDEN, ErrorCodes.NOT_MEETING_HOST);

  // Mark all active participants as left
  await prisma.participant.updateMany({
    where: { meetingId, leftAt: null },
    data: { leftAt: new Date() },
  });

  const updated = await prisma.meeting.update({
    where: { id: meetingId },
    data: { status: "ENDED", endedAt: new Date(), isRecording: false },
  });

  // Cleanup LiveKit room
  await deleteRoom(meetingId).catch(() => {});

  await deleteCache(meetingCacheKey(meetingId));
  await deleteCachePattern(`meeting:${meetingId}:*`);

  emitToMeeting(meetingId, SocketEvents.MEETING_ENDED, { meetingId });

  publishEvent(KafkaTopics.MEETING_EVENTS, meetingId, {
    type: "meeting.ended",
    meetingId,
    duration: updated.startedAt ? Math.floor((updated.endedAt - updated.startedAt) / 1000) : 0,
  }).catch(() => {});

  return updated;
}

// ── LOCK / UNLOCK ────────────────────────────────────────────────────────

export async function lockMeeting(meetingId, userId) {
  const meeting = await prisma.meeting.findUnique({ where: { id: meetingId } });
  if (!meeting) throw new AppError("Meeting not found", HttpStatus.NOT_FOUND, ErrorCodes.MEETING_NOT_FOUND);
  if (meeting.hostId !== userId) throw new AppError("Only the host can lock this meeting", HttpStatus.FORBIDDEN, ErrorCodes.NOT_MEETING_HOST);

  const settings = { ...(meeting.settings || {}), locked: true };
  await prisma.meeting.update({ where: { id: meetingId }, data: { settings } });
  await deleteCache(meetingCacheKey(meetingId));

  emitToMeeting(meetingId, SocketEvents.MEETING_LOCKED, { meetingId });
}

export async function unlockMeeting(meetingId, userId) {
  const meeting = await prisma.meeting.findUnique({ where: { id: meetingId } });
  if (!meeting) throw new AppError("Meeting not found", HttpStatus.NOT_FOUND, ErrorCodes.MEETING_NOT_FOUND);
  if (meeting.hostId !== userId) throw new AppError("Only the host can unlock this meeting", HttpStatus.FORBIDDEN, ErrorCodes.NOT_MEETING_HOST);

  const settings = { ...(meeting.settings || {}), locked: false };
  await prisma.meeting.update({ where: { id: meetingId }, data: { settings } });
  await deleteCache(meetingCacheKey(meetingId));

  emitToMeeting(meetingId, SocketEvents.MEETING_UNLOCKED, { meetingId });
}

// ── PARTICIPANTS ─────────────────────────────────────────────────────────

export async function getParticipants(meetingId) {
  const cached = await getCache(participantsCacheKey(meetingId));
  if (cached) return cached;

  const participants = await prisma.participant.findMany({
    where: { meetingId, leftAt: null },
    include: { user: { select: { id: true, fullName: true, avatar: true, isOnline: true } } },
    orderBy: { joinedAt: "asc" },
  });

  await setCache(participantsCacheKey(meetingId), participants, CacheTTL.PARTICIPANTS);
  return participants;
}

export async function kickParticipant(meetingId, hostId, participantUserId) {
  const meeting = await prisma.meeting.findUnique({ where: { id: meetingId } });
  if (!meeting) throw new AppError("Meeting not found", HttpStatus.NOT_FOUND, ErrorCodes.MEETING_NOT_FOUND);
  if (meeting.hostId !== hostId) throw new AppError("Only the host can kick participants", HttpStatus.FORBIDDEN, ErrorCodes.NOT_MEETING_HOST);

  const participant = await prisma.participant.findUnique({
    where: { meetingId_userId: { meetingId, userId: participantUserId } },
  });
  if (!participant) throw new AppError("Participant not found", HttpStatus.NOT_FOUND);

  await prisma.participant.update({ where: { id: participant.id }, data: { leftAt: new Date() } });

  // Remove from LiveKit room
  await livekitRemove(meetingId, participantUserId).catch(() => {});

  await deleteCache(participantsCacheKey(meetingId));

  emitToMeeting(meetingId, SocketEvents.PARTICIPANT_KICKED, { userId: participantUserId, meetingId });
  emitToUser(participantUserId, SocketEvents.PARTICIPANT_KICKED, { meetingId });

  await queueNotification(participantUserId, "SYSTEM", "Removed from meeting", `You were removed from "${meeting.title}"`, { meetingId }).catch(() => {});
}

// ── LIVEKIT TOKEN ────────────────────────────────────────────────────────

export async function generateLiveKitToken(meetingId, userId) {
  const meeting = await prisma.meeting.findUnique({ where: { id: meetingId } });
  if (!meeting) throw new AppError("Meeting not found", HttpStatus.NOT_FOUND, ErrorCodes.MEETING_NOT_FOUND);

  const participant = await prisma.participant.findUnique({
    where: { meetingId_userId: { meetingId, userId } },
  });
  if (!participant || participant.leftAt) throw new AppError("You must join the meeting first", HttpStatus.BAD_REQUEST);

  const user = await prisma.user.findUnique({ where: { id: userId }, select: { fullName: true } });

  const token = await livekitToken({
    roomName: meetingId,
    participantName: user.fullName,
    participantId: userId,
    isHost: participant.role === "HOST" || participant.role === "CO_HOST",
  });

  return { token, roomName: meetingId };
}
