"use client";

import { useEffect } from "react";
import { useThemeStore } from "@/store/theme-store";

export function ThemeInitializer() {
  const theme = useThemeStore((s) => s.theme);
  const setTheme = useThemeStore((s) => s.setTheme);

  useEffect(() => {
    // Re-apply on mount to ensure DOM matches stored preference
    setTheme(theme);
  }, []);

  return null;
}
