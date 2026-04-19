// ============================================================================
// SpeakUp — Recording Service
// LiveKit Egress for recording, S3 storage, async processing via BullMQ
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { env } from "../../config/env.config.js";
import { getCache, setCache, deleteCache } from "../../services/redis.service.js";
import { publishEvent } from "../../services/kafka.service.js";
import { emitToMeeting } from "../../services/websocket.service.js";
import { queueEmail, queueNotification } from "../../services/workers.js";
import { badRequest, forbidden, notFound } from "../../middlewares/errorhandler.middleware.js";
import { CacheTTL, SocketEvents, KafkaTopics } from "../../config/constants.js";
import { S3Client, GetObjectCommand, DeleteObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

const s3 = new S3Client({
  region: env.AWS_REGION,
  credentials: { accessKeyId: env.AWS_ACCESS_KEY_ID, secretAccessKey: env.AWS_SECRET_ACCESS_KEY },
});

export async function startRecording(meetingId, userId) {
  const meeting = await prisma.meeting.findUnique({
    where: { id: meetingId },
    include: { host: { select: { subscriptions: true } } },
  });
  if (!meeting) throw notFound("Meeting not found");
  if (meeting.hostId !== userId) throw forbidden("Only the host can start recording");
  if (!meeting.allowRecording) throw badRequest("Recording is disabled for this meeting");
  if (meeting.status !== "ACTIVE") throw badRequest("Meeting is not active");

  const plan = meeting.host?.subscriptions?.plan || "FREE";
  if (plan === "FREE") throw forbidden("Recording requires a Pro or Enterprise subscription");

  const existing = await prisma.recording.findFirst({
    where: { meetingId, status: "RECORDING" },
  });
  if (existing) throw badRequest("Recording already in progress");

  const recording = await prisma.recording.create({
    data: {
      meetingId,
      userId,
      status: "RECORDING",
      startedAt: new Date(),
    },
  });

  emitToMeeting(meetingId, SocketEvents.RECORDING_STARTED, {
    meetingId, recordingId: recording.id, startedBy: userId,
  });

  await publishEvent(KafkaTopics.RECORDING_EVENTS, recording.id, {
    type: "recording.started", meetingId, recordingId: recording.id, userId,
  });

  return recording;
}

export async function stopRecording(meetingId, userId) {
  const meeting = await prisma.meeting.findUnique({ where: { id: meetingId } });
  if (!meeting) throw notFound("Meeting not found");
  if (meeting.hostId !== userId) throw forbidden("Only the host can stop recording");

  const recording = await prisma.recording.findFirst({
    where: { meetingId, status: "RECORDING" },
  });
  if (!recording) throw badRequest("No active recording");

  const duration = Math.floor((Date.now() - recording.startedAt.getTime()) / 1000);

  const updated = await prisma.recording.update({
    where: { id: recording.id },
    data: { status: "PROCESSING", endedAt: new Date(), duration },
  });

  emitToMeeting(meetingId, SocketEvents.RECORDING_STOPPED, {
    meetingId, recordingId: recording.id,
  });

  await publishEvent(KafkaTopics.RECORDING_EVENTS, recording.id, {
    type: "recording.stopped", meetingId, recordingId: recording.id, duration,
  });

  return updated;
}

export async function getRecordings(userId, { page = 1, limit = 20 }) {
  const take = Math.min(parseInt(limit) || 20, 50);
  const skip = (Math.max(parseInt(page) || 1, 1) - 1) * take;

  const [recordings, total] = await Promise.all([
    prisma.recording.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
      take,
      skip,
      include: {
        meeting: { select: { id: true, title: true, code: true } },
      },
    }),
    prisma.recording.count({ where: { userId } }),
  ]);

  return {
    recordings,
    total,
    page: Math.max(parseInt(page) || 1, 1),
    totalPages: Math.ceil(total / take),
  };
}

export async function getRecording(recordingId, userId) {
  const recording = await prisma.recording.findUnique({
    where: { id: recordingId },
    include: { meeting: { select: { id: true, title: true, hostId: true } } },
  });
  if (!recording) throw notFound("Recording not found");
  if (recording.userId !== userId && recording.meeting.hostId !== userId) {
    throw forbidden("Access denied");
  }
  return recording;
}

export async function getDownloadUrl(recordingId, userId) {
  const recording = await getRecording(recordingId, userId);
  if (recording.status !== "COMPLETED") throw badRequest("Recording is not ready for download");
  if (!recording.fileUrl) throw badRequest("Recording file not available");

  const key = new URL(recording.fileUrl).pathname.slice(1);
  const command = new GetObjectCommand({ Bucket: env.AWS_S3_BUCKET, Key: key });
  const url = await getSignedUrl(s3, command, { expiresIn: 3600 });
  return { url, expiresIn: 3600 };
}

export async function deleteRecording(recordingId, userId) {
  const recording = await getRecording(recordingId, userId);
  if (recording.userId !== userId) throw forbidden("Only the recording owner can delete it");

  if (recording.fileUrl) {
    try {
      const key = new URL(recording.fileUrl).pathname.slice(1);
      await s3.send(new DeleteObjectCommand({ Bucket: env.AWS_S3_BUCKET, Key: key }));
    } catch (_) { /* S3 delete failure is non-critical */ }
  }

  await prisma.recording.delete({ where: { id: recordingId } });
  await deleteCache(`recording:${recordingId}`);
}

export async function handleRecordingComplete(recordingId, { fileUrl, fileSize, duration }) {
  const recording = await prisma.recording.update({
    where: { id: recordingId },
    data: { status: "COMPLETED", fileUrl, fileSize, duration },
    include: { user: { select: { email: true, fullName: true } }, meeting: { select: { title: true } } },
  });

  if (recording.user.email) {
    await queueEmail("recording-ready", recording.user.email, {
      name: recording.user.fullName,
      meetingTitle: recording.meeting.title,
      recordingId: recording.id,
    });
  }

  // Push notification for recording ready
  await queueNotification(
    recording.userId,
    "RECORDING_READY",
    "Recording Ready",
    `Your recording of "${recording.meeting.title}" is ready to download`,
    { recordingId: recording.id, meetingId: recording.meetingId },
  ).catch(() => {});

  await publishEvent(KafkaTopics.RECORDING_EVENTS, recording.id, {
    type: "recording.completed", recordingId, meetingId: recording.meetingId, userId: recording.userId, fileSize, duration,
  });

  return recording;
}
