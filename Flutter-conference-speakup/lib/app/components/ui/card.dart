import 'package:flutter/material.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';

/// Versatile card component for meetings list, chat previews, settings rows, etc.
class SCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        backgroundColor ?? (isDark ? SColors.darkCard : SColors.lightCard);
    final radius = borderRadius ?? SSizes.radiusMd;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      elevation: hasShadow ? 2 : 0,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: padding ?? const EdgeInsets.all(SSizes.cardPadding),
          decoration: hasBorder
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: isDark ? SColors.darkBorder : SColors.lightBorder,
                  ),
                )
              : null,
          child: child,
        ),
      ),
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
