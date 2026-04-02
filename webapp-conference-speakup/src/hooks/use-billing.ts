import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api-client";
import { endpoints } from "@/config/endpoints";
import { STALE_TIMES } from "@/config/constants";
import type { Subscription, ApiResponse } from "@/types";

export function useSubscription() {
  return useQuery({
    queryKey: ["billing", "subscription"],
    queryFn: async () => {
      const { data } = await api.get<ApiResponse<Subscription>>(
        endpoints.billing.subscription
      );
      return data.data;
    },
    staleTime: STALE_TIMES.subscription,
  });
}
