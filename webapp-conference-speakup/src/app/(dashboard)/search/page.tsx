"use client";

import { useState } from "react";
import { Card, Spinner, EmptyState } from "@/components/ui";
import { useGlobalSearch, useSearchUsers, useSearchMeetings } from "@/hooks/use-search";
import { Search as SearchIcon, Users, Video, X, ArrowRight } from "lucide-react";
import Link from "next/link";
import type { User, Meeting } from "@/types";

function UserResult({ user }: { user: User }) {
  return (
    <div className="flex items-center gap-4 rounded-xl border border-border bg-card p-4 hover:border-primary/30 transition-colors">
      <div className="flex h-11 w-11 items-center justify-center rounded-full bg-primary/10 text-primary text-sm font-bold shrink-0">
        {user.name?.charAt(0)?.toUpperCase() ?? "?"}
      </div>
      <div className="min-w-0 flex-1">
        <p className="font-semibold text-text-primary truncate">{user.name}</p>
        <p className="text-xs text-text-tertiary truncate">{user.email}</p>
      </div>
      <span
        className={`shrink-0 h-2.5 w-2.5 rounded-full ${
          user.isOnline ? "bg-green-500" : "bg-text-tertiary/30"
        }`}
      />
    </div>
  );
}

function MeetingResult({ meeting }: { meeting: Meeting }) {
  return (
    <Link
      href={`/meeting/${meeting.id}`}
      className="flex items-center gap-4 rounded-xl border border-border bg-card p-4 hover:border-primary/30 transition-colors"
    >
      <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-blue-500/10 shrink-0">
        <Video className="h-5 w-5 text-blue-500" />
      </div>
      <div className="min-w-0 flex-1">
        <p className="font-semibold text-text-primary truncate">{meeting.title}</p>
        <p className="text-xs text-text-tertiary">
          {meeting.status === "live" ? "🔴 Live" : meeting.status} · {meeting.participantCount} participants
        </p>
      </div>
      <ArrowRight className="h-4 w-4 text-text-tertiary shrink-0" />
    </Link>
  );
}

export default function SearchPage() {
  const [query, setQuery] = useState("");
  const { data, isLoading } = useGlobalSearch(query);

  const users = data?.users ?? [];
  const meetings = data?.meetings ?? [];
  const hasResults = users.length > 0 || meetings.length > 0;

  return (
    <div className="mx-auto max-w-4xl p-6 space-y-8">
      {/* Search header */}
      <div>
        <h1 className="text-2xl font-bold text-text-primary">Search</h1>
        <p className="mt-1 text-text-secondary">Find users, meetings, and more</p>
      </div>

      {/* Search input */}
      <div className="relative">
        <SearchIcon className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-text-tertiary" />
        <input
          type="text"
          placeholder="Search users, meetings..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          className="w-full rounded-2xl border border-border bg-card py-4 pl-12 pr-12 text-text-primary placeholder:text-text-tertiary outline-none focus:border-primary/50 focus:ring-2 focus:ring-primary/20 transition-all"
        />
        {query && (
          <button
            onClick={() => setQuery("")}
            className="absolute right-4 top-1/2 -translate-y-1/2 flex h-7 w-7 items-center justify-center rounded-lg hover:bg-bg-secondary text-text-tertiary"
          >
            <X className="h-4 w-4" />
          </button>
        )}
      </div>

      {/* Results */}
      {query.length < 2 ? (
        <div className="text-center py-16">
          <SearchIcon className="mx-auto h-12 w-12 text-text-tertiary/30 mb-4" />
          <p className="text-text-secondary">Type at least 2 characters to search</p>
        </div>
      ) : isLoading ? (
        <div className="flex justify-center py-16">
          <Spinner size="lg" />
        </div>
      ) : !hasResults ? (
        <EmptyState
          icon={SearchIcon}
          title="No results found"
          description={`No matches found for "${query}". Try different keywords.`}
        />
      ) : (
        <div className="space-y-8">
          {users.length > 0 && (
            <div>
              <div className="flex items-center gap-2 mb-4">
                <Users className="h-4 w-4 text-text-tertiary" />
                <h2 className="text-sm font-semibold text-text-secondary uppercase tracking-wider">
                  Users ({users.length})
                </h2>
              </div>
              <div className="space-y-2">
                {users.map((user) => (
                  <UserResult key={user.id} user={user} />
                ))}
              </div>
            </div>
          )}

          {meetings.length > 0 && (
            <div>
              <div className="flex items-center gap-2 mb-4">
                <Video className="h-4 w-4 text-text-tertiary" />
                <h2 className="text-sm font-semibold text-text-secondary uppercase tracking-wider">
                  Meetings ({meetings.length})
                </h2>
              </div>
              <div className="space-y-2">
                {meetings.map((meeting) => (
                  <MeetingResult key={meeting.id} meeting={meeting} />
                ))}
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
