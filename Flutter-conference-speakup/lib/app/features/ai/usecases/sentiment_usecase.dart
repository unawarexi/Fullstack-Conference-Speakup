import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';

/// Manages sentiment analysis logic — filtering, aggregation, and trend detection.
class SentimentUseCase {
  final Ref _ref;
  SentimentUseCase(this._ref);

  /// Fetch full sentiment data for a meeting and compute averages.
  Future<Map<String, dynamic>> getSentimentReport(String meetingId) async {
    final repo = _ref.read(aiRepositoryProvider);
    final data = await repo.getMeetingEmotions(meetingId);
    return data;
  }

  /// Determine the dominant sentiment from a distribution map.
  String dominantSentiment(Map<String, dynamic> distribution) {
    final positive = (distribution['positive'] as num?)?.toDouble() ?? 0;
    final neutral = (distribution['neutral'] as num?)?.toDouble() ?? 0;
    final negative = (distribution['negative'] as num?)?.toDouble() ?? 0;
    if (positive >= neutral && positive >= negative) return 'positive';
    if (negative >= positive && negative >= neutral) return 'negative';
    return 'neutral';
  }
}

final sentimentUseCaseProvider = Provider<SentimentUseCase>((ref) {
  return SentimentUseCase(ref);
});
