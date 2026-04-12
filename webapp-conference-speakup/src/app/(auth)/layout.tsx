"use client";

import Image from "next/image";
import { strings } from "@/config/strings";
import { Sun, Moon } from "lucide-react";
import type { ReactNode } from "react";
import { useState, useEffect } from "react";
import { useThemeStore } from "@/store/theme-store";

export default function AuthLayout({ children }: { children: ReactNode }) {
  const [mounted, setMounted] = useState(false);
  const resolvedTheme = useThemeStore((s) => s.resolvedTheme);
  const toggleDarkMode = useThemeStore((s) => s.toggleDarkMode);

  useEffect(() => {
    setMounted(true);
  }, []);

  const isDark = mounted && resolvedTheme === "dark";

  return (
    <div className="flex min-h-screen relative">
      {/* Theme toggle — floating top-right */}
      <button
        onClick={toggleDarkMode}
        aria-label="Toggle theme"
        className="absolute top-5 right-5 z-50 flex h-10 w-10 items-center justify-center rounded-xl border border-border bg-card/80 backdrop-blur-sm text-text-secondary hover:text-text-primary hover:bg-card transition-colors"
      >
        {mounted ? (isDark ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />) : null}
      </button>

      {/* Left panel — branding with pattern background */}
      <div className="hidden lg:flex lg:w-1/2 items-center justify-center relative overflow-hidden">
        {/* Base dark bg */}
        <div className="absolute inset-0 bg-[#060610]" />

        {/* Grid pattern */}
        <div className="absolute inset-0 bg-[linear-gradient(to_right,rgba(26,107,245,0.06)_1px,transparent_1px),linear-gradient(to_bottom,rgba(26,107,245,0.06)_1px,transparent_1px)] bg-[size:60px_60px]" />

        {/* Radial glows */}
        <div className="absolute top-1/4 left-1/3 w-80 h-80 bg-primary/10 rounded-full blur-[100px]" />
        <div className="absolute bottom-1/4 right-1/4 w-60 h-60 bg-[#8B5CF6]/8 rounded-full blur-[80px]" />

        {/* Star dots */}
        <div className="absolute inset-0 overflow-hidden">
          {Array.from({ length: 40 }).map((_, i) => (
            <div
              key={i}
              className="absolute w-[2px] h-[2px] bg-white rounded-full animate-pulse"
              style={{
                top: `${(i * 37 + 13) % 100}%`,
                left: `${(i * 53 + 7) % 100}%`,
                opacity: 0.15 + (i % 5) * 0.08,
                animationDelay: `${(i * 0.3) % 3}s`,
                animationDuration: `${2 + (i % 3)}s`,
              }}
            />
          ))}
        </div>

        {/* Content */}
        <div className="relative z-10 max-w-sm text-center px-8">
          <div className="mx-auto mb-8 flex items-center justify-center">
            <Image
              src="/logo/emblem.png"
              alt="SpeakUp"
              width={80}
              height={80}
              className="drop-shadow-2xl"
              style={{ width: "auto", height: "auto" }}
              priority
            />
          </div>
          <Image
            src="/logo/logo.png"
            alt="SpeakUp"
            width={180}
            height={48}
            className="mx-auto mb-4"
            style={{ width: "auto", height: 48 }}
            priority
          />
          <p className="text-sm text-white/50 leading-relaxed">
            {strings.app.tagline}
          </p>

          {/* Feature pills */}
          <div className="mt-8 flex flex-wrap justify-center gap-2">
            {["4K Video", "AI Copilot", "E2E Encrypted", "Smart Scheduling"].map((f) => (
              <span
                key={f}
                className="rounded-full border border-white/10 bg-white/5 px-3 py-1 text-xs text-white/40"
              >
                {f}
              </span>
            ))}
          </div>
        </div>
      </div>

      {/* Right panel — form */}
      <div className="flex w-full items-center justify-center p-6 lg:w-1/2 bg-background relative overflow-hidden">
        {/* Subtle grid on form side too */}
        <div className="absolute inset-0 bg-[linear-gradient(to_right,var(--border)_1px,transparent_1px),linear-gradient(to_bottom,var(--border)_1px,transparent_1px)] bg-[size:80px_80px] opacity-20" />
        <div className="absolute top-0 right-0 w-60 h-60 bg-primary/5 rounded-full blur-[80px]" />

        <div className="w-full max-w-md relative z-10">{children}</div>
      </div>
    </div>
  );
}
