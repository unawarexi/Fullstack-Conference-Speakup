import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';

void main() {
  group('MeetingModel', () {
    final now = DateTime(2026, 4, 2);
    final json = {
      'id': 'meeting-1',
      'code': 'ABC-DEF-GHI',
      'title': 'Sprint Planning',
      'description': 'Weekly sprint planning',
      'hostId': 'user-1',
      'host': {'fullName': 'John Doe', 'avatar': 'https://example.com/j.png'},
      'type': 'SCHEDULED',
      'status': 'LIVE',
      'scheduledAt': now.toIso8601String(),
      'startedAt': now.toIso8601String(),
      'endedAt': null,
      'participantCount': 5,
      'maxParticipants': 50,
      'isRecording': true,
      'password': 'secret123',
      'settings': {'muteOnJoin': true, 'allowChat': true},
      'createdAt': now.toIso8601String(),
    };

    test('fromJson parses all fields correctly', () {
      final meeting = MeetingModel.fromJson(json);
      expect(meeting.id, 'meeting-1');
      expect(meeting.code, 'ABC-DEF-GHI');
      expect(meeting.title, 'Sprint Planning');
      expect(meeting.hostId, 'user-1');
      expect(meeting.hostName, 'John Doe');
      expect(meeting.hostAvatar, 'https://example.com/j.png');
      expect(meeting.type, MeetingType.scheduled);
      expect(meeting.status, MeetingStatus.live);
      expect(meeting.isLive, true);
      expect(meeting.hasPassword, true);
      expect(meeting.participantCount, 5);
      expect(meeting.maxParticipants, 50);
      expect(meeting.isRecording, true);
      expect(meeting.scheduledAt, now);
      expect(meeting.startedAt, now);
      expect(meeting.endedAt, isNull);
      expect(meeting.settings?['muteOnJoin'], true);
    });

    test('fromJson parses hostName from nested host object', () {
      final meeting = MeetingModel.fromJson(json);
      expect(meeting.hostName, 'John Doe');
    });

    test('fromJson falls back to hostName when no host object', () {
      final noHost = Map<String, dynamic>.from(json)
        ..remove('host')
        ..['hostName'] = 'Direct Name';
      final meeting = MeetingModel.fromJson(noHost);
      expect(meeting.hostName, 'Direct Name');
    });

    test('fromJson reads _count.participants for participantCount', () {
      final withCount = {
        'id': 'm-2',
        'title': 'Test',
        'hostId': 'u-1',
        '_count': {'participants': 10},
        'createdAt': now.toIso8601String(),
      };
      final meeting = MeetingModel.fromJson(withCount);
      expect(meeting.participantCount, 10);
    });

    test('fromJson handles UPPERCASE enum conversion', () {
      for (final status in ['SCHEDULED', 'LIVE', 'ENDED', 'CANCELLED']) {
        final m = MeetingModel.fromJson({
          ...json,
          'status': status,
        });
        expect(m.status, MeetingStatus.values.byName(status.toLowerCase()));
      }
      for (final type in ['INSTANT', 'SCHEDULED', 'RECURRING']) {
        final m = MeetingModel.fromJson({...json, 'type': type});
        expect(m.type, MeetingType.values.byName(type.toLowerCase()));
      }
    });

    test('toJson round-trip preserves data', () {
      final meeting = MeetingModel.fromJson(json);
      final output = meeting.toJson();
      final restored = MeetingModel.fromJson(output);
      expect(restored.id, meeting.id);
      expect(restored.title, meeting.title);
      expect(restored.status, meeting.status);
    });

    test('isLive returns true only for live status', () {
      final live = MeetingModel.fromJson({...json, 'status': 'LIVE'});
      final ended = MeetingModel.fromJson({...json, 'status': 'ENDED'});
      expect(live.isLive, true);
      expect(ended.isLive, false);
    });

    test('hasPassword returns false for null/empty password', () {
      final noPass = MeetingModel.fromJson({...json, 'password': null});
      expect(noPass.hasPassword, false);
      final emptyPass = MeetingModel.fromJson({...json, 'password': ''});
      expect(emptyPass.hasPassword, false);
    });

    test('copyWith modifies specified fields only', () {
      final meeting = MeetingModel.fromJson(json);
      final updated = meeting.copyWith(
        title: 'New Title',
        status: MeetingStatus.ended,
      );
      expect(updated.title, 'New Title');
      expect(updated.status, MeetingStatus.ended);
      expect(updated.id, meeting.id);
      expect(updated.code, meeting.code);
    });
  });
}
