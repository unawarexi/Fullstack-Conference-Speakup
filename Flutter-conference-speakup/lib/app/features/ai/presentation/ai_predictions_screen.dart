import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// AI outcome predictions — success probabilities for upcoming meetings.
class AIPredictionsScreen extends ConsumerWidget {
  const AIPredictionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final predictionsAsync = ref.watch(aiPredictOutcomeProvider('latest'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outcome Predictions'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: predictionsAsync.when(
        loading: () => const AILoadingState(message: 'Analyzing outcomes…'),
        error: (err, _) => AIErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(aiPredictOutcomeProvider('latest')),
        ),
        data: (data) {
          final predictions =
              (data['predictions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          if (predictions.isEmpty) {
            return const AIEmptyState(
              icon: Icons.trending_up_rounded,
              message: 'No predictions yet',
              subMessage: 'Predictions appear after meetings are analyzed',
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(aiPredictOutcomeProvider('latest')),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                final p = predictions[index];
                return _PredictionCard(
                  title: p['title'] as String? ?? '',
                  prediction: ((p['probability'] as num? ?? 0) * 100).round(),
                  detail: p['detail'] as String? ?? '',
                  sentiment: p['sentiment'] as String? ?? 'neutral',
                  isDark: isDark,
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (index * 60).ms)
                    .slideY(begin: 0.05, end: 0);
              },
            ),
          );
        },
      ),
    ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final String title;
  final int prediction;
  final String detail;
  final String sentiment;
  final bool isDark;
  const _PredictionCard({
    required this.title,
    required this.prediction,
    required this.detail,
    required this.sentiment,
    required this.isDark,
  });

  Color get _color {
    if (prediction >= 70) return SColors.success;
    if (prediction >= 50) return SColors.warning;
    return SColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(SSizes.radiusFull)),
                  child: Text('$prediction%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _color)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: prediction / 100, backgroundColor: _color.withValues(alpha: 0.1), valueColor: AlwaysStoppedAnimation(_color), minHeight: 4),
            ),
            const SizedBox(height: 8),
            Text(detail, style: TextStyle(fontSize: 12, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
          ],
        ),
      ),
    );
  }
}
