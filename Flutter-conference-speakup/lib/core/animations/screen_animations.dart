import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  Reusable animation presets for screens.
//  Each preset bundles a controller with its
//  driven animations as a single disposable unit.
// ─────────────────────────────────────────────

/// Sheet / panel that slides up and fades in.
/// Used by: Login bottom sheet, any modal-style reveal.
class SheetRevealAnim {
  late final AnimationController controller;
  late final Animation<Offset> slide;
  late final Animation<double> fade;

  SheetRevealAnim({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 800),
    Offset beginOffset = const Offset(0, 0.15),
    Curve slideCurve = Curves.easeOutCubic,
    double fadeEnd = 0.7,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);
    slide = Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: controller, curve: slideCurve),
    );
    fade = CurvedAnimation(
      parent: controller,
      curve: Interval(0.0, fadeEnd, curve: Curves.easeOut),
    );
  }

  void forward() => controller.forward();
  void dispose() => controller.dispose();
}

/// Brand emblem entrance: scale-up + fade-in + subtle rotation.
/// Used by: Splash screen emblem.
class BrandRevealAnim {
  late final AnimationController controller;
  late final Animation<double> scale;
  late final Animation<double> fade;
  late final Animation<double> rotation;

  BrandRevealAnim({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 900),
    double scaleBegin = 0.3,
    double rotationBegin = -0.05,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);
    scale = Tween<double>(begin: scaleBegin, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
    );
    fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    rotation = Tween<double>(begin: rotationBegin, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );
  }

  void forward() => controller.forward();
  void dispose() => controller.dispose();
}

/// Content that slides up and fades in simultaneously.
/// Used by: Splash logo text, onboarding content transitions.
class SlideUpFadeAnim {
  late final AnimationController controller;
  late final Animation<double> fade;
  late final Animation<Offset> slide;

  SlideUpFadeAnim({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 700),
    Offset beginOffset = const Offset(0, 0.4),
    Curve slideCurve = Curves.easeOutCubic,
    Curve fadeCurve = Curves.easeOut,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);
    fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: fadeCurve),
    );
    slide = Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: controller, curve: slideCurve),
    );
  }

  void forward() => controller.forward();
  void reset() => controller.reset();
  void dispose() => controller.dispose();
}

/// Ambient glow pulse (0 → 1 ease-in-out).
/// Used by: Splash glow ring behind emblem.
class GlowPulseAnim {
  late final AnimationController controller;
  late final Animation<double> value;

  GlowPulseAnim({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 1800),
    Curve curve = Curves.easeInOut,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);
    value = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  void forward() => controller.forward();
  void dispose() => controller.dispose();
}

/// Simple fade (0 → 1).
/// Used by: Splash tagline, onboarding content fade.
class FadeInAnim {
  late final AnimationController controller;
  late final Animation<double> fade;

  FadeInAnim({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeOut,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);
    fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  void forward() => controller.forward();
  void reset() => controller.reset();
  void dispose() => controller.dispose();
}

/// Screen exit: fade-out + slight scale-up.
/// Used by: Splash screen exit transition.
class ExitAnim {
  late final AnimationController controller;
  late final Animation<double> fade;
  late final Animation<double> scale;

  ExitAnim({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 400),
    double scaleEnd = 1.1,
    Curve curve = Curves.easeIn,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);
    fade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
    scale = Tween<double>(begin: 1.0, end: scaleEnd).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  Future<void> forward() => controller.forward().orCancel.catchError((_) {});
  void dispose() => controller.dispose();
}
