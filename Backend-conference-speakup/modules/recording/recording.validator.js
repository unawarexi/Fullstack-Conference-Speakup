// ============================================================================
// SpeakUp — Recording Validator (Zod Schemas)
// ============================================================================

import { z } from "zod/v4";

export const recordingWebhookSchema = z.object({
  recordingId: z.string().uuid(),
  fileUrl: z.string().url(),
  fileSize: z.number().int().positive(),
  duration: z.number().int().nonnegative(),
});
