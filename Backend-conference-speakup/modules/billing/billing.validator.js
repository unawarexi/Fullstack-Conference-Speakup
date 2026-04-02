// ============================================================================
// SpeakUp — Billing Validator (Zod Schemas)
// ============================================================================

import { z } from "zod/v4";

export const createCheckoutSchema = z.object({
  plan: z.enum(["PRO", "ENTERPRISE"]),
});
