import { cn } from "@/lib/utils";
import type { ReactNode } from "react";

/* ── Badge ───────────────────────────────────────────────── */

type BadgeVariant = "default" | "success" | "warning" | "error" | "info" | "outline";

const variantStyles: Record<BadgeVariant, string> = {
  default: "bg-primary/10 text-primary",
  success: "bg-success/10 text-success",
  warning: "bg-warning/10 text-warning",
  error: "bg-error/10 text-error",
  info: "bg-info/10 text-info",
  outline: "border border-border text-textSecondary bg-transparent",
};

interface BadgeProps {
  children: ReactNode;
  variant?: BadgeVariant;
  className?: string;
}

export function Badge({ children, variant = "default", className }: BadgeProps) {
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
        variantStyles[variant],
        className
      )}
    >
      {children}
    </span>
  );
}

/* ── CountBadge (notification dot / count) ───────────────── */

interface CountBadgeProps {
  count: number;
  className?: string;
}

export function CountBadge({ count, className }: CountBadgeProps) {
  if (count <= 0) return null;
  const display = count > 99 ? "99+" : String(count);
  return (
    <span
      className={cn(
        "inline-flex items-center justify-center rounded-full bg-error text-white font-semibold",
        display.length === 1 ? "h-5 w-5 text-[10px]" : "h-5 min-w-5 px-1.5 text-[10px]",
        className
      )}
    >
      {display}
    </span>
  );
}

/* ── LiveBadge ───────────────────────────────────────────── */

export function LiveBadge({ className }: { className?: string }) {
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1.5 rounded-full bg-error/10 px-2.5 py-0.5 text-xs font-semibold text-error",
        className
      )}
    >
      <span className="h-1.5 w-1.5 rounded-full bg-error animate-pulse" />
      LIVE
    </span>
  );
}
