import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/button.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';

/// Pre-meeting lobby — camera/mic preview before joining
class MeetingLobbyScreen extends ConsumerStatefulWidget {
  final String meetingId;
  const MeetingLobbyScreen({super.key, required this.meetingId});

  @override
  ConsumerState<MeetingLobbyScreen> createState() =>
      _MeetingLobbyScreenState();
}

class _MeetingLobbyScreenState extends ConsumerState<MeetingLobbyScreen> {
  bool _micOn = true;
  bool _cameraOn = true;
  bool _isJoining = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meetingAsync = ref.watch(meetingByIdProvider(widget.meetingId));

    return Scaffold(
      backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: SSizes.pagePadding, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(SIcons.back,
                        color:
                            isDark ? SColors.textDark : SColors.textLight),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  Text(
                    'Ready to join?',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark ? SColors.textDark : SColors.textLight,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Camera preview area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: SSizes.pagePadding),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SSizes.radiusLg),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isDark ? SColors.darkCard : SColors.lightElevated,
                      borderRadius:
                          BorderRadius.circular(SSizes.radiusLg),
                    ),
                    child: _cameraOn
                        ? Stack(
                            children: [
                              // Camera preview placeholder
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.videocam_rounded,
                                      size: 48,
                                      color: isDark
                                          ? SColors.textDarkTertiary
                                          : SColors.textLightTertiary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Camera Preview',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? SColors.textDarkTertiary
                                            : SColors.textLightTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Flip camera button
                              Positioned(
                                top: 12,
                                right: 12,
                                child: _CircleButton(
                                  icon: SIcons.flipCamera,
                                  isDark: isDark,
                                  onTap: () {},
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? SColors.darkElevated
                                        : SColors.lightBorder,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    SIcons.cameraOff,
                                    size: 32,
                                    color: isDark
                                        ? SColors.textDarkTertiary
                                        : SColors.textLightTertiary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Camera is off',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? SColors.textDarkTertiary
                                        : SColors.textLightTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: SSizes.lg),

            // Meeting info
            meetingAsync.when(
              data: (meeting) => Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: SSizes.pagePadding),
                child: Column(
                  children: [
                    Text(
                      meeting.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? SColors.textDark : SColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(SIcons.participants, size: 14,
                            color: isDark
                                ? SColors.textDarkTertiary
                                : SColors.textLightTertiary),
                        const SizedBox(width: 4),
                        Text(
                          '${meeting.participantCount} in meeting',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? SColors.textDarkSecondary
                                : SColors.textLightSecondary,
                          ),
                        ),
                        if (meeting.isLive) ...[
                          const SizedBox(width: 8),
                          StatusBadge.live(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              loading: () => const CupertinoActivityIndicator(),
              error: (_, _) => const SizedBox.shrink(),
            ),

            const SizedBox(height: SSizes.lg),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ControlButton(
                  icon: _micOn ? SIcons.micOn : SIcons.micOff,
                  isActive: _micOn,
                  label: _micOn ? 'Mute' : 'Unmute',
                  onTap: () => setState(() => _micOn = !_micOn),
                ),
                const SizedBox(width: 16),
                _ControlButton(
                  icon: _cameraOn ? SIcons.cameraOn : SIcons.cameraOff,
                  isActive: _cameraOn,
                  label: _cameraOn ? 'Stop Video' : 'Start Video',
                  onTap: () => setState(() => _cameraOn = !_cameraOn),
                ),
                const SizedBox(width: 16),
                _ControlButton(
                  icon: Icons.settings_outlined,
                  isActive: false,
                  label: 'Settings',
                  onTap: () => context.push('/settings/audio-video'),
                ),
              ],
            ),

            const SizedBox(height: SSizes.lg),

            // Join button
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: SSizes.pagePadding),
              child: SButton(
                text: 'Join Meeting',
                prefixIcon: Icons.videocam_rounded,
                isLoading: _isJoining,
                onPressed: _join,
              ),
            ),
            const SizedBox(height: SSizes.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _join() async {
    setState(() => _isJoining = true);
    try {
      final notifier = ref.read(activeMeetingProvider.notifier);
      await notifier.joinMeeting(widget.meetingId);
      if (mounted) {
        context.pushReplacement('/meeting/${widget.meetingId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _CircleButton(
      {required this.icon, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final String label;
  final VoidCallback onTap;
  const _ControlButton({
    required this.icon,
    required this.isActive,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isActive
                  ? (isDark ? SColors.darkCard : SColors.lightCard)
                  : SColors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? (isDark ? SColors.darkBorder : SColors.lightBorder)
                    : SColors.error.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isActive
                  ? (isDark ? SColors.textDark : SColors.textLight)
                  : SColors.error,
            ),
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
