import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/image_strings.dart';
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
    final tileColor = isDark ? SColors.participantTile : SColors.participantTileLight;

    return Stack(
      children: [
        // ── Full background image ──
        Positioned.fill(
          child: Image.asset(
            SImages.onboarding3,
            fit: BoxFit.cover,
          ),
        ),
        // ── Dark overlay for readability ──
        Positioned.fill(
          child: Container(
            color: (isDark ? Colors.black : const Color(0xFF1A1A2E))
                .withOpacity(isDark ? 0.65 : 0.55),
          ),
        ),
        // ── Content on top ──
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: compact ? 45 : 50),
            child: Column(
              children: [
                // ── Main ── 
           
                Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(SSizes.md, SSizes.md, SSizes.md, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2E).withOpacity(0.5) : const Color(0xFFF1F3F5).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor.withOpacity(0.6), width: 1.5),
                    ),
                    child: Stack(
                      children: [
                        // Avatar + info
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _SpeakerAvatar(
                                radius: compact ? 22 : 26,
                                initials: 'SC',
                                isSpeaking: true,
                                isDark: isDark,
                                image: SImages.onboarding3,
                              ),
                              const SizedBox(height: SSizes.xs),
                              Text(
                                'Sarah Chen',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
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
                                      color: SColors.primarySurface,
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
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(SSizes.sm, 4, SSizes.sm, SSizes.sm),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 1.2,
                    padding: EdgeInsets.zero,
                    children: const [
                      _ListenerTile(initials: 'AJ', name: 'Alex', isMuted: false, image: SImages.onboarding4),
                      _ListenerTile(initials: 'MK', name: 'Maya', isMuted: true),
                      _ListenerTile(initials: 'RB', name: 'Ryan', isMuted: false),
                      _ListenerTile(initials: 'LP', name: 'Lisa', isMuted: true, image: SImages.onboarding6),
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
                  border: Border(top: BorderSide(color: borderColor.withOpacity(0.3))),
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
        ),
    )],
    );
  }
}

// ── Speaker avatar with active speaking ring ──
class _SpeakerAvatar extends StatelessWidget {
  final double radius;
  final String initials;
  final bool isSpeaking;
  final bool isDark;
  final String? image;

  const _SpeakerAvatar({
    required this.radius,
    required this.initials,
    required this.isSpeaking,
    required this.isDark,
    this.image,
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
        backgroundImage: image != null ? AssetImage(image!) : null,
        child: image == null
            ? Text(
                initials,
                style: TextStyle(
                  color: SColors.primary,
                  fontSize: radius * 0.55,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
      ),
    );
  }
}

// ── Grid tile for each listener ──
class _ListenerTile extends StatelessWidget {
  final String initials;
  final String name;
  final bool isMuted;
  final String? image;

  const _ListenerTile({
    required this.initials,
    required this.name,
    required this.isMuted,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = isDark ? const Color(0xFF1E1E2E).withOpacity(0.5) : const Color(0xFFF1F3F5).withOpacity(0.4);
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08);

    return Container(
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(SSizes.radiusSm + 2),
        border: Border.all(
          color: borderColor.withOpacity(0.6),
          width: 1.5,
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
                  backgroundImage: image != null ? AssetImage(image!) : null,
                  child: image == null
                      ? Text(
                          initials,
                          style: TextStyle(
                            color: SColors.primarySurface,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
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
