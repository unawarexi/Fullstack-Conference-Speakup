"use client";

import { cn } from "@/lib/utils";
import { useState, type ReactNode } from "react";

/* ── Tabs container ──────────────────────────────────────── */

interface TabsProps {
  tabs: { label: string; value: string }[];
  defaultValue?: string;
  onChange?: (value: string) => void;
  children: (activeTab: string) => ReactNode;
  className?: string;
}

export function Tabs({ tabs, defaultValue, onChange, children, className }: TabsProps) {
  const [active, setActive] = useState(defaultValue ?? tabs[0]?.value ?? "");

  const handleChange = (value: string) => {
    setActive(value);
    onChange?.(value);
  };

  return (
    <div className={cn("w-full", className)}>
      <div className="flex border-b border-border">
        {tabs.map((tab) => (
          <button
            key={tab.value}
            onClick={() => handleChange(tab.value)}
            className={cn(
              "px-4 py-2.5 text-sm font-medium transition-colors relative",
              active === tab.value
                ? "text-primary"
                : "text-textSecondary hover:text-textPrimary"
            )}
          >
            {tab.label}
            {active === tab.value && (
              <span className="absolute inset-x-0 bottom-0 h-0.5 bg-primary rounded-full" />
            )}
          </button>
        ))}
      </div>
      <div className="mt-4">{children(active)}</div>
    </div>
  );
}
