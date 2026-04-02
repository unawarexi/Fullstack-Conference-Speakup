"use client";

import { use, useEffect, useRef, useState } from "react";
import { useChatMessages, useSendMessage, useDeleteMessage } from "@/hooks/use-chat";
import { useCurrentUser } from "@/hooks/use-auth";
import { useChatStore } from "@/store/chat-store";
import { Avatar, Spinner, EmptyState } from "@/components/ui";
import { TypingIndicator } from "@/components/ui/spinner";
import { timeAgo } from "@/lib/formatters";
import { Send, ArrowLeft, Trash2, MessageSquare } from "lucide-react";
import Link from "next/link";

export default function ChatRoomPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const { data: currentUser } = useCurrentUser();
  const {
    data: messagesData,
    isLoading,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
  } = useChatMessages(id);
  const { mutate: sendMessage, isPending: sending } = useSendMessage();
  const { mutate: deleteMessage } = useDeleteMessage();
  const { realtimeMessages, typingUsers } = useChatStore();

  const [input, setInput] = useState("");
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  const allPages = messagesData?.pages ?? [];
  const serverMessages = allPages.flatMap((p) => p.items ?? []);
  const messages = [...serverMessages, ...realtimeMessages.filter((rm) => rm.chatRoomId === id)];

  // Auto-scroll on new messages
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages.length]);

  const handleSend = () => {
    const content = input.trim();
    if (!content) return;
    sendMessage({ chatRoomId: id, content, type: "text" });
    setInput("");
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  // Infinite scroll: load more on scroll to top
  const handleScroll = () => {
    if (containerRef.current && containerRef.current.scrollTop < 50 && hasNextPage && !isFetchingNextPage) {
      fetchNextPage();
    }
  };

  return (
    <div className="flex h-full flex-col">
      {/* Header */}
      <div className="flex items-center gap-3 border-b border-border px-4 py-3">
        <Link href="/chat" className="lg:hidden text-textSecondary hover:text-textPrimary">
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <h2 className="text-sm font-semibold text-textPrimary">Chat Room</h2>
      </div>

      {/* Messages */}
      <div
        ref={containerRef}
        onScroll={handleScroll}
        className="flex-1 overflow-y-auto p-4 space-y-4"
      >
        {isFetchingNextPage && (
          <div className="flex justify-center py-2">
            <Spinner size="sm" />
          </div>
        )}

        {isLoading ? (
          <div className="flex h-full items-center justify-center">
            <Spinner size="lg" />
          </div>
        ) : messages.length === 0 ? (
          <EmptyState
            icon={MessageSquare}
            title="No messages yet"
            description="Start the conversation!"
          />
        ) : (
          messages.map((msg) => {
            const isMe = msg.senderId === currentUser?.id;
            return (
              <div key={msg.id} className={`flex ${isMe ? "justify-end" : "justify-start"}`}>
                <div className={`flex gap-2 max-w-[70%] ${isMe ? "flex-row-reverse" : ""}`}>
                  {!isMe && <Avatar name={msg.sender?.name} src={msg.sender?.avatar} size="sm" />}
                  <div>
                    {!isMe && (
                      <p className="text-xs text-textSecondary mb-1">{msg.sender?.name}</p>
                    )}
                    <div
                      className={`group relative rounded-2xl px-4 py-2.5 text-sm ${
                        isMe
                          ? "bg-primary text-white rounded-br-md"
                          : "bg-surfaceLight text-textPrimary rounded-bl-md"
                      }`}
                    >
                      <p className="whitespace-pre-wrap break-words">{msg.content}</p>
                      {isMe && (
                        <button
                          onClick={() => deleteMessage(msg.id)}
                          className="absolute -left-8 top-1/2 -translate-y-1/2 hidden group-hover:flex h-6 w-6 items-center justify-center rounded-full bg-surface text-textSecondary hover:text-error"
                        >
                          <Trash2 className="h-3 w-3" />
                        </button>
                      )}
                    </div>
                    <p className={`text-[10px] text-textSecondary mt-1 ${isMe ? "text-right" : ""}`}>
                      {timeAgo(msg.createdAt)}
                    </p>
                  </div>
                </div>
              </div>
            );
          })
        )}

        {typingUsers.length > 0 && (
          <div className="flex items-center gap-2 text-xs text-textSecondary">
            <TypingIndicator />
            {typingUsers.join(", ")} typing…
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      <div className="border-t border-border p-4">
        <div className="flex items-end gap-3">
          <textarea
            rows={1}
            placeholder="Type a message…"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={handleKeyDown}
            className="flex-1 resize-none rounded-xl border border-border bg-surface px-4 py-3 text-sm text-textPrimary placeholder:text-textSecondary focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none"
          />
          <button
            onClick={handleSend}
            disabled={!input.trim() || sending}
            className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-primary text-white disabled:opacity-50 hover:bg-primary/90 transition-colors"
          >
            <Send className="h-5 w-5" />
          </button>
        </div>
      </div>
    </div>
  );
}
