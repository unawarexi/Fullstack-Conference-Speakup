// ============================================================================
// SpeakUp — Room Service
// Handles real-time room state synced with LiveKit
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { getCache, setCache, deleteCache } from "../../services/redis.service.js";
import { listParticipants as lkParticipants, muteParticipant } from "../../services/livekit.service.js";
import { emitToMeeting } from "../../services/websocket.service.js";
import { publishEvent } from "../../services/kafka.service.js";
import { forbidden, notFound } from "../../middlewares/errorhandler.middleware.js";
import { CacheTTL, SocketEvents, KafkaTopics } from "../../config/constants.js";

export async function getRoomState(meetingId, userId) {
  const meeting = await prisma.meeting.findUnique({
    where: { id: meetingId },
    select: {
      id: true, title: true, code: true, status: true, type: true,
      hostId: true, isLocked: true, allowScreenShare: true,
      allowChat: true, allowRecording: true, waitingRoom: true,
      maxParticipants: true, startedAt: true,
    },
  });
  if (!meeting) throw notFound("Meeting not found");

  const participant = await prisma.participant.findUnique({
    where: { meetingId_userId: { meetingId, userId } },
  });
  if (!participant || participant.leftAt) throw forbidden("Not a participant of this meeting");

  let liveParticipants = [];
  try {
    liveParticipants = await lkParticipants(meetingId);
  } catch (_) { /* LiveKit room may not exist yet */ }

  const dbParticipants = await prisma.participant.findMany({
    where: { meetingId, leftAt: null },
    include: { user: { select: { id: true, fullName: true, avatar: true } } },
  });

  const liveMap = new Map(liveParticipants.map(p => [p.identity, p]));
  const participants = dbParticipants.map(p => ({
    id: p.id,
    userId: p.userId,
    displayName: p.user.fullName,
    avatar: p.user.avatar,
    role: p.role,
    isMuted: liveMap.get(p.userId)?.isSpeaking === false,
    isVideoOn: liveMap.get(p.userId)?.tracks?.some(t => t.source === "CAMERA" && !t.muted) ?? false,
    isScreenSharing: liveMap.get(p.userId)?.tracks?.some(t => t.source === "SCREEN_SHARE") ?? false,
    joinedAt: p.joinedAt,
  }));

  return {
    meeting,
    participants,
    myRole: participant.role,
    participantCount: participants.length,
  };
}

export async function updateRoomSettings(meetingId, userId, settings) {
  const meeting = await prisma.meeting.findUnique({ where: { id: meetingId } });
  if (!meeting) throw notFound("Meeting not found");
  if (meeting.hostId !== userId) throw forbidden("Only the host can update room settings");

  const allowedFields = ["allowScreenShare", "allowChat", "allowRecording", "waitingRoom", "maxParticipants"];
  const data = {};
  for (const key of allowedFields) {
    if (settings[key] !== undefined) data[key] = settings[key];
  }

  const updated = await prisma.meeting.update({ where: { id: meetingId }, data });
  await deleteCache(`meeting:${meetingId}`);

  emitToMeeting(meetingId, SocketEvents.ROOM_SETTINGS_UPDATED, {
    meetingId,
    settings: data,
    updatedBy: userId,
  });

  return updated;
}

export async function muteAllParticipants(meetingId, userId) {
  const meeting = await prisma.meeting.findUnique({ where: { id: meetingId } });
  if (!meeting) throw notFound("Meeting not found");
  if (meeting.hostId !== userId) throw forbidden("Only the host can mute all");

  let participants = [];
  try {
    participants = await lkParticipants(meetingId);
  } catch (_) { return; }

  const mutePromises = participants
    .filter(p => p.identity !== userId)
    .map(p => muteParticipant(meetingId, p.identity, "MICROPHONE", true).catch(() => {}));

  await Promise.allSettled(mutePromises);

  emitToMeeting(meetingId, SocketEvents.ALL_MUTED, { meetingId, mutedBy: userId });
  await publishEvent(KafkaTopics.MEETING_EVENTS, meetingId, { type: "meeting.mute_all", meetingId, userId });
}

export async function getActiveRooms(userId) {
  const cacheKey = `user:${userId}:active-rooms`;
  const cached = await getCache(cacheKey);
  if (cached) return cached;

  const active = await prisma.participant.findMany({
    where: { userId, leftAt: null },
    include: {
      meeting: {
        select: {
          id: true, title: true, code: true, status: true, hostId: true,
          _count: { select: { participants: { where: { leftAt: null } } } },
        },
      },
    },
    orderBy: { joinedAt: "desc" },
  });

  const rooms = active
    .filter(p => p.meeting.status === "ACTIVE" || p.meeting.status === "SCHEDULED")
    .map(p => ({
      meetingId: p.meeting.id,
      title: p.meeting.title,
      code: p.meeting.code,
      status: p.meeting.status,
      isHost: p.meeting.hostId === userId,
      role: p.role,
      participantCount: p.meeting._count.participants,
      joinedAt: p.joinedAt,
    }));

  await setCache(cacheKey, rooms, CacheTTL.PARTICIPANTS);
  return rooms;
}
