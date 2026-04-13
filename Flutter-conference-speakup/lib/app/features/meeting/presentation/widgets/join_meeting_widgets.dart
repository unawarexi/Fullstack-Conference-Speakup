import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

class JoinActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Gradient? gradient;
  final Color? color;
  final Color? borderColor;
  final Color textColor;
  final Color? iconColor;
  final bool isLoading;
  final VoidCallback? onTap;

  const JoinActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    this.gradient,
    this.color,
    this.borderColor,
    required this.textColor,
    this.iconColor,
    this.isLoading = false,
    this.onTap,
  });

  @override
  State<JoinActionCard> createState() => _JoinActionCardState();
}

class _JoinActionCardState extends State<JoinActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            color: widget.gradient == null ? widget.color : null,
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!, width: 0.5)
                : null,
            boxShadow: widget.gradient != null
                ? [
                    BoxShadow(
                      color: SColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: widget.isLoading
              ? SizedBox(
                  height: 44,
                  child: Center(
                    child: CupertinoActivityIndicator(
                      color: widget.textColor,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(widget.icon,
                        color: widget.iconColor ?? widget.textColor,
                        size: 24),
                    const SizedBox(height: 10),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: widget.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class JoinCompactToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback? onTap;

  const JoinCompactToggle({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: isActive
                ? SColors.primary.withValues(alpha: 0.1)
                : (isDark ? SColors.darkElevated : SColors.lightElevated),
            borderRadius: BorderRadius.circular(SSizes.radiusSm),
            border: Border.all(
              color: isActive
                  ? SColors.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: isActive
                      ? SColors.primary
                      : (isDark
                          ? SColors.textDarkTertiary
                          : SColors.textLightTertiary)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? SColors.primary
                      : (isDark
                          ? SColors.textDarkSecondary
                          : SColors.textLightSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
