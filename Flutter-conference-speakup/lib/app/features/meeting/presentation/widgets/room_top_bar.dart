import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';

class RoomTopBar extends StatelessWidget {
  final String meetingId;
  final Duration elapsed;
  final int participantCount;
  final bool isRecording;
  final String Function(Duration) formatDuration;
  final MeetingAIState aiState;
  final bool isDark;
  final VoidCallback onToggleRecording;
  final VoidCallback onTapParticipants;
  final VoidCallback onTapChat;

  const RoomTopBar({
    super.key,
    required this.meetingId,
    required this.elapsed,
    required this.participantCount,
    required this.isRecording,
    required this.formatDuration,
    required this.aiState,
    required this.isDark,
    required this.onToggleRecording,
    required this.onTapParticipants,
    required this.onTapChat,
  });

  @override
  Widget build(BuildContext context) {
    final chipBg = isDark
        ? Colors.black.withOpacity(0.4)
        : Colors.white.withOpacity(0.65);
    final textPrimary = isDark ? Colors.white : SColors.textLight;
    final textSecondary = isDark
        ? Colors.white.withOpacity(0.7)
        : SColors.textLightSecondary;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + SResponsive.sp(context, SSizes.xs, tabletSize: SSizes.sm),
        left: SResponsive.pagePadding(context),
        right: SResponsive.sp(context, SSizes.sm, tabletSize: SSizes.md),
        bottom: SResponsive.sp(context, SSizes.sm, tabletSize: SSizes.md),
      ),
      child: Row(
        children: [
          // Encrypted badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(SSizes.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    color: SColors.success, size: 12),
                const SizedBox(width: 4),
                Text(
                  meetingId.length > 8
                      ? '${meetingId.substring(0, 8)}…'
                      : meetingId,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: SSizes.sm),

          // Duration
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(SSizes.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isRecording) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: SColors.error,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .fadeIn(duration: 600.ms)
                      .then()
                      .fadeOut(duration: 600.ms),
                  const SizedBox(width: 6),
                ],
                Text(
                  formatDuration(elapsed),
                  style: TextStyle(
                    color: isRecording ? SColors.error : textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // AI active indicators
          if (aiState.isCopilotEnabled)
            const RoomTopBarChip(
              icon: Iconsax.cpu,
              label: 'AI',
              color: SColors.screenShare,
            ),

          if (aiState.isTranscriptionEnabled)
            const RoomTopBarChip(
              icon: Iconsax.subtitle,
              label: 'CC',
              color: SColors.info,
            ),

          // Participants
          RoomTopBarIconButton(
            icon: Iconsax.people,
            badge:
                participantCount > 0 ? '$participantCount' : null,
            iconColor: textPrimary,
            onTap: onTapParticipants,
          ),

          // Chat
          RoomTopBarIconButton(
            icon: Iconsax.message,
            iconColor: textPrimary,
            onTap: onTapChat,
          ),
        ],
      ),
    );
  }
}

class RoomTopBarChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const RoomTopBarChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(SSizes.radiusFull),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class RoomTopBarIconButton extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final Color iconColor;
  final VoidCallback onTap;

  const RoomTopBarIconButton({
    super.key,
    required this.icon,
    this.badge,
    this.iconColor = SColors.textLight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: iconColor, size: 22),
            if (badge != null)
              Positioned(
                right: -6,
                top: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: SColors.primary,
                    borderRadius: BorderRadius.circular(SSizes.radiusFull),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
