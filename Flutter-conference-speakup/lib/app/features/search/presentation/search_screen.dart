import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/app/domain/models/user_model.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';
import 'package:flutter_conference_speakup/store/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late final TabController _tabCtrl;
  final _recentSearches = <String>['Flutter meeting', 'Design review', 'John'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
      appBar: AppBar(
        titleSpacing: 0,
        title: SSearchBar(
          controller: _searchCtrl,
          hint: 'Search people, meetings...',
          autofocus: true,
          onChanged: _onSearch,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel', style: TextStyle(
              fontSize: 15, color: SColors.primary,
            )),
          ),
        ],
      ),
      body: query.isEmpty
          ? _RecentSearches(
              searches: _recentSearches,
              isDark: isDark,
              onTap: (s) {
                _searchCtrl.text = s;
                _onSearch(s);
              },
              onClear: () => setState(() => _recentSearches.clear()),
            )
          : Column(
              children: [
                // Tab bar
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? SColors.darkBorder : SColors.lightBorder,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabCtrl,
                    labelColor: SColors.primary,
                    unselectedLabelColor: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
                    indicatorColor: SColors.primary,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'People'),
                      Tab(text: 'Meetings'),
                    ],
                  ),
                ),

                // Results
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _AllResults(resultsAsync: resultsAsync, isDark: isDark),
                      _PeopleResults(resultsAsync: resultsAsync, isDark: isDark),
                      _MeetingResults(resultsAsync: resultsAsync, isDark: isDark),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  final List<String> searches;
  final bool isDark;
  final ValueChanged<String> onTap;
  final VoidCallback onClear;

  const _RecentSearches({
    required this.searches,
    required this.isDark,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) {
      return const EmptyState(
        icon: CupertinoIcons.search,
        message: 'Search for anything',
        subMessage: 'Find people, meetings, and conversations',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text('Recent', style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: isDark ? SColors.textDark : SColors.textLight,
            )),
            const Spacer(),
            GestureDetector(
              onTap: onClear,
              child: Text('Clear', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: SColors.primary,
              )),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...searches.map((s) => DenseTile(
          icon: CupertinoIcons.clock,
          title: s,
          onTap: () => onTap(s),
          showChevron: true,
        )),
      ],
    );
  }
}

class _AllResults extends StatelessWidget {
  final AsyncValue<Map<String, dynamic>> resultsAsync;
  final bool isDark;

  const _AllResults({required this.resultsAsync, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return resultsAsync.when(
      data: (data) {
        final users = (data['users'] as List<UserModel>?) ?? [];
        final meetings = (data['meetings'] as List<MeetingModel>?) ?? [];
        if (users.isEmpty && meetings.isEmpty) {
          return const EmptyState(
            icon: CupertinoIcons.search,
            message: 'No results found',
            subMessage: 'Try a different search term',
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (users.isNotEmpty) ...[
              SectionHeader(title: 'People', actionLabel: '${users.length} found'),
              ...users.take(5).map((u) => DenseTile(
                leading: SAvatar(name: u.fullName, imageUrl: u.avatar, size: 36),
                title: u.fullName,
                subtitle: u.email,
                showChevron: true,
                onTap: () {},
              )).toList(),
              const SizedBox(height: 16),
            ],
            if (meetings.isNotEmpty) ...[
              SectionHeader(title: 'Meetings', actionLabel: '${meetings.length} found'),
              ...meetings.take(5).map((m) => DenseTile(
                icon: m.isLive ? CupertinoIcons.video_camera_solid : CupertinoIcons.calendar,
                iconColor: m.isLive ? SColors.error : SColors.primary,
                title: m.title,
                subtitle: m.description ?? '${m.participantCount} participants',
                trailing: m.isLive ? StatusBadge.live() : null,
                showChevron: true,
                onTap: () => context.push('/meeting-detail/${m.id}'),
              )).toList(),
            ],
          ],
        );
      },
      loading: () => Center(child: CupertinoActivityIndicator(color: SColors.primary)),
      error: (e, _) => EmptyState(
        icon: CupertinoIcons.exclamationmark_triangle,
        message: 'Search failed',
        actionLabel: 'Retry',
        onAction: () {},
      ),
    );
  }
}

class _PeopleResults extends StatelessWidget {
  final AsyncValue<Map<String, dynamic>> resultsAsync;
  final bool isDark;

  const _PeopleResults({required this.resultsAsync, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return resultsAsync.when(
      data: (data) {
        final users = (data['users'] as List<UserModel>?) ?? [];
        if (users.isEmpty) {
          return const EmptyState(
            icon: CupertinoIcons.person_2,
            message: 'No people found',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (_, i) {
            final u = users[i];
            return DenseTile(
              leading: SAvatar(
                name: u.fullName,
                imageUrl: u.avatar,
                size: 40,
                showOnline: true,
                isOnline: u.isOnline,
              ),
              title: u.fullName,
              subtitle: u.bio ?? u.email,
              showChevron: true,
              onTap: () {},
            ).animate().fadeIn(duration: 150.ms, delay: (30 * i).ms);
          },
        );
      },
      loading: () => Center(child: CupertinoActivityIndicator(color: SColors.primary)),
      error: (_, __) => const EmptyState(icon: CupertinoIcons.exclamationmark_triangle, message: 'Failed'),
    );
  }
}

class _MeetingResults extends StatelessWidget {
  final AsyncValue<Map<String, dynamic>> resultsAsync;
  final bool isDark;

  const _MeetingResults({required this.resultsAsync, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return resultsAsync.when(
      data: (data) {
        final meetings = (data['meetings'] as List<MeetingModel>?) ?? [];
        if (meetings.isEmpty) {
          return const EmptyState(
            icon: CupertinoIcons.video_camera,
            message: 'No meetings found',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: meetings.length,
          itemBuilder: (_, i) {
            final m = meetings[i];
            return DenseTile(
              icon: m.isLive ? CupertinoIcons.video_camera_solid : CupertinoIcons.calendar,
              iconColor: m.isLive ? SColors.error : SColors.primary,
              title: m.title,
              subtitle: '${m.participantCount} participants · ${m.status.name}',
              trailing: m.isLive ? StatusBadge.live() : null,
              showChevron: true,
              onTap: () => context.push('/meeting-detail/${m.id}'),
            ).animate().fadeIn(duration: 150.ms, delay: (30 * i).ms);
          },
        );
      },
      loading: () => Center(child: CupertinoActivityIndicator(color: SColors.primary)),
      error: (_, __) => const EmptyState(icon: CupertinoIcons.exclamationmark_triangle, message: 'Failed'),
    );
  }
}
