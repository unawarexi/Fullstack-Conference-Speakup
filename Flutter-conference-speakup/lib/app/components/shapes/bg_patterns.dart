import 'dart:math' as math;
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════
//  SpeakUp Background Patterns
//  CustomPainter-based decorative backgrounds
//  for headers, cards, and full-screen overlays.
// ═══════════════════════════════════════════════

/// Floating gradient orbs — soft, blurred circles that layer
/// behind content. Use with [CustomPaint] or in a [Stack].
///
/// ```dart
/// CustomPaint(
///   painter: SOrbFieldPainter(
///     colors: [SColors.primary, SColors.screenShare],
///     orbCount: 5,
///     isDark: true,
///   ),
///   child: yourContent,
/// )
/// ```
class SOrbFieldPainter extends CustomPainter {
  final List<Color> colors;
  final int orbCount;
  final bool isDark;
  final double seed;

  SOrbFieldPainter({
    required this.colors,
    this.orbCount = 5,
    this.isDark = true,
    this.seed = 42,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed.toInt());

    for (int i = 0; i < orbCount; i++) {
      final color = colors[i % colors.length];
      final radius = size.width * (0.15 + rng.nextDouble() * 0.25);
      final cx = size.width * rng.nextDouble();
      final cy = size.height * rng.nextDouble();

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: isDark ? 0.12 : 0.08),
            color.withValues(alpha: 0),
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(SOrbFieldPainter oldDelegate) =>
      colors != oldDelegate.colors ||
      orbCount != oldDelegate.orbCount ||
      isDark != oldDelegate.isDark ||
      seed != oldDelegate.seed;
}

/// Dot grid — a subtle matrix of evenly-spaced dots.
/// Common in modern SaaS dashboards and hero sections.
class SDotGridPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double dotRadius;

  SDotGridPainter({
    required this.dotColor,
    this.spacing = 24,
    this.dotRadius = 1.2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SDotGridPainter oldDelegate) =>
      dotColor != oldDelegate.dotColor ||
      spacing != oldDelegate.spacing ||
      dotRadius != oldDelegate.dotRadius;
}

/// Concentric ripple rings — radiating from a focal point.
/// Perfect behind avatars or as a subtle "pulse" background.
class SRippleRingsPainter extends CustomPainter {
  final Color color;
  final int ringCount;
  final Offset center;
  final double maxRadius;
  final double strokeWidth;

  SRippleRingsPainter({
    required this.color,
    this.ringCount = 4,
    this.center = Offset.zero,
    this.maxRadius = 150,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final origin = center == Offset.zero
        ? Offset(size.width / 2, size.height / 2)
        : center;

    for (int i = 1; i <= ringCount; i++) {
      final fraction = i / ringCount;
      final radius = maxRadius * fraction;
      final alpha = (1.0 - fraction) * 0.25;

      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawCircle(origin, radius, paint);
    }
  }

  @override
  bool shouldRepaint(SRippleRingsPainter oldDelegate) =>
      color != oldDelegate.color ||
      ringCount != oldDelegate.ringCount ||
      maxRadius != oldDelegate.maxRadius;
}

/// Topographic / contour lines — organic layered waves.
/// Gives a premium, generative-art feel.
class STopographyPainter extends CustomPainter {
  final Color lineColor;
  final int lineCount;
  final double seed;

  STopographyPainter({
    required this.lineColor,
    this.lineCount = 8,
    this.seed = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed.toInt());
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int i = 0; i < lineCount; i++) {
      final path = Path();
      final baseY = size.height * (i + 1) / (lineCount + 1);
      final amplitude = 10.0 + rng.nextDouble() * 20;
      final frequency = 1.5 + rng.nextDouble() * 1.5;
      final phase = rng.nextDouble() * math.pi * 2;

      path.moveTo(0, baseY);

      for (double x = 0; x <= size.width; x += 2) {
        final y = baseY +
            math.sin((x / size.width) * frequency * math.pi * 2 + phase) *
                amplitude;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(STopographyPainter oldDelegate) =>
      lineColor != oldDelegate.lineColor ||
      lineCount != oldDelegate.lineCount ||
      seed != oldDelegate.seed;
}

/// Hexagonal mesh — a subtle honeycomb overlay.
/// Used for tech-forward, conference-style branding.
class SHexMeshPainter extends CustomPainter {
  final Color strokeColor;
  final double hexSize;

  SHexMeshPainter({
    required this.strokeColor,
    this.hexSize = 30,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final hGap = hexSize * 1.5;
    final vGap = hexSize * math.sqrt(3);

    int row = 0;
    for (double y = -vGap; y < size.height + vGap; y += vGap / 2) {
      final xOffset = (row % 2 == 0) ? 0.0 : hGap / 2;
      for (double x = -hGap + xOffset; x < size.width + hGap; x += hGap) {
        _drawHex(canvas, Offset(x, y), hexSize * 0.5, paint);
      }
      row++;
    }
  }

  void _drawHex(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 6;
      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SHexMeshPainter oldDelegate) =>
      strokeColor != oldDelegate.strokeColor ||
      hexSize != oldDelegate.hexSize;
}

// ═══════════════════════════════════════════════
//  Convenience Widgets
// ═══════════════════════════════════════════════

/// A [Stack] wrapper that renders a pattern behind [child].
/// Automatically sizes to fill its parent.
///
/// ```dart
/// SPatternBackground(
///   painter: SDotGridPainter(dotColor: SColors.primary.withValues(alpha:0.1)),
///   child: YourWidget(),
/// )
/// ```
class SPatternBackground extends StatelessWidget {
  final CustomPainter painter;
  final Widget child;

  const SPatternBackground({
    super.key,
    required this.painter,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: painter),
        ),
        child,
      ],
    );
  }
}
