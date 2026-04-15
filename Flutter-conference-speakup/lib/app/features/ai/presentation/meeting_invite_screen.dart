import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/analytics_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// AI Meeting Invite — intelligent invite management with availability and context.
class MeetingInviteScreen extends ConsumerWidget {
  const MeetingInviteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analyticsAsync = ref.watch(meetingAnalyticsProvider('latest'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Invite'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: ListView(
        padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
        children: [
          // Meeting setup
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
                TextField(
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight),
                  decoration: InputDecoration(
                    hintText: 'Meeting title',
                    hintStyle: TextStyle(color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const Divider(height: 16),
                _FormRow(icon: Icons.calendar_today_rounded, label: 'Tuesday, Dec 10 · 2:00 – 3:00 PM', isDark: isDark),
                const SizedBox(height: 8),
                _FormRow(icon: Icons.repeat_rounded, label: 'Does not repeat', isDark: isDark),
                const SizedBox(height: 8),
                _FormRow(icon: Icons.videocam_rounded, label: 'SpeakUp Video Call', isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // AI time suggestion
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SColors.primary.withValues(alpha: isDark ? 0.08 : 0.05),
              borderRadius: BorderRadius.circular(SSizes.radiusSm),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 16, color: SColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('AI suggests: Wednesday 10 AM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SColors.primary)),
                      Text('All 4 invitees are free and it\'s during peak productivity hours', style: TextStyle(fontSize: 10, color: SColors.primary)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                  child: const Text('Apply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Participants
          Text('Participants', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
          analyticsAsync.when(
            loading: () => const AILoadingState(message: 'Loading participants...'),
            error: (e, _) => AIErrorState(message: e.toString(), onRetry: () => ref.invalidate(meetingAnalyticsProvider('latest'))),
            data: (data) {
              final participants = (data['participants'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              return Column(
                children: participants.isEmpty
                    ? [const AIEmptyState(icon: Icons.people_rounded, message: 'No participants added')]
                    : participants.map((p) => _ParticipantTile(
                        name: p['name'] as String? ?? '',
                        email: p['email'] as String? ?? '',
                        status: p['status'] as String? ?? 'available',
                        isDark: isDark,
                      )).toList(),
              );
            },
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? SColors.darkCard : SColors.lightCard,
              borderRadius: BorderRadius.circular(SSizes.radiusSm),
              border: Border(left: BorderSide(color: SColors.primary, width: 2)),
            ),
            child: Row(
              children: [
                Icon(Icons.person_add_rounded, size: 16, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
                const SizedBox(width: 8),
                Text('Add participants...', style: TextStyle(fontSize: 12, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // AI agenda
          Text('AI-Generated Agenda', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
          _AgendaItem(time: '5 min', title: 'Check-in & context setting', isDark: isDark),
          _AgendaItem(time: '20 min', title: 'Review Q4 deliverables status', isDark: isDark),
          _AgendaItem(time: '15 min', title: 'Discuss blockers from last sprint', isDark: isDark),
          _AgendaItem(time: '10 min', title: 'Action items & next steps', isDark: isDark),
          _AgendaItem(time: '5 min', title: 'Open Q&A', isDark: isDark),
          const SizedBox(height: 16),
          // Notes
          Container(
            padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
            decoration: BoxDecoration(
              color: isDark ? SColors.darkCard : SColors.lightCard,
              borderRadius: BorderRadius.circular(SSizes.radiusMd),
              border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
            ),
            child: TextField(
              maxLines: 3,
              style: TextStyle(fontSize: 13, color: isDark ? SColors.textDark : SColors.textLight),
              decoration: InputDecoration(
                hintText: 'Add a note for attendees...',
                hintStyle: TextStyle(color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: SColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SSizes.radiusMd)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Send Invites', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ].animate(interval: 40.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
      ),
    ),
    );
  }
}

class _FormRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _FormRow({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 13, color: isDark ? SColors.textDark : SColors.textLight)),
      ],
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final String name;
  final String email;
  final String status;
  final bool isDark;
  const _ParticipantTile({required this.name, required this.email, required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final available = status == 'available';
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
            CircleAvatar(
              radius: 16,
              backgroundColor: SColors.primary.withValues(alpha: 0.1),
              child: Text(name[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: SColors.primary)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                  Text(email, style: TextStyle(fontSize: 10, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: available ? SColors.success : SColors.error),
            ),
            const SizedBox(width: 6),
            Text(available ? 'Free' : 'Busy', style: TextStyle(fontSize: 10, color: available ? SColors.success : SColors.error)),
          ],
        ),
      ),
    );
  }
}

class _AgendaItem extends StatelessWidget {
  final String time;
  final String title;
  final bool isDark;
  const _AgendaItem({required this.time, required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(width: 4, height: 4, decoration: const BoxDecoration(color: SColors.primary, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: SColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(time, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: SColors.primary)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: TextStyle(fontSize: 12, color: isDark ? SColors.textDark : SColors.textLight))),
        ],
      ),
);
  }
}
