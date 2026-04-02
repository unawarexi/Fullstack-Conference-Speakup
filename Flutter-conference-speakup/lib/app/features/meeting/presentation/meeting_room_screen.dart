import 'package:flutter/material.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';

/// Active meeting / video call screen.
class MeetingRoomScreen extends StatefulWidget {
  final String meetingId;

  const MeetingRoomScreen({super.key, required this.meetingId});

  @override
  State<MeetingRoomScreen> createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends State<MeetingRoomScreen> {
  bool _isMicOn = true;
  bool _isCameraOn = true;
  bool _isScreenSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SSizes.md,
                vertical: SSizes.sm,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SSizes.sm,
                      vertical: SSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: SColors.darkCard,
                      borderRadius: BorderRadius.circular(SSizes.radiusSm),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, color: SColors.success, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          widget.meetingId,
                          style: const TextStyle(
                            color: SColors.textDark,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.people_outline, color: SColors.textDark),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline, color: SColors.textDark),
                  ),
                ],
              ),
            ),

            // Video grid
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(SSizes.sm),
                decoration: BoxDecoration(
                  color: SColors.participantTile,
                  borderRadius: BorderRadius.circular(SSizes.tileRadius),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: SColors.primary,
                        child: Text(
                          'U',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: SSizes.sm),
                      Text(
                        'You',
                        style: TextStyle(color: SColors.textDark, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Controls bar
            Container(
              height: SSizes.controlBarHeight,
              padding: const EdgeInsets.symmetric(horizontal: SSizes.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(
                    icon: _isMicOn ? Icons.mic : Icons.mic_off,
                    isActive: _isMicOn,
                    onTap: () => setState(() => _isMicOn = !_isMicOn),
                  ),
                  _ControlButton(
                    icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                    isActive: _isCameraOn,
                    onTap: () => setState(() => _isCameraOn = !_isCameraOn),
                  ),
                  _ControlButton(
                    icon: Icons.screen_share,
                    isActive: !_isScreenSharing,
                    onTap: () =>
                        setState(() => _isScreenSharing = !_isScreenSharing),
                  ),
                  _ControlButton(
                    icon: Icons.front_hand,
                    isActive: false,
                    activeColor: SColors.handRaised,
                    onTap: () {},
                  ),
                  _ControlButton(
                    icon: Icons.call_end,
                    isActive: false,
                    inactiveColor: SColors.callEnd,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;
  final Color? activeColor;
  final Color? inactiveColor;

  const _ControlButton({
    required this.icon,
    required this.isActive,
    this.onTap,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isActive
        ? (activeColor ?? SColors.darkElevated)
        : (inactiveColor ?? SColors.darkHover);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? SColors.textDark : Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
