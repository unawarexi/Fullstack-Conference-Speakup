import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_conference_speakup/app/domain/models/notification_model.dart';

void main() {
  final now = DateTime(2026, 4, 2);

  group('NotificationModel', () {
    final json = {
      'id': 'notif-1',
      'userId': 'user-1',
      'title': 'Meeting Invite',
      'body': 'You are invited to Sprint Planning',
      'type': 'MEETING_INVITE',
      'data': {'meetingId': 'meeting-1'},
      'isRead': false,
      'createdAt': now.toIso8601String(),
    };

    test('fromJson parses all fields', () {
      final n = NotificationModel.fromJson(json);
      expect(n.id, 'notif-1');
      expect(n.userId, 'user-1');
      expect(n.title, 'Meeting Invite');
      expect(n.body, 'You are invited to Sprint Planning');
      expect(n.type, NotificationType.meetingInvite);
      expect(n.data?['meetingId'], 'meeting-1');
      expect(n.isRead, false);
    });

    test('fromJson converts SNAKE_CASE to camelCase for type', () {
      final types = {
        'MEETING_INVITE': NotificationType.meetingInvite,
        'MEETING_REMINDER': NotificationType.meetingReminder,
        'MEETING_STARTED': NotificationType.meetingStarted,
        'CHAT_MESSAGE': NotificationType.chatMessage,
        'RECORDING_READY': NotificationType.recordingReady,
        'SYSTEM': NotificationType.system,
      };
      for (final entry in types.entries) {
        final n = NotificationModel.fromJson({...json, 'type': entry.key});
        expect(n.type, entry.value, reason: '${entry.key} → ${entry.value}');
      }
    });

    test('fromJson falls back to system for unknown type', () {
      final n = NotificationModel.fromJson({...json, 'type': 'UNKNOWN_TYPE'});
      expect(n.type, NotificationType.system);
    });

    test('copyWith changes isRead', () {
      final n = NotificationModel.fromJson(json);
      final read = n.copyWith(isRead: true);
      expect(read.isRead, true);
      expect(read.id, n.id);
      expect(read.title, n.title);
    });

    test('toJson round-trip', () {
      final n = NotificationModel.fromJson(json);
      final output = n.toJson();
      expect(output['id'], 'notif-1');
      expect(output['title'], 'Meeting Invite');
    });
  });
}
