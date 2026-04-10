// ============================================================================
// SpeakUp — Meeting Validator (Zod Schemas)
// ============================================================================

import { z } from "zod/v4";

export const createMeetingSchema = z.object({
  title: z.string().min(1).max(100),
  description: z.string().max(2000).optional(),
  type: z.enum(["INSTANT", "SCHEDULED", "RECURRING"]),
  scheduledAt: z.coerce.date().optional(),
  maxParticipants: z.number().int().min(2).max(1000).optional(),
  password: z.string().min(4).max(50).optional(),
  settings: z.object({
    autoRecord: z.boolean().optional(),
    waitingRoom: z.boolean().optional(),
    muteOnJoin: z.boolean().optional(),
    cameraOffOnJoin: z.boolean().optional(),
    allowScreenShare: z.boolean().optional(),
    allowChat: z.boolean().optional(),
    allowRecording: z.boolean().optional(),
  }).optional(),
  inviteEmails: z.array(z.email()).max(50).optional(),
});

export const updateMeetingSchema = z.object({
  title: z.string().min(1).max(100).optional(),
  description: z.string().max(2000).nullable().optional(),
  scheduledAt: z.coerce.date().optional(),
  maxParticipants: z.number().int().min(2).max(1000).optional(),
  password: z.string().min(4).max(50).nullable().optional(),
  settings: z.object({
    autoRecord: z.boolean().optional(),
    waitingRoom: z.boolean().optional(),
    muteOnJoin: z.boolean().optional(),
    cameraOffOnJoin: z.boolean().optional(),
    allowScreenShare: z.boolean().optional(),
    allowChat: z.boolean().optional(),
    allowRecording: z.boolean().optional(),
  }).optional(),
  inviteEmails: z.array(z.email()).max(50).optional(),
});

export const joinMeetingSchema = z.object({
  password: z.string().max(50).optional(),
});
