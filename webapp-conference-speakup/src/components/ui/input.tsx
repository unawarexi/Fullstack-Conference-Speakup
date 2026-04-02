"use client";

import { forwardRef, useState, type InputHTMLAttributes } from "react";
import { cn } from "@/lib/utils";
import { Eye, EyeOff, Search, X } from "lucide-react";

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
  icon?: React.ReactNode;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ className, label, error, icon, type, ...props }, ref) => (
    <div className="w-full">
      {label && (
        <label className="mb-1.5 block text-sm font-medium text-text-secondary">
          {label}
        </label>
      )}
      <div className="relative">
        {icon && (
          <div className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-muted">
            {icon}
          </div>
        )}
        <input
          ref={ref}
          type={type}
          className={cn(
            "h-[52px] w-full rounded-xl border border-border bg-surface px-3.5 text-base text-text-primary",
            "placeholder:text-text-tertiary",
            "focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/20",
            "transition-all duration-200",
            "disabled:cursor-not-allowed disabled:opacity-50",
            icon && "pl-11",
            error && "border-error focus:border-error focus:ring-error/20",
            className
          )}
          {...props}
        />
      </div>
      {error && <p className="mt-1 text-sm text-error">{error}</p>}
    </div>
  )
);
Input.displayName = "Input";

export function PasswordInput({
  className,
  ...props
}: Omit<InputProps, "type">) {
  const [show, setShow] = useState(false);
  return (
    <div className="relative">
      <Input type={show ? "text" : "password"} className={className} {...props} />
      <button
        type="button"
        onClick={() => setShow(!show)}
        className="absolute right-3.5 top-1/2 -translate-y-1/2 text-muted hover:text-text-primary transition-colors"
        tabIndex={-1}
      >
        {show ? <EyeOff size={18} /> : <Eye size={18} />}
      </button>
    </div>
  );
}

interface SearchBarProps extends InputHTMLAttributes<HTMLInputElement> {
  onClear?: () => void;
}

export function SearchBar({ className, value, onClear, ...props }: SearchBarProps) {
  return (
    <div className="relative">
      <Search
        size={18}
        className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-muted"
      />
      <input
        type="text"
        value={value}
        className={cn(
          "h-11 w-full rounded-full border border-border bg-elevated pl-10 pr-10 text-sm text-text-primary",
          "placeholder:text-text-tertiary",
          "focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/20",
          "transition-all duration-200",
          className
        )}
        {...props}
      />
      {value && onClear && (
        <button
          type="button"
          onClick={onClear}
          className="absolute right-3 top-1/2 -translate-y-1/2 text-muted hover:text-text-primary"
        >
          <X size={16} />
        </button>
      )}
    </div>
  );
}
