// ─── User ───
export type UserRole = "user" | "admin" | "moderator";

export interface DeviceInfo {
  id: string;
  deviceId: string;
  platform: string;
  name: string;
  pushToken?: string;
  lastActiveAt: string;
}

export interface User {
  id: string;
  firebaseUid: string;
  email: string;
  name: string;
  fullName: string;
  avatar?: string;
  bio?: string;
  isOnline: boolean;
  lastSeenAt?: string;
  role: UserRole;
  createdAt: string;
  updatedAt: string;
}

// ─── Meeting ───
export type MeetingType = "instant" | "scheduled" | "recurring";
export type MeetingStatus = "scheduled" | "live" | "ended" | "cancelled";
export type ParticipantRole = "host" | "coHost" | "attendee";

export interface MeetingSettings {
  muteOnEntry: boolean;
  cameraOffOnEntry: boolean;
  allowScreenShare: boolean;
  allowRecording: boolean;
  waitingRoom: boolean;
  maxParticipants: number;
}

export interface Meeting {
  id: string;
  code: string;
  title: string;
  description?: string;
  host?: User;
  hostName?: string;
  type: MeetingType;
  status: MeetingStatus;
  scheduledAt?: string;
  startedAt?: string;
  endedAt?: string;
  participantCount: number;
  maxParticipants: number;
  isRecording: boolean;
  password?: string;
  settings: MeetingSettings;
  createdAt: string;
  updatedAt: string;
}

export interface Participant {
  id: string;
  userId: string;
  meetingId: string;
  user?: User;
  name?: string;
  role: ParticipantRole;
  isMuted: boolean;
  isCameraOff: boolean;
  isScreenSharing: boolean;
  isHandRaised: boolean;
  joinedAt: string;
  leftAt?: string;
}

// ─── Chat ───
export type ChatMessageType = "text" | "image" | "file" | "system";

export interface ChatMessage {
  id: string;
  chatRoomId: string;
  senderId: string;
  sender?: User;
  content: string;
  type: ChatMessageType;
  replyToId?: string;
  isEdited: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface ChatMember {
  id: string;
  userId: string;
  user?: User;
  joinedAt: string;
}

export interface ChatRoom {
  id: string;
  name?: string;
  isGroup: boolean;
  meetingId?: string;
  members: ChatMember[];
  lastMessage?: ChatMessage;
  unreadCount: number;
  createdAt: string;
}

// ─── Notification ───
export type NotificationType =
  | "meetingInvite"
  | "meetingReminder"
  | "meetingStarted"
  | "chatMessage"
  | "recordingReady"
  | "system";

export interface Notification {
  id: string;
  userId: string;
  title: string;
  body: string;
  type: NotificationType;
  data?: Record<string, unknown>;
  isRead: boolean;
  createdAt: string;
}

// ─── Recording ───
export type RecordingStatus = "processing" | "ready" | "failed";

export interface Recording {
  id: string;
  meetingId: string;
  meeting?: Meeting;
  url?: string;
  duration: number;
  sizeBytes: number;
  status: RecordingStatus;
  createdAt: string;
}

// ─── Billing ───
export type SubscriptionPlan = "free" | "pro" | "enterprise";
export type SubscriptionStatus =
  | "active"
  | "pastDue"
  | "cancelled"
  | "trialing"
  | "incomplete";

export interface Subscription {
  id: string;
  userId: string;
  plan: SubscriptionPlan;
  status: SubscriptionStatus;
  stripeCustomerId?: string;
  stripeSubscriptionId?: string;
  currentPeriodStart?: string;
  currentPeriodEnd?: string;
  createdAt: string;
}

// ─── API Responses ───
export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
  hasMore: boolean;
}

// ─── Search ───
export interface SearchResult {
  users: User[];
  meetings: Meeting[];
}

// ─── Analytics ───
export interface DashboardAnalytics {
  totalMeetings: number;
  totalParticipants: number;
  totalRecordings: number;
  averageDuration: number;
  meetingsThisWeek: number;
}

// ─── Meeting Room State (Client-side) ───
export interface MeetingRoomState {
  meeting: Meeting | null;
  participants: Participant[];
  isMicOn: boolean;
  isCameraOn: boolean;
  isScreenSharing: boolean;
  isHandRaised: boolean;
  isRecording: boolean;
  elapsedSeconds: number;
}
