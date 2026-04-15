import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// AI Speaking Time — per-participant speaking time analysis with balance score.
class AISpeakingTimeScreen extends ConsumerWidget {
  const AISpeakingTimeScreen({super.key});

  static const _speakerColors = [
    SColors.primary,
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emotionsAsync = ref.watch(aiMeetingEmotionsProvider('latest'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speaking Time'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: emotionsAsync.when(
        loading: () => const AILoadingState(message: 'Analyzing speaking time…'),
        error: (e, _) => AIErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(aiMeetingEmotionsProvider('latest')),
        ),
        data: (data) {
          final speakingTime = data['speaking_time'] as Map<String, dynamic>? ?? {};
          final balanceScore = ((speakingTime['balance_score'] as num?) ?? 0).toDouble();
          final balancePercent = (balanceScore * 100).round();
          final speakers = (speakingTime['speakers'] as List<dynamic>?) ?? [];
          final observations = (speakingTime['observations'] as List<dynamic>?) ?? [];

          if (speakers.isEmpty) {
            return const AIEmptyState(
              icon: Icons.mic_none_rounded,
              message: 'No speaking data yet',
              subMessage: 'Data will appear after your first analyzed meeting.',
            );
          }

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
            children: [
              // Balance score
              Container(
                padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
                decoration: BoxDecoration(
                  color: isDark ? SColors.darkCard : SColors.lightCard,
                  borderRadius: BorderRadius.circular(SSizes.radiusMd),
                  border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
                ),
                child: Column(
                  children: [
                    Text('Participation Balance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: balanceScore.clamp(0.0, 1.0),
                            strokeWidth: 8,
                            backgroundColor: isDark ? SColors.darkBorder : SColors.lightBorder,
                            valueColor: AlwaysStoppedAnimation(
                              balanceScore >= 0.6 ? SColors.success : (balanceScore >= 0.4 ? SColors.warning : SColors.error),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text('$balancePercent%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: isDark ? SColors.textDark : SColors.textLight)),
                            Text(
                              balanceScore >= 0.6 ? 'Balanced' : (balanceScore >= 0.4 ? 'Moderate' : 'Imbalanced'),
                              style: TextStyle(fontSize: 10, color: balanceScore >= 0.6 ? SColors.success : (balanceScore >= 0.4 ? SColors.warning : SColors.error)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Per speaker
              Text('Speaker Breakdown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
              const SizedBox(height: 8),
              ...speakers.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value as Map<String, dynamic>;
                final name = s['name'] as String? ?? 'Unknown';
                final pct = ((s['percentage'] as num?) ?? 0).toDouble();
                final dur = (s['duration_minutes'] as num?) ?? 0;
                final interruptions = (s['interruptions'] as num?) ?? 0;
                final percent = (pct * 100).round();
                final color = _speakerColors[i % _speakerColors.length];
                return _SpeakerBar(
                  name: name,
                  percent: percent,
                  time: '${dur}m · ${interruptions} int.',
                  color: color,
                  isDark: isDark,
                );
              }),
              const SizedBox(height: 16),
              // AI observations
              if (observations.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
                  decoration: BoxDecoration(
                    color: SColors.primary.withValues(alpha: isDark ? 0.08 : 0.05),
                    borderRadius: BorderRadius.circular(SSizes.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 16, color: SColors.primary),
                          SizedBox(width: 8),
                          Text('AI Observations', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...observations.map((o) => _TipRow(tip: o.toString())),
                    ],
                  ),
                ),
            ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
          );
        },
      ),
    ),
    );
  }
}

class _SpeakerBar extends StatelessWidget {
  final String name;
  final int percent;
  final String time;
  final Color color;
  final bool isDark;
  const _SpeakerBar({required this.name, required this.percent, required this.time, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
              Text('$percent% · $time', style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: isDark ? SColors.darkBorder : SColors.lightBorder,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String tip;
  const _TipRow({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 12, color: SColors.primary)),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 12, color: SColors.primary, height: 1.4))),
        ],
      ),
    );
  }
}
