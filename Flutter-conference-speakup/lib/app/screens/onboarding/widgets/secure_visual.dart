import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/image_strings.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

/// Slide 3 — Original wave/rings/shield design on top of a full background image
class SecureVisual extends StatelessWidget {
  final bool compact;
  const SecureVisual({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? SColors.darkCard : SColors.lightCard;
    final borderColor = theme.colorScheme.outline;

    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Full background image ──
        Positioned.fill(
          child: Image.asset(
            SImages.onboarding7,
            fit: BoxFit.cover,
          ),
        ),

        // ── Dark overlay so the rings/badges are visible ──
        Positioned.fill(
          child: Container(
            color: (isDark ? Colors.black : const Color(0xFF1A1A2E))
                .withOpacity(isDark ? 0.55 : 0.45),
          ),
        ),

        // ── Wave background ──
        Positioned.fill(
          child: CustomPaint(
            painter: _WavePainter(isDark: isDark),
          ),
        ),

        // Outer ring
        Container(
          width: compact ? 150 : 190,
          height: compact ? 150 : 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: SColors.primary.withOpacity(0.1),
              width: 100,
            ),
          ),
        ),
        // Middle ring
        Container(
          width: compact ? 110 : 140,
          height: compact ? 110 : 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: SColors.primary.withOpacity(0.15),
              width: 100,
            ),
          ),
        ),
        // Inner ring with glow
        Container(
          width: compact ? 80 : 100,
          height: compact ? 80 : 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: SColors.primary.withOpacity(isDark ? 0.1 : 0.06),
            border: Border.all(
              color: SColors.primary.withOpacity(0.25),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: SColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
        // Shield icon
        Container(
          width: compact ? 54 : 64,
          height: compact ? 54 : 64,
          decoration: BoxDecoration(
            gradient: SColors.primaryGradient,
            borderRadius: BorderRadius.circular(compact ? 14 : 18),
            boxShadow: [
              BoxShadow(
                color: SColors.primary.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.shield_rounded,
            size: compact ? 26 : 32,
            color: Colors.white,
          ),
        ),
        // Orbiting badges
        Positioned(
          top: compact ? 120 : 150,
          right: compact ? 90 : 130,
          child: _SecurityBadge(
            icon: Icons.lock_rounded,
            label: 'AES-256',
            isDark: isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            compact: compact,
          ),
        ),
        Positioned(
          bottom: compact ? 130 : 160,
          left: compact ? 90 : 120,
          child: _SecurityBadge(
            icon: Icons.verified_user_rounded,
            label: 'E2E',
            isDark: isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            compact: compact,
          ),
        ),
        Positioned(
          bottom: compact ? 120 : 150,
          right: compact ? 90 : 120,
          child: _SecurityBadge(
            icon: Icons.fingerprint_rounded,
            label: 'Biometric',
            isDark: isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            compact: compact,
          ),
        ),
        Positioned(
          top: compact ? 130 : 160,
          left: compact ? 90 : 120,
          child: _SecurityBadge(
            icon: Icons.vpn_key_rounded,
            label: 'DTLS',
            isDark: isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            compact: compact,
          ),
        ),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  final bool isDark;
  const _WavePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (int layer = 0; layer < 4; layer++) {
      final opacity = isDark
          ? 0.06 - (layer * 0.012)
          : 0.08 - (layer * 0.015);
      final paint = Paint()
        ..color = SColors.primary.withOpacity(opacity.clamp(0.01, 1.0))
        ..style = PaintingStyle.fill;

      final yOffset = h * 0.35 + (layer * h * 0.08);
      final amplitude = 20.0 + (layer * 8.0);
      final frequency = 1.5 + (layer * 0.4);

      final path = Path()..moveTo(0, yOffset);
      for (double x = 0; x <= w; x += 1) {
        final y = yOffset + amplitude * sin((x / w) * frequency * pi + (layer * 0.8));
        path.lineTo(x, y);
      }
      path.lineTo(w, h);
      path.lineTo(0, h);
      path.close();

      canvas.drawPath(path, paint);
    }

    for (int i = 0; i < 3; i++) {
      final lineOpacity = isDark ? 0.05 : 0.07;
      final linePaint = Paint()
        ..color = SColors.primary.withOpacity(lineOpacity - (i * 0.015))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final yStart = h * 0.15 + (i * h * 0.07);
      final amp = 12.0 + (i * 5.0);

      final linePath = Path()..moveTo(0, yStart);
      for (double x = 0; x <= w; x += 1) {
        final y = yStart + amp * sin((x / w) * 2.5 * pi + (i * 1.2));
        linePath.lineTo(x, y);
      }
      canvas.drawPath(linePath, linePaint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.isDark != isDark;
}

class _SecurityBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final bool compact;

  const _SecurityBadge({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 4 : 6),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(SSizes.radiusFull),
        border: Border.all(color: SColors.primary.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: SColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: SColors.primary,
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
