import 'dart:math';
import 'package:flutter/material.dart';

/// Responsive breakpoints and helpers for cross-platform layout.
class SResponsive {
  SResponsive._();

  // ──────────────── BREAKPOINTS ────────────────
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double widescreen = 1440;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tablet;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= tablet && w < desktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  static bool isWidescreen(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= widescreen;

  /// Returns 1 for mobile, 2 for tablet, 3+ for desktop grid columns.
  static int meetingGridColumns(BuildContext context, int participantCount) {
    if (isMobile(context)) return participantCount <= 2 ? 1 : 2;
    if (isTablet(context)) return min(participantCount, 3);
    return min(participantCount, 4);
  }

  /// Responsive value picker: returns mobile / tablet / desktop value.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// Screen width.
  static double width(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// Screen height.
  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// Horizontal page padding that adapts to screen size.
  static double pagePadding(BuildContext context) {
    if (isDesktop(context)) return 48.0;
    if (isTablet(context)) return 32.0;
    return 20.0;
  }

  /// Max content width constraint for large screens.
  static double maxContentWidth(BuildContext context) {
    if (isWidescreen(context)) return 1200;
    if (isDesktop(context)) return 960;
    return double.infinity;
  }
}

/// Responsive layout builder widget.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= SResponsive.desktop) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= SResponsive.tablet) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}
