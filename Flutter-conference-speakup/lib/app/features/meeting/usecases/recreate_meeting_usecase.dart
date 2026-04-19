import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/meeting_repository.dart';

/// Parameters for recreating a past meeting.
class RecreateMeetingParams {
  final String meetingId;
  final String title;
  final String? description;
  final int? durationMinutes;
  final bool copyMaterials;

  const RecreateMeetingParams({
    required this.meetingId,
    required this.title,
    this.description,
    this.durationMinutes,
    this.copyMaterials = true,
  });

  Map<String, dynamic> toOverrides() => {
        'title': title,
        if (description != null && description!.isNotEmpty)
          'description': description,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
        'copyMaterials': copyMaterials,
      };
}

/// Recreate a past meeting via the repository.
/// Returns the newly created [MeetingModel].
Future<MeetingModel> recreateMeeting(
  MeetingRepository repo,
  RecreateMeetingParams params,
) {
  return repo.recreate(params.meetingId, overrides: params.toOverrides());
}
