import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/sentiment_widgets.dart';

/// AI Sentiment Timeline — sentiment analysis across a meeting with speaker breakdown.
class AISentimentScreen extends ConsumerWidget {
  const AISentimentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emotionsAsync = ref.watch(aiMeetingEmotionsProvider('latest'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentiment Analysis'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: emotionsAsync.when(
        loading: () => const AILoadingState(message: 'Analyzing sentiment…'),
        error: (err, _) => AIErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(aiMeetingEmotionsProvider('latest')),
        ),
        data: (data) {
          final overall =
              data['overall_sentiment'] as Map<String, dynamic>? ?? {};
          final posPercent =
              ((overall['positive'] as num?)?.toDouble() ?? 0) * 100;
          final neuPercent =
              ((overall['neutral'] as num?)?.toDouble() ?? 0) * 100;
          final negPercent =
              ((overall['negative'] as num?)?.toDouble() ?? 0) * 100;
          final shifts = (data['shifts'] as List?)
                  ?.cast<Map<String, dynamic>>() ??
              [];
          final speakers = (data['speakers'] as List?)
                  ?.cast<Map<String, dynamic>>() ??
              [];
          final keywords = (data['keywords'] as List?)
                  ?.cast<Map<String, dynamic>>() ??
              [];

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(aiMeetingEmotionsProvider('latest')),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
              children: [
                // Overall
                Container(
                  padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
                  decoration: BoxDecoration(
                    color: isDark ? SColors.darkCard : SColors.lightCard,
                    borderRadius: BorderRadius.circular(SSizes.radiusMd),
                    border: Border.all(
                        color: isDark
                            ? SColors.darkBorder
                            : SColors.lightBorder,
                        width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Overall Sentiment',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? SColors.textDark
                                  : SColors.textLight)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SentimentCircle(
                              emoji: '😊',
                              label: 'Positive',
                              percent: posPercent.round(),
                              color: SColors.success),
                          SentimentCircle(
                              emoji: '😐',
                              label: 'Neutral',
                              percent: neuPercent.round(),
                              color: SColors.warning),
                          SentimentCircle(
                              emoji: '😟',
                              label: 'Negative',
                              percent: negPercent.round(),
                              color: SColors.error),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Timeline
                Text('Sentiment Timeline',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? SColors.textDark
                            : SColors.textLight)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: CustomPaint(
                      painter: SentimentWavePainter(isDark: isDark)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['0:00', '10:00', '20:00', '30:00', '40:00']
                        .map((t) => Text(t,
                            style: TextStyle(
                                fontSize: 9,
                                color: isDark
                                    ? SColors.textDarkSecondary
                                    : SColors.textLightSecondary)))
                        .toList(),
                  ),
                ),
                if (shifts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Key Sentiment Shifts',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? SColors.textDark
                              : SColors.textLight)),
                  const SizedBox(height: 8),
                  ...shifts.map((s) => SentimentShiftCard(
                        time: s['time'] as String? ?? '',
                        shift: s['shift'] as String? ?? '',
                        trigger: s['trigger'] as String? ?? '',
                        emoji: s['emoji'] as String? ?? '📊',
                        isDark: isDark,
                      )),
                ],
                if (speakers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Per Speaker',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? SColors.textDark
                              : SColors.textLight)),
                  const SizedBox(height: 8),
                  ...speakers.map((sp) => SpeakerSentimentBar(
                        name: sp['name'] as String? ?? '',
                        positive:
                            ((sp['positive'] as num?)?.toDouble() ?? 0) * 100,
                        neutral:
                            ((sp['neutral'] as num?)?.toDouble() ?? 0) * 100,
                        negative:
                            ((sp['negative'] as num?)?.toDouble() ?? 0) * 100,
                        isDark: isDark,
                      )),
                ],
                if (keywords.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Emotion Keywords',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? SColors.textDark
                              : SColors.textLight)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: keywords
                        .map((k) => EmotionChip(
                              word: k['word'] as String? ?? '',
                              sentiment:
                                  k['sentiment'] as String? ?? 'neutral',
                            ))
                        .toList(),
                  ),
                ],
              ]
                  .animate(interval: 50.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.04, end: 0),
            ),
          );
        },
      ),
    ),
    );
  }
}

