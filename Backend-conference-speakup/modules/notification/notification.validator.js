// ============================================================================
// SpeakUp — Notification Validator (Zod Schemas)
// ============================================================================

import { z } from "zod/v4";

export const notificationIdSchema = z.object({
  id: z.string().uuid(),
});
