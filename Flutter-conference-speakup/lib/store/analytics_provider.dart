import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/analytics_repository.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository();
});

/// Dashboard overview data.
final analyticsDashboardProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.read(analyticsRepositoryProvider).getDashboard();
});

/// Usage stats with optional date range.
final analyticsUsageProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>, ({String? startDate, String? endDate})>(
        (ref, params) {
  return ref
      .read(analyticsRepositoryProvider)
      .getUsage(startDate: params.startDate, endDate: params.endDate);
});

/// Per-meeting analytics.
final meetingAnalyticsProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>, String>((ref, meetingId) {
  return ref.read(analyticsRepositoryProvider).getMeetingAnalytics(meetingId);
});
