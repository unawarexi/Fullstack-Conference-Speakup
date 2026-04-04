import 'package:flutter_conference_speakup/core/network/api_client.dart';
import 'package:flutter_conference_speakup/core/apis/endpoints.dart';

class AnalyticsRepository {
  final _api = ApiClient.instance;

  Future<Map<String, dynamic>> getDashboard() async {
    final res = await _api.get(ApiEndpoints.analyticsDashboard);
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getUsage({
    String? startDate,
    String? endDate,
  }) async {
    final res = await _api.get(ApiEndpoints.analyticsUsage, queryParameters: {
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMeetingAnalytics(String meetingId) async {
    final res = await _api.get(ApiEndpoints.meetingAnalytics(meetingId));
    return res.data['data'] as Map<String, dynamic>;
  }
}
