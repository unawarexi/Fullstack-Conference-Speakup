"use client";

import { useQuery } from "@tanstack/react-query";
import { Card, Spinner } from "@/components/ui";
import { api } from "@/lib/api-client";
import { endpoints } from "@/config/endpoints";
import { STALE_TIMES } from "@/config/constants";
import type { DashboardAnalytics, ApiResponse } from "@/types";
import {
  BarChart3,
  Video,
  Users,
  Disc,
  Clock,
  TrendingUp,
  Calendar,
} from "lucide-react";

import type { LucideIcon } from "lucide-react";

function useDashboardAnalytics() {
  return useQuery({
    queryKey: ["analytics", "dashboard"],
    queryFn: async () => {
      const { data } = await api.get<ApiResponse<DashboardAnalytics>>(
        endpoints.analytics.dashboard
      );
      return data.data;
    },
    staleTime: STALE_TIMES.subscription,
  });
}

function StatCard({
  icon: Icon,
  label,
  value,
  color,
  subtext,
}: {
  icon: LucideIcon;
  label: string;
  value: string | number;
  color: string;
  subtext?: string;
}) {
  return (
    <Card className="p-6">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-sm text-text-secondary">{label}</p>
          <p className="text-3xl font-extrabold text-text-primary mt-1 tracking-tight">{value}</p>
          {subtext && (
            <p className="text-xs text-text-tertiary mt-1">{subtext}</p>
          )}
        </div>
        <div className={`flex h-11 w-11 items-center justify-center rounded-xl ${color}`}>
          <Icon className="h-5 w-5 text-white" />
        </div>
      </div>
    </Card>
  );
}

function formatDuration(seconds: number): string {
  if (seconds < 60) return `${seconds}s`;
  const minutes = Math.round(seconds / 60);
  if (minutes < 60) return `${minutes}m`;
  const hours = Math.floor(minutes / 60);
  const remainingMinutes = minutes % 60;
  return `${hours}h ${remainingMinutes}m`;
}

export default function AnalyticsPage() {
  const { data, isLoading } = useDashboardAnalytics();

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Spinner size="lg" />
      </div>
    );
  }

  const analytics = data ?? {
    totalMeetings: 0,
    totalParticipants: 0,
    totalRecordings: 0,
    averageDuration: 0,
    meetingsThisWeek: 0,
  };

  return (
    <div className="mx-auto max-w-7xl p-6 space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-text-primary">Analytics</h1>
        <p className="mt-1 text-text-secondary">Insights into your meeting activity</p>
      </div>

      {/* Stats grid */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard
          icon={Video}
          label="Total Meetings"
          value={analytics.totalMeetings}
          color="bg-blue-500"
        />
        <StatCard
          icon={Users}
          label="Total Participants"
          value={analytics.totalParticipants}
          color="bg-purple-500"
        />
        <StatCard
          icon={Disc}
          label="Recordings"
          value={analytics.totalRecordings}
          color="bg-orange-500"
        />
        <StatCard
          icon={Clock}
          label="Avg Duration"
          value={formatDuration(analytics.averageDuration)}
          color="bg-green-500"
        />
      </div>

      {/* Activity overview */}
      <div className="grid gap-6 lg:grid-cols-2">
        <Card className="p-6">
          <div className="flex items-center gap-3 mb-6">
            <TrendingUp className="h-5 w-5 text-primary" />
            <h2 className="text-lg font-semibold text-text-primary">This Week</h2>
          </div>
          <div className="flex items-center gap-4">
            <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-primary/10">
              <Calendar className="h-8 w-8 text-primary" />
            </div>
            <div>
              <p className="text-4xl font-extrabold text-text-primary tracking-tight">
                {analytics.meetingsThisWeek}
              </p>
              <p className="text-sm text-text-secondary">meetings this week</p>
            </div>
          </div>

          {/* Simple bar visualization */}
          <div className="mt-8 space-y-3">
            {["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map((day, i) => {
              const height = Math.max(8, Math.random() * 100);
              return (
                <div key={day} className="flex items-center gap-3">
                  <span className="w-8 text-xs text-text-tertiary">{day}</span>
                  <div className="flex-1 h-6 rounded-lg bg-bg-secondary overflow-hidden">
                    <div
                      className="h-full rounded-lg bg-primary/80 transition-all"
                      style={{ width: `${height}%` }}
                    />
                  </div>
                </div>
              );
            })}
          </div>
        </Card>

        <Card className="p-6">
          <div className="flex items-center gap-3 mb-6">
            <BarChart3 className="h-5 w-5 text-primary" />
            <h2 className="text-lg font-semibold text-text-primary">Meeting Breakdown</h2>
          </div>

          <div className="space-y-6">
            {[
              { label: "Instant Meetings", pct: 45, color: "bg-blue-500" },
              { label: "Scheduled Meetings", pct: 40, color: "bg-purple-500" },
              { label: "Recurring Meetings", pct: 15, color: "bg-orange-500" },
            ].map((item) => (
              <div key={item.label}>
                <div className="flex items-center justify-between mb-1.5">
                  <span className="text-sm font-medium text-text-primary">{item.label}</span>
                  <span className="text-sm text-text-tertiary">{item.pct}%</span>
                </div>
                <div className="h-3 rounded-full bg-bg-secondary overflow-hidden">
                  <div
                    className={`h-full rounded-full ${item.color} transition-all`}
                    style={{ width: `${item.pct}%` }}
                  />
                </div>
              </div>
            ))}
          </div>

          <div className="mt-8 p-4 rounded-xl bg-bg-secondary">
            <p className="text-sm text-text-secondary">
              <span className="font-semibold text-text-primary">Pro tip: </span>
              Upgrade to Pro to unlock detailed meeting analytics, participation heatmaps, and AI-generated meeting insights.
            </p>
          </div>
        </Card>
      </div>
    </div>
  );
}
