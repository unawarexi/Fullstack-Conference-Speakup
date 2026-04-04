import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/app/domain/models/participant_model.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/recording_repository.dart';

final recordingRepositoryProvider = Provider<RecordingRepository>((ref) {
  return RecordingRepository();
});

/// All recordings for current user.
final recordingsProvider =
    FutureProvider.autoDispose<List<RecordingModel>>((ref) {
  return ref.read(recordingRepositoryProvider).getRecordings();
});

/// Single recording by ID.
final recordingByIdProvider =
    FutureProvider.family.autoDispose<RecordingModel, String>((ref, id) {
  return ref.read(recordingRepositoryProvider).getById(id);
});
