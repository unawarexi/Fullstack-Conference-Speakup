import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_conference_speakup/app/domain/models/chat_model.dart';

void main() {
  final now = DateTime(2026, 4, 2);

  group('ChatMessage', () {
    final json = {
      'id': 'msg-1',
      'chatRoomId': 'room-1',
      'senderId': 'user-1',
      'sender': {'fullName': 'Alice', 'avatar': 'https://example.com/a.png'},
      'content': 'Hello!',
      'type': 'TEXT',
      'replyToId': null,
      'isEdited': false,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };

    test('fromJson parses all fields', () {
      final msg = ChatMessage.fromJson(json);
      expect(msg.id, 'msg-1');
      expect(msg.chatRoomId, 'room-1');
      expect(msg.senderId, 'user-1');
      expect(msg.senderName, 'Alice');
      expect(msg.senderAvatar, 'https://example.com/a.png');
      expect(msg.content, 'Hello!');
      expect(msg.type, MessageType.text);
      expect(msg.isEdited, false);
    });

    test('fromJson handles roomId fallback', () {
      final withRoomId = Map<String, dynamic>.from(json)
        ..remove('chatRoomId')
        ..['roomId'] = 'room-fallback';
      final msg = ChatMessage.fromJson(withRoomId);
      expect(msg.chatRoomId, 'room-fallback');
    });

    test('fromJson parses IMAGE type', () {
      final imageMsg = ChatMessage.fromJson({...json, 'type': 'IMAGE'});
      expect(imageMsg.type, MessageType.image);
    });

    test('fromJson parses FILE type', () {
      final fileMsg = ChatMessage.fromJson({...json, 'type': 'FILE'});
      expect(fileMsg.type, MessageType.file);
    });

    test('fromJson parses SYSTEM type', () {
      final sysMsg = ChatMessage.fromJson({...json, 'type': 'SYSTEM'});
      expect(sysMsg.type, MessageType.system);
    });

    test('toJson round-trip', () {
      final msg = ChatMessage.fromJson(json);
      final output = msg.toJson();
      final restored = ChatMessage.fromJson(output);
      expect(restored.id, msg.id);
      expect(restored.content, msg.content);
    });
  });

  group('ChatRoom', () {
    final json = {
      'id': 'room-1',
      'name': 'General',
      'isGroup': true,
      'meetingId': 'meeting-1',
      'members': [
        {
          'id': 'member-1',
          'userId': 'user-1',
          'user': {'fullName': 'Alice', 'avatar': null},
          'joinedAt': now.toIso8601String(),
        }
      ],
      'lastMessage': null,
      'unreadCount': 3,
      'createdAt': now.toIso8601String(),
    };

    test('fromJson parses all fields', () {
      final room = ChatRoom.fromJson(json);
      expect(room.id, 'room-1');
      expect(room.name, 'General');
      expect(room.isGroup, true);
      expect(room.meetingId, 'meeting-1');
      expect(room.members.length, 1);
      expect(room.unreadCount, 3);
    });

    test('fromJson handles empty members', () {
      final noMembers = Map<String, dynamic>.from(json)..['members'] = null;
      final room = ChatRoom.fromJson(noMembers);
      expect(room.members, isEmpty);
    });

    test('toJson round-trip', () {
      final room = ChatRoom.fromJson(json);
      final output = room.toJson();
      final restored = ChatRoom.fromJson(output);
      expect(restored.id, room.id);
      expect(restored.members.length, room.members.length);
    });
  });

  group('ChatMember', () {
    test('fromJson parses nested user object', () {
      final json = {
        'id': 'member-1',
        'userId': 'user-1',
        'user': {'fullName': 'Bob', 'avatar': 'https://example.com/b.png'},
        'joinedAt': now.toIso8601String(),
      };
      final member = ChatMember.fromJson(json);
      expect(member.fullName, 'Bob');
      expect(member.avatar, 'https://example.com/b.png');
    });
  });
}
