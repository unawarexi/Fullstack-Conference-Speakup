import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// Emotion & engagement analytics for meetings — multimodal signals.
class EmotionAnalyticsScreen extends ConsumerWidget {
  final String? meetingId;
  const EmotionAnalyticsScreen({super.key, this.meetingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emotionsAsync = ref.watch(aiMeetingEmotionsProvider(meetingId ?? 'latest'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Analytics'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: emotionsAsync.when(
        data: (data) {
          final overallEngagement = ((data['overall_engagement'] as num?)?.toDouble() ?? 0.0) * 100;
          final engagementChange = data['engagement_change'] as String? ?? '';
          final signals = (data['signals'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          final participants = (data['participants'] as List?)?.cast<Map<String, dynamic>>() ?? [];

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(aiMeetingEmotionsProvider(meetingId ?? 'latest')),
            color: SColors.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
              children: [
                // Overall engagement
                Container(
                  padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
                  decoration: BoxDecoration(
                    gradient: SColors.primaryGradient,
                    borderRadius: BorderRadius.circular(SSizes.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Overall Engagement', style: TextStyle(fontSize: 12, color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text('${overallEngagement.round()}%', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
                        ],
                      ),
                      const Spacer(),
                      if (engagementChange.isNotEmpty)
                        Text(engagementChange, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Signal breakdown
                if (signals.isNotEmpty) ...[
                  Text('Signal Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                  const SizedBox(height: 10),
                  ...signals.map((s) {
                    final label = s['label'] as String? ?? '';
                    final value = (s['value'] as num?)?.toDouble() ?? 0.0;
                    final color = _signalColor(label);
                    return _SignalRow(label, value, color, isDark: isDark);
                  }),
                  const SizedBox(height: 20),
                ],

                // Per-participant
                if (participants.isNotEmpty) ...[
                  Text('Participant Signals', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                  const SizedBox(height: 10),
                  ...participants.map((p) {
                    final name = p['name'] as String? ?? 'Unknown';
                    final signal = p['signal'] as String? ?? 'neutral';
                    final engagement = (p['engagement'] as num?)?.toDouble() ?? 0.5;
                    final emoji = _emotionEmoji(p['emotion'] as String? ?? signal);
                    return _ParticipantCard(name, signal, engagement, emoji, isDark: isDark);
                  }),
                  const SizedBox(height: 20),
                ],

                // Privacy note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SColors.info.withValues(alpha: isDark ? 0.08 : 0.05),
                    borderRadius: BorderRadius.circular(SSizes.radiusMd),
                    border: Border.all(color: SColors.info.withValues(alpha: 0.2), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.privacy_tip_rounded, size: 18, color: SColors.info),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Emotion signals use probabilistic soft labels only. No hard emotion classification or identity inference.',
                          style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
            ),
          );
        },
        loading: () => const AILoadingState(message: 'Analyzing emotions...'),
        error: (e, _) => AIErrorState(
          message: 'Failed to load emotion data',
          onRetry: () => ref.invalidate(aiMeetingEmotionsProvider(meetingId ?? 'latest')),
        ),
      ),
    ),
    );
  }

  Color _signalColor(String label) {
    final l = label.toLowerCase();
    if (l.contains('excite') || l.contains('engage')) return SColors.success;
    if (l.contains('confus') || l.contains('fatigu')) return SColors.warning;
    if (l.contains('frust') || l.contains('anger')) return SColors.error;
    if (l.contains('confid')) return SColors.info;
    return SColors.primary;
  }

  String _emotionEmoji(String emotion) => switch (emotion.toLowerCase()) {
        'happy' || 'joy' => '😊',
        'excited' || 'enthusiastic' => '🤩',
        'confused' || 'uncertain' => '😕',
        'frustrated' || 'angry' => '😤',
        'bored' || 'disengaged' => '😴',
        'surprised' => '😲',
        'focused' || 'attentive' => '🎯',
        _ => '😐',
      };
}

class _SignalRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isDark;
  const _SignalRow(this.label, this.value, this.color, {required this.isDark});

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
              Text(label, style: TextStyle(fontSize: 13, color: isDark ? SColors.textDark : SColors.textLight)),
              Text('${(value * 100).round()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(value: value, backgroundColor: color.withValues(alpha: 0.1), valueColor: AlwaysStoppedAnimation(color), minHeight: 5),
          ),
        ],
      ),
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  final String name;
  final String signal;
  final double engagement;
  final String emoji;
  final bool isDark;
  const _ParticipantCard(this.name, this.signal, this.engagement, this.emoji, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                  const SizedBox(height: 2),
                  Text(signal, style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: SColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(SSizes.radiusFull),
              ),
              child: Text('${(engagement * 100).round()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
