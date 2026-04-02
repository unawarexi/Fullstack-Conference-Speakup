import {
  format,
  formatDistanceToNow,
  isToday,
  isYesterday,
  differenceInMinutes,
} from "date-fns";

/** "Apr 2, 2026" */
export function formatDate(date: string | Date) {
  return format(new Date(date), "MMM d, yyyy");
}

/** "2:30 PM" */
export function formatTime(date: string | Date) {
  return format(new Date(date), "h:mm a");
}

/** "2 hours ago" / "Yesterday" / "Apr 2" */
export function formatRelative(date: string | Date) {
  const d = new Date(date);
  const minutes = differenceInMinutes(new Date(), d);
  if (minutes < 1) return "Just now";
  if (minutes < 60) return `${minutes}m ago`;
  if (isToday(d)) return formatTime(d);
  if (isYesterday(d)) return "Yesterday";
  return format(d, "MMM d");
}

/** "1h 23m 45s" */
export function formatDuration(seconds: number) {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  if (h > 0) return `${h}h ${m}m ${s}s`;
  if (m > 0) return `${m}m ${s}s`;
  return `${s}s`;
}

/** "01:23:45" timer format */
export function formatTimer(seconds: number) {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  const pad = (n: number) => n.toString().padStart(2, "0");
  return h > 0 ? `${pad(h)}:${pad(m)}:${pad(s)}` : `${pad(m)}:${pad(s)}`;
}

/** "3 participants" / "1 participant" */
export function formatParticipantCount(count: number) {
  return `${count} participant${count !== 1 ? "s" : ""}`;
}

/** "2.5 MB" / "340 KB" */
export function formatFileSize(bytes: number) {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

/** "John D." — truncate to first name + initial */
export function formatName(fullName: string) {
  const parts = fullName.trim().split(" ");
  if (parts.length === 1) return parts[0];
  return `${parts[0]} ${parts[parts.length - 1][0]}.`;
}

/** "Good morning" / "Good afternoon" / "Good evening" */
export function getGreeting() {
  const h = new Date().getHours();
  if (h < 12) return "Good morning";
  if (h < 18) return "Good afternoon";
  return "Good evening";
}

/** "5 minutes ago" */
export function timeAgo(date: string | Date) {
  return formatDistanceToNow(new Date(date), { addSuffix: true });
}
