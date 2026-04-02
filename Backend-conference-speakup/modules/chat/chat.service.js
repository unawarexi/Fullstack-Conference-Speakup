// ============================================================================
// SpeakUp — Chat Service
// Cursor-based pagination, WebSocket real-time, Kafka analytics
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { getCache, setCache, deleteCache } from "../../services/redis.service.js";
import { emitToMeeting, emitToUser } from "../../services/websocket.service.js";
import { publishEvent } from "../../services/kafka.service.js";
import { badRequest, forbidden, notFound } from "../../middlewares/errorhandler.middleware.js";
import { CacheTTL, SocketEvents, KafkaTopics, Pagination } from "../../config/constants.js";

export async function getOrCreateMeetingChat(meetingId, userId) {
  const meeting = await prisma.meeting.findUnique({ where: { id: meetingId } });
  if (!meeting) throw notFound("Meeting not found");

  const participant = await prisma.participant.findUnique({
    where: { meetingId_userId: { meetingId, userId } },
  });
  if (!participant || participant.leftAt) throw forbidden("Not a participant");

  let chatRoom = await prisma.chatRoom.findFirst({
    where: { meetingId, isGroup: true },
  });

  if (!chatRoom) {
    chatRoom = await prisma.chatRoom.create({
      data: {
        meetingId,
        name: meeting.title,
        isGroup: true,
        members: {
          create: { userId, role: meeting.hostId === userId ? "ADMIN" : "MEMBER" },
        },
      },
    });
  } else {
    await prisma.chatMember.upsert({
      where: { chatRoomId_userId: { chatRoomId: chatRoom.id, userId } },
      update: {},
      create: { chatRoomId: chatRoom.id, userId, role: meeting.hostId === userId ? "ADMIN" : "MEMBER" },
    });
  }

  return chatRoom;
}

export async function getMessages(chatRoomId, userId, { cursor, limit = Pagination.DEFAULT_PAGE_SIZE }) {
  const member = await prisma.chatMember.findUnique({
    where: { chatRoomId_userId: { chatRoomId, userId } },
  });
  if (!member) throw forbidden("Not a member of this chat");

  const take = Math.min(parseInt(limit) || Pagination.DEFAULT_PAGE_SIZE, Pagination.MAX_PAGE_SIZE);
  const where = { chatRoomId };
  if (cursor) where.id = { lt: cursor };

  const messages = await prisma.message.findMany({
    where,
    take: take + 1,
    orderBy: { createdAt: "desc" },
    include: {
      sender: { select: { id: true, fullName: true, avatar: true } },
    },
  });

  const hasMore = messages.length > take;
  if (hasMore) messages.pop();

  return {
    messages: messages.reverse(),
    hasMore,
    nextCursor: hasMore ? messages[0]?.id : null,
  };
}

export async function sendMessage(chatRoomId, userId, { content, type = "TEXT", replyToId }) {
  const member = await prisma.chatMember.findUnique({
    where: { chatRoomId_userId: { chatRoomId, userId } },
  });
  if (!member) throw forbidden("Not a member of this chat");

  const chatRoom = await prisma.chatRoom.findUnique({
    where: { id: chatRoomId },
    select: { meetingId: true },
  });

  if (!content?.trim() && type === "TEXT") throw badRequest("Message content is required");

  if (replyToId) {
    const parent = await prisma.message.findUnique({ where: { id: replyToId } });
    if (!parent || parent.chatRoomId !== chatRoomId) throw badRequest("Invalid reply target");
  }

  const message = await prisma.message.create({
    data: {
      chatRoomId,
      senderId: userId,
      content: content.trim(),
      type,
      replyToId: replyToId || null,
    },
    include: {
      sender: { select: { id: true, fullName: true, avatar: true } },
    },
  });

  if (chatRoom?.meetingId) {
    emitToMeeting(chatRoom.meetingId, SocketEvents.CHAT_MESSAGE, { message });
  }

  await publishEvent(KafkaTopics.CHAT_MESSAGES, chatRoomId, {
    chatRoomId,
    messageId: message.id,
    senderId: userId,
    meetingId: chatRoom?.meetingId,
    type,
  });

  return message;
}

export async function deleteMessage(messageId, userId) {
  const message = await prisma.message.findUnique({
    where: { id: messageId },
    include: { chatRoom: { select: { meetingId: true } } },
  });
  if (!message) throw notFound("Message not found");
  if (message.senderId !== userId) {
    const member = await prisma.chatMember.findUnique({
      where: { chatRoomId_userId: { chatRoomId: message.chatRoomId, userId } },
    });
    if (!member || member.role !== "ADMIN") throw forbidden("Cannot delete this message");
  }

  await prisma.message.delete({ where: { id: messageId } });

  if (message.chatRoom?.meetingId) {
    emitToMeeting(message.chatRoom.meetingId, SocketEvents.CHAT_MESSAGE_DELETED, {
      messageId, chatRoomId: message.chatRoomId,
    });
  }
}

export async function getChatRooms(userId, { page = 1, limit = 20 }) {
  const take = Math.min(parseInt(limit) || 20, 50);
  const skip = (Math.max(parseInt(page) || 1, 1) - 1) * take;

  const [rooms, total] = await Promise.all([
    prisma.chatRoom.findMany({
      where: { members: { some: { userId } } },
      include: {
        _count: { select: { messages: true } },
        messages: { take: 1, orderBy: { createdAt: "desc" }, select: { content: true, createdAt: true } },
        meeting: { select: { id: true, title: true, status: true } },
      },
      orderBy: { updatedAt: "desc" },
      take,
      skip,
    }),
    prisma.chatRoom.count({ where: { members: { some: { userId } } } }),
  ]);

  return {
    rooms: rooms.map(r => ({
      id: r.id,
      name: r.name,
      isGroup: r.isGroup,
      meetingId: r.meeting?.id,
      meetingTitle: r.meeting?.title,
      meetingStatus: r.meeting?.status,
      messageCount: r._count.messages,
      lastMessage: r.messages[0] || null,
    })),
    total,
    page: Math.max(parseInt(page) || 1, 1),
    totalPages: Math.ceil(total / take),
  };
}
