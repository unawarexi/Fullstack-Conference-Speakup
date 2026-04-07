import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/store/legal_provider.dart';
import 'package:flutter_conference_speakup/app/features/legal/presentation/legal_document_view.dart';

class TermsOfServiceScreen extends ConsumerWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsAsync = ref.watch(termsOfServiceProvider);

    return LegalDocumentView(
      title: 'Terms of Service',
      document: termsAsync,
      onRetry: () => ref.invalidate(termsOfServiceProvider),
    );
  }
}
