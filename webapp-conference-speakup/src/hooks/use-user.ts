import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api, getErrorMessage } from "@/lib/api-client";
import { endpoints } from "@/config/endpoints";
import { STALE_TIMES } from "@/config/constants";
import type { User, ApiResponse } from "@/types";
import type { ProfileInput } from "@/lib/validators";
import { toast } from "sonner";

export function useUserProfile() {
  return useQuery({
    queryKey: ["user", "profile"],
    queryFn: async () => {
      const { data } = await api.get<ApiResponse<User>>(endpoints.users.profile);
      return data.data;
    },
    staleTime: STALE_TIMES.user,
  });
}

export function useUpdateProfile() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (input: ProfileInput) => {
      const { data } = await api.put<ApiResponse<User>>(endpoints.users.profile, input);
      return data.data;
    },
    onSuccess: (user) => {
      qc.setQueryData(["user", "profile"], user);
      qc.setQueryData(["auth", "me"], user);
      toast.success("Profile updated");
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });
}

export function useUpdateAvatar() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (file: File) => {
      const form = new FormData();
      form.append("avatar", file);
      const { data } = await api.put<ApiResponse<User>>(endpoints.users.avatar, form, {
        headers: { "Content-Type": "multipart/form-data" },
      });
      return data.data;
    },
    onSuccess: (user) => {
      qc.setQueryData(["user", "profile"], user);
      toast.success("Avatar updated");
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });
}
