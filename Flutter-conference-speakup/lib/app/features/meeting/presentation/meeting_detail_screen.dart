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
import 'package:flutter_conference_speakup/store/auth_provider.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';
import 'package:flutter_conference_speakup/store/notification_provider.dart';

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
                    _InfoRow(
                      icon: SIcons.calendar,
                      label: 'Date',
                      value: dateStr,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: SIcons.clock,
                      label: 'Time',
                      value: timeStr,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: SIcons.link,
                      label: 'Meeting Code',
                      value: meeting.code,
                      isDark: isDark,
                      copyable: true,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: SIcons.participants,
                      label: 'Participants',
                      value:
                          '${meeting.participantCount} / ${meeting.maxParticipants}',
                      isDark: isDark,
                    ),
                    if (meeting.hasPassword) ...[
                      const SizedBox(height: 12),
                      _InfoRow(
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
              _ActionGrid(meeting: meeting, isDark: isDark),
              const SizedBox(height: SSizes.lg),

              // Join / Leave Button
              if (meeting.isLive || meeting.status == MeetingStatus.scheduled)
                _JoinButton(meeting: meeting),
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
      builder: (_) => _ShareSheet(meeting: meeting),
    );
  }

  void _showOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final bool copyable;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16,
            color: isDark
                ? SColors.textDarkTertiary
                : SColors.textLightTertiary),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? SColors.textDarkSecondary
                : SColors.textLightSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? SColors.textDark : SColors.textLight,
          ),
        ),
        if (copyable) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              HapticFeedback.lightImpact();
            },
            child: Icon(SIcons.copy, size: 14, color: SColors.primary),
          ),
        ],
      ],
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final MeetingModel meeting;
  final bool isDark;
  const _ActionGrid({required this.meeting, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ActionTile(
          icon: SIcons.chat,
          label: 'Chat',
          onTap: () => context.push('/chat/${meeting.id}?name=${Uri.encodeComponent(meeting.title)}'),
          isDark: isDark,
        ),
        _ActionTile(
          icon: SIcons.record,
          label: 'Recordings',
          onTap: () => context.push('/recordings'),
          isDark: isDark,
        ),
        _ActionTile(
          icon: Icons.note_alt_outlined,
          label: 'Notes',
          onTap: () => context.push('/meeting/${meeting.id}/notes'),
          isDark: isDark,
        ),
        _ActionTile(
          icon: Icons.analytics_outlined,
          label: 'Analytics',
          onTap: () => context.push('/meeting/${meeting.id}/analytics'),
          isDark: isDark,
        ),
        _ActionTile(
          icon: Icons.closed_caption_outlined,
          label: 'Transcript',
          onTap: () => context.push('/meeting/${meeting.id}/transcript'),
          isDark: isDark,
        ),
        _ActionTile(
          icon: Icons.attach_file_rounded,
          label: 'Files',
          onTap: () => context.push('/meeting/${meeting.id}/files'),
          isDark: isDark,
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  const _ActionTile(
      {required this.icon,
      required this.label,
      required this.onTap,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 56) / 3,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
          border: Border.all(
            color: isDark ? SColors.darkBorder : SColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20,
                color: isDark
                    ? SColors.textDarkSecondary
                    : SColors.textLightSecondary),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? SColors.textDarkSecondary
                    : SColors.textLightSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinButton extends ConsumerWidget {
  final MeetingModel meeting;
  const _JoinButton({required this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/meeting/${meeting.id}');
      },
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: SColors.primaryGradient,
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          boxShadow: [
            BoxShadow(
              color: SColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                meeting.isLive ? Icons.videocam_rounded : Icons.login_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                meeting.isLive ? 'Join Now' : 'Join Meeting',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareSheet extends StatelessWidget {
  final MeetingModel meeting;
  const _ShareSheet({required this.meeting});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(SSizes.pagePadding),
      decoration: BoxDecoration(
        color: isDark ? SColors.darkSurface : SColors.lightSurface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SSizes.radiusXl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? SColors.darkBorder : SColors.lightBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: SSizes.lg),
          Text(
            'Share Meeting',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? SColors.textDark : SColors.textLight,
            ),
          ),
          const SizedBox(height: SSizes.md),
          // Meeting code
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? SColors.darkCard : SColors.lightElevated,
              borderRadius: BorderRadius.circular(SSizes.radiusSm),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    meeting.code,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? SColors.textDark : SColors.textLight,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: meeting.code));
                    HapticFeedback.lightImpact();
                  },
                  child: const Icon(SIcons.copy,
                      size: 18, color: SColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: SSizes.md),
          // Share options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareOption(
                icon: Icons.email_outlined,
                label: 'Email',
                onTap: () => Navigator.pop(context),
              ),
              _ShareOption(
                icon: Icons.link,
                label: 'Copy Link',
                onTap: () {
                  Clipboard.setData(ClipboardData(
                      text:
                          'https://speakup.app/meeting/${meeting.id}'));
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              ),
              _ShareOption(
                icon: Icons.message_outlined,
                label: 'Message',
                onTap: () => Navigator.pop(context),
              ),
              _ShareOption(
                icon: Icons.more_horiz,
                label: 'More',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: SSizes.lg),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ShareOption(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? SColors.darkElevated : SColors.lightElevated,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22,
                color: isDark
                    ? SColors.textDarkSecondary
                    : SColors.textLightSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? SColors.textDarkTertiary
                  : SColors.textLightTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
