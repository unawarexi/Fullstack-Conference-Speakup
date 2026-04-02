"use client";

import Link from "next/link";
import { useChatRooms, useSendMessage } from "@/hooks/use-chat";
import { Avatar, Card, SearchBar, EmptyState, ChatListSkeleton } from "@/components/ui";
import { useChatStore } from "@/store/chat-store";
import { timeAgo } from "@/lib/formatters";
import { MessageSquare, Plus } from "lucide-react";
import { useState } from "react";

export default function ChatPage() {
  const { data, isLoading } = useChatRooms();
  const [search, setSearch] = useState("");
  const rooms = data ?? [];

  const filtered = search
    ? rooms.filter((r) =>
        r.name?.toLowerCase().includes(search.toLowerCase()) ||
        r.members?.some((m) => m.user?.name?.toLowerCase().includes(search.toLowerCase()))
      )
    : rooms;

  return (
    <div className="mx-auto max-w-3xl p-6 space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-textPrimary">Chat</h1>
      </div>

      <SearchBar
        placeholder="Search conversations…"
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        onClear={() => setSearch("")}
      />

      {isLoading ? (
        <ChatListSkeleton />
      ) : filtered.length === 0 ? (
        <EmptyState
          icon={MessageSquare}
          title="No conversations yet"
          description="Start a chat from a meeting or with a team member"
        />
      ) : (
        <div className="space-y-1">
          {filtered.map((room) => {
            const displayName = room.name || room.members?.[0]?.user?.name || "Chat";
            const displayAvatar = room.isGroup ? undefined : room.members?.[0]?.user?.avatar;

            return (
              <Link key={room.id} href={`/chat/${room.id}`}>
                <Card hoverable className="flex items-center gap-3 p-4">
                  <Avatar src={displayAvatar} name={displayName} size="md" />
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between">
                      <p className="font-medium text-textPrimary truncate">{displayName}</p>
                      {room.lastMessage?.createdAt && (
                        <span className="text-xs text-textSecondary shrink-0 ml-2">
                          {timeAgo(room.lastMessage.createdAt)}
                        </span>
                      )}
                    </div>
                    {room.lastMessage && (
                      <p className="text-sm text-textSecondary truncate mt-0.5">
                        {room.lastMessage.content}
                      </p>
                    )}
                  </div>
                  {room.unreadCount ? (
                    <span className="flex h-5 min-w-5 items-center justify-center rounded-full bg-primary px-1.5 text-[10px] font-bold text-white">
                      {room.unreadCount > 99 ? "99+" : room.unreadCount}
                    </span>
                  ) : null}
                </Card>
              </Link>
            );
          })}
        </div>
      )}
    </div>
  );
}
