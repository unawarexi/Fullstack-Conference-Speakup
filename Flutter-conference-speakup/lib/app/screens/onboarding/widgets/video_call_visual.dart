import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

class VideoCallVisual extends StatelessWidget {
  final bool compact;
  const VideoCallVisual({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = theme.colorScheme.outline;
    final cardColor = isDark ? SColors.darkCard : SColors.lightCard;
    final tileColor = isDark ? SColors.participantTile : SColors.participantTileLight;

    return Stack(
      children: [
        // ── Main video tile (full size bg) ──
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(SSizes.radiusXl),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: SColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Gradient simulating camera feed
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        SColors.primary.withOpacity(isDark ? 0.15 : 0.08),
                        tileColor,
                        SColors.primaryDark.withOpacity(isDark ? 0.12 : 0.06),
                      ],
                    ),
                  ),
                ),
                // Avatar circle in center
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: compact ? 32 : 40,
                        backgroundColor: SColors.primary.withOpacity(0.15),
                        child: Icon(
                          Icons.person_rounded,
                          size: compact ? 36 : 44,
                          color: SColors.primary.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: SSizes.sm),
                      Text(
                        'Sarah Chen',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: compact ? 13 : 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Speaking...',
                        style: TextStyle(
                          color: SColors.primary,
                          fontSize: compact ? 11 : 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Active speaker ring
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SSizes.radiusXl),
                      border: Border.all(
                        color: SColors.primary.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                // Top-left: meeting info
                Positioned(
                  top: SSizes.md,
                  left: SSizes.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(SSizes.radiusFull),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            color: SColors.success,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: SColors.success, blurRadius: 4)],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: SColors.success,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '24:15',
                          style: TextStyle(
                            color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom: meeting controls bar
                Positioned(
                  bottom: SSizes.md,
                  left: SSizes.md,
                  right: SSizes.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(SSizes.radiusLg),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ControlIcon(icon: Icons.mic_rounded, color: SColors.primary, active: true),
                        _ControlIcon(icon: Icons.videocam_rounded, color: SColors.primary, active: true),
                        _ControlIcon(icon: Icons.screen_share_rounded, color: SColors.primary, active: false),
                        _ControlIcon(icon: Icons.chat_bubble_outline_rounded, color: SColors.primary, active: false),
                        Container(
                          width: compact ? 32 : 36,
                          height: compact ? 32 : 36,
                          decoration: BoxDecoration(
                            color: SColors.callEnd,
                            borderRadius: BorderRadius.circular(SSizes.radiusSm),
                          ),
                          child: Icon(Icons.call_end_rounded, color: Colors.white, size: compact ? 14 : 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── PiP (small self-view) top-right ──
        Positioned(
          top: SSizes.sm,
          right: SSizes.sm,
          child: Container(
            width: compact ? 72 : 90,
            height: compact ? 96 : 120,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C2E) : const Color(0xFFE8EDF4),
              borderRadius: BorderRadius.circular(SSizes.radiusMd),
              border: Border.all(color: SColors.primary.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        SColors.primary.withOpacity(isDark ? 0.1 : 0.06),
                        isDark ? const Color(0xFF1C1C2E) : const Color(0xFFE8EDF4),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: CircleAvatar(
                    radius: compact ? 16 : 20,
                    backgroundColor: SColors.primary.withOpacity(0.2),
                    child: Icon(
                      Icons.person_rounded,
                      size: compact ? 18 : 22,
                      color: SColors.primary.withOpacity(0.7),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  left: 0, right: 0,
                  child: Center(
                    child: Text(
                      'You',
                      style: TextStyle(
                        color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Participants count badge ──
        Positioned(
          top: SSizes.md,
          right: compact ? 84 : 104,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: SColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(SSizes.radiusFull),
              border: Border.all(color: SColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_rounded, size: 12, color: SColors.primary),
                const SizedBox(width: 3),
                Text(
                  '12',
                  style: TextStyle(
                    color: SColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ControlIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool active;
  const _ControlIcon({required this.icon, required this.color, required this.active});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.15) : (isDark ? SColors.darkElevated : SColors.lightElevated),
        borderRadius: BorderRadius.circular(SSizes.radiusSm),
      ),
      child: Icon(
        icon,
        size: 16,
        color: active ? color : (isDark ? SColors.textDarkTertiary : SColors.textLightTertiary),
      ),
    );
  }
}
