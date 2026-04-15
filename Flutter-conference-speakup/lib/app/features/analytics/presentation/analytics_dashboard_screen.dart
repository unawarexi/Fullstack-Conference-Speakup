import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/store/analytics_provider.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardAsync = ref.watch(analyticsDashboardProvider);

    return Scaffold(
      backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
      appBar: AppBar(
        title: Text('Analytics', style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700,
          color: isDark ? SColors.textDark : SColors.textLight,
        )),
      ),
      body: ResponsiveBody(child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(analyticsDashboardProvider);
          ref.invalidate(meetingsProvider(null));
        },
        color: SColors.primary,
        child: dashboardAsync.when(
          data: (dashboard) {
            final totalMeetings = dashboard['totalMeetings'] ?? 0;
            final totalMinutes = dashboard['totalMinutes'] ?? 0;
            final totalParticipants = dashboard['totalParticipants'] ?? 0;
            final totalRecordings = dashboard['totalRecordings'] ?? 0;
            final meetingChange = dashboard['meetingChange'] as String? ?? '+0%';
            final minuteChange = dashboard['minuteChange'] as String? ?? '+0%';
            final participantChange = dashboard['participantChange'] as String? ?? '+0%';
            final recordingChange = dashboard['recordingChange'] as String? ?? '+0%';
            final recentMeetings =
                (dashboard['recentMeetings'] as List?)?.cast<Map<String, dynamic>>() ?? [];

            final stats = [
              {'label': 'Meetings', 'value': '$totalMeetings', 'icon': Icons.video_call, 'color': SColors.primary, 'change': meetingChange, 'isPositive': !meetingChange.startsWith('-')},
              {'label': 'Minutes', 'value': _formatNumber(totalMinutes), 'icon': Icons.timer, 'color': SColors.success, 'change': minuteChange, 'isPositive': !minuteChange.startsWith('-')},
              {'label': 'Participants', 'value': '$totalParticipants', 'icon': Icons.people, 'color': SColors.info, 'change': participantChange, 'isPositive': !participantChange.startsWith('-')},
              {'label': 'Recordings', 'value': '$totalRecordings', 'icon': Icons.fiber_smart_record, 'color': SColors.error, 'change': recordingChange, 'isPositive': !recordingChange.startsWith('-')},
            ];

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                SectionHeader(title: 'Overview'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: stats.map((s) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: StatCard(
                        label: s['label'] as String,
                        value: s['value'] as String,
                        icon: s['icon'] as IconData,
                        color: s['color'] as Color,
                        change: s['change'] as String?,
                        isPositive: s['isPositive'] as bool,
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 24),
                SectionHeader(title: 'Recent Activity'),
                if (recentMeetings.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('No recent activity',
                        style: TextStyle(color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary))),
                  )
                else
                  ...recentMeetings.take(10).map((m) {
                    final title = m['title'] as String? ?? 'Untitled Meeting';
                    final status = m['status'] as String? ?? 'ended';
                    final date = m['endedAt'] != null
                        ? DateFormat.yMMMd().format(DateTime.parse(m['endedAt'] as String))
                        : m['scheduledAt'] != null
                            ? DateFormat.yMMMd().format(DateTime.parse(m['scheduledAt'] as String))
                            : '';

                    return DenseTile(
                      icon: Icons.event,
                      title: title,
                      subtitle: date,
                      trailing: StatusBadge(
                        label: status[0].toUpperCase() + status.substring(1),
                        color: status == 'active' ? SColors.success : SColors.darkMuted,
                      ),
                      onTap: () {},
                    );
                  }),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load analytics',
                  style: TextStyle(color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(analyticsDashboardProvider),
                child: const Text('Retry'),
              ),
            ],
          )),
        ),
      ),
    ),
);
  }

  String _formatNumber(dynamic n) {
    if (n is int && n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}
