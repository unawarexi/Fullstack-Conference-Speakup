import { cn } from "@/lib/utils";

interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  hoverable?: boolean;
}

export function Card({ className, hoverable, children, ...props }: CardProps) {
  return (
    <div
      className={cn(
        "rounded-xl border border-border bg-card p-4",
        hoverable && "transition-all duration-200 hover:border-primary/30 hover:shadow-md cursor-pointer",
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
}

interface MeetingCardProps {
  title: string;
  time?: string;
  isLive?: boolean;
  participantCount?: number;
  host?: string;
  onClick?: () => void;
}

export function MeetingCard({
  title,
  time,
  isLive,
  participantCount,
  host,
  onClick,
}: MeetingCardProps) {
  return (
    <Card hoverable onClick={onClick} className="flex flex-col gap-2">
      <div className="flex items-center justify-between">
        <h3 className="font-semibold text-text-primary truncate">{title}</h3>
        {isLive && (
          <span className="flex items-center gap-1 rounded-full bg-error/10 px-2 py-0.5 text-xs font-medium text-error">
            <span className="h-1.5 w-1.5 rounded-full bg-error animate-pulse" />
            Live
          </span>
        )}
      </div>
      {time && <p className="text-sm text-text-secondary">{time}</p>}
      <div className="flex items-center justify-between text-xs text-text-tertiary">
        {host && <span>Host: {host}</span>}
        {participantCount !== undefined && (
          <span>
            {participantCount} participant{participantCount !== 1 ? "s" : ""}
          </span>
        )}
      </div>
    </Card>
  );
}
