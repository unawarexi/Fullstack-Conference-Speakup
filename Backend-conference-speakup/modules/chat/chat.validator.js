// ============================================================================
// SpeakUp — Chat Validator (Zod Schemas)
// ============================================================================

import { z } from "zod/v4";

export const sendMessageSchema = z.object({
  content: z.string().min(1).max(2000),
  type: z.enum(["TEXT", "IMAGE", "FILE"]).optional(),
  replyToId: z.string().uuid().optional(),
});
