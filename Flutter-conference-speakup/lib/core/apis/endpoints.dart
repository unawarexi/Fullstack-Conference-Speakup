/// Centralized API endpoint paths matching backend routes.
/// All paths are relative — base URL is set on the Dio client.
class ApiEndpoints {
  ApiEndpoints._();

  // ──────────── Auth ────────────
  static const signIn = '/auth/signin';
  static const signOut = '/auth/signout';
  static const me = '/auth/me';
  static const deleteAccount = '/auth/account';

  // ──────────── Users ────────────
  static const userProfile = '/users/profile';
  static const userAvatar = '/users/avatar';
  static const userDevices = '/users/devices';
  static String userDevice(String deviceId) => '/users/devices/$deviceId';
  static const userOnlineStatus = '/users/online-status';

  // ──────────── Meetings ────────────
  static const meetings = '/meetings';
  static String meeting(String id) => '/meetings/$id';
  static String joinByCode(String code) => '/meetings/join/$code';
  static String joinMeeting(String id) => '/meetings/$id/join';
  static String leaveMeeting(String id) => '/meetings/$id/leave';
  static String endMeeting(String id) => '/meetings/$id/end';
  static String lockMeeting(String id) => '/meetings/$id/lock';
  static String unlockMeeting(String id) => '/meetings/$id/unlock';
  static String meetingParticipants(String id) => '/meetings/$id/participants';
  static String kickParticipant(String meetingId, String participantId) =>
      '/meetings/$meetingId/kick/$participantId';
  static String meetingToken(String id) => '/meetings/$id/token';

  // ──────────── Rooms ────────────
  static const activeRooms = '/rooms/active';
  static String roomState(String id) => '/rooms/$id';
  static String roomSettings(String id) => '/rooms/$id/settings';
  static String roomMuteAll(String id) => '/rooms/$id/mute-all';

  // ──────────── Chat ────────────
  static const chatRooms = '/chat/rooms';
  static String meetingChat(String meetingId) => '/chat/meeting/$meetingId';
  static String chatMessages(String chatRoomId) => '/chat/$chatRoomId/messages';
  static String deleteMessage(String messageId) => '/chat/messages/$messageId';

  // ──────────── Notifications ────────────
  static const notifications = '/notifications';
  static const notificationUnreadCount = '/notifications/unread-count';
  static const notificationReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';
  static String notificationDelete(String id) => '/notifications/$id';

  // ──────────── Recordings ────────────
  static const recordings = '/recordings';
  static String recording(String id) => '/recordings/$id';
  static String recordingDownload(String id) => '/recordings/$id/download';
  static String startRecording(String meetingId) =>
      '/recordings/meeting/$meetingId/start';
  static String stopRecording(String meetingId) =>
      '/recordings/meeting/$meetingId/stop';

  // ──────────── Analytics ────────────
  static const analyticsDashboard = '/analytics/dashboard';
  static const analyticsUsage = '/analytics/usage';
  static String meetingAnalytics(String meetingId) =>
      '/analytics/meeting/$meetingId';

  // ──────────── Billing ────────────
  static const subscription = '/billing/subscription';
  static const billingCheckout = '/billing/checkout';
  static const billingPortal = '/billing/portal';
  static const billingCancel = '/billing/cancel';

  // ──────────── Search ────────────
  static const search = '/search';
  static const searchUsers = '/search/users';
  static const searchMeetings = '/search/meetings';
}
