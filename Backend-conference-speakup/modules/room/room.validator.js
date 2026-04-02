// ============================================================================
// SpeakUp — Room Validator (Zod Schemas)
// ============================================================================

import { z } from "zod/v4";

export const updateRoomSettingsSchema = z.object({
  allowScreenShare: z.boolean().optional(),
  allowChat: z.boolean().optional(),
  allowRecording: z.boolean().optional(),
  waitingRoom: z.boolean().optional(),
  maxParticipants: z.number().int().min(2).max(1000).optional(),
});
