import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glowOpacity = isDark ? 0.18 : 0.10;

    return Stack(
      children: [
        Positioned(
          top: -160,
          left: -120,
          child: _GlowBlob(
            size: 500,
            color: SColors.primary.withOpacity(glowOpacity),
          ),
        ),
        Positioned(
          bottom: -180,
          right: -140,
          child: _GlowBlob(
            size: 420,
            color: SColors.primaryLight.withOpacity(glowOpacity * 0.7),
          ),
        ),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: size * 0.6, spreadRadius: size * 0.1)],
      ),
    );
  }
}
