import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';

/// Use case for AI coaching — fetches coaching reports.
class CoachingUseCase {
  final Ref _ref;
  CoachingUseCase(this._ref);

  Future<Map<String, dynamic>> getReport(String meetingId) {
    return _ref.read(aiRepositoryProvider).getCoachingReport(meetingId);
  }
}

final coachingUseCaseProvider = Provider<CoachingUseCase>((ref) {
  return CoachingUseCase(ref);
});
