import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/image_strings.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

class OnboardingEmblem extends StatelessWidget {
  final bool compact;
  const OnboardingEmblem({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      SImages.brandEmblem,
      height: compact ? 28 : 36,
      fit: BoxFit.contain,
    );
  }
}

class DotRow extends StatelessWidget {
  final int current;
  final int total;
  const DotRow({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final inactiveColor = Theme.of(context).colorScheme.outline;

    return Row(
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: SSizes.sm),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? SColors.primary : inactiveColor,
            borderRadius: BorderRadius.circular(SSizes.radiusXs),
          ),
        );
      }),
    );
  }
}

class StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const StepIndicator({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final inactiveColor = Theme.of(context).colorScheme.outline;

    return Row(
      children: List.generate(total, (i) {
        final isDone = i <= current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          margin: const EdgeInsets.only(right: 6),
          width: isDone ? 24 : 16,
          height: 4,
          decoration: BoxDecoration(
            color: isDone ? SColors.primary : inactiveColor,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

class SkipButton extends StatelessWidget {
  final VoidCallback onTap;
  const SkipButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: SSizes.md, vertical: SSizes.sm),
       
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusFull),
          side: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
      child: const Text(
        'Skip',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class CTAButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const CTAButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  State<CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<CTAButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _pressCtrl;
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) {
        _pressCtrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.forward(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: double.infinity,
          height: SSizes.buttonHeightLg,
          decoration: BoxDecoration(
            gradient: SColors.primaryGradient,
            borderRadius: BorderRadius.circular(SSizes.radiusLg),
            boxShadow: [
              BoxShadow(
                color: SColors.primary.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: SSizes.sm),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: SSizes.iconSm),
            ],
          ),
        ),
      ),
    );
  }
}
