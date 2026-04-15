import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/meetings_list_widgets.dart';

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
            ? ListSearchField(
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
          child: ListTabBar(controller: _tabController, isDark: isDark),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListMeetingsTab(status: 'SCHEDULED', searchQuery: _searchController.text),
          ListMeetingsTab(status: 'ENDED', searchQuery: _searchController.text),
          ListMeetingsTab(status: 'RECURRING', searchQuery: _searchController.text),
        ],
      ),
    );
  }
}

