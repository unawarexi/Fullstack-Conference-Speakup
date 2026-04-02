// ============================================================================
// SpeakUp — Analytics Validator (Zod Schemas)
// ============================================================================

import { z } from "zod/v4";

export const usageQuerySchema = z.object({
  from: z.string().datetime().optional(),
  to: z.string().datetime().optional(),
});
