// ============================================================================
// SpeakUp — Search Validator (Zod Schemas)
// ============================================================================

import { z } from "zod/v4";

export const searchQuerySchema = z.object({
  q: z.string().min(2).max(100),
  page: z.coerce.number().int().min(1).optional(),
  limit: z.coerce.number().int().min(1).max(100).optional(),
  status: z.enum(["SCHEDULED", "ACTIVE", "ENDED", "CANCELED"]).optional(),
});
