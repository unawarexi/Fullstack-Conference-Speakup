import { z } from "zod/v4";

export const updateProfileSchema = z.object({
  fullName: z.string().min(1).max(100).optional(),
  bio: z.string().max(500).optional(),
});

export const registerDeviceSchema = z.object({
  fcmToken: z.string().min(1),
  platform: z.enum(["IOS", "ANDROID", "WEB", "MACOS", "WINDOWS", "LINUX"]),
});
