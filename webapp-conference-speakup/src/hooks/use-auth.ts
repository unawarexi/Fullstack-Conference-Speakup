import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api, getErrorMessage } from "@/lib/api-client";
import { endpoints } from "@/config/endpoints";
import { STALE_TIMES } from "@/config/constants";
import type { User, ApiResponse } from "@/types";
import {
  signInWithPopup,
  GoogleAuthProvider,
  GithubAuthProvider,
  signOut as firebaseSignOut,
} from "firebase/auth";
import { auth } from "@/lib/firebase";
import { toast } from "sonner";
import { useRouter } from "next/navigation";

function getAuth() {
  if (!auth) throw new Error("Firebase auth not initialized");
  return auth;
}

/** Store Firebase token as a cookie so middleware can gate protected routes */
async function setSessionCookie() {
  const user = auth?.currentUser;
  if (!user) return;
  const token = await user.getIdToken();
  document.cookie = `__session=${token}; path=/; max-age=${60 * 60 * 24 * 7}; SameSite=Lax`;
}

// ─── Firebase OAuth ───
export function useGoogleSignIn() {
  const qc = useQueryClient();
  const router = useRouter();
  return useMutation({
    mutationFn: async () => {
      const provider = new GoogleAuthProvider();
      const result = await signInWithPopup(getAuth(), provider);
      const token = await result.user.getIdToken();
      const { data } = await api.post<ApiResponse<{ user: User }>>(endpoints.auth.signIn, {
        firebaseToken: token,
        provider: "google",
      });
      return data.data.user;
    },
    onSuccess: async (user) => {
      qc.setQueryData(["auth", "me"], user);
      await setSessionCookie();
      toast.success(`Welcome, ${user.fullName || user.email}!`);
      router.replace("/home");
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });
}

export function useGithubSignIn() {
  const qc = useQueryClient();
  const router = useRouter();
  return useMutation({
    mutationFn: async () => {
      const provider = new GithubAuthProvider();
      provider.addScope("read:user");
      provider.addScope("user:email");
      const result = await signInWithPopup(getAuth(), provider);
      const token = await result.user.getIdToken();
      const { data } = await api.post<ApiResponse<{ user: User }>>(endpoints.auth.signIn, {
        firebaseToken: token,
        provider: "github",
      });
      return data.data.user;
    },
    onSuccess: async (user) => {
      qc.setQueryData(["auth", "me"], user);
      await setSessionCookie();
      toast.success(`Welcome, ${user.fullName || user.email}!`);
      router.replace("/home");
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });
}

export function useSignOut() {
  const qc = useQueryClient();
  const router = useRouter();
  return useMutation({
    mutationFn: async () => {
      await api.post(endpoints.auth.signOut);
      await firebaseSignOut(getAuth());
    },
    onSuccess: () => {
      // Clear session cookie
      document.cookie = "__session=; path=/; max-age=0";
      qc.clear();
      toast.success("Signed out");
      router.replace("/login");
    },
  });
}

export function useCurrentUser() {
  return useQuery({
    queryKey: ["auth", "me"],
    queryFn: async () => {
      const { data } = await api.get<ApiResponse<User>>(endpoints.auth.me);
      return data.data;
    },
    staleTime: STALE_TIMES.user,
    retry: false,
  });
}

export function useDeleteAccount() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async () => {
      await api.delete(endpoints.auth.deleteAccount);
      await firebaseSignOut(getAuth());
    },
    onSuccess: () => {
      qc.clear();
      toast.success("Account deleted");
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });
}
