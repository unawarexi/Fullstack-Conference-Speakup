import 'dart:math' as math;
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════
//  SpeakUp Decorative Painters
//  Painted curves, swooshes, and accent shapes
//  using CustomPainter for layered compositions.
// ═══════════════════════════════════════════════

/// A flowing, multi-layer gradient swoosh.
/// Stacks 2–3 translucent Bezier ribbon layers.
///
/// ```dart
/// CustomPaint(
///   size: Size(double.infinity, 260),
///   painter: SSwooshPainter(
///     colors: [SColors.primary, SColors.screenShare],
///     isDark: true,
///   ),
/// )
/// ```
class SSwooshPainter extends CustomPainter {
  final List<Color> colors;
  final bool isDark;
  final double intensity;

  SSwooshPainter({
    required this.colors,
    this.isDark = true,
    this.intensity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final baseAlpha = isDark ? 0.15 : 0.10;

    // Layer 1 — wide background swoosh
    final p1 = Path()
      ..moveTo(0, h * 0.55)
      ..cubicTo(w * 0.2, h * 0.3, w * 0.5, h * 0.7, w, h * 0.35)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final paint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors[0].withValues(alpha: baseAlpha * intensity),
          (colors.length > 1 ? colors[1] : colors[0])
              .withValues(alpha: baseAlpha * 0.6 * intensity),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(p1, paint1);

    // Layer 2 — sharper mid-swoosh
    final p2 = Path()
      ..moveTo(0, h * 0.72)
      ..cubicTo(w * 0.35, h * 0.45, w * 0.65, h * 0.85, w, h * 0.6)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final paint2 = Paint()
      ..shader = LinearGradient(
        colors: [
          colors[0].withValues(alpha: baseAlpha * 0.7 * intensity),
          (colors.length > 1 ? colors[1] : colors[0])
              .withValues(alpha: baseAlpha * 0.4 * intensity),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(p2, paint2);

    // Layer 3 — thin accent line along the top edge of the main swoosh
    final p3 = Path()
      ..moveTo(0, h * 0.72)
      ..cubicTo(w * 0.35, h * 0.45, w * 0.65, h * 0.85, w, h * 0.6);

    final linePaint = Paint()
      ..color = colors[0].withValues(alpha: isDark ? 0.2 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(p3, linePaint);
  }

  @override
  bool shouldRepaint(SSwooshPainter oldDelegate) =>
      colors != oldDelegate.colors ||
      isDark != oldDelegate.isDark ||
      intensity != oldDelegate.intensity;
}

/// Animated-ready aurora / northern-lights effect.
/// Multiple overlapping gradient arcs.
class SAuroraPainter extends CustomPainter {
  final List<Color> colors;
  final double phase;
  final bool isDark;

  SAuroraPainter({
    required this.colors,
    this.phase = 0.0,
    this.isDark = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (int i = 0; i < colors.length; i++) {
      final t = (phase + i * 0.7) % (math.pi * 2);
      final yOffset = math.sin(t) * h * 0.1;

      final path = Path()
        ..moveTo(-w * 0.1, h * (0.3 + i * 0.12) + yOffset)
        ..cubicTo(
          w * 0.25, h * (0.15 + i * 0.08) + yOffset,
          w * 0.75, h * (0.45 + i * 0.06) + yOffset,
          w * 1.1, h * (0.2 + i * 0.1) + yOffset,
        );

      final paint = Paint()
        ..color = colors[i].withValues(alpha: isDark ? 0.08 : 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 40 + i * 15.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(SAuroraPainter oldDelegate) =>
      colors != oldDelegate.colors ||
      phase != oldDelegate.phase ||
      isDark != oldDelegate.isDark;
}

/// Geometric accent — a rotated diamond/rhombus shape.
/// Use as a floating decorative element.
class SDiamondPainter extends CustomPainter {
  final Color color;
  final double rotation;
  final bool filled;

  SDiamondPainter({
    required this.color,
    this.rotation = math.pi / 4,
    this.filled = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(size.width, size.height) / 2.2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotation);

    final path = Path()
      ..moveTo(0, -r)
      ..lineTo(r, 0)
      ..lineTo(0, r)
      ..lineTo(-r, 0)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(SDiamondPainter oldDelegate) =>
      color != oldDelegate.color ||
      rotation != oldDelegate.rotation ||
      filled != oldDelegate.filled;
}

/// Corner gradient arc — a curved accent in one corner.
/// Typically placed top-right or bottom-left.
class SCornerArcPainter extends CustomPainter {
  final Color color;
  final double radius;
  final CornerPosition corner;

  SCornerArcPainter({
    required this.color,
    this.radius = 200,
    this.corner = CornerPosition.topRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset center;
    switch (corner) {
      case CornerPosition.topLeft:
        center = Offset.zero;
      case CornerPosition.topRight:
        center = Offset(size.width, 0);
      case CornerPosition.bottomLeft:
        center = Offset(0, size.height);
      case CornerPosition.bottomRight:
        center = Offset(size.width, size.height);
    }

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.15),
          color.withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(SCornerArcPainter oldDelegate) =>
      color != oldDelegate.color ||
      radius != oldDelegate.radius ||
      corner != oldDelegate.corner;
}

enum CornerPosition { topLeft, topRight, bottomLeft, bottomRight }

/// Noise-grain texture overlay for a premium matte finish.
/// Apply over gradients for added depth.
class SGrainPainter extends CustomPainter {
  final double opacity;
  final int density;

  SGrainPainter({this.opacity = 0.03, this.density = 3000});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(12345);
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);

    for (int i = 0; i < density; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(SGrainPainter oldDelegate) =>
      opacity != oldDelegate.opacity || density != oldDelegate.density;
}
