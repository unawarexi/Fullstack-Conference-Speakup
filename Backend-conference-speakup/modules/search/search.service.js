// ============================================================================
// SpeakUp — Search Service
// Full-text user & meeting search with access control
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { getCache, setCache } from "../../services/redis.service.js";
import { Pagination } from "../../config/constants.js";

export async function searchUsers(query, { page = 1, limit = 20 }) {
  if (!query || query.trim().length < 2) return { users: [], total: 0, page: 1, totalPages: 0 };

  const take = Math.min(parseInt(limit) || 20, Pagination.MAX_PAGE_SIZE);
  const skip = (Math.max(parseInt(page) || 1, 1) - 1) * take;
  const term = `%${query.trim()}%`;

  const where = {
    OR: [
      { fullName: { contains: query.trim(), mode: "insensitive" } },
      { email: { contains: query.trim(), mode: "insensitive" } },
    ],
  };

  const [users, total] = await Promise.all([
    prisma.user.findMany({
      where,
      select: {
        id: true,
        fullName: true,
        avatar: true,
        isOnline: true,
        lastSeenAt: true,
      },
      take,
      skip,
      orderBy: { fullName: "asc" },
    }),
    prisma.user.count({ where }),
  ]);

  return {
    users,
    total,
    page: Math.max(parseInt(page) || 1, 1),
    totalPages: Math.ceil(total / take),
  };
}

export async function searchMeetings(userId, query, { page = 1, limit = 20, status }) {
  if (!query || query.trim().length < 2) return { meetings: [], total: 0, page: 1, totalPages: 0 };

  const take = Math.min(parseInt(limit) || 20, Pagination.MAX_PAGE_SIZE);
  const skip = (Math.max(parseInt(page) || 1, 1) - 1) * take;

  const where = {
    AND: [
      {
        OR: [
          { hostId: userId },
          { participants: { some: { userId } } },
        ],
      },
      {
        OR: [
          { title: { contains: query.trim(), mode: "insensitive" } },
          { code: { contains: query.trim(), mode: "insensitive" } },
        ],
      },
    ],
  };

  if (status) where.AND.push({ status });

  const [meetings, total] = await Promise.all([
    prisma.meeting.findMany({
      where,
      select: {
        id: true,
        title: true,
        code: true,
        type: true,
        status: true,
        scheduledAt: true,
        hostId: true,
        createdAt: true,
        host: { select: { id: true, fullName: true, avatar: true } },
        _count: { select: { participants: true } },
      },
      take,
      skip,
      orderBy: { createdAt: "desc" },
    }),
    prisma.meeting.count({ where }),
  ]);

  return {
    meetings: meetings.map(m => ({
      ...m,
      isHost: m.hostId === userId,
      participantCount: m._count.participants,
      _count: undefined,
    })),
    total,
    page: Math.max(parseInt(page) || 1, 1),
    totalPages: Math.ceil(total / take),
  };
}

export async function globalSearch(userId, query, { page = 1, limit = 10 }) {
  const [users, meetings] = await Promise.all([
    searchUsers(query, { page: 1, limit: 5 }),
    searchMeetings(userId, query, { page: 1, limit: 5 }),
  ]);

  return { users: users.users, meetings: meetings.meetings };
}
