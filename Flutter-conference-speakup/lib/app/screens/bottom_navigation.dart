import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

class BottomNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const BottomNavigation({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    if (SResponsive.isDesktop(context)) {
      return _DesktopNavigation(navigationShell: navigationShell);
    }
    return _MobileNavigation(navigationShell: navigationShell);
  }
}

// ═════════════════════════════════════════════
//  DESKTOP: Side rail navigation
// ═════════════════════════════════════════════
class _DesktopNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _DesktopNavigation({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final index = navigationShell.currentIndex;

    return Scaffold(
      body: Row(
        children: [
          // ── Side rail ──
          Container(
            width: 72,
            decoration: BoxDecoration(
              color: isDark ? SColors.darkSurface : SColors.lightSurface,
              border: Border(
                right: BorderSide(
                  color: isDark ? SColors.darkBorder : SColors.lightBorder,
                  width: SSizes.dividerThickness,
                ),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: SSizes.lg),
                // Brand icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: SColors.accentGradient,
                    borderRadius: BorderRadius.circular(SSizes.radiusMd),
                  ),
                  child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(height: SSizes.xl),

                // Main nav items
                _RailItem(
                  icon: SIcons.home,
                  activeIcon: SIcons.homeFilled,
                  label: 'Home',
                  isActive: index == 0,
                  onTap: () => _go(0),
                ),
                const SizedBox(height: SSizes.xs),
                _RailItem(
                  icon: SIcons.meetings,
                  activeIcon: SIcons.meetingsFilled,
                  label: 'Meetings',
                  isActive: index == 1,
                  onTap: () => _go(1),
                ),
                const SizedBox(height: SSizes.xs),
                _RailItem(
                  icon: SIcons.chat,
                  activeIcon: SIcons.chatFilled,
                  label: 'Chat',
                  isActive: index == 2,
                  onTap: () => _go(2),
                ),

                const Spacer(),

                // Settings at bottom
                _RailItem(
                  icon: SIcons.settings,
                  activeIcon: SIcons.settingsFilled,
                  label: 'Settings',
                  isActive: index == 3,
                  onTap: () => _go(3),
                ),
                const SizedBox(height: SSizes.lg),
              ],
            ),
          ),

          // ── Content ──
          Expanded(child: navigationShell),
        ],
      ),
    );
  }

  void _go(int i) {
    navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex);
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _RailItem({
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

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
        child: AnimatedContainer(
          duration: Duration(milliseconds: SSizes.animFast),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isActive
                ? SColors.primary.withValues(alpha: isDark ? 0.15 : 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
          ),
          child: Icon(isActive ? activeIcon : icon, color: color, size: SSizes.iconMd),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
//  MOBILE: Island navigation
//
//  Layout:
//    ┌───────────────────┐         ┌──────┐
//    │  🏠  📹  💬       │  · · ·  │  ⚙️  │
//    └───────────────────┘         └──────┘
//       Island (3 items)        Satellite
//
//  The satellite (Settings) magnetically drifts
//  toward the island when tapped, merges briefly,
//  then the island absorbs it. When another tab
//  is picked the satellite floats back out.
// ═════════════════════════════════════════════
class _MobileNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const _MobileNavigation({required this.navigationShell});

  @override
  State<_MobileNavigation> createState() => _MobileNavigationState();
}

class _MobileNavigationState extends State<_MobileNavigation>
    with TickerProviderStateMixin {
  late AnimationController _mergeController;
  late Animation<double> _mergeAnim;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  bool _isMerged = false;

  @override
  void initState() {
    super.initState();
    _mergeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _mergeAnim = CurvedAnimation(
      parent: _mergeController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _syncMergeState();
  }

  @override
  void didUpdateWidget(covariant _MobileNavigation old) {
    super.didUpdateWidget(old);
    _syncMergeState();
  }

  void _syncMergeState() {
    final isSettingsActive = widget.navigationShell.currentIndex == 3;
    if (isSettingsActive && !_isMerged) {
      _isMerged = true;
      _mergeController.forward();
      _pulseController.stop();
      _pulseController.value = 0;
    } else if (!isSettingsActive && _isMerged) {
      _isMerged = false;
      _mergeController.reverse();
    }
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _onSatelliteLongPress() {
    _pulseController.forward(from: 0).then((_) {
      if (mounted) _pulseController.reverse();
    });
  }

  @override
  void dispose() {
    _mergeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentIndex = widget.navigationShell.currentIndex;

    return Scaffold(
      body: Stack(
        children: [
          // ── Page content ──
          Positioned.fill(
            child: widget.navigationShell,
          ),

          // ── Navigation island ──
          Positioned(
            left: SSizes.pagePadding,
            right: SSizes.pagePadding,
            bottom: MediaQuery.of(context).padding.bottom + SSizes.md,
            child: AnimatedBuilder(
              animation: _mergeAnim,
              builder: (context, _) {
                return _buildIslandBar(context, isDark, currentIndex);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIslandBar(BuildContext context, bool isDark, int currentIndex) {
    final mergeVal = _mergeAnim.value;
    // When merged: gap shrinks to 0, satellite joins the island
    // When separated: gap is 12, satellite floats independently
    final gap = 12.0 * (1.0 - mergeVal);

    final bgColor = isDark
        ? SColors.darkSurface.withValues(alpha: 0.95)
        : SColors.lightSurface.withValues(alpha: 0.95);
    final borderColor = isDark ? SColors.darkBorder : SColors.lightBorder;

    return Row(
      children: [
        // ── Main island (3 items, expands when merged to absorb satellite) ──
        Expanded(
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(SSizes.radiusXl + 8),
              border: Border.all(color: borderColor, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                if (!isDark)
                  BoxShadow(
                    color: SColors.primary.withValues(alpha: 0.05),
                    blurRadius: 40,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _IslandItem(
                  icon: SIcons.home,
                  activeIcon: SIcons.homeFilled,
                  label: 'Home',
                  isActive: currentIndex == 0,
                  onTap: () => _onTap(0),
                ),
                _IslandItem(
                  icon: SIcons.meetings,
                  activeIcon: SIcons.meetingsFilled,
                  label: 'Meetings',
                  isActive: currentIndex == 1,
                  onTap: () => _onTap(1),
                ),
                _IslandItem(
                  icon: SIcons.chat,
                  activeIcon: SIcons.chatFilled,
                  label: 'Chat',
                  isActive: currentIndex == 2,
                  onTap: () => _onTap(2),
                ),
                // When merged, settings appears inside the island
                if (mergeVal > 0.5)
                  _IslandItem(
                    icon: SIcons.settings,
                    activeIcon: SIcons.settingsFilled,
                    label: 'Settings',
                    isActive: currentIndex == 3,
                    onTap: () => _onTap(3),
                  ),
              ],
            ),
          ),
        ),

        // ── Gap ──
        SizedBox(width: gap),

        // ── Satellite icon (Settings) ──
        if (mergeVal < 0.5)
          GestureDetector(
            onTap: () => _onTap(3),
            onLongPress: _onSatelliteLongPress,
            child: ScaleTransition(
              scale: _pulseAnim,
              child: AnimatedContainer(
                duration: Duration(milliseconds: SSizes.animNormal),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: currentIndex == 3
                      ? SColors.primary
                      : bgColor,
                  borderRadius: BorderRadius.circular(SSizes.radiusXl),
                  border: Border.all(
                    color: currentIndex == 3
                        ? SColors.primary.withValues(alpha: 0.6)
                        : borderColor,
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: currentIndex == 3
                          ? SColors.primary.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  currentIndex == 3 ? SIcons.settingsFilled : SIcons.settings,
                  color: currentIndex == 3
                      ? Colors.white
                      : (isDark ? SColors.darkMuted : SColors.lightMuted),
                  size: SSizes.iconMd,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Island nav item with active indicator pill
// ─────────────────────────────────────────────
class _IslandItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _IslandItem({
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
        width: 56,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: SSizes.animNormal),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? SColors.primary.withValues(alpha: isDark ? 0.18 : 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(SSizes.radiusFull),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: color,
                size: isActive ? 22 : 20,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: SSizes.animFast),
              style: TextStyle(
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
