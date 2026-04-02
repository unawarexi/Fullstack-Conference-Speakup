import 'package:flutter/material.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';

/// Animated floating action button for "New Meeting" / "Join".
class SFab extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? label;
  final bool extended;

  const SFab({
    super.key,
    this.onPressed,
    this.icon = Icons.add,
    this.label,
    this.extended = false,
  });

  @override
  Widget build(BuildContext context) {
    if (extended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        backgroundColor: SColors.primary,
        foregroundColor: Colors.white,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: SColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      child: Icon(icon),
    );
  }
}

/// Speed-dial style expandable FAB for meeting actions.
class SMeetingFab extends StatefulWidget {
  final VoidCallback? onNewMeeting;
  final VoidCallback? onJoinMeeting;
  final VoidCallback? onScheduleMeeting;

  const SMeetingFab({
    super.key,
    this.onNewMeeting,
    this.onJoinMeeting,
    this.onScheduleMeeting,
  });

  @override
  State<SMeetingFab> createState() => _SMeetingFabState();
}

class _SMeetingFabState extends State<SMeetingFab>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: SSizes.animNormal),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    _isOpen ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ScaleTransition(
          scale: _animation,
          alignment: Alignment.bottomRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MiniAction(
                label: 'Schedule',
                icon: Icons.calendar_today,
                onTap: () {
                  _toggle();
                  widget.onScheduleMeeting?.call();
                },
              ),
              const SizedBox(height: SSizes.sm),
              _MiniAction(
                label: 'Join',
                icon: Icons.login,
                onTap: () {
                  _toggle();
                  widget.onJoinMeeting?.call();
                },
              ),
              const SizedBox(height: SSizes.sm),
              _MiniAction(
                label: 'New Meeting',
                icon: Icons.videocam,
                onTap: () {
                  _toggle();
                  widget.onNewMeeting?.call();
                },
              ),
              const SizedBox(height: SSizes.md),
            ],
          ),
        ),
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: SColors.primary,
          foregroundColor: Colors.white,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: SSizes.animNormal),
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ],
    );
  }
}

class _MiniAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _MiniAction({
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SSizes.sm,
              vertical: SSizes.xs,
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        const SizedBox(width: SSizes.sm),
        FloatingActionButton.small(
          heroTag: label,
          onPressed: onTap,
          backgroundColor: isDark ? SColors.darkElevated : SColors.blue50,
          foregroundColor: SColors.primary,
          elevation: 2,
          child: Icon(icon, size: 20),
        ),
      ],
    );
  }
}
