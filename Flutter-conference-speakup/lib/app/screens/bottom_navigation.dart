import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
//  MOBILE: Liquid Glass Island + Dissolving Satellite
// ═════════════════════════════════════════════
class _MobileNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const _MobileNavigation({required this.navigationShell});

  @override
  State<_MobileNavigation> createState() => _MobileNavigationState();
}

class _MobileNavigationState extends State<_MobileNavigation>
    with TickerProviderStateMixin {
  // Controls the satellite dissolve/reconstitute
  late AnimationController _dissolveCtrl;
  // Controls the island width expansion when settings merges in
  late AnimationController _expandCtrl;

  late int _currentIndex;
  late int _previousIndex;

  static const _items = [
    _NavItemData(SIcons.home, SIcons.homeFilled, 'Home'),
    _NavItemData(SIcons.meetings, SIcons.meetingsFilled, 'Meetings'),
    _NavItemData(SIcons.chat, SIcons.chatFilled, 'Chat'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.navigationShell.currentIndex;
    _previousIndex = _currentIndex;

    _dissolveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _expandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    if (_currentIndex == 3) {
      _dissolveCtrl.value = 1.0;
      _expandCtrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _MobileNavigation old) {
    super.didUpdateWidget(old);
    final newIndex = widget.navigationShell.currentIndex;
    if (newIndex != _currentIndex) {
      _previousIndex = _currentIndex;
      setState(() => _currentIndex = newIndex);
      _animateTransition();
    }
  }

  void _animateTransition() {
    if (_currentIndex == 3) {
      // Dissolve satellite → expand island
      _dissolveCtrl.forward().then((_) {
        if (mounted) _expandCtrl.forward();
      });
    } else if (_previousIndex == 3) {
      // Shrink island → reconstitute satellite
      _expandCtrl.reverse().then((_) {
        if (mounted) _dissolveCtrl.reverse();
      });
    }
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    _previousIndex = _currentIndex;
    setState(() => _currentIndex = index);
    _animateTransition();
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  void dispose() {
    _dissolveCtrl.dispose();
    _expandCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: widget.navigationShell),

          // ── Navigation bar ──
          Positioned(
            left: SSizes.pagePadding,
            right: SSizes.pagePadding,
            bottom: MediaQuery.of(context).padding.bottom + SSizes.md,
            child: AnimatedBuilder(
              animation: Listenable.merge([_dissolveCtrl, _expandCtrl]),
              builder: (context, _) => _buildBar(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(bool isDark) {
    final dissolve = CurvedAnimation(
      parent: _dissolveCtrl,
      curve: Curves.easeOutCubic,
    ).value;
    final expand = CurvedAnimation(
      parent: _expandCtrl,
      curve: Curves.easeOutCubic,
    ).value;

    // Satellite gap: 12 → 0 as it dissolves
    final gap = 12.0 * (1.0 - dissolve);
    // Satellite width: 64 → 0 so island can centre properly
    final satWidth = 64.0 * (1.0 - dissolve);
    // Satellite opacity
    final satOpacity = (1.0 - dissolve).clamp(0.0, 1.0);

    // How many items the island shows (3 base + settings when expanded)
    final showSettingsInIsland = expand > 0.05;
    final itemCount = showSettingsInIsland ? 4 : 3;

    return Row(
      children: [
        // ── Main glass island ──
        Expanded(
          child: _GlassIsland(
            isDark: isDark,
            currentIndex: _currentIndex,
            previousIndex: _previousIndex,
            itemCount: itemCount,
            items: _items,
            showSettings: showSettingsInIsland,
            settingsOpacity: expand,
            onTap: _onTap,
          ),
        ),

        // ── Gap (animates to 0) ──
        SizedBox(width: gap),

        // ── Satellite (width collapses so island stays centered) ──
        SizedBox(
          width: satWidth,
          height: 64,
          child: Opacity(
            opacity: satOpacity,
            child: IgnorePointer(
              ignoring: dissolve > 0.5,
              child: GestureDetector(
                onTap: () => _onTap(3),
                child: satWidth > 8
                    ? GlassContainer(
                        width: satWidth,
                        height: 64,
                        shape: LiquidRoundedSuperellipse(
                          borderRadius: SSizes.radiusXl,
                        ),
                        useOwnLayer: true,
                        quality: GlassQuality.standard,
                        settings: LiquidGlassSettings(
                          thickness: isDark ? 40 : 25,
                          blur: isDark ? 16 : 12,
                        ),
                        child: Center(
                          child: Icon(
                            SIcons.settings,
                            color: isDark
                                ? SColors.darkMuted
                                : SColors.lightMuted,
                            size: SSizes.iconMd,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Glass Island with snake-style sliding pill
// ─────────────────────────────────────────────
class _GlassIsland extends StatelessWidget {
  final bool isDark;
  final int currentIndex;
  final int previousIndex;
  final int itemCount;
  final List<_NavItemData> items;
  final bool showSettings;
  final double settingsOpacity;
  final ValueChanged<int> onTap;

  const _GlassIsland({
    required this.isDark,
    required this.currentIndex,
    required this.previousIndex,
    required this.itemCount,
    required this.items,
    required this.showSettings,
    required this.settingsOpacity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      height: 64,
      shape: LiquidRoundedSuperellipse(borderRadius: SSizes.radiusXl + 8),
      useOwnLayer: true,
      quality: GlassQuality.standard,
      settings: LiquidGlassSettings(
        thickness: isDark ? 40 : 25,
        blur: isDark ? 16 : 12,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final slotWidth = totalWidth / itemCount;
          // The active pill index (settings = 3 maps to slot 3)
          final activeSlot = currentIndex < itemCount ? currentIndex : -1;

          // Pill sizing: fill the slot with small horizontal inset
          const pillHInset = 6.0;
          const pillVInset = 6.0;
          final pillWidth = slotWidth - pillHInset * 2;
          const pillHeight = 64.0 - pillVInset * 2;

          return Stack(
            children: [
              // ── Glassmorphic sliding pill (Apple-style) ──
              if (activeSlot >= 0)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  left: slotWidth * activeSlot + pillHInset,
                  top: pillVInset,
                  child: GlassContainer(
                    width: pillWidth,
                    height: pillHeight,
                    shape: LiquidRoundedSuperellipse(
                      borderRadius: SSizes.radiusFull,
                    ),
                    useOwnLayer: true,
                    quality: GlassQuality.standard,
                    settings: LiquidGlassSettings(
                      thickness: isDark ? 55 : 35,
                      blur: isDark ? 14 : 10,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),

              // ── Nav items ──
              Row(
                children: [
                  for (int i = 0; i < items.length; i++)
                    Expanded(
                      child: _IslandItem(
                        data: items[i],
                        isActive: currentIndex == i,
                        isDark: isDark,
                        onTap: () => onTap(i),
                      ),
                    ),
                  // Settings slot (animated in/out via opacity)
                  if (showSettings)
                    Expanded(
                      child: Opacity(
                        opacity: settingsOpacity.clamp(0.0, 1.0),
                        child: _IslandItem(
                          data: const _NavItemData(
                            SIcons.settings,
                            SIcons.settingsFilled,
                            'Settings',
                          ),
                          isActive: currentIndex == 3,
                          isDark: isDark,
                          onTap: () => onTap(3),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Individual nav item (no colored background — the
//  snake pill slides behind the active one)
// ─────────────────────────────────────────────
class _IslandItem extends StatelessWidget {
  final _NavItemData data;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _IslandItem({
    required this.data,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? SColors.textDark : SColors.primary;
    final inactiveColor = isDark ? SColors.darkMuted : SColors.lightMuted;
    final color = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutCubic,
              child: Icon(
                isActive ? data.activeIcon : data.icon,
                key: ValueKey(isActive),
                color: color,
                size: isActive ? 22 : 20,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
              child: Text(data.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Nav item data tuple
// ─────────────────────────────────────────────
class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItemData(this.icon, this.activeIcon, this.label);
}
