import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api, getErrorMessage } from "@/lib/api-client";
import { endpoints } from "@/config/endpoints";
import { STALE_TIMES } from "@/config/constants";
import type {
  Meeting,
  Participant,
  MeetingStatus,
  ApiResponse,
  PaginatedResponse,
} from "@/types";
import type { CreateMeetingInput } from "@/lib/validators";
import { toast } from "sonner";

export function useMeetings(status?: MeetingStatus) {
  return useQuery({
    queryKey: ["meetings", { status }],
    queryFn: async () => {
      const params = status ? { status } : {};
      const { data } = await api.get<ApiResponse<PaginatedResponse<Meeting>>>(
        endpoints.meetings.list,
        { params }
      );
      return data.data;
    },
    staleTime: STALE_TIMES.meetings,
  });
}

export function useMeeting(id: string) {
  return useQuery({
    queryKey: ["meetings", id],
    queryFn: async () => {
      const { data } = await api.get<ApiResponse<Meeting>>(
        endpoints.meetings.byId(id)
      );
      return data.data;
    },
    enabled: !!id,
  });
}

export function useMeetingParticipants(id: string) {
  return useQuery({
    queryKey: ["meetings", id, "participants"],
    queryFn: async () => {
      const { data } = await api.get<ApiResponse<Participant[]>>(
        endpoints.meetings.participants(id)
      );
      return data.data;
    },
    enabled: !!id,
    refetchInterval: 10_000,
  });
}

export function useCreateMeeting() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (input: CreateMeetingInput) => {
      const { data } = await api.post<ApiResponse<Meeting>>(
        endpoints.meetings.list,
        input
      );
      return data.data;
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["meetings"] });
      toast.success("Meeting created");
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });
}

export function useJoinMeeting() {
  return useMutation({
    mutationFn: async ({ id, password }: { id: string; password?: string }) => {
      const { data } = await api.post<ApiResponse<{ token: string }>>(
        endpoints.meetings.join(id),
        { password }
      );
      return data.data;
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });
}

export function useJoinByCode() {
  return useMutation({
    mutationFn: async ({ code, password }: { code: string; password?: string }) => {
      const { data } = await api.post<ApiResponse<Meeting>>(
        endpoints.meetings.joinByCode(code),
        { password }
      );
      return data.data;
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });
}

export function useLeaveMeeting() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      await api.post(endpoints.meetings.leave(id));
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["meetings"] }),
  });
}

export function useEndMeeting() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      await api.post(endpoints.meetings.end(id));
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["meetings"] });
      toast.success("Meeting ended");
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });
}

export function useKickParticipant() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({
      meetingId,
      participantId,
    }: {
      meetingId: string;
      participantId: string;
    }) => {
      await api.post(endpoints.meetings.kick(meetingId, participantId));
    },
    onSuccess: (_, vars) => {
      qc.invalidateQueries({
        queryKey: ["meetings", vars.meetingId, "participants"],
      });
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });
}

export function useMeetingToken(meetingId: string) {
  return useQuery({
    queryKey: ["meetings", meetingId, "token"],
    queryFn: async () => {
      const { data } = await api.get<ApiResponse<{ token: string }>>(
        endpoints.meetings.token(meetingId)
      );
      return data.data.token;
    },
    enabled: !!meetingId,
  });
}
