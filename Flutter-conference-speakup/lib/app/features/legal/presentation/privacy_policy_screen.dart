import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/store/legal_provider.dart';
import 'package:flutter_conference_speakup/app/features/legal/presentation/legal_document_view.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacyAsync = ref.watch(privacyPolicyProvider);

    return LegalDocumentView(
      title: 'Privacy Policy',
      document: privacyAsync,
      onRetry: () => ref.invalidate(privacyPolicyProvider),
    );
  }
}
