import 'package:flutter/material.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';
import 'package:video_confrence_app/core/constants/text_strings.dart';

class MeetingsListScreen extends StatelessWidget {
  const MeetingsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(STexts.meetings),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: SColors.primary,
              unselectedLabelColor:
                  isDark ? SColors.darkMuted : SColors.lightMuted,
              indicatorColor: SColors.primary,
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
                Tab(text: 'Recurring'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _EmptyMeetings(label: 'No upcoming meetings'),
                  _EmptyMeetings(label: 'No past meetings'),
                  _EmptyMeetings(label: 'No recurring meetings'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMeetings extends StatelessWidget {
  final String label;
  const _EmptyMeetings({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 56,
            color: isDark ? SColors.darkMuted : SColors.lightMuted,
          ),
          const SizedBox(height: SSizes.md),
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? SColors.textDarkSecondary
                  : SColors.textLightSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
