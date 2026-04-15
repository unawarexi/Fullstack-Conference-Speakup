import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/analytics_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// Smart Scheduling — AI-recommended meeting times based on habits & availability.
class AISmartSchedulingScreen extends ConsumerWidget {
  const AISmartSchedulingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analyticsAsync = ref.watch(analyticsDashboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Scheduling'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: ListView(
        padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
        children: [
          // Productivity pattern
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: SColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.insights_rounded, color: SColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('Your Productivity Pattern', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                  ],
                ),
                const SizedBox(height: 12),
                _HeatmapRow(label: 'Mon', values: const [0.9, 0.8, 0.6, 0.3, 0.5, 0.7, 0.4], isDark: isDark),
                _HeatmapRow(label: 'Tue', values: const [0.7, 0.9, 0.8, 0.4, 0.6, 0.5, 0.3], isDark: isDark),
                _HeatmapRow(label: 'Wed', values: const [0.8, 0.7, 0.9, 0.5, 0.3, 0.6, 0.4], isDark: isDark),
                _HeatmapRow(label: 'Thu', values: const [0.6, 0.8, 0.7, 0.4, 0.5, 0.8, 0.3], isDark: isDark),
                _HeatmapRow(label: 'Fri', values: const [0.5, 0.6, 0.8, 0.3, 0.4, 0.5, 0.2], isDark: isDark),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['9 AM', '10', '11', '12 PM', '1', '2', '3'].map(
                    (t) => Text(t, style: TextStyle(fontSize: 9, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                  ).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Best times
          Text('Recommended Slots', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
          analyticsAsync.when(
            loading: () => const AILoadingState(message: 'Loading scheduling data...'),
            error: (e, _) => AIErrorState(message: e.toString(), onRetry: () => ref.invalidate(analyticsDashboardProvider)),
            data: (data) {
              final slots = (data['recommendedSlots'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              final conflicts = (data['conflicts'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              final summary = data['weeklySummary'] as Map<String, dynamic>? ?? {};
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (slots.isEmpty)
                    const AIEmptyState(icon: Icons.calendar_today_rounded, message: 'No recommendations yet', subMessage: 'AI needs more data to suggest optimal slots')
                  else
                    ...slots.map((s) => _SlotCard(
                      time: s['time'] as String? ?? '',
                      reason: s['reason'] as String? ?? '',
                      score: s['score'] as int? ?? 0,
                      isDark: isDark,
                    )),
                  const SizedBox(height: 16),
                  Text('Schedule Conflicts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                  const SizedBox(height: 8),
                  if (conflicts.isEmpty)
                    Text('No conflicts detected', style: TextStyle(fontSize: 12, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary))
                  else
                    ...conflicts.map((c) => _ConflictTile(
                      time: c['time'] as String? ?? '',
                      issue: c['issue'] as String? ?? '',
                      isDark: isDark,
                    )),
                  const SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
                    decoration: BoxDecoration(
                      color: SColors.primary.withValues(alpha: isDark ? 0.08 : 0.05),
                      borderRadius: BorderRadius.circular(SSizes.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Weekly Summary', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SColors.primary)),
                        const SizedBox(height: 6),
                        _SummaryRow(label: 'Total meetings this week', value: '${summary['totalMeetings'] ?? 0}', isDark: isDark),
                        _SummaryRow(label: 'Focus time preserved', value: summary['focusTimePreserved'] as String? ?? '0 hrs', isDark: isDark),
                        _SummaryRow(label: 'Avg. meeting duration', value: summary['avgDuration'] as String? ?? '0 min', isDark: isDark),
                        _SummaryRow(label: 'Back-to-back meetings', value: '${summary['backToBack'] ?? 0}', isDark: isDark),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
      ),
    ),
    );
  }
}

class _HeatmapRow extends StatelessWidget {
  final String label;
  final List<double> values;
  final bool isDark;
  const _HeatmapRow({required this.label, required this.values, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text(label, style: TextStyle(fontSize: 10, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary))),
          ...values.map((v) => Expanded(
            child: Container(
              height: 18,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: SColors.primary.withValues(alpha: v * (isDark ? 0.6 : 0.5)),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final String time;
  final String reason;
  final int score;
  final bool isDark;
  const _SlotCard({required this.time, required this.reason, required this.score, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                  const SizedBox(height: 2),
                  Text(reason, style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: SColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(SSizes.radiusFull),
              ),
              child: Text('$score%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: SColors.success)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConflictTile extends StatelessWidget {
  final String time;
  final String issue;
  final bool isDark;
  const _ConflictTile({required this.time, required this.issue, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SColors.error.withValues(alpha: isDark ? 0.08 : 0.05),
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          border: Border.all(color: SColors.error.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, size: 18, color: SColors.error),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                  Text(issue, style: const TextStyle(fontSize: 11, color: SColors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _SummaryRow({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
        ],
      ),
);
  }
}
