// ============================================================================
// SpeakUp — Analytics Service
// Aggregate meeting stats, user usage, admin dashboard
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { getCache, setCache } from "../../services/redis.service.js";
import { CacheTTL } from "../../config/constants.js";

export async function getMeetingAnalytics(meetingId, userId) {
  const meeting = await prisma.meeting.findUnique({
    where: { id: meetingId },
    select: { id: true, hostId: true },
  });
  if (!meeting || meeting.hostId !== userId) return null;

  const cacheKey = `analytics:meeting:${meetingId}`;
  const cached = await getCache(cacheKey);
  if (cached) return cached;

  const [participantStats, recordingStats, messageCount] = await Promise.all([
    prisma.participant.aggregate({
      where: { meetingId },
      _count: true,
      _max: { leftAt: true },
      _min: { joinedAt: true },
    }),
    prisma.recording.aggregate({
      where: { meetingId },
      _count: true,
      _sum: { duration: true, fileSize: true },
    }),
    prisma.message.count({
      where: { chatRoom: { meetingId } },
    }),
  ]);

  const uniqueParticipants = await prisma.participant.groupBy({
    by: ["userId"],
    where: { meetingId },
  });

  const analytics = {
    meetingId,
    totalJoins: participantStats._count,
    uniqueParticipants: uniqueParticipants.length,
    firstJoin: participantStats._min.joinedAt,
    lastLeave: participantStats._max.leftAt,
    recordings: recordingStats._count,
    totalRecordingDuration: recordingStats._sum.duration || 0,
    totalRecordingSize: recordingStats._sum.fileSize || 0,
    messageCount,
  };

  await setCache(cacheKey, analytics, CacheTTL.ANALYTICS);
  return analytics;
}

export async function getUserUsage(userId, { from, to } = {}) {
  const cacheKey = `analytics:user:${userId}:${from || "all"}:${to || "now"}`;
  const cached = await getCache(cacheKey);
  if (cached) return cached;

  const dateFilter = {};
  if (from) dateFilter.gte = new Date(from);
  if (to) dateFilter.lte = new Date(to);
  const createdFilter = Object.keys(dateFilter).length ? { createdAt: dateFilter } : {};

  const [meetingsHosted, meetingsAttended, recordings, totalMinutes] = await Promise.all([
    prisma.meeting.count({ where: { hostId: userId, ...createdFilter } }),
    prisma.participant.count({
      where: {
        userId,
        meeting: { hostId: { not: userId } },
        ...(Object.keys(dateFilter).length ? { joinedAt: dateFilter } : {}),
      },
    }),
    prisma.recording.count({ where: { userId, ...createdFilter } }),
    prisma.participant.findMany({
      where: {
        userId,
        leftAt: { not: null },
        ...(Object.keys(dateFilter).length ? { joinedAt: dateFilter } : {}),
      },
      select: { joinedAt: true, leftAt: true },
    }),
  ]);

  const totalMs = totalMinutes.reduce((sum, p) => {
    return sum + (p.leftAt.getTime() - p.joinedAt.getTime());
  }, 0);

  const usage = {
    meetingsHosted,
    meetingsAttended,
    totalMeetings: meetingsHosted + meetingsAttended,
    recordings,
    totalMinutes: Math.round(totalMs / 60000),
  };

  await setCache(cacheKey, usage, CacheTTL.ANALYTICS);
  return usage;
}

export async function getDashboard(userId) {
  const cacheKey = `analytics:dashboard:${userId}`;
  const cached = await getCache(cacheKey);
  if (cached) return cached;

  const now = new Date();
  const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

  const [usage, recentMeetings, upcomingMeetings, subscription] = await Promise.all([
    getUserUsage(userId, { from: thirtyDaysAgo.toISOString() }),
    prisma.meeting.findMany({
      where: { hostId: userId, status: "ENDED" },
      orderBy: { endedAt: "desc" },
      take: 5,
      select: {
        id: true, title: true, code: true, endedAt: true,
        _count: { select: { participants: true } },
      },
    }),
    prisma.meeting.findMany({
      where: {
        OR: [
          { hostId: userId },
          { participants: { some: { userId } } },
        ],
        status: "SCHEDULED",
        scheduledAt: { gte: now },
      },
      orderBy: { scheduledAt: "asc" },
      take: 5,
      select: { id: true, title: true, code: true, scheduledAt: true, hostId: true },
    }),
    prisma.subscription.findUnique({ where: { userId }, select: { plan: true, status: true, currentPeriodEnd: true } }),
  ]);

  const dashboard = {
    usage,
    subscription: subscription || { plan: "FREE", status: "ACTIVE" },
    recentMeetings: recentMeetings.map(m => ({
      ...m,
      participantCount: m._count.participants,
      _count: undefined,
    })),
    upcomingMeetings: upcomingMeetings.map(m => ({
      ...m,
      isHost: m.hostId === userId,
      hostId: undefined,
    })),
  };

  await setCache(cacheKey, dashboard, CacheTTL.ANALYTICS);
  return dashboard;
}
