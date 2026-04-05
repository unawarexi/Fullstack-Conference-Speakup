import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

/// Slide 2 — Group voice call with main speaker + listener grid
class TeamChatVisual extends StatelessWidget {
  final bool compact;
  const TeamChatVisual({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = theme.colorScheme.outline;
    final cardColor = isDark ? SColors.darkCard : SColors.lightCard;
    final tileColor = isDark ? SColors.participantTile : SColors.participantTileLight;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
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
      child: Column(
        children: [
          // ── Call header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: SSizes.md, vertical: SSizes.sm + 2),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: SColors.success,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: SColors.success, blurRadius: 4)],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Team Standup',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '12:34',
                  style: TextStyle(
                    color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: SColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(SSizes.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_rounded, size: 11, color: SColors.primary),
                      const SizedBox(width: 3),
                      Text(
                        '6',
                        style: TextStyle(
                          color: SColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Main speaker ──
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(SSizes.sm, SSizes.sm, SSizes.sm, 4),
              child: Container(
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(SSizes.radiusMd),
                  border: Border.all(color: SColors.primary.withOpacity(0.4), width: 2),
                ),
                child: Stack(
                  children: [
                    // Gradient bg
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(SSizes.radiusMd - 1),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              SColors.primary.withOpacity(isDark ? 0.12 : 0.06),
                              tileColor,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Avatar + info
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SpeakerAvatar(
                            radius: compact ? 28 : 34,
                            initials: 'SC',
                            isSpeaking: true,
                            isDark: isDark,
                          ),
                          const SizedBox(height: SSizes.xs),
                          Text(
                            'Sarah Chen',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: compact ? 12 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.graphic_eq_rounded, size: 14, color: SColors.primary),
                              const SizedBox(width: 3),
                              Text(
                                'Speaking',
                                style: TextStyle(
                                  color: SColors.primary,
                                  fontSize: compact ? 10 : 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Mic icon top-right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: SColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(SSizes.radiusSm),
                        ),
                        child: Icon(Icons.mic_rounded, size: 14, color: SColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Listener grid (2 rows × 3 cols) ──
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(SSizes.sm, 4, SSizes.sm, SSizes.sm),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1.1,
                padding: EdgeInsets.zero,
                children: const [
                  _ListenerTile(initials: 'AJ', name: 'Alex', isMuted: false),
                  _ListenerTile(initials: 'MK', name: 'Maya', isMuted: true),
                  _ListenerTile(initials: 'RB', name: 'Ryan', isMuted: false),
                  _ListenerTile(initials: 'LP', name: 'Lisa', isMuted: true),
                  _ListenerTile(initials: 'JW', name: 'James', isMuted: true),
                  _MoreParticipants(count: 4),
                ],
              ),
            ),
          ),

          // ── Bottom controls ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: SSizes.md, vertical: SSizes.sm),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CallControl(icon: Icons.mic_rounded, active: true),
                _CallControl(icon: Icons.volume_up_rounded, active: true),
                _CallControl(icon: Icons.screen_share_rounded, active: false),
                _CallControl(icon: Icons.pan_tool_rounded, active: false),
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
        ],
      ),
    );
  }
}

// ── Speaker avatar with active speaking ring ──
class _SpeakerAvatar extends StatelessWidget {
  final double radius;
  final String initials;
  final bool isSpeaking;
  final bool isDark;

  const _SpeakerAvatar({
    required this.radius,
    required this.initials,
    required this.isSpeaking,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: isSpeaking
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: SColors.primary.withOpacity(0.6), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: SColors.primary.withOpacity(0.25),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            )
          : null,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: SColors.primary.withOpacity(0.15),
        child: Text(
          initials,
          style: TextStyle(
            color: SColors.primary,
            fontSize: radius * 0.55,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── Grid tile for each listener ──
class _ListenerTile extends StatelessWidget {
  final String initials;
  final String name;
  final bool isMuted;

  const _ListenerTile({
    required this.initials,
    required this.name,
    required this.isMuted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = isDark ? SColors.participantTile : SColors.participantTileLight;

    return Container(
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(SSizes.radiusSm + 2),
        border: Border.all(
          color: isDark ? SColors.darkBorder : SColors.lightBorder,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: SColors.primary.withOpacity(0.12),
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: SColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  name,
                  style: TextStyle(
                    color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Icon(
              isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              size: 10,
              color: isMuted
                  ? (isDark ? SColors.textDarkTertiary : SColors.textLightTertiary)
                  : SColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── "+N more" tile ──
class _MoreParticipants extends StatelessWidget {
  final int count;
  const _MoreParticipants({required this.count});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: SColors.primary.withOpacity(isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(SSizes.radiusSm + 2),
        border: Border.all(
          color: SColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '+$count',
          style: TextStyle(
            color: SColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── Bottom call control button ──
class _CallControl extends StatelessWidget {
  final IconData icon;
  final bool active;
  const _CallControl({required this.icon, required this.active});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active
            ? SColors.primary.withOpacity(0.15)
            : (isDark ? SColors.darkElevated : SColors.lightElevated),
        borderRadius: BorderRadius.circular(SSizes.radiusSm),
      ),
      child: Icon(
        icon,
        size: 16,
        color: active
            ? SColors.primary
            : (isDark ? SColors.textDarkTertiary : SColors.textLightTertiary),
      ),
    );
  }
}
