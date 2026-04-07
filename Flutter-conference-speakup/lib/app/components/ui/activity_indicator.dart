import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';

/// Hybrid activity indicator — uses CupertinoActivityIndicator for a premium
/// iOS-style spinner, with Material fallback for branding when needed.
class SActivityIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final bool adaptive;

  const SActivityIndicator({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 2.5,
    this.adaptive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (adaptive) {
      return CupertinoActivityIndicator(
        radius: size / 2,
        color: color ?? SColors.primary,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation(
          color ?? SColors.primary,
        ),
      ),
    );
  }
}

/// Full-screen loading overlay with Cupertino spinner.
class SLoadingOverlay extends StatelessWidget {
  final String? message;

  const SLoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CupertinoActivityIndicator(radius: 16),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? SColors.textDarkSecondary
                        : SColors.textLightSecondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
