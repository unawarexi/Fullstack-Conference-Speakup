import 'package:flutter/material.dart';
import 'package:video_confrence_app/core/constants/colors.dart';

/// Pulsing dot indicator (e.g. recording, live).
class SPulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const SPulsingDot({
    super.key,
    this.color = SColors.error,
    this.size = 10,
  });

  @override
  State<SPulsingDot> createState() => _SPulsingDotState();
}

class _SPulsingDotState extends State<SPulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_ctrl),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Three-dot typing indicator for chat.
class STypingIndicator extends StatefulWidget {
  const STypingIndicator({super.key});

  @override
  State<STypingIndicator> createState() => _STypingIndicatorState();
}

class _STypingIndicatorState extends State<STypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          listenable: _ctrl,
          builder: (_, __) {
            final delay = i * 0.2;
            final value = (_ctrl.value - delay).clamp(0.0, 1.0);
            final offset = -4 * (1 - (2 * value - 1).abs());
            return Transform.translate(
              offset: Offset(0, offset),
              child: Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isDark ? SColors.darkMuted : SColors.lightMuted,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Animated builder helper (since AnimatedBuilder is just a builder widget).
class AnimatedBuilder extends AnimatedWidget {
  final TransitionBuilder builder;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) => builder(context, null);
}

/// Full-page spinner.
class SPageSpinner extends StatelessWidget {
  const SPageSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: SColors.primary),
      ),
    );
  }
}
