import 'package:flutter_test/flutter_test.dart';
import 'package:video_confrence_app/core/apis/endpoints.dart';

void main() {
  group('ApiEndpoints', () {
    group('Auth', () {
      test('signIn', () => expect(ApiEndpoints.signIn, '/auth/signin'));
      test('signOut', () => expect(ApiEndpoints.signOut, '/auth/signout'));
      test('me', () => expect(ApiEndpoints.me, '/auth/me'));
      test('deleteAccount',
          () => expect(ApiEndpoints.deleteAccount, '/auth/account'));
    });

    group('Users', () {
      test('userProfile',
          () => expect(ApiEndpoints.userProfile, '/users/profile'));
      test('userAvatar',
          () => expect(ApiEndpoints.userAvatar, '/users/avatar'));
      test('userDevices',
          () => expect(ApiEndpoints.userDevices, '/users/devices'));
      test('userDevice',
          () => expect(ApiEndpoints.userDevice('d1'), '/users/devices/d1'));
      test('userOnlineStatus',
          () => expect(ApiEndpoints.userOnlineStatus, '/users/online-status'));
    });

    group('Meetings', () {
      test('meetings', () => expect(ApiEndpoints.meetings, '/meetings'));
      test('meeting',
          () => expect(ApiEndpoints.meeting('m1'), '/meetings/m1'));
      test('joinByCode',
          () => expect(ApiEndpoints.joinByCode('ABC'), '/meetings/join/ABC'));
      test('joinMeeting',
          () => expect(ApiEndpoints.joinMeeting('m1'), '/meetings/m1/join'));
      test('leaveMeeting',
          () => expect(ApiEndpoints.leaveMeeting('m1'), '/meetings/m1/leave'));
      test('endMeeting',
          () => expect(ApiEndpoints.endMeeting('m1'), '/meetings/m1/end'));
      test('lockMeeting',
          () => expect(ApiEndpoints.lockMeeting('m1'), '/meetings/m1/lock'));
      test('unlockMeeting', () {
        expect(ApiEndpoints.unlockMeeting('m1'), '/meetings/m1/unlock');
      });
      test('meetingParticipants', () {
        expect(ApiEndpoints.meetingParticipants('m1'),
            '/meetings/m1/participants');
      });
      test('kickParticipant', () {
        expect(ApiEndpoints.kickParticipant('m1', 'p1'),
            '/meetings/m1/kick/p1');
      });
      test('meetingToken',
          () => expect(ApiEndpoints.meetingToken('m1'), '/meetings/m1/token'));
    });

    group('Rooms', () {
      test('activeRooms',
          () => expect(ApiEndpoints.activeRooms, '/rooms/active'));
      test('roomState',
          () => expect(ApiEndpoints.roomState('r1'), '/rooms/r1'));
      test('roomSettings',
          () => expect(ApiEndpoints.roomSettings('r1'), '/rooms/r1/settings'));
      test('roomMuteAll',
          () => expect(ApiEndpoints.roomMuteAll('r1'), '/rooms/r1/mute-all'));
    });

    group('Chat', () {
      test('chatRooms', () => expect(ApiEndpoints.chatRooms, '/chat/rooms'));
      test('meetingChat', () {
        expect(ApiEndpoints.meetingChat('m1'), '/chat/meeting/m1');
      });
      test('chatMessages', () {
        expect(ApiEndpoints.chatMessages('cr1'), '/chat/cr1/messages');
      });
      test('deleteMessage', () {
        expect(ApiEndpoints.deleteMessage('msg1'), '/chat/messages/msg1');
      });
    });

    group('Notifications', () {
      test('notifications',
          () => expect(ApiEndpoints.notifications, '/notifications'));
      test('unreadCount', () {
        expect(
            ApiEndpoints.notificationUnreadCount, '/notifications/unread-count');
      });
      test('readAll', () {
        expect(ApiEndpoints.notificationReadAll, '/notifications/read-all');
      });
      test('read', () {
        expect(ApiEndpoints.notificationRead('n1'), '/notifications/n1/read');
      });
      test('delete', () {
        expect(ApiEndpoints.notificationDelete('n1'), '/notifications/n1');
      });
    });

    group('Recordings', () {
      test('recordings',
          () => expect(ApiEndpoints.recordings, '/recordings'));
      test('recording',
          () => expect(ApiEndpoints.recording('r1'), '/recordings/r1'));
      test('download', () {
        expect(ApiEndpoints.recordingDownload('r1'), '/recordings/r1/download');
      });
      test('start', () {
        expect(ApiEndpoints.startRecording('m1'),
            '/recordings/meeting/m1/start');
      });
      test('stop', () {
        expect(
            ApiEndpoints.stopRecording('m1'), '/recordings/meeting/m1/stop');
      });
    });

    group('Analytics', () {
      test('dashboard',
          () => expect(ApiEndpoints.analyticsDashboard, '/analytics/dashboard'));
      test('usage',
          () => expect(ApiEndpoints.analyticsUsage, '/analytics/usage'));
      test('meetingAnalytics', () {
        expect(
            ApiEndpoints.meetingAnalytics('m1'), '/analytics/meeting/m1');
      });
    });

    group('Billing', () {
      test('subscription',
          () => expect(ApiEndpoints.subscription, '/billing/subscription'));
      test('checkout',
          () => expect(ApiEndpoints.billingCheckout, '/billing/checkout'));
      test('portal',
          () => expect(ApiEndpoints.billingPortal, '/billing/portal'));
      test('cancel',
          () => expect(ApiEndpoints.billingCancel, '/billing/cancel'));
    });

    group('Search', () {
      test('search', () => expect(ApiEndpoints.search, '/search'));
      test('searchUsers',
          () => expect(ApiEndpoints.searchUsers, '/search/users'));
      test('searchMeetings',
          () => expect(ApiEndpoints.searchMeetings, '/search/meetings'));
    });
  });
}
