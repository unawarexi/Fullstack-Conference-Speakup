import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

/// Circular emoji + percent display for a sentiment category.
class SentimentCircle extends StatelessWidget {
  final String emoji;
  final String label;
  final int percent;
  final Color color;
  const SentimentCircle({super.key, required this.emoji, required this.label, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text('$percent%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

/// Card showing a sentiment shift event with timestamp.
class SentimentShiftCard extends StatelessWidget {
  final String time;
  final String shift;
  final String trigger;
  final String emoji;
  final bool isDark;
  const SentimentShiftCard({super.key, required this.time, required this.shift, required this.trigger, required this.emoji, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(shift, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                      const Spacer(),
                      Text(time, style: TextStyle(fontSize: 10, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(trigger, style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal stacked bar showing sentiment breakdown per speaker.
class SpeakerSentimentBar extends StatelessWidget {
  final String name;
  final double positive;
  final double neutral;
  final double negative;
  final bool isDark;
  const SpeakerSentimentBar({super.key, required this.name, required this.positive, required this.neutral, required this.negative, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
          border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Row(
                children: [
                  Expanded(flex: positive.round().clamp(1, 100), child: Container(height: 6, color: SColors.success)),
                  Expanded(flex: neutral.round().clamp(1, 100), child: Container(height: 6, color: SColors.warning)),
                  Expanded(flex: negative.round().clamp(1, 100), child: Container(height: 6, color: SColors.error)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('😊 ${positive.round()}%', style: TextStyle(fontSize: 9, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                Text('😐 ${neutral.round()}%', style: TextStyle(fontSize: 9, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                Text('😟 ${negative.round()}%', style: TextStyle(fontSize: 9, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip displaying a keyword with sentiment-based coloring.
class EmotionChip extends StatelessWidget {
  final String word;
  final String sentiment;
  const EmotionChip({super.key, required this.word, required this.sentiment});

  Color get _color {
    if (sentiment == 'positive') return SColors.success;
    if (sentiment == 'negative') return SColors.error;
    return SColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SSizes.radiusFull),
        border: Border.all(color: _color.withValues(alpha: 0.2)),
      ),
      child: Text(word, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _color)),
    );
  }
}

/// Custom painter for dual sentiment wave lines.
class SentimentWavePainter extends CustomPainter {
  final bool isDark;
  SentimentWavePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    paint.color = SColors.success;
    final posPath = Path();
    posPath.moveTo(0, size.height * 0.4);
    posPath.cubicTo(size.width * 0.15, size.height * 0.2, size.width * 0.25, size.height * 0.3, size.width * 0.35, size.height * 0.35);
    posPath.cubicTo(size.width * 0.45, size.height * 0.4, size.width * 0.55, size.height * 0.6, size.width * 0.65, size.height * 0.3);
    posPath.cubicTo(size.width * 0.75, size.height * 0.1, size.width * 0.85, size.height * 0.2, size.width, size.height * 0.25);
    canvas.drawPath(posPath, paint);

    paint.color = SColors.error.withValues(alpha: 0.6);
    final negPath = Path();
    negPath.moveTo(0, size.height * 0.7);
    negPath.cubicTo(size.width * 0.15, size.height * 0.75, size.width * 0.25, size.height * 0.65, size.width * 0.35, size.height * 0.5);
    negPath.cubicTo(size.width * 0.45, size.height * 0.35, size.width * 0.55, size.height * 0.55, size.width * 0.65, size.height * 0.7);
    negPath.cubicTo(size.width * 0.75, size.height * 0.8, size.width * 0.85, size.height * 0.75, size.width, size.height * 0.7);
    canvas.drawPath(negPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
