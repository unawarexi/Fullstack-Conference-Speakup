import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

enum SToastType { success, error, warning, info }

class SToast {
  SToast._();

  static void show(
    BuildContext context, {
    required String message,
    SToastType type = SToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final (icon, bg, fg) = _resolveStyle(type);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: fg, size: 20),
              const SizedBox(width: SSizes.sm),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: fg, fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: bg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
          ),
          margin: const EdgeInsets.all(SSizes.md),
          duration: duration,
        ),
      );
  }

  static (IconData, Color, Color) _resolveStyle(SToastType type) {
    return switch (type) {
      SToastType.success => (Icons.check_circle_outline, SColors.success, Colors.white),
      SToastType.error => (Icons.error_outline, SColors.error, Colors.white),
      SToastType.warning => (Icons.warning_amber_outlined, SColors.warning, Colors.white),
      SToastType.info => (Icons.info_outline, SColors.primary, Colors.white),
    };
  }
}
