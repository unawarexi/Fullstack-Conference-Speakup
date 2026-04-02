// ============================================================================
// SpeakUp — Meeting Validator (Zod Schemas)
// ============================================================================

import { z } from "zod/v4";

export const createMeetingSchema = z.object({
  title: z.string().min(1).max(100),
  type: z.enum(["INSTANT", "SCHEDULED"]),
  scheduledAt: z.coerce.date().optional(),
  maxParticipants: z.number().int().min(2).max(1000).optional(),
  password: z.string().min(4).max(50).optional(),
  allowScreenShare: z.boolean().optional(),
  allowChat: z.boolean().optional(),
  allowRecording: z.boolean().optional(),
  waitingRoom: z.boolean().optional(),
});

export const updateMeetingSchema = z.object({
  title: z.string().min(1).max(100).optional(),
  scheduledAt: z.coerce.date().optional(),
  maxParticipants: z.number().int().min(2).max(1000).optional(),
  password: z.string().min(4).max(50).nullable().optional(),
  allowScreenShare: z.boolean().optional(),
  allowChat: z.boolean().optional(),
  allowRecording: z.boolean().optional(),
  waitingRoom: z.boolean().optional(),
});

export const joinMeetingSchema = z.object({
  password: z.string().max(50).optional(),
});
