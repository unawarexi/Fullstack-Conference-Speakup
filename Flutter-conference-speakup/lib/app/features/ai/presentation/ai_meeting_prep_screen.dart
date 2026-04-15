import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/analytics_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// AI Meeting Prep — auto-generated talking points, attendee research, agenda.
class AIMeetingPrepScreen extends ConsumerWidget {
  const AIMeetingPrepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analyticsAsync = ref.watch(meetingAnalyticsProvider('latest'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Prep'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: ListView(
        padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
        children: [
          // Meeting context
          analyticsAsync.when(
            loading: () => const AILoadingState(message: 'Preparing meeting data...'),
            error: (e, _) => AIErrorState(message: e.toString(), onRetry: () => ref.invalidate(meetingAnalyticsProvider('latest'))),
            data: (data) {
              final prep = data['meetingPrep'] as Map<String, dynamic>? ?? {};
              final meetingTitle = prep['title'] as String? ?? 'Upcoming Meeting';
              final meetingSubtitle = prep['subtitle'] as String? ?? '';
              final talkingPoints = (prep['talkingPoints'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              final attendees = (prep['attendees'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              final unresolved = (prep['unresolved'] as List?)?.cast<String>() ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PrepCard(
                    icon: Icons.event_rounded,
                    title: meetingTitle,
                    subtitle: meetingSubtitle,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle('AI-Generated Talking Points', isDark),
                  const SizedBox(height: 8),
                  if (talkingPoints.isEmpty)
                    const AIEmptyState(icon: Icons.lightbulb_rounded, message: 'No talking points generated yet')
                  else
                    ...talkingPoints.asMap().entries.map((e) => _TalkingPoint(
                      index: e.key + 1,
                      text: e.value['text'] as String? ?? '',
                      isDark: isDark,
                    )),
                  const SizedBox(height: 20),
                  _SectionTitle('Attendee Context', isDark),
                  const SizedBox(height: 8),
                  if (attendees.isEmpty)
                    const AIEmptyState(icon: Icons.people_rounded, message: 'No attendee context available')
                  else
                    ...attendees.map((a) => _AttendeeCard(
                      name: a['name'] as String? ?? '',
                      role: a['role'] as String? ?? '',
                      note: a['note'] as String? ?? '',
                      isDark: isDark,
                    )),
                  const SizedBox(height: 20),
                  _SectionTitle('Unresolved From Last Meeting', isDark),
                  const SizedBox(height: 8),
                  if (unresolved.isEmpty)
                    Text('All items resolved!', style: TextStyle(fontSize: 12, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary))
                  else
                    ...unresolved.map((item) => _UnresolvedItem(item, isDark: isDark)),
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

class _PrepCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  const _PrepCard({required this.icon, required this.title, required this.subtitle, required this.isDark});

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
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionTitle(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight));
  }
}

class _TalkingPoint extends StatelessWidget {
  final int index;
  final String text;
  final bool isDark;
  const _TalkingPoint({required this.index, required this.text, required this.isDark});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(color: SColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: Center(child: Text('$index', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: SColors.primary))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: isDark ? SColors.textDark : SColors.textLight))),
          ],
        ),
      ),
    );
  }
}

class _AttendeeCard extends StatelessWidget {
  final String name;
  final String role;
  final String note;
  final bool isDark;
  const _AttendeeCard({required this.name, required this.role, required this.note, required this.isDark});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 14, backgroundColor: SColors.primary.withValues(alpha: 0.12),
                    child: Text(name[0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: SColors.primary))),
                const SizedBox(width: 8),
                Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                const SizedBox(width: 6),
                Text('· $role', style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
              ],
            ),
            const SizedBox(height: 6),
            Text(note, style: TextStyle(fontSize: 12, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
          ],
        ),
      ),
    );
  }
}

class _UnresolvedItem extends StatelessWidget {
  final String text;
  final bool isDark;
  const _UnresolvedItem(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SColors.warning.withValues(alpha: isDark ? 0.08 : 0.06),
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          border: Border.all(color: SColors.warning.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, size: 16, color: SColors.warning),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: isDark ? SColors.textDark : SColors.textLight))),
          ],
        ),
      ),
);
  }
}
