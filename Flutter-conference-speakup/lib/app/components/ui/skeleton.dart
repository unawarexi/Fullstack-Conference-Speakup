import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';

class SSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SSkeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = SSizes.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? SColors.darkElevated : SColors.lightElevated,
      highlightColor: isDark ? SColors.darkHover : SColors.lightHover,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton for meeting card list.
class SMeetingCardSkeleton extends StatelessWidget {
  const SMeetingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: SSizes.sm),
      child: Row(
        children: [
          SSkeleton(width: 4, height: 48, borderRadius: 2),
          SizedBox(width: SSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SSkeleton(height: 16, width: 180),
                SizedBox(height: SSizes.sm),
                SSkeleton(height: 12, width: 120),
                SizedBox(height: SSizes.sm),
                SSkeleton(height: 12, width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for avatar row.
class SAvatarSkeleton extends StatelessWidget {
  final double size;
  const SAvatarSkeleton({super.key, this.size = SSizes.avatarMd});

  @override
  Widget build(BuildContext context) {
    return SSkeleton(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }
}
