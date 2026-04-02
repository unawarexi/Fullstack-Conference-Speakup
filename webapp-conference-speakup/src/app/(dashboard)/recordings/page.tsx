"use client";

import { useRecordings } from "@/hooks/use-recordings";
import { Card, EmptyState, Skeleton, Badge } from "@/components/ui";
import { formatDate, formatDuration } from "@/lib/formatters";
import { Disc, Play, Download, Clock } from "lucide-react";

export default function RecordingsPage() {
  const { data, isLoading } = useRecordings();
  const recordings = data ?? [];

  return (
    <div className="mx-auto max-w-5xl p-6 space-y-6">
      <h1 className="text-2xl font-bold text-textPrimary">Recordings</h1>

      {isLoading ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {Array.from({ length: 6 }).map((_, i) => (
            <Skeleton key={i} className="h-48 rounded-xl" />
          ))}
        </div>
      ) : recordings.length === 0 ? (
        <EmptyState
          icon={Disc}
          title="No recordings yet"
          description="Your meeting recordings will appear here"
        />
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {recordings.map((rec) => (
            <Card key={rec.id} hoverable className="overflow-hidden">
              {/* Thumbnail */}
              <div className="relative aspect-video bg-[#0A0A0F] flex items-center justify-center">
                <Disc className="h-10 w-10 text-white/20" />
                <Badge
                  variant={rec.status === "ready" ? "success" : "warning"}
                  className="absolute top-3 right-3"
                >
                  {rec.status}
                </Badge>
                {rec.status === "ready" && (
                  <button className="absolute inset-0 flex items-center justify-center bg-black/30 opacity-0 hover:opacity-100 transition-opacity">
                    <div className="flex h-12 w-12 items-center justify-center rounded-full bg-white/20 backdrop-blur-sm">
                      <Play className="h-6 w-6 text-white ml-0.5" />
                    </div>
                  </button>
                )}
              </div>

              <div className="p-4 space-y-2">
                <h3 className="font-semibold text-textPrimary truncate">{rec.meeting?.title ?? "Recording"}</h3>
                <div className="flex items-center gap-4 text-xs text-textSecondary">
                  <span className="flex items-center gap-1">
                    <Clock className="h-3.5 w-3.5" />
                    {rec.duration ? formatDuration(rec.duration) : "—"}
                  </span>
                  <span>{formatDate(rec.createdAt)}</span>
                </div>
                {rec.status === "ready" && rec.url && (
                  <a
                    href={rec.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center gap-1.5 text-xs text-primary hover:underline mt-1"
                  >
                    <Download className="h-3.5 w-3.5" />
                    Download
                  </a>
                )}
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
