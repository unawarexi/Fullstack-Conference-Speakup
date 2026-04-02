import { cn } from "@/lib/utils";
import { Loader2 } from "lucide-react";

interface SpinnerProps {
  size?: "sm" | "md" | "lg";
  className?: string;
}

export function Spinner({ size = "md", className }: SpinnerProps) {
  const sizeMap = { sm: "h-4 w-4", md: "h-6 w-6", lg: "h-10 w-10" };
  return (
    <Loader2
      className={cn("animate-spin text-primary", sizeMap[size], className)}
    />
  );
}

export function PageSpinner() {
  return (
    <div className="flex h-[60vh] items-center justify-center">
      <Spinner size="lg" />
    </div>
  );
}

export function PulsingDot({ className }: { className?: string }) {
  return (
    <span
      className={cn(
        "inline-block h-2 w-2 rounded-full bg-success animate-pulse",
        className
      )}
    />
  );
}

export function TypingIndicator() {
  return (
    <div className="flex items-center gap-1 px-2">
      {[0, 1, 2].map((i) => (
        <span
          key={i}
          className="h-1.5 w-1.5 rounded-full bg-muted animate-bounce"
          style={{ animationDelay: `${i * 150}ms` }}
        />
      ))}
    </div>
  );
}
