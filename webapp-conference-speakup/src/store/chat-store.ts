import { create } from "zustand";
import type { ChatMessage } from "@/types";

interface ChatStore {
  activeChatRoomId: string | null;
  realtimeMessages: ChatMessage[];
  typingUsers: string[];

  setActiveChatRoom: (id: string | null) => void;
  addRealtimeMessage: (msg: ChatMessage) => void;
  clearRealtimeMessages: () => void;
  setTypingUsers: (users: string[]) => void;
}

export const useChatStore = create<ChatStore>()((set) => ({
  activeChatRoomId: null,
  realtimeMessages: [],
  typingUsers: [],

  setActiveChatRoom: (id) =>
    set({ activeChatRoomId: id, realtimeMessages: [], typingUsers: [] }),
  addRealtimeMessage: (msg) =>
    set((s) => ({ realtimeMessages: [...s.realtimeMessages, msg] })),
  clearRealtimeMessages: () => set({ realtimeMessages: [] }),
  setTypingUsers: (users) => set({ typingUsers: users }),
}));
