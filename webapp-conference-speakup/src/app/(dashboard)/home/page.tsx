"use client";

import Link from "next/link";
import { Button, Card, MeetingCard, MeetingCardSkeleton, Avatar } from "@/components/ui";
import { strings } from "@/config/strings";
import { useCurrentUser } from "@/hooks/use-auth";
import { useMeetings, useCreateMeeting } from "@/hooks/use-meetings";
import { getGreeting, formatRelative } from "@/lib/formatters";
import {
  Plus,
  Video,
  Keyboard,
  Calendar,
  ArrowRight,
} from "lucide-react";
import { useState } from "react";

export default function HomePage() {
  const { data: user } = useCurrentUser();
  const { data: upcoming, isLoading } = useMeetings("scheduled");
  const { mutate: createMeeting, isPending: creating } = useCreateMeeting();
  const [joinCode, setJoinCode] = useState("");

  const meetings = upcoming?.items?.slice(0, 4) ?? [];

  return (
    <div className="mx-auto max-w-7xl p-6 space-y-8">
      {/* Greeting */}
      <div>
        <h1 className="text-2xl font-bold text-textPrimary">
          {getGreeting()}, {user?.name?.split(" ")[0] ?? "there"} 👋
        </h1>
        <p className="mt-1 text-textSecondary">What would you like to do today?</p>
      </div>

      {/* Quick actions */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <Card
          hoverable
          className="p-6 cursor-pointer"
          onClick={() =>
            createMeeting({
              title: "Instant Meeting",
              type: "instant",
              scheduledAt: new Date().toISOString(),
            })
          }
        >
          <div className="flex items-center gap-4">
            <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary text-white">
              <Video className="h-6 w-6" />
            </div>
            <div>
              <p className="font-semibold text-textPrimary">{strings.home.newMeeting}</p>
              <p className="text-xs text-textSecondary">Start instantly</p>
            </div>
          </div>
        </Card>

        <Card hoverable className="p-6 cursor-pointer">
          <Link href="/meetings?tab=create" className="flex items-center gap-4">
            <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-success text-white">
              <Calendar className="h-6 w-6" />
            </div>
            <div>
              <p className="font-semibold text-textPrimary">{strings.home.scheduleMeeting}</p>
              <p className="text-xs text-textSecondary">Pick a date & time</p>
            </div>
          </Link>
        </Card>

        <Card className="p-6 sm:col-span-2">
          <div className="flex items-center gap-3">
            <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-surfaceLight">
              <Keyboard className="h-6 w-6 text-textSecondary" />
            </div>
            <div className="flex-1">
              <input
                type="text"
                placeholder={strings.meeting.joinByCode}
                value={joinCode}
                onChange={(e) => setJoinCode(e.target.value)}
                className="w-full bg-transparent text-sm text-textPrimary placeholder:text-textSecondary outline-none"
              />
            </div>
            <Button
              size="sm"
              disabled={joinCode.length < 4}
              onClick={() => {
                if (joinCode.trim()) window.location.href = `/meeting/join?code=${joinCode.trim()}`;
              }}
            >
              Join
            </Button>
          </div>
        </Card>
      </div>

      {/* Upcoming meetings */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-textPrimary">{strings.home.upcomingMeetings}</h2>
          <Link href="/meetings" className="flex items-center gap-1 text-sm text-primary hover:underline">
            View all <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>

        {isLoading ? (
          <div className="grid gap-4 sm:grid-cols-2">
            {Array.from({ length: 4 }).map((_, i) => (
              <MeetingCardSkeleton key={i} />
            ))}
          </div>
        ) : meetings.length === 0 ? (
          <Card className="p-12 text-center">
            <Calendar className="mx-auto h-10 w-10 text-textSecondary mb-3" />
            <p className="font-medium text-textPrimary">{strings.meeting.noMeetings}</p>
            <p className="text-sm text-textSecondary mt-1">Start a meeting or schedule one for later</p>
          </Card>
        ) : (
          <div className="grid gap-4 sm:grid-cols-2">
            {meetings.map((m) => (
              <Link key={m.id} href={`/meeting/${m.id}`}>
                <MeetingCard
                  title={m.title}
                  time={m.scheduledAt ? formatRelative(m.scheduledAt) : "—"}
                  isLive={m.status === "live"}
                  participantCount={m.participantCount}
                  host={m.host?.name ?? "Unknown"}
                />
              </Link>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
