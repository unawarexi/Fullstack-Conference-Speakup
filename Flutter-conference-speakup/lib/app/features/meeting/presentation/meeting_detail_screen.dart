import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_conference_speakup/core/utils/formatters.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
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
      body: ResponsiveBody(child: meetingAsync.when(
        data: (meeting) => _MeetingDetailBody(meeting: meeting, meetingId: meetingId),
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
    ),
    );
  }
}

class _MeetingDetailBody extends ConsumerWidget {
  final MeetingModel meeting;
  final String meetingId;
  const _MeetingDetailBody({required this.meeting, required this.meetingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = meeting.scheduledAt != null
        ? SFormatters.formatDateFull(meeting.scheduledAt!)
        : 'Not scheduled';
    String timeStr;
    if (meeting.scheduledAt != null && meeting.scheduledEndAt != null) {
      timeStr = '${SFormatters.formatTime(meeting.scheduledAt!)} – '
          '${SFormatters.formatTime(meeting.scheduledEndAt!)}';
    } else if (meeting.scheduledAt != null) {
      timeStr = SFormatters.formatTime(meeting.scheduledAt!);
    } else {
      timeStr = '';
    }

    return CustomScrollView(
      slivers: [
        // Plain app bar — no gradient
        SliverAppBar(
          pinned: true,
          backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(SIcons.back,
                color: isDark ? SColors.textDark : SColors.textLight),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Meeting Details',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isDark ? SColors.textDark : SColors.textLight,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  color: SColors.primary, size: 20),
              onPressed: () => context.push('/meeting-detail/$meetingId/edit'),
            ),
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
              onPressed: () => _showOptions(context, ref),
            ),
          ],
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

              // Meeting info card
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

              // Settings toggles (read-only display)
              if (meeting.settings != null && meeting.settings!.isNotEmpty) ...[
                SectionHeader(title: 'Settings'),
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
                      if (meeting.settings!['waitingRoom'] == true)
                        DetailInfoRow(icon: Icons.hourglass_top_rounded, label: 'Waiting Room', value: 'Enabled', isDark: isDark),
                      if (meeting.settings!['muteOnJoin'] == true) ...[
                        if (meeting.settings!['waitingRoom'] == true) const SizedBox(height: 12),
                        DetailInfoRow(icon: Icons.mic_off_rounded, label: 'Mute on Join', value: 'Enabled', isDark: isDark),
                      ],
                      if (meeting.settings!['autoRecord'] == true) ...[
                        const SizedBox(height: 12),
                        DetailInfoRow(icon: SIcons.record, label: 'Auto Record', value: 'Enabled', isDark: isDark),
                      ],
                      if (meeting.settings!['cameraOffOnJoin'] == true) ...[
                        const SizedBox(height: 12),
                        DetailInfoRow(icon: Icons.videocam_off_rounded, label: 'Camera Off on Join', value: 'Enabled', isDark: isDark),
                      ],
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                const SizedBox(height: SSizes.lg),
              ],

              // Materials
              _MaterialsPreview(meetingId: meetingId, isDark: isDark),

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

              // Quick Actions — functional cards
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
        builder: (_) => DetailShareSheet(meeting: meeting));
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup(
        context: context,
        builder: (_) => CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/meeting-detail/$meetingId/edit');
                    },
                    child: const Text('Edit Meeting')),
                CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/meeting/${meeting.id}/participants');
                    },
                    child: const Text('View Participants')),
                CupertinoActionSheetAction(
                    isDestructiveAction: true,
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(context, ref);
                    },
                    child: const Text('Cancel Meeting')),
              ],
              cancelButton: CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close')),
            ));
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Cancel Meeting?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(meetingRepositoryProvider).delete(meeting.id);
                ref.invalidate(meetingsProvider(null));
                if (context.mounted) context.pop();
              } catch (_) {}
            },
            child: const Text('Cancel Meeting'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Materials Preview (inline in detail screen)
// ─────────────────────────────────────────────
class _MaterialsPreview extends ConsumerWidget {
  final String meetingId;
  final bool isDark;
  const _MaterialsPreview({required this.meetingId, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(meetingMaterialsProvider(meetingId));

    return materialsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (materials) {
        if (materials.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Materials',
                actionLabel: 'Upload',
                actionIcon: Icons.upload_file_rounded,
                onAction: () => context.push('/meeting-detail/$meetingId/materials'),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                    Icon(Icons.folder_open_rounded, size: 28,
                        color: isDark ? SColors.darkMuted : SColors.lightMuted),
                    const SizedBox(height: 8),
                    Text(
                      'No materials attached',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 250.ms),
              const SizedBox(height: SSizes.lg),
            ],
          );
        }

        final preview = materials.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Materials (${materials.length})',
              actionLabel: 'View All',
              onAction: () => context.push('/meeting-detail/$meetingId/materials'),
            ),
            ...preview.map((m) => _MaterialTile(material: m, isDark: isDark)),
            if (materials.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onTap: () => context.push('/meeting-detail/$meetingId/materials'),
                  child: Text(
                    '+${materials.length - 3} more files',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: SColors.primary,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: SSizes.lg),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 250.ms);
      },
    );
  }
}

class _MaterialTile extends StatelessWidget {
  final dynamic material;
  final bool isDark;
  const _MaterialTile({required this.material, required this.isDark});

  IconData _iconForType(String type) {
    if (type.startsWith('image/')) return Icons.image_rounded;
    if (type.startsWith('video/')) return Icons.videocam_rounded;
    if (type.startsWith('audio/')) return Icons.audiotrack_rounded;
    if (type.contains('pdf')) return Icons.picture_as_pdf_rounded;
    if (type.contains('sheet') || type.contains('csv')) return Icons.table_chart_rounded;
    if (type.contains('presentation') || type.contains('ppt')) return Icons.slideshow_rounded;
    if (type.contains('word') || type.contains('doc')) return Icons.description_rounded;
    return Icons.insert_drive_file_rounded;
  }

  Color _colorForType(String type) {
    if (type.startsWith('image/')) return const Color(0xFF8B5CF6);
    if (type.startsWith('video/')) return const Color(0xFFEC4899);
    if (type.startsWith('audio/')) return const Color(0xFFF59E0B);
    if (type.contains('pdf')) return const Color(0xFFEF4444);
    if (type.contains('sheet') || type.contains('csv')) return const Color(0xFF10B981);
    return SColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.tryParse(material.url);
          if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? SColors.darkCard : SColors.lightCard,
            borderRadius: BorderRadius.circular(SSizes.radiusSm),
            border: Border.all(
              color: isDark ? SColors.darkBorder : SColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _colorForType(material.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_iconForType(material.type),
                    color: _colorForType(material.type), size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? SColors.textDark : SColors.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${material.readableSize} · ${SFormatters.formatSmartTime(material.createdAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new_rounded, size: 14,
                  color: isDark ? SColors.darkMuted : SColors.lightMuted),
            ],
          ),
        ),
      ),
    );
  }
}
