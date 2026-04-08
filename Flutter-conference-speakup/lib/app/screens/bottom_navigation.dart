import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
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
//  DESKTOP: Glass side rail navigation
// ═════════════════════════════════════════════
class _DesktopNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _DesktopNavigation({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final index = navigationShell.currentIndex;

    return Scaffold(
      body: Row(
        children: [
          // ── Glass side rail ──
          GlassSideBar(
            width: 72,
            quality: GlassQuality.premium,
            children: [
              const SizedBox(height: SSizes.lg),
              // Brand icon
              GlassContainer(
                width: 40,
                height: 40,
                shape: LiquidRoundedSuperellipse(borderRadius: SSizes.radiusMd),
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
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: SSizes.animFast),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isActive
                ? SColors.primary.withValues(alpha: isDark ? 0.18 : 0.12)
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
//  MOBILE: Liquid Glass Island navigation
//
//  Layout:
//    ┌───────────────────┐         ┌──────┐
//    │  🏠  📹  💬       │  · · ·  │  ⚙️  │
//    └───────────────────┘         └──────┘
//       Glass Island (3)        Glass Satellite
//
//  The satellite (Settings) magnetically drifts
//  toward the island when tapped, merges briefly,
//  then the island absorbs it. When another tab
//  is picked the satellite floats back out.
//  Both surfaces use frosted liquid glass.
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
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.navigationShell.currentIndex;

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

    _syncMergeState(animate: false);
  }

  @override
  void didUpdateWidget(covariant _MobileNavigation old) {
    super.didUpdateWidget(old);
    final newIndex = widget.navigationShell.currentIndex;
    if (newIndex != _currentIndex) {
      setState(() => _currentIndex = newIndex);
      _syncMergeState();
    }
  }

  void _syncMergeState({bool animate = true}) {
    final isSettingsActive = _currentIndex == 3;
    if (isSettingsActive && !_isMerged) {
      _isMerged = true;
      if (animate) {
        _mergeController.forward();
      } else {
        _mergeController.value = 1.0;
      }
      _pulseController.stop();
      _pulseController.value = 0;
    } else if (!isSettingsActive && _isMerged) {
      _isMerged = false;
      if (animate) {
        _mergeController.reverse();
      } else {
        _mergeController.value = 0.0;
      }
    }
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _syncMergeState();
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
    return Scaffold(
      body: Stack(
        children: [
          // ── Page content ──
          Positioned.fill(child: widget.navigationShell),

          // ── Glass navigation island ──
          Positioned(
            left: SSizes.pagePadding,
            right: SSizes.pagePadding,
            bottom: MediaQuery.of(context).padding.bottom + SSizes.md,
            child: AnimatedBuilder(
              animation: _mergeAnim,
              builder: (context, _) {
                return _buildGlassIslandBar(context, _currentIndex);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassIslandBar(BuildContext context, int currentIndex) {
    final mergeVal = _mergeAnim.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // When merged: gap shrinks to 0, satellite joins the island
    final gap = 12.0 * (1.0 - mergeVal);

    return Row(
      children: [
        // ── Main glass island (3 items, expands when merged) ──
        Expanded(
          child: GlassContainer(
            height: 64,
            shape: LiquidRoundedSuperellipse(borderRadius: SSizes.radiusXl + 8),
            useOwnLayer: true,
            quality: GlassQuality.standard,
            settings: LiquidGlassSettings(
              thickness: isDark ? 40 : 25,
              blur: isDark ? 16 : 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _GlassIslandItem(
                  icon: SIcons.home,
                  activeIcon: SIcons.homeFilled,
                  label: 'Home',
                  isActive: currentIndex == 0,
                  onTap: () => _onTap(0),
                ),
                _GlassIslandItem(
                  icon: SIcons.meetings,
                  activeIcon: SIcons.meetingsFilled,
                  label: 'Meetings',
                  isActive: currentIndex == 1,
                  onTap: () => _onTap(1),
                ),
                _GlassIslandItem(
                  icon: SIcons.chat,
                  activeIcon: SIcons.chatFilled,
                  label: 'Chat',
                  isActive: currentIndex == 2,
                  onTap: () => _onTap(2),
                ),
                // When merged, settings appears inside the glass island
                if (mergeVal > 0.5)
                  _GlassIslandItem(
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

        // ── Glass satellite (Settings) ──
        if (mergeVal < 0.5)
          GestureDetector(
            onTap: () => _onTap(3),
            onLongPress: _onSatelliteLongPress,
            child: ScaleTransition(
              scale: _pulseAnim,
              child: GlassContainer(
                width: 64,
                height: 64,
                shape: LiquidRoundedSuperellipse(borderRadius: SSizes.radiusXl),
                useOwnLayer: true,
                quality: GlassQuality.standard,
                settings: LiquidGlassSettings(
                  thickness: currentIndex == 3
                      ? (isDark ? 55 : 40)
                      : (isDark ? 40 : 25),
                  blur: isDark ? 16 : 12,
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: SSizes.animNormal),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: currentIndex == 3
                          ? SColors.primary.withValues(alpha: 0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(SSizes.radiusMd),
                    ),
                    child: Icon(
                      currentIndex == 3 ? SIcons.settingsFilled : SIcons.settings,
                      color: currentIndex == 3
                          ? SColors.primary
                          : (isDark ? SColors.darkMuted : SColors.lightMuted),
                      size: SSizes.iconMd,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Glass island nav item with active indicator pill
// ─────────────────────────────────────────────
class _GlassIslandItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _GlassIslandItem({
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
                    ? SColors.primary.withValues(alpha: isDark ? 0.20 : 0.14)
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
