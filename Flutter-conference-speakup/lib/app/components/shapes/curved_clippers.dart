import 'dart:math' as math;
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════
//  SpeakUp Custom Clippers
//  Reusable CustomClipper<Path> shapes for
//  AppBars, cards, containers, and overlays.
// ═══════════════════════════════════════════════

/// Smooth concave wave cut at the bottom of a container.
/// Perfect for hero headers and collapsing app bars.
///
/// ```
/// ClipPath(
///   clipper: SWaveClipper(waveDepth: 30),
///   child: Container(color: Colors.blue),
/// )
/// ```
class SWaveClipper extends CustomClipper<Path> {
  final double waveDepth;
  final double wavePhase;

  SWaveClipper({this.waveDepth = 28, this.wavePhase = 0.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.lineTo(0, h - waveDepth);

    // Smooth sine-like wave using two quadratic segments
    path.quadraticBezierTo(
      w * 0.25 + wavePhase, h,
      w * 0.5, h - waveDepth * 0.6,
    );
    path.quadraticBezierTo(
      w * 0.75 - wavePhase, h - waveDepth * 1.3,
      w, h - waveDepth * 0.3,
    );

    path.lineTo(w, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(SWaveClipper oldClipper) =>
      waveDepth != oldClipper.waveDepth || wavePhase != oldClipper.wavePhase;
}

/// Diagonal slice — a clean angular cut at the bottom.
///
/// [angle] – height delta from left to right (positive = slopes down-right).
class SDiagonalClipper extends CustomClipper<Path> {
  final double angle;
  final bool reverse;

  SDiagonalClipper({this.angle = 40, this.reverse = false});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    if (reverse) {
      path.lineTo(0, h);
      path.lineTo(w, h - angle);
      path.lineTo(w, 0);
    } else {
      path.lineTo(0, h - angle);
      path.lineTo(w, h);
      path.lineTo(w, 0);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(SDiagonalClipper oldClipper) =>
      angle != oldClipper.angle || reverse != oldClipper.reverse;
}

/// Organic blob-like shape using cubic Bezier curves.
/// Great for avatar backgrounds and floating accents.
///
/// [morphFactor] 0.0–1.0 controls how "blobby" it is.
class SBlobClipper extends CustomClipper<Path> {
  final double morphFactor;

  SBlobClipper({this.morphFactor = 0.5});

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final m = morphFactor.clamp(0.0, 1.0);

    final path = Path();
    path.moveTo(w * 0.5, 0);

    // Top-right bulge
    path.cubicTo(
      w * (0.75 + m * 0.1), h * 0.02,
      w * (1.0 + m * 0.05), h * (0.25 - m * 0.05),
      w, h * 0.45,
    );
    // Bottom-right
    path.cubicTo(
      w * (1.0 - m * 0.08), h * (0.7 + m * 0.05),
      w * (0.85 + m * 0.05), h * (0.95 + m * 0.02),
      w * 0.55, h,
    );
    // Bottom-left
    path.cubicTo(
      w * (0.25 - m * 0.08), h * (1.0 + m * 0.02),
      w * (-0.05 + m * 0.03), h * (0.7 + m * 0.08),
      0, h * 0.5,
    );
    // Top-left
    path.cubicTo(
      w * (0.02 - m * 0.02), h * (0.2 - m * 0.05),
      w * (0.2 - m * 0.05), h * (-0.02 + m * 0.01),
      w * 0.5, 0,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(SBlobClipper oldClipper) =>
      morphFactor != oldClipper.morphFactor;
}

/// Multi-wave ribbon — stacks 2 overlapping sine curves.
/// Use as a decorative bottom edge on a header.
class SDoubleWaveClipper extends CustomClipper<Path> {
  final double amplitude;

  SDoubleWaveClipper({this.amplitude = 20});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.lineTo(0, h - amplitude * 2);

    // Primary wave
    for (double x = 0; x <= w; x++) {
      final y = h - amplitude * 2 +
          math.sin(x / w * 2 * math.pi) * amplitude +
          math.sin(x / w * 4 * math.pi) * (amplitude * 0.3);
      path.lineTo(x, y);
    }

    path.lineTo(w, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(SDoubleWaveClipper oldClipper) =>
      amplitude != oldClipper.amplitude;
}

/// Rounded arch — convex bulge at the bottom.
/// Good for profile header sections.
class SArchClipper extends CustomClipper<Path> {
  final double archHeight;

  SArchClipper({this.archHeight = 40});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.lineTo(0, h - archHeight);
    path.quadraticBezierTo(w / 2, h + archHeight * 0.5, w, h - archHeight);
    path.lineTo(w, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(SArchClipper oldClipper) =>
      archHeight != oldClipper.archHeight;
}

/// Liquid edge with 3 control-point cubic curves.
/// Looks like a fluid, organic container bottom.
class SLiquidClipper extends CustomClipper<Path> {
  final double intensity;

  SLiquidClipper({this.intensity = 1.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final i = intensity.clamp(0.5, 2.0);

    path.lineTo(0, h - 35 * i);

    path.cubicTo(
      w * 0.15, h - 10 * i,
      w * 0.3, h + 5 * i,
      w * 0.5, h - 20 * i,
    );
    path.cubicTo(
      w * 0.7, h - 45 * i,
      w * 0.85, h - 5 * i,
      w, h - 30 * i,
    );

    path.lineTo(w, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(SLiquidClipper oldClipper) =>
      intensity != oldClipper.intensity;
}

/// A widget that wraps its child with the [SLiquidClipper] organic shape
/// and optionally blends the decorative background into the layer below
/// using a full-height gradient overlay.
///
/// When [blendBase] is `false` (default), the child is hard-clipped with
/// the liquid shape.
///
/// When [blendBase] is `true`, the child is rendered **without** clipping
/// as a full background. A gradient overlay sits on top — transparent at
/// the top (exposing the decorative curves) and solid [blendColor] /
/// scaffold bg at the bottom, so the shapes naturally dissolve into the
/// card layer beneath. Use [foreground] to place content (text, avatars)
/// above the gradient veil so it stays fully visible.
///
/// ```dart
/// SLiquidShape(
///   blendBase: true,
///   isDark: isDark,
///   foreground: MyContent(),
///   child: MyDecorativeBackground(),
/// )
/// ```
class SLiquidShape extends StatelessWidget {
  final double intensity;
  final bool blendBase;
  final bool isDark;
  final Color? blendColor;
  final Widget? foreground;
  final Widget child;

  const SLiquidShape({
    super.key,
    this.intensity = 1.0,
    this.blendBase = false,
    this.isDark = true,
    this.blendColor,
    this.foreground,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!blendBase) {
      return ClipPath(
        clipper: SLiquidClipper(intensity: intensity),
        child: child,
      );
    }

    final bg = blendColor ??
        (isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF8F9FC));

    return Stack(
      children: [
        // Background decorative layer — no clip, fills entire area
        Positioned.fill(child: child),

        // Gradient veil — transparent at top, solid bg at bottom
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 0.65, 1.0],
                  colors: [
                    bg.withValues(alpha: 0.0),
                    bg.withValues(alpha: 0.15),
                    bg.withValues(alpha: 0.7),
                    bg,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Foreground content — above the gradient veil
        if (foreground != null) foreground!,
      ],
    );
  }
}
