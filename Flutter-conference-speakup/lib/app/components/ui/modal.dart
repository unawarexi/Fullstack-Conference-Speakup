import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/button.dart';

class SModal {
  SModal._();

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDanger = false,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? SColors.darkCard : SColors.lightCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SSizes.radiusLg),
          ),
          title: Text(title),
          content: content ??
              (message != null
                  ? Text(
                      message,
                      style: TextStyle(
                        color: isDark
                            ? SColors.textDarkSecondary
                            : SColors.textLightSecondary,
                      ),
                    )
                  : null),
          actions: [
            SButton(
              text: cancelText,
              variant: SButtonVariant.ghost,
              size: SButtonSize.sm,
              isFullWidth: false,
              onPressed: () {
                onCancel?.call();
                Navigator.of(ctx).pop();
              },
            ),
            SButton(
              text: confirmText,
              variant: isDanger ? SButtonVariant.danger : SButtonVariant.primary,
              size: SButtonSize.sm,
              isFullWidth: false,
              onPressed: () {
                onConfirm?.call();
                Navigator.of(ctx).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
