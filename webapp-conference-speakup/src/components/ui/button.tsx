"use client";

import { forwardRef, type ButtonHTMLAttributes } from "react";
import { cn } from "@/lib/utils";
import { Loader2 } from "lucide-react";

type ButtonVariant = "primary" | "secondary" | "outline" | "ghost" | "danger";
type ButtonSize = "sm" | "md" | "lg";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  loading?: boolean;
  icon?: React.ReactNode;
  iconRight?: React.ReactNode;
}

const variantStyles: Record<ButtonVariant, string> = {
  primary:
    "bg-primary text-white hover:bg-primary-dark active:bg-primary-dark shadow-sm",
  secondary:
    "bg-elevated text-text-primary hover:bg-hover border border-border",
  outline:
    "border border-primary text-primary hover:bg-primary-surface",
  ghost: "text-text-secondary hover:bg-hover hover:text-text-primary",
  danger: "bg-error text-white hover:bg-red-700 active:bg-red-800",
};

const sizeStyles: Record<ButtonSize, string> = {
  sm: "h-9 px-3 text-sm gap-1.5 rounded-lg",
  md: "h-12 px-5 text-base gap-2 rounded-xl",
  lg: "h-14 px-6 text-base gap-2 rounded-xl",
};

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      className,
      variant = "primary",
      size = "md",
      loading,
      disabled,
      icon,
      iconRight,
      children,
      ...props
    },
    ref
  ) => (
    <button
      ref={ref}
      disabled={disabled || loading}
      className={cn(
        "inline-flex items-center justify-center font-semibold transition-all duration-200 cursor-pointer select-none",
        "disabled:opacity-50 disabled:cursor-not-allowed",
        variantStyles[variant],
        sizeStyles[size],
        className
      )}
      {...props}
    >
      {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : icon}
      {children}
      {iconRight}
    </button>
  )
);
Button.displayName = "Button";

interface IconButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  icon: React.ReactNode;
}

export function IconButton({
  className,
  variant = "ghost",
  size = "md",
  icon,
  ...props
}: IconButtonProps) {
  const sizeMap: Record<ButtonSize, string> = {
    sm: "h-8 w-8",
    md: "h-10 w-10",
    lg: "h-12 w-12",
  };
  return (
    <button
      className={cn(
        "inline-flex items-center justify-center rounded-xl transition-all duration-200 cursor-pointer",
        variantStyles[variant],
        sizeMap[size],
        className
      )}
      {...props}
    >
      {icon}
    </button>
  );
}
