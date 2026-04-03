import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/icons.dart';
import 'package:video_confrence_app/core/constants/responsive.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';
import 'package:video_confrence_app/core/constants/text_strings.dart';
import 'package:video_confrence_app/app/components/ui/card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = SResponsive.isMobile(context);

    // Extra bottom padding so content clears the island nav on mobile
    final navPadding = isMobile ? 96.0 : 0.0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: SColors.primary.withValues(alpha: isDark ? 0.25 : 0.15),
              child: const Icon(Icons.person_rounded, color: SColors.primary, size: 20),
            ),
            const SizedBox(width: SSizes.sm + 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
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
            icon: Icon(
              SIcons.notification,
              color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
            ),
          ),
          const SizedBox(width: SSizes.xs),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          SSizes.pagePadding,
          SSizes.md,
          SSizes.pagePadding,
          SSizes.pagePadding + navPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Quick Actions ──
            _QuickActionsGrid(isDark: isDark),
            const SizedBox(height: SSizes.sectionSpacing),

            // ── Upcoming section ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Meetings',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () => context.go('/meetings'),
                  child: const Text(
                    'See all',
                    style: TextStyle(fontSize: 13, color: SColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SSizes.sm),

            // Placeholder
            _EmptyState(
              icon: SIcons.meetings,
              message: 'No upcoming meetings',
              subMessage: 'Create or join a meeting to get started',
              isDark: isDark,
            ),

            const SizedBox(height: SSizes.sectionSpacing),

            // ── Recent Chats ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Chats',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () => context.go('/chat'),
                  child: const Text(
                    'See all',
                    style: TextStyle(fontSize: 13, color: SColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SSizes.sm),

            _EmptyState(
              icon: SIcons.chat,
              message: 'No recent conversations',
              subMessage: 'Start chatting with your team',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Quick Actions
// ─────────────────────────────────────────────
class _QuickActionsGrid extends StatelessWidget {
  final bool isDark;
  const _QuickActionsGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionTile(
          icon: Icons.videocam_rounded,
          label: STexts.newMeeting,
          color: SColors.primary,
          isDark: isDark,
          onTap: () => context.push('/join'),
        ),
        const SizedBox(width: SSizes.sm + 2),
        _ActionTile(
          icon: Icons.login_rounded,
          label: STexts.joinMeeting,
          color: SColors.blue700,
          isDark: isDark,
          onTap: () => context.push('/join'),
        ),
        const SizedBox(width: SSizes.sm + 2),
        _ActionTile(
          icon: Icons.calendar_today_rounded,
          label: 'Schedule',
          color: SColors.screenShare,
          isDark: isDark,
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
  final bool isDark;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SCard(
        hasBorder: true,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: SSizes.md, horizontal: SSizes.sm),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(SSizes.sm + 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.15 : 0.10),
                borderRadius: BorderRadius.circular(SSizes.radiusMd),
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
    );
  }
}

// ─────────────────────────────────────────────
//  Empty state placeholder
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subMessage;
  final bool isDark;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.subMessage,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SCard(
      hasBorder: true,
      padding: const EdgeInsets.symmetric(vertical: SSizes.xxl, horizontal: SSizes.md),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(SSizes.md),
              decoration: BoxDecoration(
                color: (isDark ? SColors.darkElevated : SColors.lightElevated),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isDark ? SColors.darkMuted : SColors.lightMuted,
              ),
            ),
            const SizedBox(height: SSizes.md),
            Text(
              message,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
              ),
            ),
            const SizedBox(height: SSizes.xs),
            Text(
              subMessage,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
