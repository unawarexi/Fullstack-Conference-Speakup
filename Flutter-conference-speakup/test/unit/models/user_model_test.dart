import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_conference_speakup/app/domain/models/user_model.dart';

void main() {
  group('UserModel', () {
    final now = DateTime(2026, 4, 2);
    final json = {
      'id': 'user-1',
      'firebaseUid': 'fb-1',
      'email': 'test@speakup.app',
      'fullName': 'Test User',
      'avatar': 'https://example.com/avatar.png',
      'bio': 'Hello',
      'isOnline': true,
      'lastSeenAt': now.toIso8601String(),
      'role': 'USER',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };

    test('fromJson parses all fields correctly', () {
      final user = UserModel.fromJson(json);
      expect(user.id, 'user-1');
      expect(user.firebaseUid, 'fb-1');
      expect(user.email, 'test@speakup.app');
      expect(user.fullName, 'Test User');
      expect(user.avatar, 'https://example.com/avatar.png');
      expect(user.bio, 'Hello');
      expect(user.isOnline, true);
      expect(user.lastSeenAt, now);
      expect(user.role, UserRole.user);
      expect(user.createdAt, now);
      expect(user.updatedAt, now);
    });

    test('fromJson handles UPPERCASE role enum', () {
      final user = UserModel.fromJson({...json, 'role': 'ADMIN'});
      expect(user.role, UserRole.admin);
    });

    test('fromJson handles MODERATOR role', () {
      final user = UserModel.fromJson({...json, 'role': 'MODERATOR'});
      expect(user.role, UserRole.moderator);
    });

    test('fromJson uses default values for missing optional fields', () {
      final minimal = {
        'id': 'user-2',
        'email': 'min@test.com',
        'fullName': 'Minimal',
        'createdAt': now.toIso8601String(),
      };
      final user = UserModel.fromJson(minimal);
      expect(user.firebaseUid, '');
      expect(user.avatar, isNull);
      expect(user.bio, isNull);
      expect(user.isOnline, false);
      expect(user.lastSeenAt, isNull);
      expect(user.role, UserRole.user);
    });

    test('toJson round-trip preserves data', () {
      final user = UserModel.fromJson(json);
      final output = user.toJson();
      final restored = UserModel.fromJson(output);
      expect(restored.id, user.id);
      expect(restored.email, user.email);
      expect(restored.fullName, user.fullName);
    });

    test('toCacheJson excludes transient fields', () {
      final user = UserModel.fromJson(json);
      final cache = user.toCacheJson();
      expect(cache.containsKey('isOnline'), false);
      expect(cache.containsKey('lastSeenAt'), false);
      expect(cache['id'], 'user-1');
    });

    test('copyWith creates modified copy', () {
      final user = UserModel.fromJson(json);
      final updated = user.copyWith(fullName: 'New Name', bio: 'Updated bio');
      expect(updated.fullName, 'New Name');
      expect(updated.bio, 'Updated bio');
      expect(updated.id, user.id);
      expect(updated.email, user.email);
    });

    test('copyWith preserves original when no params', () {
      final user = UserModel.fromJson(json);
      final copy = user.copyWith();
      expect(copy.fullName, user.fullName);
      expect(copy.email, user.email);
    });
  });

  group('DeviceModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'device-1',
        'fcmToken': 'token-abc',
        'platform': 'android',
        'createdAt': DateTime(2026, 4, 2).toIso8601String(),
      };
      final device = DeviceModel.fromJson(json);
      expect(device.id, 'device-1');
      expect(device.fcmToken, 'token-abc');
      expect(device.platform, 'android');
    });
  });
}
