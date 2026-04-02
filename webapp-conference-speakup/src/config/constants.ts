// ─── App Constants ───
export const APP_NAME = "SpeakUp";
export const APP_TAGLINE = "Conference. Collaborate. Connect.";
export const APP_DESCRIPTION =
  "Enterprise-grade video conferencing for teams that move fast.";

// ─── API ───
export const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000/api/v1";
export const WS_BASE_URL =
  process.env.NEXT_PUBLIC_WS_URL || "ws://localhost:3000";

// ─── Auth ───
export const FIREBASE_CONFIG = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY!,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN!,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID!,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET!,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID!,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID!,
};

// ─── Breakpoints (matches Flutter SResponsive) ───
export const BREAKPOINTS = {
  mobile: 480,
  tablet: 768,
  desktop: 1024,
  widescreen: 1440,
} as const;

// ─── Sizes (matches Flutter SSizes) ───
export const SIZES = {
  spacing: { xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 48, xxxl: 64 },
  pagePadding: 20,
  cardPadding: 16,
  sectionSpacing: 28,
  icon: { xs: 14, sm: 18, md: 24, lg: 32, xl: 48 },
  radius: { xs: 4, sm: 8, md: 12, lg: 16, xl: 24, full: 999 },
  button: { sm: 36, md: 48, lg: 56 },
  avatar: { sm: 32, md: 40, lg: 56, xl: 80, xxl: 120 },
  inputHeight: 52,
  bottomNavHeight: 72,
  appBarHeight: 56,
  controlBarHeight: 80,
} as const;

// ─── Animation Durations ───
export const ANIMATION = {
  fast: 150,
  normal: 250,
  slow: 400,
} as const;

// ─── Stale Times (TanStack Query) ───
export const STALE_TIMES = {
  user: 5 * 60 * 1000,
  meetings: 30 * 1000,
  chat: 10 * 1000,
  notifications: 15 * 1000,
  recordings: 2 * 60 * 1000,
  subscription: 10 * 60 * 1000,
} as const;
