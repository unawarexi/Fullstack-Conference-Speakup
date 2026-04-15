import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// AI Knowledge Gap Detection — surfaces topics that need clarification.
class AIKnowledgeGapsScreen extends ConsumerWidget {
  const AIKnowledgeGapsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gapsAsync = ref.watch(aiKnowledgeGapsProvider('latest'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Gaps'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: gapsAsync.when(
        loading: () => const AILoadingState(message: 'Detecting knowledge gaps…'),
        error: (err, _) => AIErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(aiKnowledgeGapsProvider('latest')),
        ),
        data: (data) {
          final count = data['count'] as int? ?? 0;
          final gaps =
              (data['gaps'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          if (gaps.isEmpty) {
            return const AIEmptyState(
              icon: Icons.lightbulb_outline_rounded,
              message: 'No knowledge gaps detected',
              subMessage: 'Gaps are surfaced after meeting analysis',
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(aiKnowledgeGapsProvider('latest')),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]),
                    borderRadius: BorderRadius.circular(SSizes.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_rounded,
                          color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$count Knowledge Gap${count == 1 ? '' : 's'} Detected',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            const Text('From your recent meetings',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...gaps.map((g) => _GapCard(
                      topic: g['topic'] as String? ?? '',
                      context: g['context'] as String? ?? '',
                      suggestion: g['suggestion'] as String? ?? '',
                      severity: g['severity'] as String? ?? 'low',
                      isDark: isDark,
                    )),
              ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideY(
                  begin: 0.04, end: 0),
            ),
          );
        },
      ),
    ),
    );
  }
}

class _GapCard extends StatelessWidget {
  final String topic;
  final String context;
  final String suggestion;
  final String severity;
  final bool isDark;
  const _GapCard({required this.topic, required this.context, required this.suggestion, required this.severity, required this.isDark});

  Color get _color {
    switch (severity) {
      case 'high': return SColors.error;
      case 'medium': return SColors.warning;
      default: return SColors.info;
    }
  }

  @override
  Widget build(BuildContext context2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context2), vertical: SSizes.md),
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
                Container(width: 8, height: 8, decoration: BoxDecoration(color: _color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Text(topic, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight))),
              ],
            ),
            const SizedBox(height: 6),
            Text(context, style: TextStyle(fontSize: 12, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SColors.primary.withValues(alpha: isDark ? 0.08 : 0.05),
                borderRadius: BorderRadius.circular(SSizes.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 14, color: SColors.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(suggestion, style: const TextStyle(fontSize: 12, color: SColors.primary))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
