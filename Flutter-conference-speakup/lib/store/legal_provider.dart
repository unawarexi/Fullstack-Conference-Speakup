import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/app/domain/models/legal_model.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/legal_repository.dart';

/// Legal repository singleton.
final legalRepositoryProvider = Provider<LegalRepository>((ref) {
  return LegalRepository();
});

/// Terms of Service — fetched once and cached.
final termsOfServiceProvider = FutureProvider<LegalDocument>((ref) {
  return ref.read(legalRepositoryProvider).getTermsOfService();
});

/// Privacy Policy — fetched once and cached.
final privacyPolicyProvider = FutureProvider<LegalDocument>((ref) {
  return ref.read(legalRepositoryProvider).getPrivacyPolicy();
});
