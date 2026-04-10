import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

// ============================================================================
// DENSE SECTION HEADER — compact "title + action" row
// ============================================================================
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: SSizes.sm),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? SColors.textDark : SColors.textLight,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (actionLabel != null || actionIcon != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (actionLabel != null)
                    Text(
                      actionLabel!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: SColors.primary,
                      ),
                    ),
                  if (actionIcon != null) ...[
                    const SizedBox(width: 2),
                    Icon(actionIcon, size: 14, color: SColors.primary),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// DENSE LIST TILE — compact info row with icon, title, subtitle, trailing
// ============================================================================
class DenseTile extends StatefulWidget {
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool hasDivider;

  const DenseTile({
    super.key,
    this.icon,
    this.iconColor,
    this.iconBgColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.showChevron = false,
    this.hasDivider = false,
  });

  @override
  State<DenseTile> createState() => _DenseTileState();
}

class _DenseTileState extends State<DenseTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        GestureDetector(
          onTapDown: widget.onTap != null
              ? (_) => setState(() => _pressed = true)
              : null,
          onTapUp: widget.onTap != null
              ? (_) {
                  setState(() => _pressed = false);
                  HapticFeedback.selectionClick();
                  widget.onTap?.call();
                }
              : null,
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            decoration: BoxDecoration(
              color: _pressed
                  ? (isDark ? SColors.darkHover : SColors.lightHover)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(SSizes.radiusSm),
            ),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 12),
                ] else if (widget.icon != null) ...[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: widget.iconBgColor ??
                          (isDark
                              ? SColors.darkElevated
                              : SColors.lightElevated),
                      borderRadius: BorderRadius.circular(SSizes.radiusSm),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 17,
                      color: widget.iconColor ??
                          (isDark
                              ? SColors.textDarkSecondary
                              : SColors.textLightSecondary),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              isDark ? SColors.textDark : SColors.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? SColors.textDarkTertiary
                                : SColors.textLightTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: 8),
                  widget.trailing!,
                ],
                if (widget.showChevron) ...[
                  const SizedBox(width: 4),
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: 14,
                    color: isDark
                        ? SColors.textDarkTertiary
                        : SColors.textLightTertiary,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (widget.hasDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: widget.icon != null ? 50 : 0,
            color: isDark ? SColors.darkBorder : SColors.lightBorder,
          ),
      ],
    );
  }
}

// ============================================================================
// STAT CARD — compact metric display
// ============================================================================
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? change;
  final bool isPositive;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = SColors.primary,
    this.change,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? SColors.darkCard : SColors.lightCard,
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
        border: Border.all(
          color: isDark ? SColors.darkBorder : SColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const Spacer(),
              if (change != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isPositive ? SColors.success : SColors.error)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(SSizes.radiusFull),
                  ),
                  child: Text(
                    change!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isPositive ? SColors.success : SColors.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? SColors.textDark : SColors.textLight,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? SColors.textDarkTertiary
                  : SColors.textLightTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CHIP — compact tag / filter chip
// ============================================================================
class SChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? color;

  const SChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipColor = color ?? SColors.primary;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.15)
              : (isDark ? SColors.darkElevated : SColors.lightElevated),
          borderRadius: BorderRadius.circular(SSizes.radiusFull),
          border: Border.all(
            color: isSelected
                ? chipColor.withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: isSelected ? chipColor : (isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? chipColor
                    : (isDark
                        ? SColors.textDarkSecondary
                        : SColors.textLightSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// AVATAR — compact user avatar with online indicator
// ============================================================================
class SAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool showOnline;
  final bool isOnline;

  const SAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 36,
    this.showOnline = false,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = name.isNotEmpty
        ? name.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase()
        : '?';
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor:
                isDark ? SColors.darkElevated : SColors.lightElevated,
            backgroundImage:
                imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null
                ? Text(
                    initials,
                    style: TextStyle(
                      fontSize: size * 0.38,
                      fontWeight: FontWeight.w600,
                      color: SColors.primary,
                    ),
                  )
                : null,
          ),
          if (showOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: isOnline ? SColors.success : SColors.darkMuted,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? SColors.darkBg : SColors.lightBg,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// STATUS BADGE — live / scheduled / ended
// ============================================================================
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool pulse;

  const StatusBadge({
    super.key,
    required this.label,
    this.color = SColors.success,
    this.pulse = false,
  });

  factory StatusBadge.live() =>
      const StatusBadge(label: 'LIVE', color: SColors.error, pulse: true);
  factory StatusBadge.scheduled() =>
      const StatusBadge(label: 'Scheduled', color: SColors.primary);
  factory StatusBadge.ended() =>
      const StatusBadge(label: 'Ended', color: SColors.darkMuted);
  factory StatusBadge.recording() =>
      const StatusBadge(label: 'REC', color: SColors.error, pulse: true);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(SSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pulse) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EMPTY STATE — placeholder with icon and message
// ============================================================================
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subMessage;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.subMessage,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? SColors.darkElevated : SColors.lightElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 26,
                color: isDark
                    ? SColors.textDarkTertiary
                    : SColors.textLightTertiary,
              ),
            ),
            const SizedBox(height: SSizes.md),
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? SColors.textDark : SColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                subMessage!,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? SColors.textDarkTertiary
                      : SColors.textLightTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: SSizes.md),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: SColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SEARCH BAR — compact iOS-style search
// ============================================================================
class SSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;

  const SSearchBar({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: readOnly ? onTap : null,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? SColors.darkElevated : SColors.lightElevated,
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          readOnly: readOnly,
          autofocus: autofocus,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? SColors.textDark : SColors.textLight,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: isDark
                  ? SColors.textDarkTertiary
                  : SColors.textLightTertiary,
            ),
            prefixIcon: Icon(
              CupertinoIcons.search,
              size: 17,
              color: isDark
                  ? SColors.textDarkTertiary
                  : SColors.textLightTertiary,
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 38, minHeight: 38),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 9),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TOGGLE ROW — settings toggle with label
// ============================================================================
class ToggleRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  const ToggleRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDark ? SColors.darkElevated : SColors.lightElevated,
                borderRadius: BorderRadius.circular(SSizes.radiusSm),
              ),
              child: Icon(
                icon,
                size: 17,
                color: isDark
                    ? SColors.textDarkSecondary
                    : SColors.textLightSecondary,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? SColors.textDark : SColors.textLight,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
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
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: SColors.primary,
          ),
        ],
      ),
    );
  }
}
