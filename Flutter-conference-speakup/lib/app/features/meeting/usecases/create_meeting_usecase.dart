import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/meeting_repository.dart';

/// Parameters for creating a new meeting.
class CreateMeetingParams {
  final String title;
  final String? description;
  final String type;
  final DateTime? scheduledAt;
  final int maxParticipants;
  final String? password;
  final bool autoRecord;
  final bool waitingRoom;
  final bool muteOnJoin;
  final bool cameraOffOnJoin;
  final List<String> inviteEmails;

  const CreateMeetingParams({
    required this.title,
    this.description,
    this.type = 'INSTANT',
    this.scheduledAt,
    this.maxParticipants = 100,
    this.password,
    this.autoRecord = false,
    this.waitingRoom = false,
    this.muteOnJoin = false,
    this.cameraOffOnJoin = false,
    this.inviteEmails = const [],
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null && description!.isNotEmpty)
          'description': description,
        'type': type,
        if (scheduledAt != null) 'scheduledAt': scheduledAt!.toIso8601String(),
        'maxParticipants': maxParticipants,
        if (password != null && password!.isNotEmpty) 'password': password,
        'settings': {
          'autoRecord': autoRecord,
          'waitingRoom': waitingRoom,
          'muteOnJoin': muteOnJoin,
          'cameraOffOnJoin': cameraOffOnJoin,
        },
        if (inviteEmails.isNotEmpty) 'inviteEmails': inviteEmails,
      };
}

/// Create a meeting via the repository.
Future<dynamic> createMeeting(
  MeetingRepository repo,
  CreateMeetingParams params,
) {
  return repo.create(params.toJson());
}

/// Upload a list of attachment files in sequence.
/// Silently skips individual failures so one bad file doesn't block the rest.
Future<void> uploadMeetingAttachments(
  MeetingRepository repo,
  String meetingId,
  List<File> files,
) async {
  for (final file in files) {
    try {
      await repo.uploadMaterial(meetingId, file);
    } catch (e) {
      debugPrint('Failed to upload material: $e');
    }
  }
}
