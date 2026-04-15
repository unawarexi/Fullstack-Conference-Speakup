import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/recording_repository.dart';
import 'package:url_launcher/url_launcher.dart';

/// Recordings business logic — list, download, delete.
class RecordingsUseCase {
  final RecordingRepository _repo;
  RecordingsUseCase(this._repo);

  /// Download a recording by opening its URL in the browser.
  Future<bool> downloadRecording(String recordingId) async {
    final url = await _repo.getDownloadUrl(recordingId);
    return launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  /// Delete a recording permanently.
  Future<void> deleteRecording(String recordingId) => _repo.delete(recordingId);
}

final recordingsUseCaseProvider = Provider<RecordingsUseCase>((ref) {
  return RecordingsUseCase(RecordingRepository());
});
