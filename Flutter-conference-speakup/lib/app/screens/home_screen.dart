import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/card.dart';
import 'package:flutter_conference_speakup/app/components/ui/button.dart';
import 'package:flutter_conference_speakup/app/components/shapes/shapes.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';
import 'package:flutter_conference_speakup/store/auth_provider.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch fresh profile from backend on home load
    Future.microtask(() {
      ref.read(currentUserProvider.notifier).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = SResponsive.isMobile(context);
    final navPadding = isMobile ? 96.0 : 0.0;
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;
    final upcomingMeetings = ref.watch(meetingsProvider(null));
    final greeting = _greeting();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Collapsing Header ──
          SliverAppBar(
            expandedHeight: 240,
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
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? SColors.textDark : SColors.textLight,
              ),
            ),
            actions: [
              _HeaderIconButton(
                icon: SIcons.search,
                isDark: isDark,
                onTap: () {},
              ),
              _HeaderIconButton(
                icon: SIcons.notification,
                isDark: isDark,
                badge: true,
                onTap: () {},
              ),
              const SizedBox(width: SSizes.sm),
            ],
          ),

          // ── Body ──
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              SSizes.pagePadding, SSizes.md,
              SSizes.pagePadding, SSizes.pagePadding + navPadding,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Quick Actions ──
                _QuickActionsRow(isDark: isDark)
                    .animate().fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: SSizes.sectionSpacing),

                // ── AI Insights Banner ──
                _AIInsightsBanner(isDark: isDark)
                    .animate().fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: SSizes.sectionSpacing),

                // ── Upcoming Meetings ──
                _SectionHeader(
                  title: 'Upcoming Meetings',
                  actionLabel: 'See all',
                  onAction: () => context.go('/meetings'),
                ),
                const SizedBox(height: SSizes.sm),
                upcomingMeetings.when(
                  data: (meetings) {
                    final upcoming = meetings
                        .where((m) =>
                            m.status == MeetingStatus.scheduled ||
                            m.status == MeetingStatus.live)
                        .take(3).toList();
                    if (upcoming.isEmpty) {
                      return _EmptyState(
                        icon: SIcons.calendar,
                        message: 'No upcoming meetings',
                        subMessage: 'Your schedule is clear!',
                        isDark: isDark,
                      ).animate().fadeIn(duration: 300.ms);
                    }
                    return Column(
                      children: [
                        for (var i = 0; i < upcoming.length; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: i < upcoming.length - 1 ? SSizes.sm : 0,
                            ),
                            child: _MeetingTile(
                              meeting: upcoming[i],
                              isDark: isDark,
                              onTap: () => context.push('/meeting/${upcoming[i].id}'),
                            ).animate()
                                .fadeIn(duration: 400.ms, delay: (300 + i * 80).ms)
                                .slideX(begin: 0.05, end: 0),
                          ),
                      ],
                    );
                  },
                  loading: () => _MeetingsSkeleton(isDark: isDark),
                  error: (_, __) => _EmptyState(
                    icon: SIcons.calendar,
                    message: 'Unable to load meetings',
                    subMessage: 'Pull to refresh',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: SSizes.sectionSpacing),

                // ── Quick Stats ──
                _SectionHeader(title: 'This Week'),
                const SizedBox(height: SSizes.sm),
                _WeeklyStats(isDark: isDark)
                    .animate().fadeIn(duration: 400.ms, delay: 500.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: SSizes.sectionSpacing),

                // ── Recent Activity ──
                _SectionHeader(
                  title: 'Recent Activity',
                  actionLabel: 'View all',
                  onAction: () => context.go('/meetings'),
                ),
                const SizedBox(height: SSizes.sm),
                upcomingMeetings.when(
                  data: (meetings) {
                    final past = meetings
                        .where((m) => m.status == MeetingStatus.ended)
                        .take(3).toList();
                    if (past.isEmpty) {
                      return _EmptyState(
                        icon: SIcons.meetings,
                        message: 'No recent activity',
                        subMessage: 'Start your first meeting!',
                        isDark: isDark,
                      ).animate().fadeIn(duration: 300.ms);
                    }
                    return Column(
                      children: [
                        for (var i = 0; i < past.length; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: i < past.length - 1 ? SSizes.sm : 0,
                            ),
                            child: _RecentActivityTile(
                              meeting: past[i], isDark: isDark,
                            ),
                          ),
                      ],
                    );
                  },
                  loading: () => _MeetingsSkeleton(isDark: isDark),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ]),
            ),
          ),
        ],
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

    return ClipPath(
      clipper: SLiquidClipper(intensity: 1.2),
      child: Stack(
        children: [
          // ── Base gradient ──
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.5, 1.0],
                  colors: isDark
                      ? [
                          SColors.primary.withValues(alpha: 0.18),
                          SColors.screenShare.withValues(alpha: 0.06),
                          SColors.darkBg,
                        ]
                      : [
                          SColors.primary.withValues(alpha: 0.10),
                          SColors.blue50.withValues(alpha: 0.6),
                          SColors.lightBg,
                        ],
                ),
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

          // ── Content ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                SSizes.pagePadding, SSizes.xxl + SSizes.md,
                SSizes.pagePadding, SSizes.lg + 20,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(greeting, style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500,
                          color: isDark
                              ? SColors.textDarkSecondary
                              : SColors.textLightSecondary,
                          letterSpacing: 0.2,
                        )),
                        const SizedBox(height: SSizes.xs),
                        if (isLoading && firstName.isEmpty)
                          _NameSkeleton(isDark: isDark)
                        else
                          Text(
                            firstName.isNotEmpty ? firstName : 'Welcome',
                            style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w700,
                              color: isDark ? SColors.textDark : SColors.textLight,
                              letterSpacing: -0.5,
                            ),
                          ),
                        const SizedBox(height: SSizes.xs),
                        Text(
                          DateFormat('EEEE, MMMM d').format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? SColors.textDarkTertiary
                                : SColors.textLightTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SSizes.md),
                  // Avatar with ripple rings behind it
                  SizedBox(
                    width: SSizes.avatarLg + 24,
                    height: SSizes.avatarLg + 24,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ripple rings behind avatar
                        CustomPaint(
                          size: Size(SSizes.avatarLg + 24, SSizes.avatarLg + 24),
                          painter: SRippleRingsPainter(
                            color: SColors.primary,
                            ringCount: 3,
                            maxRadius: (SSizes.avatarLg + 24) / 2,
                            strokeWidth: 0.8,
                          ),
                        ),
                        // Avatar
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: SColors.primary.withValues(alpha: 0.4),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: SColors.primary.withValues(alpha: 0.25),
                                blurRadius: 24, spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: SSizes.avatarLg / 2,
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
                                      fontSize: 22, fontWeight: FontWeight.w700,
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
      width: 120, height: 28,
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
        width: 40, height: 40,
        margin: const EdgeInsets.only(right: SSizes.xs),
        decoration: BoxDecoration(
          color: isDark
              ? SColors.darkCard.withValues(alpha: 0.8)
              : SColors.lightElevated.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, size: 20,
              color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
            )),
            if (badge)
              Positioned(top: 8, right: 8, child: Container(
                width: 8, height: 8,
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

// ─────────────────────────────────────────────
//  Quick Actions Row
// ─────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  final bool isDark;
  const _QuickActionsRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionChip(
          icon: Icons.videocam_rounded, label: 'New Meeting',
          gradient: SColors.primaryGradient,
          textColor: Colors.white,
          onTap: () => context.push('/join'),
        ),
        const SizedBox(width: SSizes.sm + 2),
        _ActionChip(
          icon: Icons.login_rounded, label: 'Join',
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderColor: isDark ? SColors.darkBorder : SColors.lightBorder,
          textColor: isDark ? SColors.textDark : SColors.textLight,
          iconColor: SColors.primary,
          onTap: () => context.push('/join'),
        ),
        const SizedBox(width: SSizes.sm + 2),
        _ActionChip(
          icon: Icons.calendar_today_rounded, label: 'Schedule',
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderColor: isDark ? SColors.darkBorder : SColors.lightBorder,
          textColor: isDark ? SColors.textDark : SColors.textLight,
          iconColor: SColors.screenShare,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final Gradient? gradient;
  final Color? color;
  final Color? borderColor;
  final Color textColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.icon, required this.label,
    this.gradient, this.color, this.borderColor,
    required this.textColor, this.iconColor, this.onTap,
  });

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: SSizes.md + 2, horizontal: SSizes.sm),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              color: widget.gradient == null ? widget.color : null,
              borderRadius: BorderRadius.circular(SSizes.radiusLg),
              border: widget.borderColor != null
                  ? Border.all(color: widget.borderColor!) : null,
              boxShadow: widget.gradient != null
                  ? [BoxShadow(
                      color: SColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16, offset: const Offset(0, 4),
                    )]
                  : null,
            ),
            child: Column(
              children: [
                Icon(widget.icon, color: widget.iconColor ?? widget.textColor, size: SSizes.iconLg),
                const SizedBox(height: SSizes.sm),
                Text(widget.label, style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: widget.textColor,
                ), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AI Insights Banner
// ─────────────────────────────────────────────
class _AIInsightsBanner extends StatelessWidget {
  final bool isDark;
  const _AIInsightsBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SSizes.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1A35), const Color(0xFF0F1A2E)]
              : [const Color(0xFFEEF2FF), const Color(0xFFF0F7FF)],
        ),
        borderRadius: BorderRadius.circular(SSizes.radiusLg),
        border: Border.all(
          color: SColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: SColors.accentGradient,
              borderRadius: BorderRadius.circular(SSizes.radiusMd),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: SSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Meeting Assistant', style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: isDark ? SColors.textDark : SColors.textLight,
                )),
                const SizedBox(height: 2),
                Text('Real-time transcription, smart suggestions & coaching',
                  style: TextStyle(fontSize: 12,
                    color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
            color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Section Header
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(
          fontSize: 17, fontWeight: FontWeight.w700,
          color: isDark ? SColors.textDark : SColors.textLight,
          letterSpacing: -0.3,
        )),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!, style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500, color: SColors.primary,
            )),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Meeting Tile
// ─────────────────────────────────────────────
class _MeetingTile extends StatelessWidget {
  final MeetingModel meeting;
  final bool isDark;
  final VoidCallback? onTap;

  const _MeetingTile({required this.meeting, required this.isDark, this.onTap});

  @override
  Widget build(BuildContext context) {
    final timeStr = meeting.scheduledAt != null
        ? DateFormat('h:mm a').format(meeting.scheduledAt!) : 'Now';

    return SCard(
      onTap: onTap, hasBorder: true,
      padding: const EdgeInsets.all(SSizes.cardPadding),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: meeting.isLive
                  ? SColors.success.withValues(alpha: 0.12)
                  : SColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(SSizes.radiusMd),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (meeting.isLive)
                  Container(width: 8, height: 8, decoration: const BoxDecoration(
                    color: SColors.success, shape: BoxShape.circle,
                  ))
                else
                  Icon(SIcons.clock, size: 18,
                    color: meeting.isLive ? SColors.success : SColors.primary,
                  ),
                const SizedBox(height: 2),
                Text(
                  meeting.isLive ? 'LIVE' : timeStr,
                  style: TextStyle(
                    fontSize: meeting.isLive ? 9 : 10,
                    fontWeight: FontWeight.w700,
                    color: meeting.isLive ? SColors.success : SColors.primary,
                    letterSpacing: meeting.isLive ? 0.5 : 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meeting.title, style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600,
                  color: isDark ? SColors.textDark : SColors.textLight,
                ), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: SSizes.xs),
                Row(children: [
                  if (meeting.hostName != null) ...[
                    Icon(SIcons.profile, size: 12,
                      color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary),
                    const SizedBox(width: 4),
                    Text(meeting.hostName!, style: TextStyle(fontSize: 12,
                      color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                    const SizedBox(width: SSizes.sm),
                  ],
                  Icon(Icons.people_outline_rounded, size: 12,
                    color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary),
                  const SizedBox(width: 4),
                  Text('${meeting.participantCount}', style: TextStyle(fontSize: 12,
                    color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ]),
              ],
            ),
          ),
          if (meeting.isLive)
            SButton(
              text: 'Join', variant: SButtonVariant.primary,
              size: SButtonSize.sm, isFullWidth: false,
              onPressed: onTap,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Weekly Stats
// ─────────────────────────────────────────────
class _WeeklyStats extends StatelessWidget {
  final bool isDark;
  const _WeeklyStats({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: 'Meetings', value: '—', icon: SIcons.meetings,
          color: SColors.primary, isDark: isDark),
        const SizedBox(width: SSizes.sm + 2),
        _StatCard(label: 'Hours', value: '—', icon: SIcons.clock,
          color: SColors.screenShare, isDark: isDark),
        const SizedBox(width: SSizes.sm + 2),
        _StatCard(label: 'AI Insights', value: '—', icon: Icons.auto_awesome_outlined,
          color: SColors.success, isDark: isDark),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.label, required this.value,
    required this.icon, required this.color, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SCard(
        hasBorder: true,
        padding: const EdgeInsets.all(SSizes.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(SSizes.radiusSm),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: SSizes.sm + 2),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
              color: isDark ? SColors.textDark : SColors.textLight)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11,
              color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Recent Activity Tile
// ─────────────────────────────────────────────
class _RecentActivityTile extends StatelessWidget {
  final MeetingModel meeting;
  final bool isDark;
  const _RecentActivityTile({required this.meeting, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final date = meeting.endedAt ?? meeting.createdAt;
    return SCard(
      hasBorder: true,
      padding: const EdgeInsets.symmetric(horizontal: SSizes.cardPadding, vertical: SSizes.sm + 4),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isDark ? SColors.darkElevated : SColors.lightElevated,
              borderRadius: BorderRadius.circular(SSizes.radiusSm),
            ),
            child: Icon(SIcons.meetings, size: 18,
              color: isDark ? SColors.darkMuted : SColors.lightMuted),
          ),
          const SizedBox(width: SSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meeting.title, style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500,
                  color: isDark ? SColors.textDark : SColors.textLight,
                ), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(DateFormat('MMM d, h:mm a').format(date), style: TextStyle(
                  fontSize: 12,
                  color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
                )),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 20,
            color: isDark ? SColors.darkMuted : SColors.lightMuted),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Skeleton Loading
// ─────────────────────────────────────────────
class _MeetingsSkeleton extends StatelessWidget {
  final bool isDark;
  const _MeetingsSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(2, (i) => Padding(
        padding: EdgeInsets.only(bottom: i < 1 ? SSizes.sm : 0),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? SColors.darkCard : SColors.lightCard,
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
            border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder),
          ),
        ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 1200.ms,
          color: (isDark ? SColors.darkElevated : SColors.lightElevated).withValues(alpha: 0.5),
        ),
      )),
    );
  }
}

// ─────────────────────────────────────────────
//  Empty State
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subMessage;
  final bool isDark;

  const _EmptyState({
    required this.icon, required this.message,
    required this.subMessage, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SCard(
      hasBorder: true,
      padding: const EdgeInsets.symmetric(vertical: SSizes.xl, horizontal: SSizes.md),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(SSizes.md),
              decoration: BoxDecoration(
                color: isDark ? SColors.darkElevated : SColors.lightElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28,
                color: isDark ? SColors.darkMuted : SColors.lightMuted),
            ),
            const SizedBox(height: SSizes.md),
            Text(message, style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: isDark ? SColors.textDark : SColors.textLight,
            )),
            const SizedBox(height: SSizes.xs),
            Text(subMessage, style: TextStyle(
              fontSize: 13,
              color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
            )),
          ],
        ),
      ),
    );
  }
}
