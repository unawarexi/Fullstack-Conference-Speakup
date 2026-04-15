import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
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
    final elevatedColor = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.black.withOpacity(0.08);
    final textTertiary = isDark
        ? Colors.white.withOpacity(0.5)
        : Colors.black.withOpacity(0.45);
    final inactiveIcon = isDark
        ? Colors.white.withOpacity(0.6)
        : Colors.black.withOpacity(0.5);

    return GlassContainer(
      height: SResponsive.sp(context, 72, tabletSize: 80, desktopSize: 84),
      shape: LiquidRoundedSuperellipse(
        borderRadius: SSizes.radiusXl + 8,
      ),
      useOwnLayer: true,
      quality: GlassQuality.standard,
      settings: LiquidGlassSettings(
        thickness: isDark ? 40 : 25,
        blur: isDark ? 16 : 12,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SSizes.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RoomControlBtn(
              icon: meetingState.isMicOn ? SIcons.micOn : SIcons.micOff,
              label: meetingState.isMicOn ? 'Mute' : 'Unmute',
              isActive: meetingState.isMicOn,
              activeColor: SColors.micOn,
              inactiveColor: meetingState.isMicOn ? inactiveIcon : SColors.micOff,
              elevatedColor: elevatedColor,
              textTertiary: textTertiary,
              onTap: onToggleMic,
            ),
            RoomControlBtn(
              icon: meetingState.isCameraOn ? SIcons.cameraOn : SIcons.cameraOff,
              label: 'Camera',
              isActive: meetingState.isCameraOn,
              activeColor: SColors.cameraOn,
              inactiveColor: meetingState.isCameraOn ? inactiveIcon : SColors.cameraOff,
              elevatedColor: elevatedColor,
              textTertiary: textTertiary,
              onTap: onToggleCamera,
            ),
            RoomControlBtn(
              icon: meetingState.isScreenSharing
                  ? SIcons.stopScreenShare
                  : SIcons.screenShare,
              label: 'Share',
              isActive: meetingState.isScreenSharing,
              activeColor: SColors.screenShare,
              inactiveColor: inactiveIcon,
              elevatedColor: elevatedColor,
              textTertiary: textTertiary,
              onTap: onToggleScreenShare,
            ),
            RoomControlBtn(
              icon: Iconsax.cpu,
              label: 'Copilot',
              isActive: showCopilot,
              activeColor: SColors.screenShare,
              inactiveColor: inactiveIcon,
              hasDot: aiState.suggestions.where((s) => !s.isDismissed).isNotEmpty,
              elevatedColor: elevatedColor,
              textTertiary: textTertiary,
              onTap: onToggleCopilot,
            ),
            RoomControlBtn(
              icon: Iconsax.microphone_2,
              label: 'Voice',
              isActive: aiState.isVoiceAssistantActive,
              activeColor: SColors.warning,
              inactiveColor: inactiveIcon,
              elevatedColor: elevatedColor,
              textTertiary: textTertiary,
              onTap: onToggleVoiceAssistant,
            ),
            RoomControlBtn(
              icon: SIcons.moreOptions,
              label: 'More',
              isActive: false,
              inactiveColor: inactiveIcon,
              elevatedColor: elevatedColor,
              textTertiary: textTertiary,
              onTap: onMore,
            ),
            // Leave button
            GestureDetector(
              onTap: onLeave,
              child: Container(
                width: SResponsive.sp(context, 48, tabletSize: 52),
                height: SResponsive.sp(context, 36, tabletSize: 40),
                decoration: BoxDecoration(
                  color: SColors.callEnd,
                  borderRadius: BorderRadius.circular(SSizes.radiusMd),
                ),
                child: const Icon(SIcons.callEnd, color: Colors.white, size: 18),
              ),
            ),
          ],
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
    this.surfaceColor = Colors.transparent,
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
        width: SResponsive.sp(context, 48, tabletSize: 56, desktopSize: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: SResponsive.sp(context, 40, tabletSize: 44, desktopSize: 48),
                  height: SResponsive.sp(context, 40, tabletSize: 44, desktopSize: 48),
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
