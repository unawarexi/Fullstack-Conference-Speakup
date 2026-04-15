import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';

/// Responsive breakpoints and helpers for cross-platform layout.
class SResponsive {
  SResponsive._();

  // ──────────────── BREAKPOINTS ────────────────
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double widescreen = 1440;

  // ──────────────── REFERENCE DESIGN WIDTH ────────────────
  /// The width of the design mockup (iPhone 14 / 390-pt).
  static const double _designWidth = 390;

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

  // ──────────────── SCALE FACTOR ────────────────
  /// A multiplier relative to the design width, clamped to avoid
  /// absurdly large or tiny results on extreme screen sizes.
  /// On mobile this scales proportionally to the device width;
  /// on tablet/desktop it is capped at 1.0 so content stays readable
  /// without growing too large.
  static double scaleFactor(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= desktop) return 1.0;
    return (w / _designWidth).clamp(0.8, 1.0);
  }

  /// Scale a pixel value relative to the design width.
  /// Useful for font sizes, icon sizes, fixed containers.
  /// On desktop the value is returned as-is (or with a tablet/desktop
  /// override if provided).
  static double sp(
    BuildContext context,
    double size, {
    double? tabletSize,
    double? desktopSize,
  }) {
    if (isDesktop(context)) return desktopSize ?? tabletSize ?? size;
    if (isTablet(context)) return tabletSize ?? size;
    return size * scaleFactor(context);
  }

  /// Responsive grid column count based on screen width.
  static int gridColumns(BuildContext context,
      {int mobileCols = 1, int tabletCols = 2, int desktopCols = 3}) {
    if (isDesktop(context)) return desktopCols;
    if (isTablet(context)) return tabletCols;
    return mobileCols;
  }

  /// Fraction of screen width, handy for proportional widths.
  static double widthFraction(BuildContext context, double fraction) =>
      MediaQuery.sizeOf(context).width * fraction;

  /// Fraction of screen height.
  static double heightFraction(BuildContext context, double fraction) =>
      MediaQuery.sizeOf(context).height * fraction;
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

/// A scaffold wrapper that constrains content to [SResponsive.maxContentWidth]
/// on large screens, centers it, and uses responsive page padding.
/// Drop-in replacement for the common Scaffold + ListView pattern.
class ResponsiveScaffold extends StatelessWidget {
  final String? title;
  final PreferredSizeWidget? appBar;
  final List<Widget> slivers;
  final Widget? body;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final Future<void> Function()? onRefresh;

  const ResponsiveScaffold({
    super.key,
    this.title,
    this.appBar,
    this.slivers = const [],
    this.body,
    this.floatingActionButton,
    this.backgroundColor,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxWidth = SResponsive.maxContentWidth(context);
    final hPad = SResponsive.pagePadding(context);

    final effectiveAppBar = appBar ??
        (title != null
            ? AppBar(
                title: Text(title!),
                backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
                surfaceTintColor: Colors.transparent,
              )
            : null);

    Widget content;
    if (body != null) {
      content = body!;
    } else {
      final scrollView = CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(slivers),
            ),
          ),
        ],
      );
      content = onRefresh != null
          ? RefreshIndicator(onRefresh: onRefresh!, child: scrollView)
          : scrollView;
    }

    return Scaffold(
      backgroundColor: backgroundColor ??
          (isDark ? SColors.darkBg : SColors.lightBg),
      appBar: effectiveAppBar,
      floatingActionButton: floatingActionButton,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: content,
        ),
      ),
    );
  }
}

/// Lightweight wrapper that constrains + centers any body widget on
/// tablet / desktop.  Keeps mobile full-width.
/// Usage:  `body: ResponsiveBody(child: ListView(...))`
class ResponsiveBody extends StatelessWidget {
  final Widget child;
  const ResponsiveBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final maxWidth = SResponsive.maxContentWidth(context);
    if (maxWidth == double.infinity) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
