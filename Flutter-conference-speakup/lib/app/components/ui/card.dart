import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

/// Premium card with Cupertino-style press scale and haptic feedback.
class SCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final bool hasBorder;
  final bool hasShadow;

  const SCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.hasBorder = false,
    this.hasShadow = false,
  });

  @override
  State<SCard> createState() => _SCardState();
}

class _SCardState extends State<SCard> {
  bool _pressed = false;

  bool get _interactive => widget.onTap != null || widget.onLongPress != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        widget.backgroundColor ?? (isDark ? SColors.darkCard : SColors.lightCard);
    final radius = widget.borderRadius ?? SSizes.radiusMd;

    final card = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Container(
        padding: widget.padding ?? const EdgeInsets.all(SSizes.cardPadding),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          border: widget.hasBorder
              ? Border.all(
                  color: isDark ? SColors.darkBorder : SColors.lightBorder,
                )
              : null,
          boxShadow: widget.hasShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: widget.child,
      ),
    );

    if (!_interactive) return card;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      onLongPress: widget.onLongPress != null
          ? () {
              HapticFeedback.mediumImpact();
              widget.onLongPress?.call();
            }
          : null,
      child: card,
    );
  }
}

/// Meeting card for upcoming / past meetings list.
class SMeetingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final int participantCount;
  final bool isLive;
  final VoidCallback? onTap;

  const SMeetingCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    this.participantCount = 0,
    this.isLive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SCard(
      onTap: onTap,
      hasBorder: true,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: isLive ? SColors.success : SColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: SSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SSizes.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: SColors.success,
                          borderRadius:
                              BorderRadius.circular(SSizes.radiusFull),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: SSizes.xs),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? SColors.textDarkSecondary
                            : SColors.textLightSecondary,
                      ),
                ),
                const SizedBox(height: SSizes.xs),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 14,
                        color: isDark
                            ? SColors.textDarkTertiary
                            : SColors.textLightTertiary),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? SColors.textDarkTertiary
                            : SColors.textLightTertiary,
                      ),
                    ),
                    if (participantCount > 0) ...[
                      const SizedBox(width: SSizes.md),
                      Icon(Icons.people_outline,
                          size: 14,
                          color: isDark
                              ? SColors.textDarkTertiary
                              : SColors.textLightTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '$participantCount',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? SColors.textDarkTertiary
                              : SColors.textLightTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
