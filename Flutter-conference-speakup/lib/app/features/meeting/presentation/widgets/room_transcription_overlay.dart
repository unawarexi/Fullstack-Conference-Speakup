import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/domain/models/ai_models.dart';

class RoomTranscriptionOverlay extends StatelessWidget {
  final List<TranscriptionSegment> segments;
  final bool isDark;

  const RoomTranscriptionOverlay({super.key, required this.segments, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Show last 3 segments
    final recent = segments.length > 3 ? segments.sublist(segments.length - 3) : segments;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: SSizes.md),
      padding: const EdgeInsets.symmetric(horizontal: SSizes.md, vertical: SSizes.sm + 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
        border: Border.all(color: SColors.darkBorder.withOpacity(0.5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // CC indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: SColors.info.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'CC',
                  style: TextStyle(
                    color: SColors.info,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Iconsax.subtitle, size: 12, color: SColors.textDarkTertiary),
            ],
          ),
          const SizedBox(height: 4),
          ...recent.map((seg) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: RichText(
                  text: TextSpan(
                    children: [
                      if (seg.speakerName != null)
                        TextSpan(
                          text: '${seg.speakerName}: ',
                          style: const TextStyle(
                            color: SColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      TextSpan(
                        text: seg.text,
                        style: TextStyle(
                          color: seg.isFinal
                              ? SColors.textDark
                              : SColors.textDarkSecondary,
                          fontSize: 12,
                          fontStyle:
                              seg.isFinal ? FontStyle.normal : FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
