import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/utils/formatters.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/app/components/shapes/shapes.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';
import 'package:flutter_conference_speakup/app/screens/home/home_widgets.dart';
import 'package:flutter_conference_speakup/store/auth_provider.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';
import 'package:flutter_conference_speakup/store/notification_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(currentUserProvider.notifier).fetchProfile();
    });
  }

  Future<void> _onRefresh() async {
    ref.invalidate(meetingsProvider(null));
    await ref.read(currentUserProvider.notifier).fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = SResponsive.isMobile(context);
    final navPadding = isMobile ? 80.0 : 0.0;
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;
    final upcomingMeetings = ref.watch(meetingsProvider(null));
    final greeting = _greeting();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: SColors.primary,
        child: CustomScrollView(
          slivers: [
            // ── Collapsing Header ──
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: _HeaderHero(
                  isDark: isDark,
                  greeting: greeting,
                  userName: user?.fullName ?? '',
                  email: user?.email ?? '',
                  avatar: user?.avatar,
                  isLoading: userAsync.isLoading,
                ),
              ),
              title: Text(
                'SpeakUp',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? SColors.textDark : SColors.textLight,
                ),
              ),
              actions: [
                _HeaderIconButton(
                  icon: SIcons.search,
                  isDark: isDark,
                  onTap: () => context.push('/search'),
                ),
                _HeaderIconButton(
                  icon: SIcons.notification,
                  isDark: isDark,
                  badge: true,
                  onTap: () => context.push('/notifications'),
                ),
                const SizedBox(width: 6),
              ],
            ),

            // ── Body ──
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + navPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Quick Actions ──
                  QuickActionGrid(isDark: isDark)
                      .animate()
                      .fadeIn(duration: 350.ms, delay: 80.ms)
                      .slideY(begin: 0.08, end: 0),
                  const SizedBox(height: 16),

                  // ── AI Suggestions — reasons to start a meeting ──
                  AISuggestionsSection(isDark: isDark)
                      .animate()
                      .fadeIn(duration: 350.ms, delay: 150.ms)
                      .slideY(begin: 0.08, end: 0),
                  const SizedBox(height: 20),

                  // ── Ongoing / Live Meetings (instant + live) ──
                  upcomingMeetings.when(
                    data: (meetings) {
                      final ongoing = meetings
                          .where((m) =>
                              m.status == MeetingStatus.live ||
                              (m.type == MeetingType.instant &&
                                  m.status != MeetingStatus.ended &&
                                  m.status != MeetingStatus.cancelled))
                          .take(3)
                          .toList();
                      if (ongoing.isEmpty) return const SizedBox.shrink();
                      return Column(
                        children: [
                          SectionHeader(
                            title: 'Ongoing',
                            actionLabel: 'View all',
                            onAction: () => context.go('/meetings'),
                          ),
                          for (var i = 0; i < ongoing.length; i++)
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      i < ongoing.length - 1 ? 6 : 0),
                              child: CompactMeetingTile(
                                meeting: ongoing[i],
                                isDark: isDark,
                                onTap: () => context.push(
                                    '/meeting/${ongoing[i].id}'),
                              )
                                  .animate()
                                  .fadeIn(
                                      duration: 350.ms,
                                      delay: (200 + i * 60).ms)
                                  .slideX(begin: 0.04, end: 0),
                            ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // ── Upcoming Meetings (scheduled + recurring only) ──
                  SectionHeader(
                    title: 'Upcoming',
                    actionLabel: 'See all',
                    onAction: () => context.go('/meetings'),
                  ),
                  upcomingMeetings.when(
                    data: (meetings) {
                      final now = DateTime.now();
                      final upcoming = meetings
                          .where((m) =>
                              (m.type == MeetingType.scheduled ||
                                  m.type == MeetingType.recurring) &&
                              (m.status == MeetingStatus.scheduled ||
                                  m.status == MeetingStatus.live) &&
                              (m.scheduledAt == null ||
                                  m.scheduledAt!.isAfter(
                                      now.subtract(const Duration(minutes: 30)))))
                          .take(3)
                          .toList();
                      if (upcoming.isEmpty) {
                        return CompactEmptyState(
                          icon: SIcons.calendar,
                          message: 'No upcoming meetings',
                          subMessage: 'Your schedule is clear!',
                          isDark: isDark,
                          actionLabel: 'Schedule one',
                          onAction: () => context.push('/create-meeting?type=scheduled'),
                        ).animate().fadeIn(duration: 250.ms);
                      }
                      return Column(
                        children: [
                          for (var i = 0; i < upcoming.length; i++)
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      i < upcoming.length - 1 ? 6 : 0),
                              child: CompactMeetingTile(
                                meeting: upcoming[i],
                                isDark: isDark,
                                onTap: () => context.push(
                                    '/meeting-detail/${upcoming[i].id}'),
                              )
                                  .animate()
                                  .fadeIn(
                                      duration: 350.ms,
                                      delay: (200 + i * 60).ms)
                                  .slideX(begin: 0.04, end: 0),
                            ),
                        ],
                      );
                    },
                    loading: () => MeetingsSkeleton(isDark: isDark),
                    error: (_, __) => CompactEmptyState(
                      icon: SIcons.calendar,
                      message: 'Unable to load meetings',
                      subMessage: 'Pull to refresh',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── This Week Stats ──
                  SectionHeader(title: 'This Week'),
                  WeeklyStatsRow(isDark: isDark)
                      .animate()
                      .fadeIn(duration: 350.ms, delay: 350.ms)
                      .slideY(begin: 0.08, end: 0),
                  const SizedBox(height: 20),

                  // ── Recent Activity (ended + instant past) ──
                  SectionHeader(
                    title: 'Recent Activity',
                    actionLabel: 'View all',
                    onAction: () => context.push('/meeting-history'),
                  ),
                  upcomingMeetings.when(
                    data: (meetings) {
                      final now = DateTime.now();
                      final past = meetings
                          .where((m) =>
                              m.status == MeetingStatus.ended ||
                              m.status == MeetingStatus.cancelled ||
                              // Scheduled meetings whose time has passed
                              (m.status == MeetingStatus.scheduled &&
                                  m.scheduledAt != null &&
                                  m.scheduledAt!.isBefore(
                                      now.subtract(const Duration(minutes: 30)))))
                          .take(4)
                          .toList();
                      if (past.isEmpty) {
                        return CompactEmptyState(
                          icon: SIcons.meetings,
                          message: 'No recent activity',
                          subMessage: 'Start your first meeting!',
                          isDark: isDark,
                          actionLabel: 'New meeting',
                          onAction: () => context.push('/create-meeting'),
                        ).animate().fadeIn(duration: 250.ms);
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? SColors.darkCard
                              : SColors.lightCard,
                          borderRadius:
                              BorderRadius.circular(SSizes.radiusMd),
                          border: Border.all(
                            color: isDark
                                ? SColors.darkBorder
                                : SColors.lightBorder,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < past.length; i++)
                              RecentActivityTile(
                                meeting: past[i],
                                isDark: isDark,
                              ),
                          ],
                        ),
                      );
                    },
                    loading: () => MeetingsSkeleton(isDark: isDark),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// ─────────────────────────────────────────────
//  Header Hero — layered shapes + orbs + user data
// ─────────────────────────────────────────────
class _HeaderHero extends StatelessWidget {
  final bool isDark;
  final String greeting;
  final String userName;
  final String email;
  final String? avatar;
  final bool isLoading;

  const _HeaderHero({
    required this.isDark,
    required this.greeting,
    required this.userName,
    this.email = '',
    this.avatar,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = userName.isNotEmpty
        ? userName.split(' ').first
        : '';

    return SLiquidShape(
      intensity: 1.2,
      blendBase: true,
      isDark: isDark,
      foreground: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16, SSizes.xl + 4, 16, SSizes.xl + 4,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(greeting, style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500,
                      color: isDark
                          ? SColors.textDarkSecondary
                          : SColors.textLightSecondary,
                      letterSpacing: 0.2,
                    )),
                    const SizedBox(height: 3),
                    if (isLoading && firstName.isEmpty)
                      _NameSkeleton(isDark: isDark)
                    else
                      Text(
                        firstName.isNotEmpty ? firstName : 'Welcome',
                        style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w700,
                          color: isDark ? SColors.textDark : SColors.textLight,
                          letterSpacing: -0.5,
                        ),
                      ),
                    const SizedBox(height: 3),
                    Text(
                      SFormatters.formatDateWithDay(DateTime.now()),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? SColors.textDarkTertiary
                            : SColors.textLightTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Avatar with ripple rings behind it
              SizedBox(
                width: SSizes.avatarMd + 20,
                height: SSizes.avatarMd + 20,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(SSizes.avatarMd + 20, SSizes.avatarMd + 20),
                      painter: SRippleRingsPainter(
                        color: SColors.primary,
                        ringCount: 2,
                        maxRadius: (SSizes.avatarMd + 20) / 2,
                        strokeWidth: 0.6,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SColors.primary.withValues(alpha: 0.35),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: SColors.primary.withValues(alpha: 0.2),
                            blurRadius: 16, spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: SSizes.avatarMd / 2,
                        backgroundColor: isDark
                            ? SColors.darkElevated
                            : SColors.primarySurface,
                        backgroundImage: avatar != null
                            ? NetworkImage(avatar!)
                            : null,
                        child: avatar == null
                            ? Text(
                                firstName.isNotEmpty
                                    ? firstName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700,
                                  color: SColors.primary,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      child: Stack(
        children: [
          // ── Base fill ──
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.5, 1.0],
                        colors: [
                          SColors.primary.withValues(alpha: 0.18),
                          SColors.screenShare.withValues(alpha: 0.06),
                          SColors.darkBg,
                        ],
                      )
                    : null,
                color: isDark ? null : SColors.blue50,
              ),
            ),
          ),

          // ── Swoosh accent curves ──
          Positioned.fill(
            child: CustomPaint(
              painter: SSwooshPainter(
                colors: [SColors.primary, SColors.screenShare],
                isDark: isDark,
                intensity: 0.8,
              ),
            ),
          ),

          // ── Floating orbs ──
          Positioned.fill(
            child: CustomPaint(
              painter: SOrbFieldPainter(
                colors: [
                  SColors.primary,
                  SColors.screenShare,
                  SColors.success,
                ],
                orbCount: 4,
                isDark: isDark,
                seed: 77,
              ),
            ),
          ),

          // ── Corner arc glow ──
          Positioned.fill(
            child: CustomPaint(
              painter: SCornerArcPainter(
                color: SColors.primary,
                radius: 180,
                corner: CornerPosition.topRight,
              ),
            ),
          ),

          // ── Dot Grid overlay ──
          Positioned.fill(
            child: CustomPaint(
              painter: SDotGridPainter(
                dotColor: isDark
                    ? SColors.primary.withValues(alpha: 0.06)
                    : SColors.primary.withValues(alpha: 0.04),
                spacing: 28,
                dotRadius: 0.8,
              ),
            ),
          ),

          // ── Grain texture ──
          Positioned.fill(
            child: CustomPaint(
              painter: SGrainPainter(opacity: isDark ? 0.025 : 0.015),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton placeholder for the user's name while loading.
class _NameSkeleton extends StatelessWidget {
  final bool isDark;
  const _NameSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, height: 24,
      decoration: BoxDecoration(
        color: isDark ? SColors.darkElevated : SColors.lightElevated,
        borderRadius: BorderRadius.circular(SSizes.radiusSm),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
      duration: 1200.ms,
      color: (isDark ? SColors.darkCard : SColors.lightBorder)
          .withValues(alpha: 0.6),
    );
  }
}

// ─────────────────────────────────────────────
//  Header Icon Button
// ─────────────────────────────────────────────
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final bool badge;
  final VoidCallback? onTap;

  const _HeaderIconButton({
    required this.icon, required this.isDark,
    this.badge = false, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap?.call(); },
      child: Container(
        width: 36, height: 36,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: isDark
              ? SColors.darkCard.withValues(alpha: 0.8)
              : SColors.lightElevated.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, size: 18,
              color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
            )),
            if (badge)
              Positioned(top: 6, right: 6, child: Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                  color: SColors.error, shape: BoxShape.circle,
                ),
              )),
          ],
        ),
      ),
    );
  }
}


