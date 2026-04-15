import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';

class MeetingsScreen extends StatelessWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Meetings'),
          bottom: TabBar(
            indicatorColor: SColors.primary,
            labelColor: SColors.primary,
            unselectedLabelColor:
                isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
              Tab(text: 'Recordings'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MeetingsList(type: 'upcoming'),
            _MeetingsList(type: 'past'),
            _MeetingsList(type: 'recordings'),
          ],
        ),
      ),
    );
  }
}

class _MeetingsList extends StatelessWidget {
  final String type;
  const _MeetingsList({required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Placeholder — will be replaced with real data
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note_outlined,
            size: 56,
            color: isDark ? SColors.darkMuted : SColors.lightMuted,
          ),
          const SizedBox(height: SSizes.md),
          Text(
            'No $type meetings',
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
