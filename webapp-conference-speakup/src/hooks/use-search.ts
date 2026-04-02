import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api-client";
import { endpoints } from "@/config/endpoints";
import type { SearchResult, User, Meeting, ApiResponse } from "@/types";

export function useGlobalSearch(query: string) {
  return useQuery({
    queryKey: ["search", query],
    queryFn: async () => {
      const { data } = await api.get<ApiResponse<SearchResult>>(endpoints.search.global, {
        params: { q: query },
      });
      return data.data;
    },
    enabled: query.length >= 2,
  });
}

export function useSearchUsers(query: string) {
  return useQuery({
    queryKey: ["search", "users", query],
    queryFn: async () => {
      const { data } = await api.get<ApiResponse<User[]>>(endpoints.search.users, {
        params: { q: query },
      });
      return data.data;
    },
    enabled: query.length >= 2,
  });
}

export function useSearchMeetings(query: string) {
  return useQuery({
    queryKey: ["search", "meetings", query],
    queryFn: async () => {
      const { data } = await api.get<ApiResponse<Meeting[]>>(endpoints.search.meetings, {
        params: { q: query },
      });
      return data.data;
    },
    enabled: query.length >= 2,
  });
}
