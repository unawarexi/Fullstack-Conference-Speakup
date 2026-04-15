import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/analytics_repository.dart';

/// Analytics business logic — dashboard data, usage trends.
class AnalyticsUseCase {
  final AnalyticsRepository _repo;
  AnalyticsUseCase(this._repo);

  Future<Map<String, dynamic>> getDashboard() => _repo.getDashboard();

  Future<Map<String, dynamic>> getUsage({String? startDate, String? endDate}) =>
      _repo.getUsage(startDate: startDate, endDate: endDate);

  Future<Map<String, dynamic>> getMeetingAnalytics(String meetingId) =>
      _repo.getMeetingAnalytics(meetingId);
}

final analyticsUseCaseProvider = Provider<AnalyticsUseCase>((ref) {
  return AnalyticsUseCase(AnalyticsRepository());
});
