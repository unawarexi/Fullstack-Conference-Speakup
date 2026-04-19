// ============================================================================
// SpeakUp — Meeting Service
// Core meeting lifecycle: create, join, leave, end, lock, kick
// Integrates LiveKit, Redis, WebSocket, Kafka, BullMQ
// ============================================================================

import dayjs from "dayjs";
import utc from "dayjs/plugin/utc.js";
import relativeTime from "dayjs/plugin/relativeTime.js";
import duration from "dayjs/plugin/duration.js";
dayjs.extend(utc);
dayjs.extend(relativeTime);
dayjs.extend(duration);

import { prisma } from "../../config/prisma.js";
import { getCache, setCache, deleteCache, deleteCachePattern } from "../../services/redis.service.js";
import { generateToken as livekitToken, deleteRoom, removeParticipant as livekitRemove, listParticipants as livekitParticipants } from "../../services/livekit.service.js";
import { emitToMeeting, emitToUser } from "../../services/websocket.service.js";
import { publishEvent } from "../../services/kafka.service.js";
import { hashPassword, verifyPassword } from "../../services/encryption.service.js";
import { generateUniqueMeetingCode, getMeetingLink, getMeetingDeepLink } from "../../core/utils/meeting-code.js";
import { uploadToCloudinary, deleteFromCloudinary } from "../../services/cloudinary.service.js";
import { CacheTTL, SocketEvents, KafkaTopics, MeetingConfig, ErrorCodes, HttpStatus, AppLinks } from "../../config/constants.js";
import { AppError } from "../../middlewares/errorhandler.middleware.js";
import { queueNotification, queueEmail } from "../../services/workers.js";
import { sendEmail } from "../../services/mailer.service.js";
import emailContent from "../../core/mail/mail-content.js";
import { render } from "../../core/mail/mail-render.js";
import { createLogger } from "../../logs/logger.js";

const log = createLogger("MeetingService");

// Direct email fallback when BullMQ/Redis is unavailable
async function sendEmailDirect(type, to, data) {
  const templateFn = type === "meeting-invite" ? emailContent.meetingInvite : emailContent.meetingInviteDownload;
  const content = templateFn(data);
  const html = render(content);
  await sendEmail({ to, subject: content.EMAIL_TITLE, html });
  log.info("Email sent directly (queue fallback)", { type, to });
}

async function queueOrSendEmail(type, to, data) {
  try {
    await queueEmail(type, to, data);
  } catch (queueErr) {
    log.warn("Queue unavailable, sending email directly", { type, to, error: queueErr.message });
    await sendEmailDirect(type, to, data);
  }
}

// ── helpers ──────────────────────────────────────────────────────────────

function meetingCacheKey(id) { return `meeting:${id}`; }
function participantsCacheKey(id) { return `meeting:${id}:participants`; }

function getMaxParticipants(plan) {
  if (plan === "ENTERPRISE") return MeetingConfig.MAX_PARTICIPANTS_ENTERPRISE;
  if (plan === "PRO") return MeetingConfig.MAX_PARTICIPANTS_PRO;
  return MeetingConfig.MAX_PARTICIPANTS_FREE;
}

/** Enrich meeting response with formatted times via dayjs */
function enrichMeetingTimes(meeting) {
  const now = dayjs();
  const result = { ...meeting };

  if (meeting.scheduledAt) {
    const scheduled = dayjs(meeting.scheduledAt);
    result.formattedScheduledAt = scheduled.format("ddd, MMM D, YYYY h:mm A");
    result.scheduledDate = scheduled.format("YYYY-MM-DD");
    result.scheduledTime = scheduled.format("h:mm A");
    result.timeUntilStart = scheduled.isAfter(now) ? scheduled.fromNow() : null;
    result.isOverdue = scheduled.isBefore(now) && meeting.status === "SCHEDULED";
  }

  if (meeting.scheduledEndAt) {
    const scheduledEnd = dayjs(meeting.scheduledEndAt);
    result.formattedScheduledEndAt = scheduledEnd.format("ddd, MMM D, YYYY h:mm A");
    result.scheduledEndDate = scheduledEnd.format("YYYY-MM-DD");
    result.scheduledEndTime = scheduledEnd.format("h:mm A");
    result.timeUntilEnd = scheduledEnd.isAfter(now) ? scheduledEnd.fromNow() : null;

    // Calculate planned duration from scheduledAt → scheduledEndAt
    if (meeting.scheduledAt) {
      const dur = dayjs.duration(scheduledEnd.diff(dayjs(meeting.scheduledAt)));
      result.plannedDurationMinutes = Math.round(dur.asMinutes());
      result.plannedDurationFormatted = dur.hours() > 0
        ? `${dur.hours()}h ${dur.minutes()}m`
        : `${dur.minutes()}m`;
    }
  }

  if (meeting.startedAt) {
    const started = dayjs(meeting.startedAt);
    result.formattedStartedAt = started.format("ddd, MMM D, YYYY h:mm A");
    if (meeting.endedAt) {
      const ended = dayjs(meeting.endedAt);
      result.formattedEndedAt = ended.format("ddd, MMM D, YYYY h:mm A");
      const dur = dayjs.duration(ended.diff(started));
      result.durationMinutes = Math.round(dur.asMinutes());
      result.durationFormatted = dur.hours() > 0
        ? `${dur.hours()}h ${dur.minutes()}m`
        : `${dur.minutes()}m`;
    } else if (meeting.status === "LIVE") {
      const dur = dayjs.duration(now.diff(started));
      result.elapsedMinutes = Math.round(dur.asMinutes());
      result.elapsedFormatted = dur.hours() > 0
        ? `${dur.hours()}h ${dur.minutes()}m`
        : `${dur.minutes()}m`;
    }
  }

  result.createdAtFormatted = dayjs(meeting.createdAt).format("MMM D, YYYY");

  // Include durationMinutes and compute expected end time for instant meetings
  if (meeting.durationMinutes) {
    result.durationMinutes = meeting.durationMinutes;
    if (meeting.startedAt) {
      const expectedEnd = dayjs(meeting.startedAt).add(meeting.durationMinutes, "minute");
      result.expectedEndAt = expectedEnd.toISOString();
      result.formattedExpectedEndAt = expectedEnd.format("h:mm A");
      if (meeting.status === "LIVE") {
        const remaining = expectedEnd.diff(now, "minute");
        result.remainingMinutes = Math.max(0, remaining);
        result.isExpired = remaining <= 0;
      }
    }
  }

  return result;
}

// ── CREATE ───────────────────────────────────────────────────────────────

export async function createMeeting(userId, data) {
  const code = await generateUniqueMeetingCode(async (c) => {
    const existing = await prisma.meeting.findUnique({ where: { code: c } });
    return !!existing;
  });

  const meetingData = {
    title: data.title,
    description: data.description || null,
    hostId: userId,
    code,
    type: data.type || "INSTANT",
    status: data.type === "SCHEDULED" || data.type === "RECURRING" ? "SCHEDULED" : "LIVE",
    scheduledAt: data.scheduledAt ? new Date(data.scheduledAt) : null,
    scheduledEndAt: data.scheduledEndAt ? new Date(data.scheduledEndAt) : null,
    durationMinutes: data.type === "INSTANT" ? null : (data.durationMinutes || null),
    startedAt: data.type !== "SCHEDULED" && data.type !== "RECURRING" ? new Date() : null,
    maxParticipants: data.maxParticipants || MeetingConfig.DEFAULT_MAX_PARTICIPANTS,
    settings: {
      ...(data.settings || {}),
      ...(data.recurrence ? { recurrence: data.recurrence } : {}),
    },
  };

  if (data.password) {
    meetingData.password = await hashPassword(data.password);
  }

  const meeting = await prisma.meeting.create({
    data: meetingData,
    include: { host: { select: { id: true, fullName: true, avatar: true, email: true } } },
  });

  // Auto-join host as HOST participant for instant meetings
  if (meeting.status === "LIVE") {
    await prisma.participant.create({
      data: { meetingId: meeting.id, userId, role: "HOST" },
    });
  }

  // Handle email invites
  if (data.inviteEmails?.length > 0) {
    await sendMeetingInvites(meeting, data.inviteEmails, meeting.host);
  }

  publishEvent(KafkaTopics.MEETING_EVENTS, meeting.id, { type: "meeting.created", meetingId: meeting.id, userId }).catch(() => {});

  const meetingLink = getMeetingLink(code);
  const deepLink = getMeetingDeepLink(code);

  log.info("Meeting created", { meetingId: meeting.id, code, type: meeting.type });

  // Schedule reminders for scheduled/recurring meetings
  if ((meeting.type === "SCHEDULED" || meeting.type === "RECURRING") && meeting.scheduledAt) {
    await scheduleMeetingReminders(meeting).catch((e) =>
      log.warn("Failed to schedule reminders", { meetingId: meeting.id, error: e })
    );
  }

  // Schedule duration-based expiry and warnings for meetings with a duration
  if (meeting.durationMinutes) {
    await scheduleDurationExpiry(meeting).catch((e) =>
      log.warn("Failed to schedule duration expiry", { meetingId: meeting.id, error: e })
    );
  }

  return enrichMeetingTimes({ ...meeting, password: undefined, meetingLink, deepLink });
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

  const result = enrichMeetingTimes({ ...meeting, password: undefined, participantCount: meeting._count.participants });
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
  return enrichMeetingTimes({ ...meeting, password: undefined, participantCount: meeting._count.participants });
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

  // Auto-transition scheduled meetings to ENDED if their end time has passed
  // Also transition LIVE meetings whose duration has expired
  const now = new Date();
  const expiredIds = [];
  for (const m of meetings) {
    if (m.status === "SCHEDULED" && m.scheduledEndAt && new Date(m.scheduledEndAt) < now) {
      expiredIds.push(m.id);
      m.status = "ENDED";
      m.endedAt = m.scheduledEndAt;
    }
    if (m.status === "LIVE" && m.durationMinutes && m.startedAt) {
      const expectedEnd = new Date(m.startedAt.getTime() + m.durationMinutes * 60 * 1000);
      if (expectedEnd < now) {
        expiredIds.push(m.id);
        m.status = "ENDED";
        m.endedAt = expectedEnd;
      }
    }
  }
  if (expiredIds.length > 0) {
    prisma.meeting.updateMany({
      where: { id: { in: expiredIds } },
      data: { status: "ENDED", endedAt: now },
    }).catch(() => {});
  }

  return {
    meetings: meetings.map((m) => enrichMeetingTimes({ ...m, password: undefined, participantCount: m._count.participants })),
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

  const updateData = {
    title: data.title,
    description: data.description,
    scheduledAt: data.scheduledAt ? new Date(data.scheduledAt) : undefined,
    scheduledEndAt: data.scheduledEndAt === null ? null : data.scheduledEndAt ? new Date(data.scheduledEndAt) : undefined,
    durationMinutes: data.durationMinutes === null ? null : data.durationMinutes || undefined,
    maxParticipants: data.maxParticipants,
    settings: data.settings || data.recurrence
      ? {
          ...(meeting.settings || {}),
          ...(data.settings || {}),
          ...(data.recurrence !== undefined ? { recurrence: data.recurrence } : {}),
        }
      : undefined,
  };

  // Handle password update: null = remove, string = set new, undefined = no change
  if (data.password === null) {
    updateData.password = null;
  } else if (data.password) {
    updateData.password = await hashPassword(data.password);
  }

  const updated = await prisma.meeting.update({
    where: { id: meetingId },
    data: updateData,
    include: {
      host: { select: { id: true, fullName: true, avatar: true } },
      _count: { select: { participants: { where: { leftAt: null } } } },
    },
  });

  await deleteCache(meetingCacheKey(meetingId));

  // Reschedule reminders if scheduledAt changed
  if (data.scheduledAt && (meeting.type === "SCHEDULED" || meeting.type === "RECURRING")) {
    await scheduleMeetingReminders(updated).catch((e) =>
      log.warn("Failed to reschedule reminders", { meetingId, error: e })
    );
  }

  // Handle new email invites
  if (data.inviteEmails?.length > 0) {
    await sendMeetingInvites(updated, data.inviteEmails, updated.host);
  }

  const enriched = enrichMeetingTimes({ ...updated, password: undefined, participantCount: updated._count.participants });
  emitToMeeting(meetingId, SocketEvents.MEETING_UPDATED, { meeting: enriched });

  return enriched;
}

export async function deleteMeeting(meetingId, userId) {
  const meeting = await prisma.meeting.findUnique({
    where: { id: meetingId },
    include: {
      materials: { select: { id: true, url: true } },
      recordings: { select: { id: true, url: true } },
      chatRoom: { select: { id: true } },
      invites: { select: { userId: true, email: true } },
      participants: { select: { userId: true }, where: { leftAt: null } },
    },
  });
  if (!meeting) throw new AppError("Meeting not found", HttpStatus.NOT_FOUND, ErrorCodes.MEETING_NOT_FOUND);
  if (meeting.hostId !== userId) throw new AppError("Only the host can delete this meeting", HttpStatus.FORBIDDEN, ErrorCodes.NOT_MEETING_HOST);

  // ── 1. End the meeting in LiveKit ──
  await deleteRoom(meetingId).catch(() => {});

  // ── 2. Cancel all pending BullMQ reminder jobs ──
  await cancelMeetingReminders(meeting).catch((err) =>
    log.warn("Failed to cancel reminder jobs", { meetingId, error: err.message })
  );

  // ── 3. Delete materials from Cloudinary ──
  for (const material of meeting.materials) {
    try {
      const publicId = material.url.split("/").slice(-2).join("/").split(".")[0];
      await deleteFromCloudinary(publicId, "raw");
    } catch (e) {
      log.warn("Failed to delete material from Cloudinary", { materialId: material.id, error: e.message });
    }
  }

  // ── 4. Delete recordings from Cloudinary ──
  for (const recording of meeting.recordings) {
    try {
      const publicId = recording.url.split("/").slice(-2).join("/").split(".")[0];
      await deleteFromCloudinary(publicId, "video");
    } catch (e) {
      log.warn("Failed to delete recording from Cloudinary", { recordingId: recording.id, error: e.message });
    }
  }

  // ── 5. Delete meeting chat room (and its messages/members via cascade) ──
  if (meeting.chatRoom) {
    await prisma.chatRoom.delete({ where: { id: meeting.chatRoom.id } }).catch((e) =>
      log.warn("Failed to delete chat room", { chatRoomId: meeting.chatRoom.id, error: e.message })
    );
  }

  // ── 6. Notify participants before deleting ──
  emitToMeeting(meetingId, SocketEvents.MEETING_ENDED, { meetingId, reason: "deleted" });

  // ── 7. Delete meeting (cascades: participants, recordings, invites, materials) ──
  await prisma.meeting.delete({ where: { id: meetingId } });

  // ── 8. Clear Redis cache ──
  await deleteCache(meetingCacheKey(meetingId));
  await deleteCachePattern(`meeting:${meetingId}:*`);

  // ── 9. Send cancellation notifications to participants/invitees ──
  const allUserIds = new Set([
    ...meeting.participants.map((p) => p.userId),
    ...meeting.invites.filter((i) => i.userId).map((i) => i.userId),
  ]);
  allUserIds.delete(userId); // Don't notify the host who deleted it

  for (const uid of allUserIds) {
    queueNotification(uid, "MEETING_CANCELLED", "Meeting cancelled",
      `"${meeting.title}" has been cancelled by the host.`,
      { meetingId, meetingCode: meeting.code }
    ).catch(() => {});
  }

  log.info("Meeting deleted with full cleanup", { meetingId });
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

  // Check if user is banned from this meeting
  const ban = await prisma.meetingBan.findUnique({
    where: { meetingId_userId: { meetingId, userId } },
  });
  if (ban) {
    throw new AppError("You are banned from this meeting", HttpStatus.FORBIDDEN, ErrorCodes.BANNED_FROM_MEETING);
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
  if (!participant) return { autoEnded: false };

  await prisma.participant.update({
    where: { id: participant.id },
    data: { leftAt: new Date() },
  });

  await deleteCache(meetingCacheKey(meetingId));
  await deleteCache(participantsCacheKey(meetingId));

  emitToMeeting(meetingId, SocketEvents.PARTICIPANT_LEFT, { userId, meetingId });

  publishEvent(KafkaTopics.PARTICIPANT_EVENTS, meetingId, { type: "participant.left", meetingId, userId }).catch(() => {});

  // ── Auto-end logic ─────────────────────────────────────────────────────
  // 2-person call: auto-end when one leaves (like a phone call)
  // Conference (3+): auto-end only when nobody remains
  const meeting = await prisma.meeting.findUnique({
    where: { id: meetingId },
    include: {
      _count: { select: { participants: { where: { leftAt: null } } } },
      participants: { select: { id: true } },
    },
  });

  if (meeting && meeting.status === "LIVE") {
    const activeCount = meeting._count.participants;
    const totalEverJoined = meeting.participants.length;

    const shouldAutoEnd =
      (totalEverJoined <= 2 && activeCount <= 1) || // 1-on-1 call — other person left
      (activeCount === 0);                           // conference — everyone left

    if (shouldAutoEnd) {
      // Mark any remaining participant as left
      await prisma.participant.updateMany({
        where: { meetingId, leftAt: null },
        data: { leftAt: new Date() },
      });

      const updated = await prisma.meeting.update({
        where: { id: meetingId },
        data: { status: "ENDED", endedAt: new Date(), isRecording: false },
      });

      await cancelMeetingReminders(meeting).catch((err) =>
        log.warn("Failed to cancel reminders on auto-end", { meetingId, error: err.message })
      );

      await deleteRoom(meetingId).catch(() => {});
      await deleteCache(meetingCacheKey(meetingId));
      await deleteCachePattern(`meeting:${meetingId}:*`);

      const reason = totalEverJoined <= 2 ? "call_ended" : "all_left";
      emitToMeeting(meetingId, SocketEvents.MEETING_ENDED, { meetingId, reason, autoEnded: true });

      publishEvent(KafkaTopics.MEETING_EVENTS, meetingId, {
        type: "meeting.ended",
        meetingId,
        reason: "auto_ended",
        duration: updated.startedAt ? Math.floor((updated.endedAt - updated.startedAt) / 1000) : 0,
      }).catch(() => {});

      log.info("Meeting auto-ended", { meetingId, reason, totalEverJoined, activeCount });
      return { autoEnded: true };
    }
  }

  return { autoEnded: false };
}

export async function endMeeting(meetingId, userId) {
  const meeting = await prisma.meeting.findUnique({
    where: { id: meetingId },
    include: { invites: { select: { userId: true, email: true } } },
  });
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

  // Cancel any pending reminder jobs
  await cancelMeetingReminders(meeting).catch((err) =>
    log.warn("Failed to cancel reminders on end", { meetingId, error: err.message })
  );

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

export async function kickParticipant(meetingId, hostId, participantUserId, { ban = false, reason } = {}) {
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

  // Optionally ban from rejoining
  if (ban) {
    await prisma.meetingBan.upsert({
      where: { meetingId_userId: { meetingId, userId: participantUserId } },
      update: { reason, bannedBy: hostId },
      create: { meetingId, userId: participantUserId, bannedBy: hostId, reason },
    });
    emitToMeeting(meetingId, SocketEvents.PARTICIPANT_BANNED, { userId: participantUserId, meetingId, reason });
    emitToUser(participantUserId, SocketEvents.PARTICIPANT_BANNED, { meetingId, reason });
  }

  await deleteCache(participantsCacheKey(meetingId));

  emitToMeeting(meetingId, SocketEvents.PARTICIPANT_KICKED, { userId: participantUserId, meetingId, banned: ban });
  emitToUser(participantUserId, SocketEvents.PARTICIPANT_KICKED, { meetingId, banned: ban });

  const action = ban ? "banned from" : "removed from";
  await queueNotification(participantUserId, "SYSTEM", ban ? "Banned from meeting" : "Removed from meeting",
    `You were ${action} "${meeting.title}"`, { meetingId }).catch(() => {});
}

export async function banParticipant(meetingId, hostId, targetUserId, reason) {
  const meeting = await prisma.meeting.findUnique({ where: { id: meetingId } });
  if (!meeting) throw new AppError("Meeting not found", HttpStatus.NOT_FOUND, ErrorCodes.MEETING_NOT_FOUND);
  if (meeting.hostId !== hostId) throw new AppError("Only the host can ban participants", HttpStatus.FORBIDDEN, ErrorCodes.NOT_MEETING_HOST);

  const ban = await prisma.meetingBan.upsert({
    where: { meetingId_userId: { meetingId, userId: targetUserId } },
    update: { reason, bannedBy: hostId },
    create: { meetingId, userId: targetUserId, bannedBy: hostId, reason },
  });

  // If user is currently in the meeting, kick them out
  const participant = await prisma.participant.findUnique({
    where: { meetingId_userId: { meetingId, userId: targetUserId } },
  });
  if (participant && !participant.leftAt) {
    await prisma.participant.update({ where: { id: participant.id }, data: { leftAt: new Date() } });
    await livekitRemove(meetingId, targetUserId).catch(() => {});
    await deleteCache(participantsCacheKey(meetingId));
  }

  emitToMeeting(meetingId, SocketEvents.PARTICIPANT_BANNED, { userId: targetUserId, meetingId, reason });
  emitToUser(targetUserId, SocketEvents.PARTICIPANT_BANNED, { meetingId, reason });

  await queueNotification(targetUserId, "SYSTEM", "Banned from meeting",
    `You were banned from "${meeting.title}"${reason ? `: ${reason}` : ""}`,
    { meetingId }).catch(() => {});

  return ban;
}

export async function unbanParticipant(meetingId, hostId, targetUserId) {
  const meeting = await prisma.meeting.findUnique({ where: { id: meetingId } });
  if (!meeting) throw new AppError("Meeting not found", HttpStatus.NOT_FOUND, ErrorCodes.MEETING_NOT_FOUND);
  if (meeting.hostId !== hostId) throw new AppError("Only the host can unban participants", HttpStatus.FORBIDDEN, ErrorCodes.NOT_MEETING_HOST);

  await prisma.meetingBan.deleteMany({ where: { meetingId, userId: targetUserId } });

  log.info("Participant unbanned", { meetingId, targetUserId, by: hostId });
}

export async function getMeetingBans(meetingId) {
  return prisma.meetingBan.findMany({
    where: { meetingId },
    include: { user: { select: { id: true, fullName: true, avatar: true } } },
    orderBy: { createdAt: "desc" },
  });
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

// ── MEETING INVITES ──────────────────────────────────────────────────────

// ── MEETING REMINDERS ────────────────────────────────────────────────────

async function scheduleMeetingReminders(meeting) {
  const { addJob } = await import("../../services/bullmq.service.js");
  const scheduledAt = dayjs(meeting.scheduledAt);
  const now = dayjs();

  // Get all invited/accepted participants + host
  const invites = await prisma.meetingInvite.findMany({
    where: { meetingId: meeting.id, status: { in: ["PENDING", "ACCEPTED"] } },
    select: { email: true, userId: true },
  });

  const host = await prisma.user.findUnique({
    where: { id: meeting.hostId },
    select: { id: true, email: true, fullName: true },
  });

  const participantData = { meetingId: meeting.id, meetingTitle: meeting.title, code: meeting.code, hostName: host?.fullName };

  // ── 5 minutes before meeting ──
  const fiveMinBefore = scheduledAt.subtract(5, "minute");
  if (fiveMinBefore.isAfter(now)) {
    const delay = fiveMinBefore.diff(now);

    // Notify host
    if (host) {
      await addJob("NOTIFICATION", `reminder:5min:host:${meeting.id}`, {
        userId: host.id, type: "MEETING_REMINDER",
        title: "Meeting starts in 5 minutes",
        body: `"${meeting.title}" starts in 5 minutes`,
        data: { meetingId: meeting.id, meetingCode: meeting.code, reminderType: "5_MINUTES_BEFORE" },
      }, { delay, jobId: `reminder-5min-host-${meeting.id}` }).catch(() => {});

      await addJob("EMAIL", `reminder:5min:email:host:${meeting.id}`, {
        type: "meeting-reminder", to: host.email,
        data: { ...participantData, inviteeName: host.fullName, reminderType: "5_MINUTES_BEFORE", scheduledTime: scheduledAt.format("h:mm A") },
      }, { delay, jobId: `reminder-5min-email-host-${meeting.id}` }).catch(() => {});
    }

    // Notify invited participants
    for (const invite of invites) {
      if (invite.userId) {
        await addJob("NOTIFICATION", `reminder:5min:${invite.userId}:${meeting.id}`, {
          userId: invite.userId, type: "MEETING_REMINDER",
          title: "Meeting starts in 5 minutes",
          body: `"${meeting.title}" starts in 5 minutes`,
          data: { meetingId: meeting.id, meetingCode: meeting.code, reminderType: "5_MINUTES_BEFORE" },
        }, { delay, jobId: `reminder-5min-${invite.userId}-${meeting.id}` }).catch(() => {});
      }
      if (invite.email) {
        await addJob("EMAIL", `reminder:5min:email:${invite.email}:${meeting.id}`, {
          type: "meeting-reminder", to: invite.email,
          data: { ...participantData, inviteeName: invite.email.split("@")[0], reminderType: "5_MINUTES_BEFORE", scheduledTime: scheduledAt.format("h:mm A") },
        }, { delay, jobId: `reminder-5min-email-${invite.email}-${meeting.id}` }).catch(() => {});
      }
    }
  }

  // ── At meeting start time ──
  if (scheduledAt.isAfter(now)) {
    const startDelay = scheduledAt.diff(now);

    if (host) {
      await addJob("NOTIFICATION", `reminder:start:host:${meeting.id}`, {
        userId: host.id, type: "MEETING_REMINDER",
        title: "Meeting is starting now",
        body: `"${meeting.title}" is starting now. Join to begin!`,
        data: { meetingId: meeting.id, meetingCode: meeting.code, reminderType: "MEETING_STARTING" },
      }, { delay: startDelay, jobId: `reminder-start-host-${meeting.id}` }).catch(() => {});
    }

    for (const invite of invites) {
      if (invite.userId) {
        await addJob("NOTIFICATION", `reminder:start:${invite.userId}:${meeting.id}`, {
          userId: invite.userId, type: "MEETING_REMINDER",
          title: "Meeting is starting now",
          body: `"${meeting.title}" is starting now`,
          data: { meetingId: meeting.id, meetingCode: meeting.code, reminderType: "MEETING_STARTING" },
        }, { delay: startDelay, jobId: `reminder-start-${invite.userId}-${meeting.id}` }).catch(() => {});
      }
    }
  }

  log.info("Meeting reminders scheduled", { meetingId: meeting.id, scheduledAt: scheduledAt.toISOString() });
}

// ── CANCEL MEETING REMINDERS ─────────────────────────────────────────────

async function cancelMeetingReminders(meeting) {
  const { removeJob } = await import("../../services/bullmq.service.js");

  // Collect all job IDs that may have been scheduled for this meeting
  const jobIds = [
    { queue: "NOTIFICATION", id: `reminder-5min-host-${meeting.id}` },
    { queue: "NOTIFICATION", id: `reminder-start-host-${meeting.id}` },
    { queue: "EMAIL", id: `reminder-5min-email-host-${meeting.id}` },
  ];

  // Add participant/invitee-specific reminder jobs
  const invites = meeting.invites || [];
  for (const invite of invites) {
    if (invite.userId) {
      jobIds.push({ queue: "NOTIFICATION", id: `reminder-5min-${invite.userId}-${meeting.id}` });
      jobIds.push({ queue: "NOTIFICATION", id: `reminder-start-${invite.userId}-${meeting.id}` });
    }
    if (invite.email) {
      jobIds.push({ queue: "EMAIL", id: `reminder-5min-email-${invite.email}-${meeting.id}` });
      jobIds.push({ queue: "EMAIL", id: `reminder-start-email-${invite.email}-${meeting.id}` });
    }
  }

  // Remove all jobs in parallel
  await Promise.allSettled(
    jobIds.map(({ queue, id }) => removeJob(queue, id))
  );

  log.info("Meeting reminders cancelled", { meetingId: meeting.id, jobCount: jobIds.length });
}

// ── SCHEDULE DURATION-BASED EXPIRY AND WARNINGS ─────────────────────────

async function scheduleDurationExpiry(meeting) {
  const { addJob } = await import("../../services/bullmq.service.js");
  const startTime = meeting.startedAt ? dayjs(meeting.startedAt) : dayjs();
  const durationMs = meeting.durationMinutes * 60 * 1000;
  const now = dayjs();

  const host = await prisma.user.findUnique({
    where: { id: meeting.hostId },
    select: { id: true, email: true, fullName: true },
  });

  // ── Warning at 5 minutes before end ──
  if (meeting.durationMinutes > 5) {
    const warningTime = startTime.add(meeting.durationMinutes - 5, "minute");
    const warningDelay = warningTime.diff(now);
    if (warningDelay > 0) {
      // Push notification to host
      await addJob("NOTIFICATION", `duration:warn:host:${meeting.id}`, {
        userId: meeting.hostId, type: "MEETING_REMINDER",
        title: "Meeting ending in 5 minutes",
        body: `"${meeting.title}" will end in 5 minutes`,
        data: { meetingId: meeting.id, meetingCode: meeting.code, reminderType: "DURATION_WARNING" },
      }, { delay: warningDelay, jobId: `duration-warn-host-${meeting.id}` }).catch(() => {});

      // Email warning to host
      if (host?.email) {
        await addJob("EMAIL", `duration:warn:email:${meeting.id}`, {
          type: "meeting-duration-warning", to: host.email,
          data: {
            meetingId: meeting.id, meetingTitle: meeting.title,
            code: meeting.code, hostName: host.fullName,
            durationMinutes: meeting.durationMinutes,
            remainingMinutes: 5,
          },
        }, { delay: warningDelay, jobId: `duration-warn-email-${meeting.id}` }).catch(() => {});
      }

      // WebSocket warning to all participants
      await addJob("NOTIFICATION", `duration:warn:ws:${meeting.id}`, {
        userId: "__broadcast__", type: "MEETING_REMINDER",
        title: "Meeting ending soon",
        body: `This meeting will end in 5 minutes`,
        data: { meetingId: meeting.id, reminderType: "DURATION_WARNING", broadcastToMeeting: true },
      }, { delay: warningDelay, jobId: `duration-warn-ws-${meeting.id}` }).catch(() => {});
    }
  }

  // ── Auto-end at duration expiry ──
  const expiryDelay = startTime.add(meeting.durationMinutes, "minute").diff(now);
  if (expiryDelay > 0) {
    await addJob("NOTIFICATION", `duration:expire:${meeting.id}`, {
      userId: meeting.hostId, type: "MEETING_REMINDER",
      title: "Meeting time is up",
      body: `"${meeting.title}" has reached its ${meeting.durationMinutes}-minute limit and has ended.`,
      data: { meetingId: meeting.id, meetingCode: meeting.code, reminderType: "DURATION_EXPIRED" },
    }, { delay: expiryDelay, jobId: `duration-expire-${meeting.id}` }).catch(() => {});

    if (host?.email) {
      await addJob("EMAIL", `duration:expire:email:${meeting.id}`, {
        type: "meeting-duration-expired", to: host.email,
        data: {
          meetingId: meeting.id, meetingTitle: meeting.title,
          code: meeting.code, hostName: host.fullName,
          durationMinutes: meeting.durationMinutes,
        },
      }, { delay: expiryDelay, jobId: `duration-expire-email-${meeting.id}` }).catch(() => {});
    }
  }

  log.info("Duration expiry scheduled", { meetingId: meeting.id, durationMinutes: meeting.durationMinutes });
}

// ── RECREATE MEETING ─────────────────────────────────────────────────────

export async function recreateMeeting(originalMeetingId, userId, overrides = {}) {
  const original = await prisma.meeting.findUnique({
    where: { id: originalMeetingId },
    include: {
      host: { select: { id: true, fullName: true, avatar: true, email: true } },
      materials: { select: { name: true, url: true, type: true, sizeBytes: true } },
    },
  });

  if (!original) throw new AppError("Meeting not found", HttpStatus.NOT_FOUND, ErrorCodes.MEETING_NOT_FOUND);
  if (original.hostId !== userId) throw new AppError("Only the host can recreate this meeting", HttpStatus.FORBIDDEN, ErrorCodes.NOT_MEETING_HOST);
  if (original.status !== "ENDED" && original.status !== "CANCELLED") {
    throw new AppError("Only past meetings can be recreated", HttpStatus.BAD_REQUEST);
  }

  const newData = {
    title: overrides.title || original.title,
    description: overrides.description !== undefined ? overrides.description : original.description,
    type: overrides.type || original.type,
    maxParticipants: original.maxParticipants,
    durationMinutes: overrides.durationMinutes || original.durationMinutes,
    settings: { ...(original.settings || {}) },
  };

  // Remove recurrence from settings if present (clean copy)
  if (newData.settings.recurrence) delete newData.settings.recurrence;

  // For scheduled: require new scheduledAt, or default to now + 1 hour
  if (newData.type === "SCHEDULED") {
    newData.scheduledAt = overrides.scheduledAt
      ? new Date(overrides.scheduledAt).toISOString()
      : new Date(Date.now() + 60 * 60 * 1000).toISOString();
    if (overrides.scheduledEndAt) {
      newData.scheduledEndAt = new Date(overrides.scheduledEndAt).toISOString();
    }
  }

  // Create as a new meeting via the existing createMeeting flow
  const newMeeting = await createMeeting(userId, newData);

  // If user wants to carry over materials, copy the references
  if (overrides.copyMaterials && original.materials.length > 0) {
    for (const mat of original.materials) {
      await prisma.meetingMaterial.create({
        data: {
          meetingId: newMeeting.id,
          userId,
          name: mat.name,
          url: mat.url,
          type: mat.type,
          sizeBytes: mat.sizeBytes,
        },
      }).catch((e) => log.warn("Failed to copy material", { name: mat.name, error: e }));
    }
  }

  log.info("Meeting recreated", { originalId: originalMeetingId, newId: newMeeting.id });
  return newMeeting;
}

async function sendMeetingInvites(meeting, emails, host) {
  const uniqueEmails = [...new Set(emails.map((e) => e.toLowerCase().trim()))];
  const isInstant = meeting.type === "INSTANT";
  let successCount = 0;
  let failCount = 0;

  for (const email of uniqueEmails) {
    try {
      // Check if user exists to link invite
      const existingUser = await prisma.user.findUnique({ where: { email }, select: { id: true, fullName: true } });

      const invite = await prisma.meetingInvite.upsert({
        where: { meetingId_email: { meetingId: meeting.id, email } },
        update: { status: "PENDING", sentAt: new Date() },
        create: {
          meetingId: meeting.id,
          email,
          userId: existingUser?.id || null,
          status: "PENDING",
        },
      });

      // Queue invite email
      const meetingDate = meeting.scheduledAt
        ? new Date(meeting.scheduledAt).toLocaleDateString("en-US", { weekday: "long", year: "numeric", month: "long", day: "numeric" })
        : "Now";
      const meetingTime = meeting.scheduledAt
        ? new Date(meeting.scheduledAt).toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit" })
        : "Instant";

      if (existingUser) {
        // ── Registered user: standard meeting invite + push notification ──
        await queueOrSendEmail("meeting-invite", email, {
          title: meeting.title,
          hostName: host.fullName,
          inviteeName: existingUser.fullName || email.split("@")[0],
          inviteeId: existingUser.id,
          date: meetingDate,
          time: meetingTime,
          code: meeting.code,
          meetingId: meeting.id,
          inviteToken: invite.token,
          isInstant,
        }).catch((e) => log.error("Failed to send invite email", { email, error: e.message || e }));

        // Send in-app notification + push (they have the app)
        try {
          await queueNotification(
            existingUser.id,
            "MEETING_INVITE",
            isInstant ? "Incoming Call" : "Meeting Invitation",
            isInstant
              ? `${host.fullName} is calling you on SpeakUp`
              : `${host.fullName} invited you to "${meeting.title}"`,
            { meetingId: meeting.id, meetingCode: meeting.code, inviteToken: invite.token, isInstant, hostName: host.fullName, hostAvatar: host.avatar || "" },
          );
        } catch (queueErr) {
          // Queue failed — send notification directly (bypassing BullMQ)
          log.warn("Queue unavailable for notification, sending directly", { userId: existingUser.id, error: queueErr.message });
          try {
            const { createNotification } = await import("../notification/notification.service.js");
            await createNotification(existingUser.id, {
              type: "MEETING_INVITE",
              title: isInstant ? "Incoming Call" : "Meeting Invitation",
              body: isInstant
                ? `${host.fullName} is calling you on SpeakUp`
                : `${host.fullName} invited you to "${meeting.title}"`,
              data: { meetingId: meeting.id, meetingCode: meeting.code, inviteToken: invite.token, isInstant, hostName: host.fullName, hostAvatar: host.avatar || "" },
            });
          } catch (directErr) {
            log.error("Failed to send invite notification directly", { userId: existingUser.id, error: directErr.message || directErr });
          }
        }
      } else {
        // ── Unregistered user: send app download invite with host profile ──
        await queueOrSendEmail("meeting-invite-download", email, {
          title: meeting.title,
          hostName: host.fullName,
          hostEmail: host.email,
          hostAvatar: host.avatar || null,
          inviteeName: email.split("@")[0],
          date: meetingDate,
          time: meetingTime,
          code: meeting.code,
          meetingId: meeting.id,
          inviteToken: invite.token,
          isInstant,
          appLinks: {
            googlePlay: AppLinks.GOOGLE_PLAY,
            appleStore: AppLinks.APPLE_STORE,
            webApp: AppLinks.WEB_APP,
          },
        }).catch((e) => log.error("Failed to send download invite email", { email, error: e.message || e }));
      }
      successCount++;
    } catch (e) {
      failCount++;
      log.error("Failed to send invite", { email, meetingId: meeting.id, error: e.message || e });
    }
  }

  log.info("Meeting invites processed", { meetingId: meeting.id, total: uniqueEmails.length, success: successCount, failed: failCount });
}

export async function respondToInvite(token, userId, response) {
  const invite = await prisma.meetingInvite.findUnique({ where: { token } });
  if (!invite) throw new AppError("Invite not found", HttpStatus.NOT_FOUND);
  if (invite.status !== "PENDING") throw new AppError("Invite already responded to", HttpStatus.BAD_REQUEST);

  const status = response === "accept" ? "ACCEPTED" : "DECLINED";
  await prisma.meetingInvite.update({
    where: { id: invite.id },
    data: { status, respondedAt: new Date(), userId: userId || invite.userId },
  });

  // Notify host
  const meeting = await prisma.meeting.findUnique({ where: { id: invite.meetingId }, select: { hostId: true, title: true } });
  if (meeting) {
    const action = status === "ACCEPTED" ? "accepted" : "declined";
    await queueNotification(
      meeting.hostId,
      status === "ACCEPTED" ? "INVITE_ACCEPTED" : "INVITE_DECLINED",
      `Invite ${action}`,
      `${invite.email} ${action} your invitation to "${meeting.title}"`,
      { meetingId: invite.meetingId },
    ).catch(() => {});
  }

  return { status };
}

export async function getMeetingInvites(meetingId, userId) {
  const meeting = await prisma.meeting.findUnique({ where: { id: meetingId } });
  if (!meeting) throw new AppError("Meeting not found", HttpStatus.NOT_FOUND, ErrorCodes.MEETING_NOT_FOUND);
  if (meeting.hostId !== userId) throw new AppError("Only the host can view invites", HttpStatus.FORBIDDEN, ErrorCodes.NOT_MEETING_HOST);

  return prisma.meetingInvite.findMany({
    where: { meetingId },
    orderBy: { sentAt: "desc" },
  });
}

// ── MEETING MATERIALS ────────────────────────────────────────────────────

export async function uploadMaterial(meetingId, userId, file) {
  const meeting = await prisma.meeting.findUnique({ where: { id: meetingId } });
  if (!meeting) throw new AppError("Meeting not found", HttpStatus.NOT_FOUND, ErrorCodes.MEETING_NOT_FOUND);

  // Only host or active participants can upload
  const isHost = meeting.hostId === userId;
  if (!isHost) {
    const participant = await prisma.participant.findUnique({
      where: { meetingId_userId: { meetingId, userId } },
    });
    if (!participant || participant.leftAt) {
      throw new AppError("You must be a participant to upload materials", HttpStatus.FORBIDDEN);
    }
  }

  const uploaded = await uploadToCloudinary(file.buffer, file.originalname, `speakup/meetings/${meetingId}`);

  const material = await prisma.meetingMaterial.create({
    data: {
      meetingId,
      userId,
      name: file.originalname,
      url: uploaded.url,
      type: file.mimetype,
      sizeBytes: BigInt(uploaded.bytes || file.size || 0),
    },
    include: { user: { select: { id: true, fullName: true, avatar: true } } },
  });

  emitToMeeting(meetingId, SocketEvents.MEETING_UPDATED, {
    type: "material.uploaded",
    material: { ...material, sizeBytes: Number(material.sizeBytes) },
  });

  log.info("Material uploaded", { meetingId, materialId: material.id, name: file.originalname });
  return { ...material, sizeBytes: Number(material.sizeBytes) };
}

export async function getMeetingMaterials(meetingId, userId) {
  const meeting = await prisma.meeting.findUnique({ where: { id: meetingId } });
  if (!meeting) throw new AppError("Meeting not found", HttpStatus.NOT_FOUND, ErrorCodes.MEETING_NOT_FOUND);

  const materials = await prisma.meetingMaterial.findMany({
    where: { meetingId },
    include: { user: { select: { id: true, fullName: true, avatar: true } } },
    orderBy: { createdAt: "desc" },
  });

  return materials.map((m) => ({ ...m, sizeBytes: Number(m.sizeBytes) }));
}

export async function getMaterialById(materialId, userId) {
  const material = await prisma.meetingMaterial.findUnique({
    where: { id: materialId },
    include: {
      user: { select: { id: true, fullName: true, avatar: true } },
      meeting: { select: { id: true, title: true, hostId: true } },
    },
  });

  if (!material) throw new AppError("Material not found", HttpStatus.NOT_FOUND);
  return { ...material, sizeBytes: Number(material.sizeBytes) };
}

export async function deleteMaterial(materialId, userId) {
  const material = await prisma.meetingMaterial.findUnique({
    where: { id: materialId },
    include: { meeting: { select: { hostId: true } } },
  });

  if (!material) throw new AppError("Material not found", HttpStatus.NOT_FOUND);

  // Only uploader or meeting host can delete
  if (material.userId !== userId && material.meeting.hostId !== userId) {
    throw new AppError("You can only delete your own materials", HttpStatus.FORBIDDEN);
  }

  // Delete from Cloudinary
  try {
    const publicId = material.url.split("/").slice(-2).join("/").split(".")[0];
    await deleteFromCloudinary(publicId, "raw");
  } catch (e) {
    log.warn("Failed to delete material from Cloudinary", { materialId, error: e });
  }

  await prisma.meetingMaterial.delete({ where: { id: materialId } });

  emitToMeeting(material.meetingId, SocketEvents.MEETING_UPDATED, {
    type: "material.deleted",
    materialId,
  });

  log.info("Material deleted", { materialId, meetingId: material.meetingId });
}
