/// Shared test helpers and mocks for the SpeakUp test suite.
library;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/auth_repository.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/meeting_repository.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/chat_repository.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/user_repository.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/notification_repository.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/recording_repository.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/billing_repository.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/search_repository.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/analytics_repository.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/room_repository.dart';
import 'package:flutter_conference_speakup/core/network/api_client.dart';
import 'package:flutter_conference_speakup/app/domain/models/user_model.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';
import 'package:flutter_conference_speakup/app/domain/models/chat_model.dart';
import 'package:flutter_conference_speakup/app/domain/models/participant_model.dart';
import 'package:flutter_conference_speakup/app/domain/models/notification_model.dart';
import 'package:flutter_conference_speakup/app/domain/models/subscription_model.dart';

// ──────────── Mock Classes ────────────

class MockDio extends Mock implements Dio {}

class MockApiClient extends Mock implements ApiClient {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockMeetingRepository extends Mock implements MeetingRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class MockRecordingRepository extends Mock implements RecordingRepository {}

class MockBillingRepository extends Mock implements BillingRepository {}

class MockSearchRepository extends Mock implements SearchRepository {}

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

class MockRoomRepository extends Mock implements RoomRepository {}

// ──────────── Fake Classes for registerFallbackValue ────────────

class FakeUri extends Fake implements Uri {}

class FakeRequestOptions extends Fake implements RequestOptions {}

// ──────────── Test Fixtures ────────────

final now = DateTime(2026, 4, 2, 12, 0, 0);

UserModel testUser({String id = 'user-1'}) => UserModel(
      id: id,
      firebaseUid: 'firebase-uid-1',
      email: 'test@speakup.app',
      fullName: 'Test User',
      avatar: 'https://example.com/avatar.png',
      bio: 'A test user',
      isOnline: true,
      lastSeenAt: now,
      role: UserRole.user,
      createdAt: now,
      updatedAt: now,
    );

MeetingModel testMeeting({String id = 'meeting-1'}) => MeetingModel(
      id: id,
      code: 'ABC-DEF-GHI',
      title: 'Test Meeting',
      description: 'A test meeting',
      hostId: 'user-1',
      hostName: 'Test User',
      hostAvatar: 'https://example.com/avatar.png',
      type: MeetingType.instant,
      status: MeetingStatus.live,
      scheduledAt: now,
      startedAt: now,
      participantCount: 3,
      maxParticipants: 100,
      isRecording: false,
      settings: {'muteOnJoin': true},
      createdAt: now,
    );

Participant testParticipant({String id = 'participant-1'}) => Participant(
      id: id,
      meetingId: 'meeting-1',
      userId: 'user-1',
      name: 'Test User',
      avatar: 'https://example.com/avatar.png',
      isMuted: false,
      isCameraOff: false,
      role: ParticipantRole.host,
      joinedAt: now,
    );

ChatRoom testChatRoom({String id = 'chat-room-1'}) => ChatRoom(
      id: id,
      name: 'Test Chat',
      isGroup: true,
      meetingId: 'meeting-1',
      members: [
        ChatMember(
          id: 'member-1',
          userId: 'user-1',
          fullName: 'Test User',
          joinedAt: now,
        ),
      ],
      unreadCount: 2,
      createdAt: now,
    );

ChatMessage testChatMessage({String id = 'msg-1'}) => ChatMessage(
      id: id,
      chatRoomId: 'chat-room-1',
      senderId: 'user-1',
      senderName: 'Test User',
      content: 'Hello world',
      type: MessageType.text,
      isEdited: false,
      createdAt: now,
      updatedAt: now,
    );

NotificationModel testNotification({String id = 'notif-1'}) =>
    NotificationModel(
      id: id,
      userId: 'user-1',
      title: 'Meeting Starting',
      body: 'Your meeting starts in 5 minutes',
      type: NotificationType.meetingReminder,
      isRead: false,
      createdAt: now,
    );

RecordingModel testRecording({String id = 'rec-1'}) => RecordingModel(
      id: id,
      meetingId: 'meeting-1',
      userId: 'user-1',
      meetingTitle: 'Test Meeting',
      url: 'https://example.com/recording.mp4',
      duration: 3600,
      sizeBytes: 52428800,
      status: RecordingStatus.ready,
      createdAt: now,
    );

SubscriptionModel testSubscription({String id = 'sub-1'}) =>
    SubscriptionModel(
      id: id,
      userId: 'user-1',
      plan: SubscriptionPlan.pro,
      status: SubscriptionStatus.active,
      stripeCustomerId: 'cus_test',
      stripeSubId: 'sub_test',
      currentPeriodStart: now,
      currentPeriodEnd: now.add(const Duration(days: 30)),
      createdAt: now,
    );

// ──────────── Provider Overrides ────────────

/// Creates a ProviderContainer with common mock overrides.
ProviderContainer createContainer({
  List<Override> overrides = const [],
}) {
  return ProviderContainer(overrides: overrides);
}
