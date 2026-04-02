import { useQuery, useMutation, useQueryClient, useInfiniteQuery } from "@tanstack/react-query";
import { api, getErrorMessage } from "@/lib/api-client";
import { endpoints } from "@/config/endpoints";
import { STALE_TIMES } from "@/config/constants";
import type { ChatRoom, ChatMessage, ApiResponse, PaginatedResponse } from "@/types";
import { toast } from "sonner";

export function useChatRooms() {
  return useQuery({
    queryKey: ["chat", "rooms"],
    queryFn: async () => {
      const { data } = await api.get<ApiResponse<ChatRoom[]>>(endpoints.chat.rooms);
      return data.data;
    },
    staleTime: STALE_TIMES.chat,
  });
}

export function useChatMessages(chatRoomId: string) {
  return useInfiniteQuery({
    queryKey: ["chat", chatRoomId, "messages"],
    queryFn: async ({ pageParam }) => {
      const { data } = await api.get<ApiResponse<PaginatedResponse<ChatMessage>>>(
        endpoints.chat.messages(chatRoomId),
        { params: { cursor: pageParam, limit: 30 } }
      );
      return data.data;
    },
    initialPageParam: undefined as string | undefined,
    getNextPageParam: (lastPage) =>
      lastPage.hasMore ? lastPage.items[lastPage.items.length - 1]?.id : undefined,
    enabled: !!chatRoomId,
  });
}

export function useSendMessage() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({
      chatRoomId,
      content,
      type = "text",
    }: {
      chatRoomId: string;
      content: string;
      type?: string;
    }) => {
      const { data } = await api.post<ApiResponse<ChatMessage>>(
        endpoints.chat.messages(chatRoomId),
        { content, type }
      );
      return data.data;
    },
    onSuccess: (_, vars) => {
      qc.invalidateQueries({ queryKey: ["chat", vars.chatRoomId, "messages"] });
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });
}

export function useDeleteMessage() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (messageId: string) => {
      await api.delete(endpoints.chat.deleteMessage(messageId));
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["chat"] });
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });
}
