import { cn } from "@/lib/utils";
import type { LucideIcon } from "lucide-react";
import type { ReactNode } from "react";

interface EmptyStateProps {
  icon?: LucideIcon;
  title: string;
  description?: string;
  action?: ReactNode;
  className?: string;
}

export function EmptyState({ icon: Icon, title, description, action, className }: EmptyStateProps) {
  return (
    <div className={cn("flex flex-col items-center justify-center py-16 px-6 text-center", className)}>
      {Icon && (
        <div className="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-surfaceLight">
          <Icon className="h-8 w-8 text-textSecondary" />
        </div>
      )}
      <h3 className="text-lg font-semibold text-textPrimary">{title}</h3>
      {description && <p className="mt-1 max-w-sm text-sm text-textSecondary">{description}</p>}
      {action && <div className="mt-6">{action}</div>}
    </div>
  );
}
