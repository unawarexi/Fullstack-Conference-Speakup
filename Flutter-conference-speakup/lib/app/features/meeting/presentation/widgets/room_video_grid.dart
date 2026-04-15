import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/app/domain/models/ai_models.dart';
import 'package:flutter_conference_speakup/app/domain/models/participant_model.dart';

class RoomVideoGrid extends StatelessWidget {
  final List<Participant> participants;
  final Map<String, EmotionSignal> emotions;
  final bool isCameraOn;
  final bool isMicOn;
  final bool isDark;

  const RoomVideoGrid({
    super.key,
    required this.participants,
    required this.emotions,
    required this.isCameraOn,
    required this.isMicOn,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final totalParticipants = participants.length + 1; // +1 for self
    final bg = isDark ? SColors.darkBg : SColors.lightBg;

    // Single participant → fill entire screen, no GridView constraints
    if (totalParticipants == 1) {
      return Container(
        color: bg,
        child: RoomParticipantTile(
          name: 'You',
          isSelf: true,
          isCameraOn: isCameraOn,
          isMicOn: isMicOn,
          emotion: null,
          isDark: isDark,
        ),
      );
    }

    final crossAxisCount = SResponsive.meetingGridColumns(context, totalParticipants);
    final aspectRatio = SResponsive.value<double>(context,
      mobile: 4 / 3,
      tablet: 16 / 10,
      desktop: 16 / 9,
    );

    return Container(
      color: bg,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          childAspectRatio: aspectRatio,
        ),
        itemCount: totalParticipants,
        itemBuilder: (context, index) {
          if (index == 0) {
            return RoomParticipantTile(
              name: 'You',
              isSelf: true,
              isCameraOn: isCameraOn,
              isMicOn: isMicOn,
              emotion: null,
              isDark: isDark,
            );
          }
          final participant = participants[index - 1];
          return RoomParticipantTile(
            name: participant.name,
            avatarUrl: participant.avatar,
            isSelf: false,
            isCameraOn: !participant.isCameraOff,
            isMicOn: !participant.isMuted,
            emotion: emotions[participant.userId],
            isDark: isDark,
          );
        },
      ),
    );
  }
}

class RoomParticipantTile extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final bool isSelf;
  final bool isCameraOn;
  final bool isMicOn;
  final EmotionSignal? emotion;
  final bool isDark;

  const RoomParticipantTile({
    super.key,
    required this.name,
    this.avatarUrl,
    required this.isSelf,
    required this.isCameraOn,
    required this.isMicOn,
    this.emotion,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final tileBg =
        isDark ? SColors.participantTile : SColors.participantTileLight;
    final avatarBg = isDark ? SColors.darkElevated : SColors.lightElevated;
    final textPrimary = isDark ? SColors.textDark : SColors.textLight;
    final textTertiary =
        isDark ? SColors.textDarkTertiary : SColors.textLightTertiary;
    final avatarRadius = SResponsive.sp(context, 28, tabletSize: 34, desktopSize: 40);

    return Container(
      decoration: BoxDecoration(
        color: tileBg,
      ),
      child: Stack(
        children: [
          // Camera off / avatar placeholder
          Center(
            child: isCameraOn
                ? Container(
                    decoration: BoxDecoration(
                      color: avatarBg,
                    ),
                    child: Center(
                      child: CircleAvatar(
                        radius: avatarRadius,
                        backgroundColor:
                            SColors.primary.withOpacity(0.2),
                        backgroundImage: avatarUrl != null
                            ? NetworkImage(avatarUrl!)
                            : null,
                        child: avatarUrl == null
                            ? Text(
                                name.isNotEmpty
                                    ? name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: SColors.primary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
                      ),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: avatarRadius,
                        backgroundColor: avatarBg,
                        child: Text(
                          name.isNotEmpty
                              ? name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        Iconsax.video_slash,
                        size: 14,
                        color: textTertiary,
                      ),
                    ],
                  ),
          ),

          // Name label (bottom left)
          Positioned(
            left: SSizes.sm,
            bottom: SSizes.sm,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(SSizes.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMicOn) ...[
                    Icon(Iconsax.microphone_slash,
                        size: 11, color: SColors.micOff),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    isSelf ? 'You' : name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Emotion badge (top right)
          if (emotion != null)
            Positioned(
              right: SSizes.sm,
              top: SSizes.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius:
                      BorderRadius.circular(SSizes.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emotion!.emoji,
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 3),
                    SizedBox(
                      width: 20,
                      height: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: emotion!.engagementScore,
                          backgroundColor: isDark
                              ? SColors.darkBorder
                              : SColors.lightBorder,
                          valueColor: AlwaysStoppedAnimation(
                            emotion!.engagementScore > 0.6
                                ? SColors.success
                                : emotion!.engagementScore > 0.3
                                    ? SColors.warning
                                    : SColors.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 200.ms).scale(
                  begin: const Offset(0.8, 0.8)),
            ),

          // Self badge
          if (isSelf)
            Positioned(
              right: SSizes.sm,
              top: SSizes.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: SColors.primary.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(SSizes.radiusFull),
                  border: Border.all(
                      color: SColors.primary.withOpacity(0.4),
                      width: 0.5),
                ),
                child: const Text(
                  'You',
                  style: TextStyle(
                    color: SColors.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
