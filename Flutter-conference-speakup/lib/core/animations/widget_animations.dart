import 'package:flutter/material.dart';

/// Pre-built widget animations for consistent motion design.
class SWidgetAnimations {
  SWidgetAnimations._();

  /// Fade-in from transparent.
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Duration delay = Duration.zero,
  }) =>
      _DelayedAnimation(
        delay: delay,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: duration,
          builder: (_, value, child) => Opacity(opacity: value, child: child),
          child: child,
        ),
      );

  /// Scale-in from 0.8 → 1.0.
  static Widget scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 350),
  }) =>
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1),
        duration: duration,
        curve: Curves.easeOutBack,
        builder: (_, value, child) =>
            Transform.scale(scale: value, child: child),
        child: child,
      );

  /// Slide-in from bottom.
  static Widget slideUp({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    double offsetY = 30,
  }) =>
      TweenAnimationBuilder<Offset>(
        tween: Tween(begin: Offset(0, offsetY), end: Offset.zero),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (_, value, child) =>
            Transform.translate(offset: value, child: child),
        child: child,
      );
}

class _DelayedAnimation extends StatefulWidget {
  final Duration delay;
  final Widget child;

  const _DelayedAnimation({required this.delay, required this.child});

  @override
  State<_DelayedAnimation> createState() => _DelayedAnimationState();
}

class _DelayedAnimationState extends State<_DelayedAnimation> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _show = true;
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) setState(() => _show = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) =>
      _show ? widget.child : const SizedBox.shrink();
}
