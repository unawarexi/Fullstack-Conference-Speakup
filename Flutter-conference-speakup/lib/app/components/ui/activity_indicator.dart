import 'package:flutter/material.dart';
import 'package:video_confrence_app/core/constants/colors.dart';

class SActivityIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const SActivityIndicator({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
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

/// Full-screen loading overlay.
class SLoadingOverlay extends StatelessWidget {
  final String? message;

  const SLoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SActivityIndicator(size: 40),
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
