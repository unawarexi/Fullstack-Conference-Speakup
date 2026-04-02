/** API endpoint paths — mirrors Flutter ApiEndpoints exactly */
export const endpoints = {
  // ─── Auth ───
  auth: {
    signIn: "/auth/signin",
    signOut: "/auth/signout",
    me: "/auth/me",
    deleteAccount: "/auth/account",
  },

  // ─── Users ───
  users: {
    profile: "/users/profile",
    avatar: "/users/avatar",
    devices: "/users/devices",
    device: (id: string) => `/users/devices/${id}`,
    onlineStatus: "/users/online-status",
  },

  // ─── Meetings ───
  meetings: {
    list: "/meetings",
    byId: (id: string) => `/meetings/${id}`,
    joinByCode: (code: string) => `/meetings/join/${code}`,
    join: (id: string) => `/meetings/${id}/join`,
    leave: (id: string) => `/meetings/${id}/leave`,
    end: (id: string) => `/meetings/${id}/end`,
    lock: (id: string) => `/meetings/${id}/lock`,
    unlock: (id: string) => `/meetings/${id}/unlock`,
    participants: (id: string) => `/meetings/${id}/participants`,
    kick: (meetingId: string, participantId: string) =>
      `/meetings/${meetingId}/kick/${participantId}`,
    token: (id: string) => `/meetings/${id}/token`,
  },

  // ─── Rooms ───
  rooms: {
    active: "/rooms/active",
    state: (id: string) => `/rooms/${id}`,
    settings: (id: string) => `/rooms/${id}/settings`,
    muteAll: (id: string) => `/rooms/${id}/mute-all`,
  },

  // ─── Chat ───
  chat: {
    rooms: "/chat/rooms",
    meetingChat: (meetingId: string) => `/chat/meeting/${meetingId}`,
    messages: (chatRoomId: string) => `/chat/${chatRoomId}/messages`,
    deleteMessage: (messageId: string) => `/chat/messages/${messageId}`,
  },

  // ─── Notifications ───
  notifications: {
    list: "/notifications",
    unreadCount: "/notifications/unread-count",
    readAll: "/notifications/read-all",
    read: (id: string) => `/notifications/${id}/read`,
    delete: (id: string) => `/notifications/${id}`,
  },

  // ─── Recordings ───
  recordings: {
    list: "/recordings",
    byId: (id: string) => `/recordings/${id}`,
    download: (id: string) => `/recordings/${id}/download`,
    start: (meetingId: string) => `/recordings/meeting/${meetingId}/start`,
    stop: (meetingId: string) => `/recordings/meeting/${meetingId}/stop`,
  },

  // ─── Analytics ───
  analytics: {
    dashboard: "/analytics/dashboard",
    usage: "/analytics/usage",
    meeting: (meetingId: string) => `/analytics/meeting/${meetingId}`,
  },

  // ─── Billing ───
  billing: {
    subscription: "/billing/subscription",
    checkout: "/billing/checkout",
    portal: "/billing/portal",
    cancel: "/billing/cancel",
  },

  // ─── Search ───
  search: {
    global: "/search",
    users: "/search/users",
    meetings: "/search/meetings",
  },
} as const;
