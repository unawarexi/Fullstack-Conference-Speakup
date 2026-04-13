import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';

class RoomMoreOptionsOverlay extends StatelessWidget {
  final MeetingRoomState meetingState;
  final MeetingAIState aiState;
  final VoidCallback onClose;
  final VoidCallback onToggleTranscription;
  final VoidCallback onToggleCoaching;
  final VoidCallback onToggleCopilot;
  final VoidCallback onToggleRecording;
  final VoidCallback onFlipCamera;
  final VoidCallback onShareMeetingLink;
  final VoidCallback? onEndMeeting;
  final bool isHost;
  final bool isDark;

  const RoomMoreOptionsOverlay({
    super.key,
    required this.meetingState,
    required this.aiState,
    required this.onClose,
    required this.onToggleTranscription,
    required this.onToggleCoaching,
    required this.onToggleCopilot,
    required this.onToggleRecording,
    required this.onFlipCamera,
    required this.onShareMeetingLink,
    this.onEndMeeting,
    this.isHost = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark ? SColors.darkSurface : SColors.lightSurface;
    final borderColor = isDark ? SColors.darkBorder : SColors.lightBorder;
    final textTertiary = isDark ? SColors.textDarkTertiary : SColors.textLightTertiary;

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // absorb taps
            child: Container(
              margin: EdgeInsets.only(
                bottom: SSizes.controlBarHeight +
                    MediaQuery.of(context).padding.bottom +
                    SSizes.sm,
              ),
              padding: const EdgeInsets.all(SSizes.md),
              width: MediaQuery.of(context).size.width - SSizes.xl,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(SSizes.radiusXl),
                border: Border.all(color: borderColor.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: SSizes.md),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'AI Features',
                      style: TextStyle(
                        color: textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: SSizes.sm),

                  _OptionToggle(
                    icon: Iconsax.subtitle,
                    label: 'Live Transcription',
                    isActive: aiState.isTranscriptionEnabled,
                    isDark: isDark,
                    onTap: onToggleTranscription,
                  ),
                  _OptionToggle(
                    icon: Iconsax.cpu,
                    label: 'AI Copilot',
                    isActive: aiState.isCopilotEnabled,
                    isDark: isDark,
                    onTap: onToggleCopilot,
                  ),
                  _OptionToggle(
                    icon: Iconsax.teacher,
                    label: 'Speaking Coach',
                    isActive: aiState.isCoachingEnabled,
                    isDark: isDark,
                    onTap: onToggleCoaching,
                  ),

                  const SizedBox(height: SSizes.sm),
                  Divider(height: 1, color: borderColor.withOpacity(0.5)),
                  const SizedBox(height: SSizes.sm),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Meeting',
                      style: TextStyle(
                        color: textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: SSizes.sm),

                  _OptionToggle(
                    icon: SIcons.record,
                    label: 'Recording',
                    isActive: meetingState.isRecording,
                    activeColor: SColors.error,
                    isDark: isDark,
                    onTap: onToggleRecording,
                  ),
                  _OptionRow(
                    icon: SIcons.flipCamera,
                    label: 'Flip Camera',
                    isDark: isDark,
                    onTap: () {
                      onFlipCamera();
                      onClose();
                    },
                  ),
                  _OptionRow(
                    icon: SIcons.share,
                    label: 'Share Meeting Link',
                    isDark: isDark,
                    onTap: () {
                      onClose();
                      onShareMeetingLink();
                    },
                  ),
                  if (isHost && onEndMeeting != null) ...[
                    const SizedBox(height: SSizes.sm),
                    Divider(height: 1, color: borderColor.withOpacity(0.5)),
                    const SizedBox(height: SSizes.sm),
                    _OptionRow(
                      icon: Iconsax.call_slash,
                      label: 'End Meeting for All',
                      isDark: isDark,
                      onTap: () {
                        onClose();
                        onEndMeeting!();
                      },
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 150.ms).slideY(begin: 0.15),
          ),
        ),
      ),
    );
  }
}

class _OptionToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final bool isDark;
  final VoidCallback onTap;

  const _OptionToggle({
    required this.icon,
    required this.label,
    required this.isActive,
    this.activeColor = SColors.primary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final elevatedColor = isDark ? SColors.darkElevated : SColors.lightElevated;
    final textPrimary = isDark ? SColors.textDark : SColors.textLight;
    final textTertiary = isDark ? SColors.textDarkTertiary : SColors.textLightTertiary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SSizes.sm + 2),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor.withOpacity(0.12)
                    : elevatedColor,
                borderRadius: BorderRadius.circular(SSizes.radiusSm),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isActive ? activeColor : textTertiary,
              ),
            ),
            const SizedBox(width: SSizes.sm + 4),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 44,
              height: 26,
              child: Switch.adaptive(
                value: isActive,
                onChanged: (_) {
                  HapticFeedback.selectionClick();
                  onTap();
                },
                activeThumbColor: activeColor,
                activeTrackColor: activeColor.withOpacity(0.3),
                inactiveThumbColor: textTertiary,
                inactiveTrackColor: elevatedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _OptionRow({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final elevatedColor = isDark ? SColors.darkElevated : SColors.lightElevated;
    final textPrimary = isDark ? SColors.textDark : SColors.textLight;
    final textSecondary = isDark ? SColors.textDarkSecondary : SColors.textLightSecondary;
    final textTertiary = isDark ? SColors.textDarkTertiary : SColors.textLightTertiary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SSizes.sm + 2),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: elevatedColor,
                borderRadius: BorderRadius.circular(SSizes.radiusSm),
              ),
              child: Icon(icon, size: 16, color: textSecondary),
            ),
            const SizedBox(width: SSizes.sm + 4),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              size: 16,
              color: textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
