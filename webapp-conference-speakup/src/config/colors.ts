/** SpeakUp brand color tokens — matches Flutter SColors exactly. */
export const colors = {
  // ─── Primary Blue ───
  primary: "#1A6BF5",
  primaryLight: "#4D8FF7",
  primaryDark: "#0D4FCC",
  primarySurface: "#E8F0FE",
  primaryMuted: "#B3D1FC",

  // ─── Blue Scale ───
  blue: {
    50: "#E8F0FE",
    100: "#BDD5FC",
    200: "#8FB8FA",
    300: "#619BF8",
    400: "#3E84F6",
    500: "#1A6BF5",
    600: "#1560DC",
    700: "#1052BE",
    800: "#0B44A0",
    900: "#063072",
  },

  // ─── Dark Mode ───
  dark: {
    bg: "#0A0A0F",
    surface: "#12121A",
    card: "#1A1A25",
    elevated: "#222233",
    border: "#2A2A3D",
    hover: "#32324A",
    muted: "#8888A0",
  },

  // ─── Light Mode ───
  light: {
    bg: "#F8F9FC",
    surface: "#FFFFFF",
    card: "#FFFFFF",
    elevated: "#F2F4F8",
    border: "#E2E5EB",
    hover: "#EDF0F5",
    muted: "#6B7280",
  },

  // ─── Text ───
  text: {
    dark: { primary: "#F0F0F5", secondary: "#A0A0B8", tertiary: "#6B6B85" },
    light: { primary: "#0F1729", secondary: "#4B5563", tertiary: "#9CA3AF" },
  },

  // ─── Semantic ───
  success: "#10B981",
  successLight: "#D1FAE5",
  successDark: "#064E3B",
  warning: "#F59E0B",
  warningLight: "#FEF3C7",
  warningDark: "#78350F",
  error: "#EF4444",
  errorLight: "#FEE2E2",
  errorDark: "#7F1D1D",
  info: "#3B82F6",
  infoLight: "#DBEAFE",
  infoDark: "#1E3A5F",

  // ─── Meeting ───
  meeting: {
    micOn: "#10B981",
    micOff: "#EF4444",
    cameraOn: "#10B981",
    cameraOff: "#EF4444",
    screenShare: "#8B5CF6",
    handRaised: "#F59E0B",
    callEnd: "#DC2626",
    callEndHover: "#B91C1C",
    tile: "#1E1E2E",
    tileLight: "#F1F3F5",
  },

  // ─── Chat ───
  chat: {
    sent: "#1A6BF5",
    received: "#222233",
    receivedLight: "#F2F4F8",
  },
} as const;

/** Gradient presets */
export const gradients = {
  primary: "linear-gradient(135deg, #1A6BF5, #3B82F6)",
  dark: "linear-gradient(180deg, #0A0A0F, #12121A)",
  accent: "linear-gradient(135deg, #1A6BF5, #8B5CF6)",
} as const;
