import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

enum SToastType { success, error, warning, info }

/// Modern, compact overlay toast that sits just below the status bar.
class SToast {
  SToast._();

  static OverlayEntry? _current;

  /// Show a small pill toast just below the notch.
  static void show(
    BuildContext context, {
    required String message,
    SToastType type = SToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    _current?.remove();
    _current = null;

    final overlay = Overlay.of(context, rootOverlay: true);
    final topPad = MediaQuery.of(context).padding.top;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _SToastWidget(
        message: message,
        type: type,

        topPad: topPad,
        duration: duration,
        onDismiss: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }

  /// Alias kept for backward compat — same modern toast.
  static void showCustom(
    BuildContext context, {
    required String message,
    SToastType type = SToastType.info,
    Duration duration = const Duration(seconds: 3),
    dynamic gravity,
  }) {
    show(context, message: message, type: type, duration: duration);
  }
}

// ── Private animated toast widget ──────────────────────────────────────────

class _SToastWidget extends StatefulWidget {
  final String message;
  final SToastType type;
  final double topPad;
  final Duration duration;
  final VoidCallback onDismiss;

  const _SToastWidget({
    required this.message,
    required this.type,
    required this.topPad,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_SToastWidget> createState() => _SToastWidgetState();
}

class _SToastWidgetState extends State<_SToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.forward();

    Future.delayed(widget.duration, () {
      if (mounted) _dismiss();
    });
  }

  void _dismiss() async {
    await _ctrl.reverse();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (icon, accent) = _resolveStyle(widget.type);

    return Positioned(
      top: widget.topPad + SSizes.xs,
      left: SSizes.lg,
      right: SSizes.lg,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: GestureDetector(
            onVerticalDragEnd: (_) => _dismiss(),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(SSizes.radiusFull),
                  border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: accent, size: 15),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: accent,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static (IconData, Color) _resolveStyle(SToastType type) {
    return switch (type) {
      SToastType.success => (Icons.check_circle_rounded, SColors.success),
      SToastType.error => (Icons.error_rounded, SColors.error),
      SToastType.warning => (Icons.warning_rounded, SColors.warning),
      SToastType.info => (Icons.info_rounded, SColors.primary),
    };
  }
}
