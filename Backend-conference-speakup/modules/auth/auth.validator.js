import { z } from "zod/v4";

export const deleteAccountSchema = z.object({
  confirmation: z.literal("DELETE MY ACCOUNT"),
});
