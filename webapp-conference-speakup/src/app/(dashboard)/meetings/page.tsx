"use client";

import Link from "next/link";
import { useState } from "react";
import {
  Button,
  Tabs,
  MeetingCard,
  MeetingCardSkeleton,
  EmptyState,
  Modal,
  Input,
} from "@/components/ui";
import { Select } from "@/components/ui/dropdown";
import { useMeetings, useCreateMeeting } from "@/hooks/use-meetings";
import { formatRelative } from "@/lib/formatters";
import type { MeetingStatus } from "@/types";
import { Calendar, Plus, Video } from "lucide-react";

const meetingTabs = [
  { label: "Upcoming", value: "scheduled" },
  { label: "Live", value: "live" },
  { label: "Past", value: "completed" },
];

export default function MeetingsPage() {
  const [showCreate, setShowCreate] = useState(false);
  const [title, setTitle] = useState("");
  const [type, setType] = useState("scheduled");
  const [scheduledAt, setScheduledAt] = useState("");
  const { mutate: create, isPending } = useCreateMeeting();

  const handleCreate = () => {
    if (!title.trim()) return;
    create(
      {
        title: title.trim(),
        type: type as "instant" | "scheduled" | "recurring",
        scheduledAt: scheduledAt || new Date().toISOString(),
      },
      { onSuccess: () => { setShowCreate(false); setTitle(""); } }
    );
  };

  return (
    <div className="mx-auto max-w-7xl p-6 space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-textPrimary">Meetings</h1>
        <Button className="gap-2" onClick={() => setShowCreate(true)}>
          <Plus className="h-4 w-4" />
          New Meeting
        </Button>
      </div>

      <Tabs tabs={meetingTabs} defaultValue="scheduled">
        {(activeTab) => <MeetingTabContent status={activeTab} />}
      </Tabs>

      {/* Create meeting modal */}
      <Modal
        open={showCreate}
        onClose={() => setShowCreate(false)}
        title="Create Meeting"
        confirmLabel="Create"
        onConfirm={handleCreate}
        loading={isPending}
      >
        <div className="space-y-4">
          <Input
            label="Meeting Title"
            placeholder="Team standup, Project review…"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
          />
          <Select
            label="Type"
            options={[
              { label: "Scheduled", value: "scheduled" },
              { label: "Instant", value: "instant" },
              { label: "Recurring", value: "recurring" },
            ]}
            value={type}
            onChange={setType}
          />
          {type !== "instant" && (
            <div>
              <label className="mb-1.5 block text-sm font-medium text-textPrimary">Date & Time</label>
              <input
                type="datetime-local"
                value={scheduledAt}
                onChange={(e) => setScheduledAt(e.target.value)}
                className="h-[52px] w-full rounded-xl border border-border bg-surface px-4 text-sm text-textPrimary"
              />
            </div>
          )}
        </div>
      </Modal>
    </div>
  );
}

function MeetingTabContent({ status }: { status: string }) {
  const { data, isLoading } = useMeetings(status as MeetingStatus);
  const meetings = data?.items ?? [];

  if (isLoading) {
    return (
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {Array.from({ length: 6 }).map((_, i) => (
          <MeetingCardSkeleton key={i} />
        ))}
      </div>
    );
  }

  if (meetings.length === 0) {
    return (
      <EmptyState
        icon={status === "live" ? Video : Calendar}
        title={status === "live" ? "No live meetings" : `No ${status} meetings`}
        description={
          status === "scheduled"
            ? "Schedule a meeting to get started"
            : status === "live"
            ? "No meetings are currently happening"
            : "Your past meetings will appear here"
        }
      />
    );
  }

  return (
    <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
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
  );
}
