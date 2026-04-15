import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// AI Topic Tracker — real-time topic tracking and agenda adherence during meetings.
class AITopicTrackerScreen extends ConsumerWidget {
  const AITopicTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contextAsync = ref.watch(aiMeetingContextProvider('latest'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Topic Tracker'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: contextAsync.when(
        loading: () => const AILoadingState(message: 'Loading topic data…'),
        error: (e, _) => AIErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(aiMeetingContextProvider('latest')),
        ),
        data: (data) {
          final adherence = ((data['adherence'] as num?) ?? 0).toDouble();
          final adherencePercent = (adherence * 100).round();
          final currentTopic = data['current_topic'] as String? ?? '';
          final timeline = (data['timeline'] as List<dynamic>?) ?? [];
          final detours = (data['detours'] as List<dynamic>?) ?? [];
          final suggestions = (data['suggestions'] as List<dynamic>?) ?? [];

          if (timeline.isEmpty && currentTopic.isEmpty) {
            return const AIEmptyState(
              icon: Icons.topic_rounded,
              message: 'No topic data yet',
              subMessage: 'Topics will appear when a meeting is analyzed.',
            );
          }

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
            children: [
              // Agenda adherence
              Container(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Agenda Adherence', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (adherence >= 0.6 ? SColors.success : SColors.warning).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(SSizes.radiusFull),
                          ),
                          child: Text('$adherencePercent%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: adherence >= 0.6 ? SColors.success : SColors.warning)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: adherence.clamp(0.0, 1.0),
                        backgroundColor: isDark ? SColors.darkBorder : SColors.lightBorder,
                        valueColor: AlwaysStoppedAnimation(adherence >= 0.6 ? SColors.success : SColors.warning),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('${timeline.length} agenda items · ${detours.length} off-topic detours detected', style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Current topic
              if (currentTopic.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [SColors.primary.withValues(alpha: 0.15), SColors.primary.withValues(alpha: 0.05)]),
                    borderRadius: BorderRadius.circular(SSizes.radiusMd),
                    border: Border.all(color: SColors.primary.withValues(alpha: 0.3), width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: SColors.primary, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text('NOW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: SColors.primary, letterSpacing: 1)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(currentTopic, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                    ],
                  ),
                ),
              if (currentTopic.isNotEmpty) const SizedBox(height: 16),
              // Topics timeline
              if (timeline.isNotEmpty) ...[
                Text('Topics Timeline', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                const SizedBox(height: 8),
                ...timeline.map((item) {
                  final t = item as Map<String, dynamic>;
                  final topic = t['topic'] as String? ?? '';
                  final time = t['time'] as String? ?? '';
                  final duration = t['duration'] as String? ?? '';
                  final isActive = topic == currentTopic;
                  return _TopicTimelineTile(
                    title: topic,
                    timeSpent: time,
                    planned: duration,
                    status: isActive ? 'active' : 'completed',
                    overTime: false,
                    isDark: isDark,
                  );
                }),
                const SizedBox(height: 16),
              ],
              // Off-topic detours
              if (detours.isNotEmpty) ...[
                Text('Off-Topic Detours', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                const SizedBox(height: 8),
                ...detours.map((item) {
                  final d = item as Map<String, dynamic>;
                  return _DetourCard(
                    topic: d['topic'] as String? ?? '',
                    duration: d['time'] as String? ?? '',
                    trigger: d['trigger'] as String? ?? '',
                    isDark: isDark,
                  );
                }),
                const SizedBox(height: 16),
              ],
              // AI suggestions
              if (suggestions.isNotEmpty)
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
                          Text('AI Suggestions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        suggestions.map((s) => '• $s').join('\n'),
                        style: TextStyle(fontSize: 12, height: 1.5, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
                      ),
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

class _TopicTimelineTile extends StatelessWidget {
  final String title;
  final String timeSpent;
  final String planned;
  final String status;
  final bool overTime;
  final bool isDark;
  const _TopicTimelineTile({required this.title, required this.timeSpent, required this.planned, required this.status, required this.overTime, required this.isDark});

  Color get _statusColor {
    if (status == 'active') return SColors.primary;
    if (status == 'completed') return SColors.success;
    return isDark ? SColors.textDarkSecondary : SColors.textLightSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: status == 'active' ? SColors.primary.withValues(alpha: isDark ? 0.06 : 0.04) : (isDark ? SColors.darkCard : SColors.lightCard),
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
          border: Border.all(color: status == 'active' ? SColors.primary.withValues(alpha: 0.3) : (isDark ? SColors.darkBorder : SColors.lightBorder), width: 0.5),
        ),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                  Text('$timeSpent / $planned${overTime ? ' ⚠️ over' : ''}', style: TextStyle(fontSize: 10, color: overTime ? SColors.warning : (isDark ? SColors.textDarkSecondary : SColors.textLightSecondary))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetourCard extends StatelessWidget {
  final String topic;
  final String duration;
  final String trigger;
  final bool isDark;
  const _DetourCard({required this.topic, required this.duration, required this.trigger, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: SColors.warning.withValues(alpha: isDark ? 0.06 : 0.04),
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
          border: Border.all(color: SColors.warning.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.fork_right_rounded, size: 16, color: SColors.warning),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topic, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? SColors.textDark : SColors.textLight)),
                  if (duration.isNotEmpty || trigger.isNotEmpty)
                    Text('${duration}${trigger.isNotEmpty ? ' · Started by $trigger' : ''}', style: TextStyle(fontSize: 10, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
