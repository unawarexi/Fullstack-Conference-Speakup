import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';
import 'package:video_confrence_app/core/constants/icons.dart';

class BottomNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigation({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? SColors.darkSurface : SColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? SColors.darkBorder : SColors.lightBorder,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: SSizes.bottomNavHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: SIcons.home,
                  activeIcon: SIcons.homeFilled,
                  label: 'Home',
                  isActive: navigationShell.currentIndex == 0,
                  onTap: () => _onTap(0),
                ),
                _NavItem(
                  icon: SIcons.meetings,
                  activeIcon: SIcons.meetingsFilled,
                  label: 'Meetings',
                  isActive: navigationShell.currentIndex == 1,
                  onTap: () => _onTap(1),
                ),
                _NavItem(
                  icon: SIcons.chat,
                  activeIcon: SIcons.chatFilled,
                  label: 'Chat',
                  isActive: navigationShell.currentIndex == 2,
                  onTap: () => _onTap(2),
                ),
                _NavItem(
                  icon: SIcons.settings,
                  activeIcon: SIcons.settingsFilled,
                  label: 'Settings',
                  isActive: navigationShell.currentIndex == 3,
                  onTap: () => _onTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isActive
        ? SColors.primary
        : (isDark ? SColors.darkMuted : SColors.lightMuted);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: SSizes.animFast),
              width: isActive ? 48 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: SColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: SSizes.sm),
            Icon(
              isActive ? activeIcon : icon,
              color: color,
              size: SSizes.iconMd,
            ),
            const SizedBox(height: SSizes.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
