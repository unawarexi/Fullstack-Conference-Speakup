import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';

class RoomControlsBar extends StatelessWidget {
  final MeetingRoomState meetingState;
  final MeetingAIState aiState;
  final bool showCopilot;
  final bool isDark;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleScreenShare;
  final VoidCallback onToggleHandRaise;
  final VoidCallback onToggleCopilot;
  final VoidCallback onToggleVoiceAssistant;
  final VoidCallback onMore;
  final VoidCallback onLeave;

  const RoomControlsBar({
    super.key,
    required this.meetingState,
    required this.aiState,
    required this.showCopilot,
    required this.isDark,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onToggleScreenShare,
    required this.onToggleHandRaise,
    required this.onToggleCopilot,
    required this.onToggleVoiceAssistant,
    required this.onMore,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark ? SColors.darkSurface : SColors.lightSurface;
    final borderColor = isDark ? SColors.darkBorder : SColors.lightBorder;
    final elevatedColor = isDark ? SColors.darkElevated : SColors.lightElevated;
    final textTertiary =
        isDark ? SColors.textDarkTertiary : SColors.textLightTertiary;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            left: SSizes.md,
            right: SSizes.md,
            top: SSizes.sm + 4,
            bottom: MediaQuery.of(context).padding.bottom + SSizes.sm,
          ),
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(isDark ? 0.85 : 0.9),
            border: Border(
                top: BorderSide(color: borderColor.withOpacity(0.5))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RoomControlBtn(
                icon: meetingState.isMicOn
                    ? SIcons.micOn
                    : SIcons.micOff,
                label: meetingState.isMicOn ? 'Mute' : 'Unmute',
                isActive: meetingState.isMicOn,
                activeColor: SColors.micOn,
                inactiveColor: SColors.micOff,
                elevatedColor: elevatedColor,
                textTertiary: textTertiary,
                surfaceColor: surfaceColor,
                onTap: onToggleMic,
              ),
              RoomControlBtn(
                icon: meetingState.isCameraOn
                    ? SIcons.cameraOn
                    : SIcons.cameraOff,
                label: 'Camera',
                isActive: meetingState.isCameraOn,
                activeColor: SColors.cameraOn,
                inactiveColor: SColors.cameraOff,
                elevatedColor: elevatedColor,
                textTertiary: textTertiary,
                surfaceColor: surfaceColor,
                onTap: onToggleCamera,
              ),
              RoomControlBtn(
                icon: meetingState.isScreenSharing
                    ? SIcons.stopScreenShare
                    : SIcons.screenShare,
                label: 'Share',
                isActive: meetingState.isScreenSharing,
                activeColor: SColors.screenShare,
                elevatedColor: elevatedColor,
                textTertiary: textTertiary,
                surfaceColor: surfaceColor,
                onTap: onToggleScreenShare,
              ),
              RoomControlBtn(
                icon: Iconsax.cpu,
                label: 'Copilot',
                isActive: showCopilot,
                activeColor: SColors.screenShare,
                hasDot: aiState.suggestions
                    .where((s) => !s.isDismissed)
                    .isNotEmpty,
                elevatedColor: elevatedColor,
                textTertiary: textTertiary,
                surfaceColor: surfaceColor,
                onTap: onToggleCopilot,
              ),
              RoomControlBtn(
                icon: Iconsax.microphone_2,
                label: 'Voice',
                isActive: aiState.isVoiceAssistantActive,
                activeColor: SColors.warning,
                elevatedColor: elevatedColor,
                textTertiary: textTertiary,
                surfaceColor: surfaceColor,
                onTap: onToggleVoiceAssistant,
              ),
              RoomControlBtn(
                icon: SIcons.moreOptions,
                label: 'More',
                isActive: false,
                elevatedColor: elevatedColor,
                textTertiary: textTertiary,
                surfaceColor: surfaceColor,
                onTap: onMore,
              ),
              // Leave button
              GestureDetector(
                onTap: onLeave,
                child: Container(
                  width: 52,
                  height: 40,
                  decoration: BoxDecoration(
                    color: SColors.callEnd,
                    borderRadius:
                        BorderRadius.circular(SSizes.radiusMd),
                  ),
                  child: const Icon(
                    SIcons.callEnd,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoomControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final Color elevatedColor;
  final Color textTertiary;
  final Color surfaceColor;
  final bool hasDot;
  final VoidCallback onTap;

  const RoomControlBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    this.activeColor = SColors.textDark,
    this.inactiveColor = SColors.textDarkTertiary,
    this.elevatedColor = SColors.darkElevated,
    this.textTertiary = SColors.textDarkTertiary,
    this.surfaceColor = SColors.darkSurface,
    this.hasDot = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive
                        ? activeColor.withOpacity(0.15)
                        : elevatedColor,
                    shape: BoxShape.circle,
                    border: isActive
                        ? Border.all(
                            color: activeColor.withOpacity(0.4),
                            width: 1)
                        : null,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
                if (hasDot)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: SColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: surfaceColor, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : textTertiary,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
