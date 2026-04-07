import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

enum SButtonVariant { primary, secondary, outline, ghost, danger }
enum SButtonSize { sm, md, lg }

/// Premium button with Cupertino-style press scaling + haptic feedback.
class SButton extends StatefulWidget {
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
  State<SButton> createState() => _SButtonState();
}

class _SButtonState extends State<SButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = switch (widget.size) {
      SButtonSize.sm => SSizes.buttonHeightSm,
      SButtonSize.md => SSizes.buttonHeightMd,
      SButtonSize.lg => SSizes.buttonHeightLg,
    };
    final fontSize = switch (widget.size) {
      SButtonSize.sm => 13.0,
      SButtonSize.md => 15.0,
      SButtonSize.lg => 17.0,
    };

    final (bg, fg, border) = _resolveColors(isDark);
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              HapticFeedback.lightImpact();
              widget.onPressed?.call();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: widget.isFullWidth ? double.infinity : null,
          height: height,
          decoration: BoxDecoration(
            color: isDisabled ? bg.withValues(alpha: 0.5) : bg,
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
            border: border != null ? Border.all(color: border) : null,
            boxShadow: widget.variant == SButtonVariant.primary && !_pressed
                ? [
                    BoxShadow(
                      color: bg.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? CupertinoActivityIndicator(
                    radius: 10,
                    color: fg,
                  )
                : widget.child ??
                    Row(
                      mainAxisSize:
                          widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.prefixIcon != null) ...[
                          Icon(widget.prefixIcon, size: fontSize + 2, color: fg),
                          const SizedBox(width: SSizes.sm),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                            color: fg,
                          ),
                        ),
                        if (widget.suffixIcon != null) ...[
                          const SizedBox(width: SSizes.sm),
                          Icon(widget.suffixIcon, size: fontSize + 2, color: fg),
                        ],
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  (Color bg, Color fg, Color? border) _resolveColors(bool isDark) {
    return switch (widget.variant) {
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
