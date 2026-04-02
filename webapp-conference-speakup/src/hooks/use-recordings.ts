import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api-client";
import { endpoints } from "@/config/endpoints";
import { STALE_TIMES } from "@/config/constants";
import type { Recording, ApiResponse } from "@/types";

export function useRecordings() {
  return useQuery({
    queryKey: ["recordings"],
    queryFn: async () => {
      const { data } = await api.get<ApiResponse<Recording[]>>(endpoints.recordings.list);
      return data.data;
    },
    staleTime: STALE_TIMES.recordings,
  });
}

export function useRecording(id: string) {
  return useQuery({
    queryKey: ["recordings", id],
    queryFn: async () => {
      const { data } = await api.get<ApiResponse<Recording>>(endpoints.recordings.byId(id));
      return data.data;
    },
    enabled: !!id,
  });
}
