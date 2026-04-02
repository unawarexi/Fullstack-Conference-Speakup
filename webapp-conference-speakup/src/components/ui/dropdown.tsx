"use client";

import { cn } from "@/lib/utils";
import { ChevronDown } from "lucide-react";
import { useEffect, useRef, useState, type ReactNode } from "react";

interface DropdownProps {
  trigger: ReactNode;
  children: ReactNode;
  align?: "left" | "right";
  className?: string;
}

export function Dropdown({ trigger, children, align = "left", className }: DropdownProps) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, []);

  return (
    <div ref={ref} className={cn("relative inline-block", className)}>
      <div onClick={() => setOpen((v) => !v)} className="cursor-pointer">
        {trigger}
      </div>
      {open && (
        <div
          className={cn(
            "absolute top-full z-50 mt-1.5 min-w-[180px] rounded-xl border border-border bg-card p-1.5 shadow-lg animate-in fade-in-0 zoom-in-95",
            align === "right" ? "right-0" : "left-0"
          )}
          onClick={() => setOpen(false)}
        >
          {children}
        </div>
      )}
    </div>
  );
}

interface DropdownItemProps {
  children: ReactNode;
  onClick?: () => void;
  icon?: ReactNode;
  danger?: boolean;
  className?: string;
}

export function DropdownItem({ children, onClick, icon, danger, className }: DropdownItemProps) {
  return (
    <button
      onClick={onClick}
      className={cn(
        "flex w-full items-center gap-2.5 rounded-lg px-3 py-2 text-sm transition-colors text-left",
        danger
          ? "text-error hover:bg-error/10"
          : "text-textPrimary hover:bg-surfaceLight",
        className
      )}
    >
      {icon && <span className="shrink-0">{icon}</span>}
      {children}
    </button>
  );
}

/* ── Select dropdown ─────────────────────────────────────── */

interface SelectOption {
  label: string;
  value: string;
}

interface SelectProps {
  options: SelectOption[];
  value?: string;
  onChange?: (value: string) => void;
  placeholder?: string;
  label?: string;
  error?: string;
  className?: string;
}

export function Select({
  options,
  value,
  onChange,
  placeholder = "Select…",
  label,
  error,
  className,
}: SelectProps) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const selected = options.find((o) => o.value === value);

  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, []);

  return (
    <div ref={ref} className={cn("relative", className)}>
      {label && <label className="mb-1.5 block text-sm font-medium text-textPrimary">{label}</label>}
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className={cn(
          "flex h-[52px] w-full items-center justify-between rounded-xl border bg-surface px-4 text-sm transition-colors",
          error ? "border-error" : "border-border hover:border-primary/50",
          open && "border-primary ring-2 ring-primary/20"
        )}
      >
        <span className={selected ? "text-textPrimary" : "text-textSecondary"}>
          {selected?.label ?? placeholder}
        </span>
        <ChevronDown className={cn("h-4 w-4 text-textSecondary transition-transform", open && "rotate-180")} />
      </button>
      {open && (
        <div className="absolute left-0 right-0 top-full z-50 mt-1 max-h-60 overflow-auto rounded-xl border border-border bg-card p-1 shadow-lg">
          {options.map((opt) => (
            <button
              key={opt.value}
              onClick={() => { onChange?.(opt.value); setOpen(false); }}
              className={cn(
                "flex w-full items-center rounded-lg px-3 py-2 text-sm transition-colors",
                opt.value === value ? "bg-primary/10 text-primary font-medium" : "text-textPrimary hover:bg-surfaceLight"
              )}
            >
              {opt.label}
            </button>
          ))}
        </div>
      )}
      {error && <p className="mt-1 text-xs text-error">{error}</p>}
    </div>
  );
}
