-- CreateEnum
CREATE TYPE "InviteStatus" AS ENUM ('PENDING', 'ACCEPTED', 'DECLINED', 'EXPIRED');

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "NotificationType" ADD VALUE 'MEETING_CANCELLED';
ALTER TYPE "NotificationType" ADD VALUE 'INVITE_ACCEPTED';
ALTER TYPE "NotificationType" ADD VALUE 'INVITE_DECLINED';
ALTER TYPE "NotificationType" ADD VALUE 'MATERIAL_SHARED';

-- CreateTable
CREATE TABLE "meeting_invites" (
    "id" TEXT NOT NULL,
    "meeting_id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "user_id" TEXT,
    "status" "InviteStatus" NOT NULL DEFAULT 'PENDING',
    "token" TEXT NOT NULL,
    "sent_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "responded_at" TIMESTAMP(3),

    CONSTRAINT "meeting_invites_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "meeting_materials" (
    "id" TEXT NOT NULL,
    "meeting_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "size_bytes" BIGINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "meeting_materials_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notification_preferences" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "push_enabled" BOOLEAN NOT NULL DEFAULT true,
    "email_digest" BOOLEAN NOT NULL DEFAULT true,
    "calendar_sync" BOOLEAN NOT NULL DEFAULT false,
    "reminder_minutes" INTEGER[] DEFAULT ARRAY[15, 5]::INTEGER[],
    "ringtone" TEXT NOT NULL DEFAULT 'default',
    "vibration" BOOLEAN NOT NULL DEFAULT true,
    "meeting_invites" BOOLEAN NOT NULL DEFAULT true,
    "meeting_reminders" BOOLEAN NOT NULL DEFAULT true,
    "chat_messages" BOOLEAN NOT NULL DEFAULT true,
    "recording_ready" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "notification_preferences_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "meeting_invites_token_key" ON "meeting_invites"("token");

-- CreateIndex
CREATE INDEX "meeting_invites_meeting_id_idx" ON "meeting_invites"("meeting_id");

-- CreateIndex
CREATE INDEX "meeting_invites_email_idx" ON "meeting_invites"("email");

-- CreateIndex
CREATE INDEX "meeting_invites_token_idx" ON "meeting_invites"("token");

-- CreateIndex
CREATE UNIQUE INDEX "meeting_invites_meeting_id_email_key" ON "meeting_invites"("meeting_id", "email");

-- CreateIndex
CREATE INDEX "meeting_materials_meeting_id_idx" ON "meeting_materials"("meeting_id");

-- CreateIndex
CREATE INDEX "meeting_materials_user_id_idx" ON "meeting_materials"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "notification_preferences_user_id_key" ON "notification_preferences"("user_id");

-- AddForeignKey
ALTER TABLE "meeting_invites" ADD CONSTRAINT "meeting_invites_meeting_id_fkey" FOREIGN KEY ("meeting_id") REFERENCES "meetings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_invites" ADD CONSTRAINT "meeting_invites_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_materials" ADD CONSTRAINT "meeting_materials_meeting_id_fkey" FOREIGN KEY ("meeting_id") REFERENCES "meetings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_materials" ADD CONSTRAINT "meeting_materials_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_preferences" ADD CONSTRAINT "notification_preferences_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
