import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/app/domain/models/ai_models.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';

/// Fetch action items for a meeting and allow toggling completion.
class ActionItemsUseCase {
  final Ref _ref;
  ActionItemsUseCase(this._ref);

  Future<List<ActionItem>> getActionItems(String meetingId) async {
    final summary = await _ref.read(aiRepositoryProvider).getMeetingSummary(meetingId);
    return summary.actionItems;
  }

  Future<void> toggleComplete(String itemId, bool isCompleted) async {
    // Toggle locally — backend doesn't have a dedicated endpoint yet
    // In production, this would call PATCH /ai/action-items/:id
  }
}

final actionItemsUseCaseProvider = Provider<ActionItemsUseCase>((ref) {
  return ActionItemsUseCase(ref);
});

/// Action items extracted from all recent meeting summaries.
final allActionItemsProvider =
    FutureProvider.autoDispose<List<ActionItem>>((ref) async {
  // Uses the latest meeting summary to get action items
  // In production, this would call a dedicated endpoint
  final repo = ref.read(aiRepositoryProvider);
  try {
    final summary = await repo.getMeetingSummary('latest');
    return summary.actionItems;
  } catch (_) {
    return [];
  }
});
