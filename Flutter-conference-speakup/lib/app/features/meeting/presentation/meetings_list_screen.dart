import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/card.dart';
import 'package:flutter_conference_speakup/app/components/ui/button.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';

class MeetingsListScreen extends ConsumerStatefulWidget {
  const MeetingsListScreen({super.key});

  @override
  ConsumerState<MeetingsListScreen> createState() => _MeetingsListScreenState();
}

class _MeetingsListScreenState extends ConsumerState<MeetingsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _isSearching
            ? _SearchField(
                controller: _searchController,
                isDark: isDark,
                onClose: () => setState(() {
                  _isSearching = false;
                  _searchController.clear();
                }),
              )
            : Text('Meetings', style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700,
                color: isDark ? SColors.textDark : SColors.textLight,
              )),
        actions: [
          if (!_isSearching)
            IconButton(
              onPressed: () => setState(() => _isSearching = true),
              icon: Icon(SIcons.search, size: 22,
                color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
            ),
          IconButton(
            onPressed: () => context.push('/join'),
            icon: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: SColors.primary,
                borderRadius: BorderRadius.circular(SSizes.radiusSm),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: SSizes.xs),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _TabBarWidget(controller: _tabController, isDark: isDark),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MeetingsList(status: 'SCHEDULED', searchQuery: _searchController.text),
          _MeetingsList(status: 'ENDED', searchQuery: _searchController.text),
          _MeetingsList(status: 'RECURRING', searchQuery: _searchController.text),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Custom Tab Bar
// ─────────────────────────────────────────────
class _TabBarWidget extends StatelessWidget {
  final TabController controller;
  final bool isDark;

  const _TabBarWidget({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: SSizes.pagePadding),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? SColors.darkCard : SColors.lightElevated,
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: isDark ? SColors.darkElevated : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusSm + 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: isDark ? SColors.textDark : SColors.textLight,
        unselectedLabelColor: isDark ? SColors.darkMuted : SColors.lightMuted,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'Upcoming', height: 36),
          Tab(text: 'Past', height: 36),
          Tab(text: 'Recurring', height: 36),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Search Field
// ─────────────────────────────────────────────
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onClose;

  const _SearchField({
    required this.controller, required this.isDark, required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? SColors.darkCard : SColors.lightElevated,
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? SColors.textDark : SColors.textLight,
        ),
        decoration: InputDecoration(
          hintText: 'Search meetings...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: isDark ? SColors.darkMuted : SColors.lightMuted,
          ),
          prefixIcon: Icon(SIcons.search, size: 18,
            color: isDark ? SColors.darkMuted : SColors.lightMuted),
          suffixIcon: IconButton(
            icon: Icon(Icons.close_rounded, size: 18,
              color: isDark ? SColors.darkMuted : SColors.lightMuted),
            onPressed: onClose,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Meetings List (per tab)
// ─────────────────────────────────────────────
class _MeetingsList extends ConsumerWidget {
  final String status;
  final String searchQuery;

  const _MeetingsList({required this.status, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meetingsAsync = ref.watch(meetingsProvider(status));

    return meetingsAsync.when(
      data: (meetings) {
        final filtered = searchQuery.isEmpty
            ? meetings
            : meetings.where((m) =>
                m.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();

        if (filtered.isEmpty) {
          return _EmptyMeetings(status: status, isDark: isDark);
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            SSizes.pagePadding, SSizes.md,
            SSizes.pagePadding, SSizes.pagePadding + 96,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < filtered.length - 1 ? SSizes.sm : 0,
              ),
              child: _MeetingCard(
                meeting: filtered[index], isDark: isDark,
              ).animate()
                  .fadeIn(duration: 300.ms, delay: (index * 60).ms)
                  .slideX(begin: 0.03, end: 0),
            );
          },
        );
      },
      loading: () => _LoadingSkeleton(isDark: isDark),
      error: (_, __) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48,
              color: isDark ? SColors.darkMuted : SColors.lightMuted),
            const SizedBox(height: SSizes.md),
            Text('Failed to load meetings', style: TextStyle(
              color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
            )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Meeting Card
// ─────────────────────────────────────────────
class _MeetingCard extends StatelessWidget {
  final MeetingModel meeting;
  final bool isDark;

  const _MeetingCard({required this.meeting, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUpcoming = meeting.status == MeetingStatus.scheduled;
    final timeStr = meeting.scheduledAt != null
        ? DateFormat('MMM d · h:mm a').format(meeting.scheduledAt!)
        : meeting.endedAt != null
            ? DateFormat('MMM d · h:mm a').format(meeting.endedAt!)
            : '';

    return SCard(
      onTap: () {
        if (meeting.isLive) {
          context.push('/meeting/${meeting.id}');
        }
      },
      hasBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status dot
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: meeting.isLive
                      ? SColors.success
                      : isUpcoming ? SColors.primary : SColors.darkMuted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: SSizes.sm + 2),
              Expanded(
                child: Text(meeting.title, style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600,
                  color: isDark ? SColors.textDark : SColors.textLight,
                ), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (meeting.isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: SSizes.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: SColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(SSizes.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(
                        color: SColors.success, shape: BoxShape.circle,
                      )),
                      const SizedBox(width: 4),
                      const Text('LIVE', style: TextStyle(
                        color: SColors.success, fontSize: 10, fontWeight: FontWeight.w700,
                      )),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: SSizes.sm + 2),
          Row(
            children: [
              Icon(SIcons.clock, size: 14,
                color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary),
              const SizedBox(width: 4),
              Text(timeStr, style: TextStyle(fontSize: 12,
                color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
              const SizedBox(width: SSizes.md),
              Icon(Icons.people_outline_rounded, size: 14,
                color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary),
              const SizedBox(width: 4),
              Text('${meeting.participantCount}', style: TextStyle(fontSize: 12,
                color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
              if (meeting.hasPassword) ...[
                const SizedBox(width: SSizes.sm),
                Icon(SIcons.lock, size: 12,
                  color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary),
              ],
            ],
          ),
          if (meeting.isLive || isUpcoming) ...[
            const SizedBox(height: SSizes.md),
            Row(
              children: [
                Expanded(
                  child: SButton(
                    text: meeting.isLive ? 'Join Now' : 'Join Meeting',
                    variant: meeting.isLive
                        ? SButtonVariant.primary
                        : SButtonVariant.outline,
                    size: SButtonSize.sm,
                    onPressed: () => context.push('/meeting/${meeting.id}'),
                  ),
                ),
                const SizedBox(width: SSizes.sm),
                GestureDetector(
                  onTap: () { HapticFeedback.lightImpact(); },
                  child: Container(
                    width: SSizes.buttonHeightSm,
                    height: SSizes.buttonHeightSm,
                    decoration: BoxDecoration(
                      color: isDark ? SColors.darkElevated : SColors.lightElevated,
                      borderRadius: BorderRadius.circular(SSizes.radiusSm),
                    ),
                    child: Icon(SIcons.moreOptions, size: 18,
                      color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Empty State
// ─────────────────────────────────────────────
class _EmptyMeetings extends StatelessWidget {
  final String status;
  final bool isDark;
  const _EmptyMeetings({required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final (icon, message, sub) = switch (status) {
      'SCHEDULED' => (SIcons.calendar, 'No upcoming meetings',
          'Schedule a meeting or join one to get started'),
      'ENDED' => (SIcons.clock, 'No past meetings',
          'Your meeting history will appear here'),
      _ => (Icons.repeat_rounded, 'No recurring meetings',
          'Set up recurring meetings for regular check-ins'),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SSizes.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: isDark ? SColors.darkCard : SColors.lightElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32,
                color: isDark ? SColors.darkMuted : SColors.lightMuted),
            ),
            const SizedBox(height: SSizes.lg),
            Text(message, style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w600,
              color: isDark ? SColors.textDark : SColors.textLight,
            )),
            const SizedBox(height: SSizes.sm),
            Text(sub, textAlign: TextAlign.center, style: TextStyle(
              fontSize: 13,
              color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
            )),
            const SizedBox(height: SSizes.lg),
            SButton(
              text: 'Create Meeting',
              variant: SButtonVariant.primary,
              size: SButtonSize.md,
              isFullWidth: false,
              prefixIcon: Icons.videocam_rounded,
              onPressed: () => context.push('/join'),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Loading Skeleton
// ─────────────────────────────────────────────
class _LoadingSkeleton extends StatelessWidget {
  final bool isDark;
  const _LoadingSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(SSizes.pagePadding),
      itemCount: 4,
      itemBuilder: (context, i) => Padding(
        padding: EdgeInsets.only(bottom: i < 3 ? SSizes.sm : 0),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: isDark ? SColors.darkCard : SColors.lightCard,
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
            border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder),
          ),
        ).animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms,
              color: (isDark ? SColors.darkElevated : SColors.lightElevated)
                  .withValues(alpha: 0.5)),
      ),
    );
  }
}
