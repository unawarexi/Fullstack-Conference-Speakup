import 'package:flutter_conference_speakup/core/network/api_client.dart';
import 'package:flutter_conference_speakup/core/apis/endpoints.dart';
import 'package:flutter_conference_speakup/app/domain/models/legal_model.dart';

class LegalRepository {
  final _api = ApiClient.instance;

  /// Fetch Terms of Service from backend.
  Future<LegalDocument> getTermsOfService() async {
    final res = await _api.get(ApiEndpoints.legalTerms);
    return LegalDocument.fromJson(
      res.data['data'] as Map<String, dynamic>,
    );
  }

  /// Fetch Privacy Policy from backend.
  Future<LegalDocument> getPrivacyPolicy() async {
    final res = await _api.get(ApiEndpoints.legalPrivacy);
    return LegalDocument.fromJson(
      res.data['data'] as Map<String, dynamic>,
    );
  }
}
