import axios, {
  AxiosError,
  type AxiosInstance,
  type InternalAxiosRequestConfig,
} from "axios";
import { auth } from "@/lib/firebase";
import { API_BASE_URL } from "@/config/constants";

/** Singleton Axios instance with auth interceptor + retry logic. */
class ApiClient {
  private static instance: ApiClient;
  public client: AxiosInstance;

  private constructor() {
    this.client = axios.create({
      baseURL: API_BASE_URL,
      timeout: 15_000,
      headers: { "Content-Type": "application/json" },
    });

    // ─── Auth interceptor: inject Firebase token ───
    this.client.interceptors.request.use(async (config: InternalAxiosRequestConfig) => {
      const user = auth?.currentUser;
      if (user) {
        const token = await user.getIdToken();
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    });

    // ─── Response interceptor: retry on 401 (token refresh) ───
    this.client.interceptors.response.use(
      (res) => res,
      async (error: AxiosError) => {
        const original = error.config;
        if (!original) return Promise.reject(error);

        // Retry once on 401 with refreshed token
        if (
          error.response?.status === 401 &&
          !(original as InternalAxiosRequestConfig & { _retried?: boolean })._retried
        ) {
          (original as InternalAxiosRequestConfig & { _retried?: boolean })._retried = true;
          const user = auth?.currentUser;
          if (user) {
            const token = await user.getIdToken(true);
            original.headers.Authorization = `Bearer ${token}`;
            return this.client(original);
          }
        }
        return Promise.reject(error);
      }
    );
  }

  static getInstance(): ApiClient {
    if (!ApiClient.instance) {
      ApiClient.instance = new ApiClient();
    }
    return ApiClient.instance;
  }
}

export const api = ApiClient.getInstance().client;

/** Extract error message from Axios error */
export function getErrorMessage(error: unknown): string {
  if (error instanceof AxiosError) {
    return (
      error.response?.data?.message ||
      error.response?.data?.error ||
      error.message
    );
  }
  if (error instanceof Error) return error.message;
  return "An unexpected error occurred";
}
