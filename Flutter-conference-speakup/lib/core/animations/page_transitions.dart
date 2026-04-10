import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared route / page transition animations.
class SAnimations {
  SAnimations._();

  static const defaultDuration = Duration(milliseconds: 300);
  static const fastDuration = Duration(milliseconds: 150);
  static const slowDuration = Duration(milliseconds: 500);

  static const defaultCurve = Curves.easeInOut;
  static const bounceCurve = Curves.elasticOut;

  /// Fade transition for GoRouter page builder.
  static CustomTransitionPage<T> fadeTransition<T>({
    required Widget child,
    required GoRouterState state,
  }) =>
      CustomTransitionPage<T>(
        key: state.pageKey,
        child: child,
        transitionsBuilder: (_, animation, _, widget) =>
            FadeTransition(opacity: animation, child: widget),
      );

  /// Slide-up transition (for modals / bottom sheets).
  static CustomTransitionPage<T> slideUpTransition<T>({
    required Widget child,
    required GoRouterState state,
  }) =>
      CustomTransitionPage<T>(
        key: state.pageKey,
        child: child,
        transitionsBuilder: (_, animation, _, widget) {
          final tween =
              Tween(begin: const Offset(0, 1), end: Offset.zero)
                  .chain(CurveTween(curve: defaultCurve));
          return SlideTransition(
              position: animation.drive(tween), child: widget);
        },
      );
}

