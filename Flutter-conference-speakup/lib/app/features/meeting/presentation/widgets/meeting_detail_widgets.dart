import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';

// ─────────────────────────────────────────────
//  Info Row
// ─────────────────────────────────────────────
class DetailInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final bool copyable;

  const DetailInfoRow({
    super.key,
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

// ─────────────────────────────────────────────
//  Action Grid
// ─────────────────────────────────────────────
class DetailActionGrid extends StatelessWidget {
  final MeetingModel meeting;
  final bool isDark;
  const DetailActionGrid({super.key, required this.meeting, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        DetailActionTile(
          icon: SIcons.chat,
          label: 'Chat',
          onTap: () => context.push('/chat/${meeting.id}?name=${Uri.encodeComponent(meeting.title)}'),
          isDark: isDark,
        ),
        DetailActionTile(
          icon: SIcons.record,
          label: 'Recordings',
          onTap: () => context.push('/recordings'),
          isDark: isDark,
        ),
        DetailActionTile(
          icon: Icons.note_alt_outlined,
          label: 'Notes',
          onTap: () => context.push('/meeting/${meeting.id}/notes'),
          isDark: isDark,
        ),
        DetailActionTile(
          icon: Icons.analytics_outlined,
          label: 'Analytics',
          onTap: () => context.push('/meeting/${meeting.id}/analytics'),
          isDark: isDark,
        ),
        DetailActionTile(
          icon: Icons.closed_caption_outlined,
          label: 'Transcript',
          onTap: () => context.push('/meeting/${meeting.id}/transcript'),
          isDark: isDark,
        ),
        DetailActionTile(
          icon: Icons.attach_file_rounded,
          label: 'Files',
          onTap: () => context.push('/meeting-detail/${meeting.id}/materials'),
          isDark: isDark,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Action Tile
// ─────────────────────────────────────────────
class DetailActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  const DetailActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

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

// ─────────────────────────────────────────────
//  Join Button
// ─────────────────────────────────────────────
class DetailJoinButton extends ConsumerWidget {
  final MeetingModel meeting;
  const DetailJoinButton({super.key, required this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

// ─────────────────────────────────────────────
//  Share Sheet
// ─────────────────────────────────────────────
class DetailShareSheet extends StatelessWidget {
  final MeetingModel meeting;
  const DetailShareSheet({super.key, required this.meeting});

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
              DetailShareOption(
                icon: Icons.email_outlined,
                label: 'Email',
                onTap: () => Navigator.pop(context),
              ),
              DetailShareOption(
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
              DetailShareOption(
                icon: Icons.message_outlined,
                label: 'Message',
                onTap: () => Navigator.pop(context),
              ),
              DetailShareOption(
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

// ─────────────────────────────────────────────
//  Share Option
// ─────────────────────────────────────────────
class DetailShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const DetailShareOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

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
