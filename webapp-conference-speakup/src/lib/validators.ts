import { z } from "zod";

export const emailSchema = z.string().email("Please enter a valid email");

export const passwordSchema = z
  .string()
  .min(8, "Password must be at least 8 characters")
  .regex(/[A-Z]/, "Must contain an uppercase letter")
  .regex(/[0-9]/, "Must contain a number");

export const nameSchema = z
  .string()
  .min(2, "Name must be at least 2 characters")
  .max(50, "Name must be less than 50 characters");

export const meetingCodeSchema = z
  .string()
  .min(6, "Meeting code must be at least 6 characters")
  .max(20, "Meeting code must be less than 20 characters")
  .regex(/^[a-zA-Z0-9-]+$/, "Only letters, numbers, and hyphens");

export const loginSchema = z.object({
  email: emailSchema,
  password: passwordSchema,
});

export const registerSchema = z
  .object({
    name: nameSchema,
    email: emailSchema,
    password: passwordSchema,
    confirmPassword: z.string(),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Passwords don't match",
    path: ["confirmPassword"],
  });

export const joinMeetingSchema = z.object({
  code: meetingCodeSchema,
});

export const createMeetingSchema = z.object({
  title: z.string().min(1, "Title is required").max(100),
  description: z.string().max(500).optional(),
  type: z.enum(["instant", "scheduled", "recurring"]),
  scheduledAt: z.string().optional(),
  password: z.string().max(50).optional(),
  maxParticipants: z.number().min(2).max(1000).optional().default(100),
});

export const profileSchema = z.object({
  fullName: nameSchema,
  bio: z.string().max(200).optional(),
});

export type LoginInput = z.infer<typeof loginSchema>;
export type RegisterInput = z.infer<typeof registerSchema>;
export type JoinMeetingInput = z.infer<typeof joinMeetingSchema>;
export type CreateMeetingInput = z.input<typeof createMeetingSchema>;
export type ProfileInput = z.infer<typeof profileSchema>;
