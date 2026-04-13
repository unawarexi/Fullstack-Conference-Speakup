import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/meeting_detail_widgets.dart';

class MeetingDetailScreen extends ConsumerWidget {
  final String meetingId;
  const MeetingDetailScreen({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meetingAsync = ref.watch(meetingByIdProvider(meetingId));

    return Scaffold(
      backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
      body: meetingAsync.when(
        data: (meeting) => _MeetingDetailBody(meeting: meeting),
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (e, _) => Center(
          child: EmptyState(
            icon: SIcons.error,
            message: 'Failed to load meeting',
            actionLabel: 'Retry',
            onAction: () => ref.invalidate(meetingByIdProvider(meetingId)),
          ),
        ),
      ),
    );
  }
}

class _MeetingDetailBody extends StatelessWidget {
  final MeetingModel meeting;
  const _MeetingDetailBody({required this.meeting});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = meeting.scheduledAt != null
        ? DateFormat('EEEE, MMM d, y').format(meeting.scheduledAt!)
        : 'Not scheduled';
    final timeStr = meeting.scheduledAt != null
        ? DateFormat('h:mm a').format(meeting.scheduledAt!)
        : '';

    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          expandedHeight: 140,
          pinned: true,
          backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(SIcons.back,
                color: isDark ? SColors.textDark : SColors.textLight),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(SIcons.share,
                  color: isDark ? SColors.textDark : SColors.textLight,
                  size: 20),
              onPressed: () => _shareMeeting(context),
            ),
            IconButton(
              icon: Icon(SIcons.moreOptions,
                  color: isDark ? SColors.textDark : SColors.textLight,
                  size: 20),
              onPressed: () => _showOptions(context),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          SColors.primary.withValues(alpha: 0.15),
                          SColors.darkBg,
                        ]
                      : [
                          SColors.primary.withValues(alpha: 0.08),
                          SColors.lightBg,
                        ],
                ),
              ),
            ),
          ),
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(SSizes.pagePadding),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Status badge
              Row(
                children: [
                  if (meeting.isLive)
                    StatusBadge.live()
                  else if (meeting.status == MeetingStatus.scheduled)
                    StatusBadge.scheduled()
                  else
                    StatusBadge.ended(),
                  if (meeting.isRecording) ...[
                    const SizedBox(width: 8),
                    StatusBadge.recording(),
                  ],
                  const Spacer(),
                  Text(
                    meeting.type.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? SColors.textDarkTertiary
                          : SColors.textLightTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: SSizes.md),

              // Title
              Text(
                meeting.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? SColors.textDark : SColors.textLight,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 50.ms),

              if (meeting.description != null &&
                  meeting.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  meeting.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? SColors.textDarkSecondary
                        : SColors.textLightSecondary,
                    height: 1.5,
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
              ],
              const SizedBox(height: SSizes.lg),

              // Meeting info cards
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? SColors.darkCard : SColors.lightCard,
                  borderRadius: BorderRadius.circular(SSizes.radiusMd),
                  border: Border.all(
                    color: isDark ? SColors.darkBorder : SColors.lightBorder,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    DetailInfoRow(
                      icon: SIcons.calendar,
                      label: 'Date',
                      value: dateStr,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    DetailInfoRow(
                      icon: SIcons.clock,
                      label: 'Time',
                      value: timeStr,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    DetailInfoRow(
                      icon: SIcons.link,
                      label: 'Meeting Code',
                      value: meeting.code,
                      isDark: isDark,
                      copyable: true,
                    ),
                    const SizedBox(height: 12),
                    DetailInfoRow(
                      icon: SIcons.participants,
                      label: 'Participants',
                      value:
                          '${meeting.participantCount} / ${meeting.maxParticipants}',
                      isDark: isDark,
                    ),
                    if (meeting.hasPassword) ...[
                      const SizedBox(height: 12),
                      DetailInfoRow(
                        icon: SIcons.lock,
                        label: 'Password Protected',
                        value: 'Yes',
                        isDark: isDark,
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
              const SizedBox(height: SSizes.lg),

              // Host
              SectionHeader(title: 'Host'),
              DenseTile(
                leading: SAvatar(
                  name: meeting.hostName ?? 'Host',
                  imageUrl: meeting.hostAvatar,
                  size: 38,
                ),
                title: meeting.hostName ?? 'Unknown',
                subtitle: 'Meeting organizer',
                showChevron: true,
                onTap: () {},
              ),
              const SizedBox(height: SSizes.lg),

              // Quick Actions
              SectionHeader(title: 'Actions'),
              const SizedBox(height: 4),
              DetailActionGrid(meeting: meeting, isDark: isDark),
              const SizedBox(height: SSizes.lg),

              // Join / Leave Button
              if (meeting.isLive || meeting.status == MeetingStatus.scheduled)
                DetailJoinButton(meeting: meeting),
              const SizedBox(height: SSizes.xxl),
            ]),
          ),
        ),
      ],
    );
  }

  void _shareMeeting(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DetailShareSheet(meeting: meeting),
    );
  }

  void _showOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              context.push('/meeting/${meeting.id}/edit');
            },
            child: const Text('Edit Meeting'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              context.push('/meeting/${meeting.id}/participants');
            },
            child: const Text('View Participants'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel Meeting'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ),
    );
  }
}
