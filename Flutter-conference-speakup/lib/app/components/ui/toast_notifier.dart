import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';

enum SToastType { success, error, warning, info }

class SToast {
  SToast._();

  static void show(
    BuildContext context, {
    required String message,
    SToastType type = SToastType.info,
    Duration duration = const Duration(seconds: 3),
    ToastGravity gravity = ToastGravity.TOP,
  }) {
    final (_, bg, fg) = _resolveStyle(type);

    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: duration.inSeconds <= 2 ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG,
      gravity: gravity,
      backgroundColor: bg,
      textColor: fg,
      fontSize: 14,
    );
  }

  /// Custom styled toast with icon — uses FToast overlay for full widget control.
  static void showCustom(
    BuildContext context, {
    required String message,
    SToastType type = SToastType.info,
    Duration duration = const Duration(seconds: 3),
    ToastGravity gravity = ToastGravity.TOP,
  }) {
    final (icon, bg, fg) = _resolveStyle(type);
    final fToast = FToast()..init(context);

    fToast.removeCustomToast();
    fToast.showToast(
      toastDuration: duration,
      gravity: gravity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: bg.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                style: TextStyle(
                  color: fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
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
