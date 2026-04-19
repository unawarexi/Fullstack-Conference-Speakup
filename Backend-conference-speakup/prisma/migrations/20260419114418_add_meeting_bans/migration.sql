-- CreateTable
CREATE TABLE "meeting_bans" (
    "id" TEXT NOT NULL,
    "meeting_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "reason" TEXT,
    "banned_by" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "meeting_bans_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "meeting_bans_meeting_id_idx" ON "meeting_bans"("meeting_id");

-- CreateIndex
CREATE INDEX "meeting_bans_user_id_idx" ON "meeting_bans"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "meeting_bans_meeting_id_user_id_key" ON "meeting_bans"("meeting_id", "user_id");

-- AddForeignKey
ALTER TABLE "meeting_bans" ADD CONSTRAINT "meeting_bans_meeting_id_fkey" FOREIGN KEY ("meeting_id") REFERENCES "meetings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_bans" ADD CONSTRAINT "meeting_bans_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_bans" ADD CONSTRAINT "meeting_bans_banned_by_fkey" FOREIGN KEY ("banned_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
