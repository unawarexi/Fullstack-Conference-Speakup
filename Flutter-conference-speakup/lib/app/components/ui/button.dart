import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

enum SButtonVariant { primary, secondary, outline, ghost, danger }
enum SButtonSize { sm, md, lg }

class SButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final SButtonVariant variant;
  final SButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? child;

  const SButton({
    super.key,
    this.text = '',
    this.onPressed,
    this.variant = SButtonVariant.primary,
    this.size = SButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = switch (size) {
      SButtonSize.sm => SSizes.buttonHeightSm,
      SButtonSize.md => SSizes.buttonHeightMd,
      SButtonSize.lg => SSizes.buttonHeightLg,
    };
    final fontSize = switch (size) {
      SButtonSize.sm => 13.0,
      SButtonSize.md => 15.0,
      SButtonSize.lg => 17.0,
    };

    final (bg, fg, border) = _resolveColors(isDark);

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
            side: border != null
                ? BorderSide(color: border)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: SSizes.md),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(fg),
                ),
              )
            : child ??
                Row(
                  mainAxisSize:
                      isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (prefixIcon != null) ...[
                      Icon(prefixIcon, size: fontSize + 2),
                      const SizedBox(width: SSizes.sm),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (suffixIcon != null) ...[
                      const SizedBox(width: SSizes.sm),
                      Icon(suffixIcon, size: fontSize + 2),
                    ],
                  ],
                ),
      ),
    );
  }

  (Color bg, Color fg, Color? border) _resolveColors(bool isDark) {
    return switch (variant) {
      SButtonVariant.primary => (
          SColors.primary,
          Colors.white,
          null,
        ),
      SButtonVariant.secondary => (
          isDark ? SColors.darkElevated : SColors.lightElevated,
          isDark ? SColors.textDark : SColors.textLight,
          null,
        ),
      SButtonVariant.outline => (
          Colors.transparent,
          isDark ? SColors.textDark : SColors.textLight,
          isDark ? SColors.darkBorder : SColors.lightBorder,
        ),
      SButtonVariant.ghost => (
          Colors.transparent,
          isDark ? SColors.textDark : SColors.textLight,
          null,
        ),
      SButtonVariant.danger => (
          SColors.error,
          Colors.white,
          null,
        ),
    };
  }
}

/// Icon-only circular button (meeting controls).
class SIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;

  const SIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        backgroundColor ?? (isDark ? SColors.darkElevated : SColors.lightElevated);
    final fg =
        iconColor ?? (isDark ? SColors.textDark : SColors.textLight);

    final button = Material(
      color: bg,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: fg, size: size * 0.45),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
