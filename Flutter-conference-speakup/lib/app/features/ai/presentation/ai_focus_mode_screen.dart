import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/analytics_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// AI Focus Mode — distraction-free meeting view with smart notifications.
class AIFocusModeScreen extends ConsumerWidget {
  const AIFocusModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analyticsAsync = ref.watch(analyticsDashboardProvider);
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050508) : SColors.lightBg,
      appBar: AppBar(
        title: const Text('Focus Mode'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: ListView(
            padding: EdgeInsets.all(SResponsive.pagePadding(context)),
        children: [
          // Focus session card
          Container(
            padding: const EdgeInsets.all(SSizes.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(SSizes.radiusMd),
            ),
            child: Column(
              children: const [
                Icon(Icons.self_improvement_rounded, color: Color(0xFF818CF8), size: 36),
                SizedBox(height: 8),
                Text('Deep Focus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                SizedBox(height: 4),
                Text('2h 15m of uninterrupted work time', style: TextStyle(fontSize: 12, color: Colors.white54)),
                SizedBox(height: 12),
                Text('Next meeting in 45 min', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF818CF8))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Smart silenced
          Text('AI Silenced Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 4),
          Text('Non-urgent items held until focus ends', style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
          const SizedBox(height: 10),
          _SilencedTile(title: '3 chat messages', from: '#engineering, #design', urgency: 'low', isDark: isDark),
          _SilencedTile(title: '1 meeting reschedule', from: 'Emma Wilson', urgency: 'low', isDark: isDark),
          _SilencedTile(title: '2 PR reviews requested', from: 'GitHub', urgency: 'medium', isDark: isDark),
          const SizedBox(height: 16),
          // Would break through
          Text('Would Break Through', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 4),
          Text('These bypass focus mode automatically', style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
          const SizedBox(height: 10),
          _BreakthroughTile(title: 'Production incident alerts', icon: Icons.warning_amber_rounded, isDark: isDark),
          _BreakthroughTile(title: 'Direct mentions from your manager', icon: Icons.person_rounded, isDark: isDark),
          _BreakthroughTile(title: 'Meeting starting in 5 minutes', icon: Icons.timer_rounded, isDark: isDark),
          const SizedBox(height: 16),
          // Today's focus stats
          Text('Today\'s Focus', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
          analyticsAsync.when(
            loading: () => const AILoadingState(message: 'Loading focus data...'),
            error: (e, _) => AIErrorState(message: e.toString(), onRetry: () => ref.invalidate(analyticsDashboardProvider)),
            data: (data) {
              final focusStats = data['focusStats'] as Map<String, dynamic>? ?? {};
              final schedule = (data['focusSchedule'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
                    decoration: BoxDecoration(
                      color: isDark ? SColors.darkCard : SColors.lightCard,
                      borderRadius: BorderRadius.circular(SSizes.radiusMd),
                      border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
                    ),
                    child: Column(
                      children: [
                        _FocusStatRow(label: 'Deep work sessions', value: '${focusStats['deepWorkSessions'] ?? 0}', isDark: isDark),
                        _FocusStatRow(label: 'Total focus time', value: focusStats['totalFocusTime'] as String? ?? '0h', isDark: isDark),
                        _FocusStatRow(label: 'Notifications deferred', value: '${focusStats['notificationsDeferred'] ?? 0}', isDark: isDark),
                        _FocusStatRow(label: 'Focus score', value: '${focusStats['focusScore'] ?? 0}/100', isDark: isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('AI-Optimized Schedule', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                  const SizedBox(height: 8),
                  if (schedule.isEmpty)
                    const AIEmptyState(icon: Icons.calendar_today_rounded, message: 'No schedule data', subMessage: 'AI will optimize your schedule as you use the app')
                  else
                    ...schedule.map((s) => _ScheduleBlock(
                      time: s['time'] as String? ?? '',
                      title: s['title'] as String? ?? '',
                      type: s['type'] as String? ?? 'focus',
                      isDark: isDark,
                    )),
                ],
              );
            },
          ),
        ].animate(interval: 40.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
        ),
      ),
    );
  }
}

class _SilencedTile extends StatelessWidget {
  final String title;
  final String from;
  final String urgency;
  final bool isDark;
  const _SilencedTile({required this.title, required this.from, required this.urgency, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
          border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.notifications_off_rounded, size: 16, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? SColors.textDark : SColors.textLight)),
                  Text(from, style: TextStyle(fontSize: 10, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (urgency == 'medium' ? SColors.warning : SColors.info).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(urgency, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: urgency == 'medium' ? SColors.warning : SColors.info)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakthroughTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  const _BreakthroughTile({required this.title, required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: SColors.error.withValues(alpha: isDark ? 0.06 : 0.04),
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
          border: Border.all(color: SColors.error.withValues(alpha: 0.15), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: SColors.error),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: TextStyle(fontSize: 12, color: isDark ? SColors.textDark : SColors.textLight))),
          ],
        ),
      ),
    );
  }
}

class _FocusStatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _FocusStatRow({required this.label, required this.value, required this.isDark});

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

class _ScheduleBlock extends StatelessWidget {
  final String time;
  final String title;
  final String type;
  final bool isDark;
  const _ScheduleBlock({required this.time, required this.title, required this.type, required this.isDark});

  Color get _color {
    switch (type) {
      case 'focus': return const Color(0xFF818CF8);
      case 'meeting': return SColors.primary;
      default: return isDark ? SColors.textDarkSecondary : SColors.textLightSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: SResponsive.sp(context, 80, tabletSize: 100), child: Text(time, style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary))),
          Container(width: 3, height: 20, decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? SColors.textDark : SColors.textLight))),
        ],
      ),
    );
  }
}
