import 'package:flutter/material.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';
import 'package:video_confrence_app/core/constants/text_strings.dart';
import 'package:video_confrence_app/app/components/widgets/fab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: SColors.primary,
              child: const Text(
                'U',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: SSizes.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? SColors.textDarkSecondary
                        : SColors.textLightSecondary,
                  ),
                ),
                const Text(
                  'User',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions
              _QuickActionsRow(),
              const SizedBox(height: SSizes.sectionSpacing),
              Text(
                'Upcoming Meetings',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: SSizes.md),
              // Placeholder for meetings list
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: SSizes.xxl),
                  child: Column(
                    children: [
                      Icon(
                        Icons.video_camera_front_outlined,
                        size: 64,
                        color: isDark
                            ? SColors.darkMuted
                            : SColors.lightMuted,
                      ),
                      const SizedBox(height: SSizes.md),
                      Text(
                        'No upcoming meetings',
                        style: TextStyle(
                          color: isDark
                              ? SColors.textDarkSecondary
                              : SColors.textLightSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SMeetingFab(
        onNewMeeting: () {},
        onJoinMeeting: () {},
        onScheduleMeeting: () {},
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionTile(
          icon: Icons.videocam,
          label: STexts.newMeeting,
          color: SColors.primary,
          onTap: () {},
        ),
        const SizedBox(width: SSizes.sm),
        _ActionTile(
          icon: Icons.login,
          label: STexts.joinMeeting,
          color: SColors.blue700,
          onTap: () {},
        ),
        const SizedBox(width: SSizes.sm),
        _ActionTile(
          icon: Icons.calendar_today,
          label: STexts.scheduleMeeting,
          color: SColors.screenShare,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: SSizes.md,
            horizontal: SSizes.sm,
          ),
          decoration: BoxDecoration(
            color: isDark ? SColors.darkCard : SColors.lightCard,
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
            border: Border.all(
              color: isDark ? SColors.darkBorder : SColors.lightBorder,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(SSizes.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(SSizes.radiusSm),
                ),
                child: Icon(icon, color: color, size: SSizes.iconLg),
              ),
              const SizedBox(height: SSizes.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
