"use client";

import { useNotifications, useMarkRead, useMarkAllRead, useDeleteNotification } from "@/hooks/use-notifications";
import { Card, EmptyState, Skeleton, Button } from "@/components/ui";
import { timeAgo } from "@/lib/formatters";
import { Bell, CheckCheck, Trash2, Video, MessageSquare, Calendar, UserPlus } from "lucide-react";
import { cn } from "@/lib/utils";

const notificationIcons: Record<string, React.ComponentType<{ className?: string }>> = {
  meetingInvite: Calendar,
  meetingStarted: Video,
  meetingReminder: Bell,
  chatMessage: MessageSquare,
  system: UserPlus,
};

export default function NotificationsPage() {
  const { data, isLoading } = useNotifications();
  const { mutate: markRead } = useMarkRead();
  const { mutate: markAllRead } = useMarkAllRead();
  const { mutate: deleteNotification } = useDeleteNotification();

  const notifications = data ?? [];

  return (
    <div className="mx-auto max-w-3xl p-6 space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-textPrimary">Notifications</h1>
        {notifications.length > 0 && (
          <Button variant="ghost" size="sm" className="gap-2" onClick={() => markAllRead()}>
            <CheckCheck className="h-4 w-4" />
            Mark all read
          </Button>
        )}
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 5 }).map((_, i) => (
            <Skeleton key={i} className="h-20 rounded-xl" />
          ))}
        </div>
      ) : notifications.length === 0 ? (
        <EmptyState
          icon={Bell}
          title="All caught up!"
          description="You'll see notifications here when something happens"
        />
      ) : (
        <div className="space-y-2">
          {notifications.map((n) => {
            const Icon = notificationIcons[n.type] ?? Bell;
            return (
              <Card
                key={n.id}
                hoverable
                className={cn(
                  "flex items-start gap-4 p-4 cursor-pointer",
                  !n.isRead && "border-l-4 border-l-primary"
                )}
                onClick={() => !n.isRead && markRead(n.id)}
              >
                <div className={cn(
                  "flex h-10 w-10 shrink-0 items-center justify-center rounded-xl",
                  !n.isRead ? "bg-primary/10 text-primary" : "bg-surfaceLight text-textSecondary"
                )}>
                  <Icon className="h-5 w-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className={cn("text-sm", !n.isRead ? "font-semibold text-textPrimary" : "text-textPrimary")}>
                    {n.title}
                  </p>
                  {n.body && <p className="text-sm text-textSecondary mt-0.5 line-clamp-2">{n.body}</p>}
                  <p className="text-xs text-textSecondary mt-1">{timeAgo(n.createdAt)}</p>
                </div>
                <button
                  onClick={(e) => { e.stopPropagation(); deleteNotification(n.id); }}
                  className="shrink-0 text-textSecondary hover:text-error transition-colors"
                >
                  <Trash2 className="h-4 w-4" />
                </button>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
