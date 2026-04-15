import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

/// Filter chip row used across AI screens.
class AIFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;
  const AIFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? SColors.primary
              : (isDark ? SColors.darkCard : SColors.lightCard),
          borderRadius: BorderRadius.circular(SSizes.radiusFull),
          border: selected
              ? null
              : Border.all(
                  color: isDark ? SColors.darkBorder : SColors.lightBorder,
                  width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : (isDark ? SColors.textDark : SColors.textLight),
          ),
        ),
      ),
    );
  }
}

/// Card used for AI insight items (action items, suggestions, etc).
class AIInsightCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final EdgeInsetsGeometry? padding;
  const AIInsightCard({
    super.key,
    required this.child,
    required this.isDark,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? SColors.darkCard : SColors.lightCard,
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
        border: Border.all(
          color: isDark ? SColors.darkBorder : SColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}

/// Meta badge (e.g., "3 decisions", "5 actions").
class AIMetaBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;
  const AIMetaBadge(this.label, this.color, {super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(SSizes.radiusFull),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

/// Priority dot indicator.
class AIPriorityDot extends StatelessWidget {
  final String priority;
  const AIPriorityDot({super.key, required this.priority});

  Color get _color => switch (priority) {
        'high' => SColors.error,
        'medium' => SColors.warning,
        _ => SColors.success,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
    );
  }
}

/// Loading state placeholder for AI screens.
class AILoadingState extends StatelessWidget {
  final String? message;
  const AILoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: SColors.primary),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!,
                style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? SColors.textDarkSecondary
                        : SColors.textLightSecondary)),
          ],
        ],
      ),
    );
  }
}

/// Error state with retry for AI screens.
class AIErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const AIErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 36,
              color: isDark
                  ? SColors.textDarkTertiary
                  : SColors.textLightTertiary),
          const SizedBox(height: 8),
          Text(message,
              style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? SColors.textDarkSecondary
                      : SColors.textLightSecondary)),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}

/// Empty result state for AI screens.
class AIEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subMessage;
  const AIEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.subMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 40,
              color: isDark
                  ? SColors.textDarkTertiary
                  : SColors.textLightTertiary),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? SColors.textDarkSecondary
                      : SColors.textLightSecondary)),
          if (subMessage != null) ...[
            const SizedBox(height: 4),
            Text(subMessage!,
                style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? SColors.textDarkTertiary
                        : SColors.textLightTertiary)),
          ],
        ],
      ),
    );
  }
}
