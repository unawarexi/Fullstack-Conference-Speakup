import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

/// Premium bottom sheet with iOS-style blur backdrop and refined drag handle.
class SBottomSheet {
  SBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    bool useRootNavigator = false,
    double? maxHeight,
    bool useBlur = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight)
          : null,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SSizes.radiusXl),
        ),
        child: BackdropFilter(
          filter: useBlur
              ? ImageFilter.blur(sigmaX: 24, sigmaY: 24)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? SColors.darkSurface.withValues(alpha: useBlur ? 0.85 : 1.0)
                  : SColors.lightSurface.withValues(alpha: useBlur ? 0.9 : 1.0),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(SSizes.radiusXl),
              ),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  SSizes.pagePadding,
                  SSizes.sm,
                  SSizes.pagePadding,
                  SSizes.pagePadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cupertino-style capsule handle
                    Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    if (title != null) ...[
                      const SizedBox(height: SSizes.md),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: SSizes.md),
                    ] else
                      const SizedBox(height: SSizes.md),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
