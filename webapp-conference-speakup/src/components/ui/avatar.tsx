"use client";

import { cn } from "@/lib/utils";
import Image from "next/image";
import { useMemo } from "react";

const sizeMap = {
  xs: "h-6 w-6 text-[10px]",
  sm: "h-8 w-8 text-xs",
  md: "h-10 w-10 text-sm",
  lg: "h-12 w-12 text-base",
  xl: "h-16 w-16 text-lg",
  xxl: "h-24 w-24 text-2xl",
};

interface AvatarProps {
  src?: string | null;
  name?: string;
  size?: keyof typeof sizeMap;
  className?: string;
  online?: boolean;
}

const bgColors = [
  "bg-primary",
  "bg-success",
  "bg-warning",
  "bg-error",
  "bg-info",
  "bg-[#8B5CF6]",
  "bg-[#EC4899]",
  "bg-[#14B8A6]",
];

export function Avatar({ src, name, size = "md", className, online }: AvatarProps) {
  const initials = useMemo(() => {
    if (!name) return "?";
    return name
      .split(" ")
      .map((w) => w[0])
      .slice(0, 2)
      .join("")
      .toUpperCase();
  }, [name]);

  const colorIndex = useMemo(() => {
    if (!name) return 0;
    let hash = 0;
    for (let i = 0; i < name.length; i++) hash = name.charCodeAt(i) + ((hash << 5) - hash);
    return Math.abs(hash) % bgColors.length;
  }, [name]);

  return (
    <div className={cn("relative inline-flex shrink-0", className)}>
      <div
        className={cn(
          "relative overflow-hidden rounded-full flex items-center justify-center font-semibold text-white",
          sizeMap[size],
          !src && bgColors[colorIndex]
        )}
      >
        {src ? (
          <Image src={src} alt={name ?? "Avatar"} fill className="object-cover" />
        ) : (
          <span>{initials}</span>
        )}
      </div>
      {online !== undefined && (
        <span
          className={cn(
            "absolute bottom-0 right-0 block rounded-full border-2 border-card",
            size === "xs" || size === "sm" ? "h-2 w-2" : "h-3 w-3",
            online ? "bg-success" : "bg-muted"
          )}
        />
      )}
    </div>
  );
}

interface AvatarGroupProps {
  items: { src?: string | null; name?: string }[];
  max?: number;
  size?: keyof typeof sizeMap;
  className?: string;
}

export function AvatarGroup({ items, max = 4, size = "sm", className }: AvatarGroupProps) {
  const visible = items.slice(0, max);
  const remaining = items.length - max;

  return (
    <div className={cn("flex -space-x-2", className)}>
      {visible.map((item, i) => (
        <Avatar
          key={i}
          src={item.src}
          name={item.name}
          size={size}
          className="ring-2 ring-card"
        />
      ))}
      {remaining > 0 && (
        <div
          className={cn(
            "flex items-center justify-center rounded-full bg-surfaceLight font-semibold text-textSecondary ring-2 ring-card",
            sizeMap[size]
          )}
        >
          +{remaining}
        </div>
      )}
    </div>
  );
}
