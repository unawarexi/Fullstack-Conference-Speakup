import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';
import 'package:flutter_conference_speakup/app/domain/models/ai_models.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';
import 'package:flutter_conference_speakup/core/utils/formatters.dart';

/// AI Meeting Summaries — browse all AI-generated recaps.
class AISummariesScreen extends ConsumerWidget {
  const AISummariesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meetingsAsync = ref.watch(meetingsProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Summaries'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: meetingsAsync.when(
        loading: () => const AILoadingState(message: 'Loading meetings…'),
        error: (err, _) => AIErrorState(
          message: 'Failed to load meetings',
          onRetry: () => ref.invalidate(meetingsProvider(null)),
        ),
        data: (meetings) {
          if (meetings.isEmpty) {
            return const AIEmptyState(
              icon: Icons.summarize_outlined,
              message: 'No meetings yet',
              subMessage: 'Summaries will appear after your meetings end.',
            );
          }
          return RefreshIndicator(
            color: SColors.primary,
            onRefresh: () async => ref.invalidate(meetingsProvider(null)),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
              itemCount: meetings.length,
              itemBuilder: (context, index) {
                final meeting = meetings[index];
                return _MeetingTile(
                  meetingId: meeting.id,
                  title: meeting.title,
                  scheduledAt: meeting.scheduledAt,
                  status: meeting.status.name,
                  participantCount: meeting.participantCount,
                  isDark: isDark,
                );
              },
            ),
          );
        },
      ),
    ),
    );
  }
}

// ─── Meeting list tile that expands into the AI summary ──────────────────────

class _MeetingTile extends ConsumerStatefulWidget {
  final String meetingId;
  final String title;
  final DateTime? scheduledAt;
  final String status;
  final int participantCount;
  final bool isDark;

  const _MeetingTile({
    required this.meetingId,
    required this.title,
    required this.scheduledAt,
    required this.status,
    required this.participantCount,
    required this.isDark,
  });

  @override
  ConsumerState<_MeetingTile> createState() => _MeetingTileState();
}

class _MeetingTileState extends ConsumerState<_MeetingTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final dateStr = widget.scheduledAt != null
        ? SFormatters.formatDateTime(widget.scheduledAt!)
        : 'No date';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AIInsightCard(
        isDark: widget.isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header — tappable
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: widget.isDark ? SColors.textDark : SColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AIMetaBadge(
                        '${widget.participantCount} joined',
                        SColors.primary,
                        isDark: widget.isDark,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: widget.isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Expanded summary section
            if (_expanded) ...[
              const SizedBox(height: 12),
              _SummaryDetail(meetingId: widget.meetingId, isDark: widget.isDark),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

// ─── Summary detail loaded per meeting ───────────────────────────────────────

class _SummaryDetail extends ConsumerWidget {
  final String meetingId;
  final bool isDark;
  const _SummaryDetail({required this.meetingId, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(aiMeetingSummaryProvider(meetingId));

    return summaryAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: AILoadingState(message: 'Generating summary…'),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: AIErrorState(
          message: 'Could not load summary',
          onRetry: () => ref.invalidate(aiMeetingSummaryProvider(meetingId)),
        ),
      ),
      data: (summary) => _SummaryContent(summary: summary, isDark: isDark),
    );
  }
}

class _SummaryContent extends StatelessWidget {
  final MeetingSummary summary;
  final bool isDark;
  const _SummaryContent({required this.summary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Duration + sentiment + counts
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            if (summary.durationMinutes > 0)
              AIMetaBadge('${summary.durationMinutes} min', SColors.primary, isDark: isDark),
            AIMetaBadge('${summary.decisions.length} decisions', SColors.primary, isDark: isDark),
            AIMetaBadge('${summary.actionItems.length} actions', SColors.success, isDark: isDark),
          ],
        ),
        const SizedBox(height: 10),

        // Summary text
        Text(
          summary.summary,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: isDark ? SColors.textDark : SColors.textLight,
          ),
        ),

        // Key topics
        if (summary.keyTopics.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Key Topics',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? SColors.textDark : SColors.textLight,
            ),
          ),
          const SizedBox(height: 6),
          ...summary.keyTopics.map(
            (topic) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: SColors.primary.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      topic,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? SColors.textDark : SColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // Decisions
        if (summary.decisions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Decisions',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? SColors.textDark : SColors.textLight,
            ),
          ),
          const SizedBox(height: 6),
          ...summary.decisions.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, size: 14, color: SColors.success),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? SColors.textDark : SColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // Action items
        if (summary.actionItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Action Items',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? SColors.textDark : SColors.textLight,
            ),
          ),
          const SizedBox(height: 6),
          ...summary.actionItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.radio_button_unchecked, size: 14, color: SColors.warning),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${item.text}${item.assignee != null ? ' → ${item.assignee}' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? SColors.textDark : SColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
