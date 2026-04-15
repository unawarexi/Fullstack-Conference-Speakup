import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';

/// Manages smart scheduling — fetching recommendations, resolving conflicts.
class SchedulingUseCase {
  final Ref _ref;
  SchedulingUseCase(this._ref);

  /// Fetch optimal time slots from AI backend.
  Future<Map<String, dynamic>> getRecommendations() async {
    return _ref.read(aiRepositoryProvider).executeTool('smart_scheduling', {});
  }

  /// Filter recommended slots by day of week.
  List<Map<String, dynamic>> filterByDay(List<Map<String, dynamic>> slots, String day) {
    return slots.where((s) => (s['day'] as String?) == day).toList();
  }
}

final schedulingUseCaseProvider = Provider<SchedulingUseCase>((ref) {
  return SchedulingUseCase(ref);
});
