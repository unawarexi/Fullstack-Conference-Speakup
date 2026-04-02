import { initializeApp, getApps, type FirebaseApp } from "firebase/app";
import { getAuth, type Auth } from "firebase/auth";
import { FIREBASE_CONFIG } from "@/config/constants";

function createApp(): FirebaseApp | undefined {
  if (typeof window === "undefined") return undefined;
  if (!FIREBASE_CONFIG.apiKey) return undefined;
  return getApps().length === 0 ? initializeApp(FIREBASE_CONFIG) : getApps()[0];
}

const app = createApp();
export const auth: Auth | undefined = app ? getAuth(app) : undefined;
export default app;
