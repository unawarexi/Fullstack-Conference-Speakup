import 'package:flutter_test/flutter_test.dart';
import 'package:video_confrence_app/app/domain/models/participant_model.dart';

void main() {
  final now = DateTime(2026, 4, 2);

  group('Participant', () {
    final json = {
      'id': 'p-1',
      'meetingId': 'meeting-1',
      'userId': 'user-1',
      'user': {'fullName': 'Alice', 'avatar': 'https://example.com/a.png'},
      'isMuted': true,
      'isCameraOff': false,
      'isScreenSharing': false,
      'isHandRaised': true,
      'role': 'HOST',
      'joinedAt': now.toIso8601String(),
      'leftAt': null,
    };

    test('fromJson parses all fields', () {
      final p = Participant.fromJson(json);
      expect(p.id, 'p-1');
      expect(p.meetingId, 'meeting-1');
      expect(p.userId, 'user-1');
      expect(p.name, 'Alice');
      expect(p.avatar, 'https://example.com/a.png');
      expect(p.isMuted, true);
      expect(p.isCameraOff, false);
      expect(p.isHandRaised, true);
      expect(p.role, ParticipantRole.host);
      expect(p.leftAt, isNull);
    });

    test('fromJson handles UPPERCASE role enums', () {
      for (final role in ['HOST', 'CO_HOST', 'ATTENDEE']) {
        // Verify the actual enum names
        if (role == 'HOST') {
          final p = Participant.fromJson({...json, 'role': role});
          expect(p.role, ParticipantRole.host);
        }
        if (role == 'ATTENDEE') {
          final p = Participant.fromJson({...json, 'role': role});
          expect(p.role, ParticipantRole.attendee);
        }
      }
    });

    test('fromJson falls back to name when no user object', () {
      final noUser = Map<String, dynamic>.from(json)
        ..remove('user')
        ..['name'] = 'Direct Name';
      final p = Participant.fromJson(noUser);
      expect(p.name, 'Direct Name');
    });

    test('copyWith modifies fields correctly', () {
      final p = Participant.fromJson(json);
      final updated = p.copyWith(isMuted: false, isHandRaised: false);
      expect(updated.isMuted, false);
      expect(updated.isHandRaised, false);
      expect(updated.id, p.id);
      expect(updated.name, p.name);
    });

    test('toJson round-trip', () {
      final p = Participant.fromJson(json);
      final output = p.toJson();
      final restored = Participant.fromJson(output);
      expect(restored.id, p.id);
      expect(restored.role, p.role);
    });
  });

  group('RecordingModel', () {
    final json = {
      'id': 'rec-1',
      'meetingId': 'meeting-1',
      'userId': 'user-1',
      'meeting': {'title': 'Sprint Planning'},
      'url': 'https://example.com/rec.mp4',
      'duration': 3600,
      'sizeBytes': 52428800,
      'status': 'READY',
      'createdAt': now.toIso8601String(),
    };

    test('fromJson parses all fields', () {
      final rec = RecordingModel.fromJson(json);
      expect(rec.id, 'rec-1');
      expect(rec.meetingId, 'meeting-1');
      expect(rec.meetingTitle, 'Sprint Planning');
      expect(rec.duration, 3600);
      expect(rec.sizeBytes, 52428800);
      expect(rec.status, RecordingStatus.ready);
    });

    test('formattedSize returns MB for large files', () {
      final rec = RecordingModel.fromJson(json);
      expect(rec.formattedSize, '50.0 MB');
    });

    test('formattedSize returns KB for small files', () {
      final small = RecordingModel.fromJson({...json, 'sizeBytes': 512000});
      expect(small.formattedSize, '500.0 KB');
    });

    test('formattedDuration returns hours for long recordings', () {
      final rec = RecordingModel.fromJson(json); // 3600s = 1h
      expect(rec.formattedDuration, '1h 0m');
    });

    test('formattedDuration returns minutes for short recordings', () {
      final short = RecordingModel.fromJson({...json, 'duration': 150});
      expect(short.formattedDuration, '2m 30s');
    });

    test('formattedDuration returns seconds for very short recordings', () {
      final tiny = RecordingModel.fromJson({...json, 'duration': 45});
      expect(tiny.formattedDuration, '45s');
    });

    test('fromJson handles PROCESSING status', () {
      final pending =
          RecordingModel.fromJson({...json, 'status': 'PROCESSING'});
      expect(pending.status, RecordingStatus.processing);
    });

    test('fromJson handles FAILED status', () {
      final failed = RecordingModel.fromJson({...json, 'status': 'FAILED'});
      expect(failed.status, RecordingStatus.failed);
    });
  });
}
