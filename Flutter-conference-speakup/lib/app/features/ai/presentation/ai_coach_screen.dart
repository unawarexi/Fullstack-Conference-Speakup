import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// AI Speaking Coach — performance reports, practice sessions, tips.
class AICoachScreen extends ConsumerWidget {
  const AICoachScreen({super.key});

  static IconData _resolveIcon(String? icon) => switch (icon) {
        'speed' => Icons.speed_rounded,
        'timer' => Icons.timer_rounded,
        'emoji_emotions' => Icons.emoji_emotions_rounded,
        'record_voice_over' => Icons.record_voice_over_rounded,
        'visibility' => Icons.visibility_rounded,
        'pause_circle_outline' => Icons.pause_circle_outline_rounded,
        'mic' => Icons.mic_rounded,
        'trending_up' => Icons.trending_up_rounded,
        'psychology' => Icons.psychology_rounded,
        _ => Icons.insights_rounded,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reportAsync = ref.watch(aiCoachingReportProvider('latest'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Speaking Coach'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: reportAsync.when(
        loading: () => const AILoadingState(message: 'Analysing your speaking data…'),
        error: (err, _) => AIErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(aiCoachingReportProvider('latest')),
        ),
        data: (report) {
          final score = report['score'] as int? ?? 0;
          final scoreChange = report['score_change'] as String? ?? '';
          final strengths = (report['strengths'] as List<dynamic>?)
                  ?.cast<Map<String, dynamic>>() ??
              [];
          final improvements = (report['improvements'] as List<dynamic>?)
                  ?.cast<Map<String, dynamic>>() ??
              [];

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
            children: [
              _CoachScoreCard(
                isDark: isDark,
                score: score,
                scoreChange: scoreChange,
              ),
              const SizedBox(height: 16),
              _CoachSection(
                title: 'Strengths',
                isDark: isDark,
                items: strengths,
                color: SColors.success,
                resolveIcon: _resolveIcon,
              ),
              const SizedBox(height: 16),
              _CoachSection(
                title: 'Areas to Improve',
                isDark: isDark,
                items: improvements,
                color: SColors.warning,
                resolveIcon: _resolveIcon,
              ),
              const SizedBox(height: 20),
              _PracticeCTA(),
            ].animate(interval: 60.ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
          );
        },
      ),
    ),
    );
  }
}

// ── Score card ──────────────────────────────────────────────────────────────

class _CoachScoreCard extends StatelessWidget {
  final bool isDark;
  final int score;
  final String scoreChange;
  const _CoachScoreCard({
    required this.isDark,
    required this.score,
    required this.scoreChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1A35), const Color(0xFF0F1A2E)]
              : [const Color(0xFFEEF2FF), const Color(0xFFF0F7FF)],
        ),
        borderRadius: BorderRadius.circular(SSizes.radiusLg),
      ),
      child: Column(
        children: [
          Text('Communication Score',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
          const SizedBox(height: 8),
          Text('$score',
              style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: SColors.primary)),
          const SizedBox(height: 4),
          Text('out of 100 · $scoreChange from last week',
              style: TextStyle(
                  fontSize: 12,
                  color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary)),
        ],
      ),
    );
  }
}

// ── Section (strengths / improvements) ─────────────────────────────────────

class _CoachSection extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<Map<String, dynamic>> items;
  final Color color;
  final IconData Function(String?) resolveIcon;

  const _CoachSection({
    required this.title,
    required this.isDark,
    required this.items,
    required this.color,
    required this.resolveIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? SColors.textDark : SColors.textLight)),
        const SizedBox(height: 10),
        ...items.map((item) {
          final icon = resolveIcon(item['icon'] as String?);
          final itemTitle = item['title'] as String? ?? '';
          final detail = item['detail'] as String? ?? '';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? SColors.darkCard : SColors.lightCard,
                borderRadius: BorderRadius.circular(SSizes.radiusMd),
                border: Border.all(
                  color: isDark ? SColors.darkBorder : SColors.lightBorder,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(itemTitle,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? SColors.textDark : SColors.textLight)),
                        const SizedBox(height: 2),
                        Text(detail,
                            style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? SColors.textDarkSecondary
                                    : SColors.textLightSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Practice CTA ───────────────────────────────────────────────────────────

class _PracticeCTA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
      decoration: BoxDecoration(
        gradient: SColors.accentGradient,
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.mic_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Start Practice Session',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                SizedBox(height: 2),
                Text('AI will coach you in real-time',
                    style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        ],
      ),
    );
  }
}
