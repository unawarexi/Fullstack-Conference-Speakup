import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/domain/models/ai_models.dart';

class RoomCoachingBanner extends StatelessWidget {
  final CoachingHint hint;
  final bool isDark;

  const RoomCoachingBanner({super.key, required this.hint, required this.isDark});

  IconData get _icon => switch (hint.type) {
        CoachingType.pace => Iconsax.speedometer,
        CoachingType.clarity => Iconsax.lamp_on,
        CoachingType.volume => Iconsax.volume_high,
        CoachingType.filler => Iconsax.message_remove,
        CoachingType.pause => Iconsax.pause,
        CoachingType.engagement => Iconsax.people,
      };

  Color get _color => switch (hint.severity) {
        'high' => SColors.warning,
        'medium' => SColors.info,
        _ => SColors.textDarkSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: SSizes.md, vertical: SSizes.xs),
      padding: const EdgeInsets.symmetric(horizontal: SSizes.sm + 4, vertical: SSizes.sm),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
        border: Border.all(color: _color.withOpacity(0.25), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(_icon, size: 16, color: _color),
          const SizedBox(width: SSizes.sm),
          Expanded(
            child: Text(
              hint.message,
              style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.3);
  }
}
