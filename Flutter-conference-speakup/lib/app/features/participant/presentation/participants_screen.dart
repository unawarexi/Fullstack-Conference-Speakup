import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/input.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';

class ParticipantsScreen extends ConsumerWidget {
  final String meetingId;

  const ParticipantsScreen({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Future<void> onRefresh() async {
      ref.invalidate(meetingParticipantsProvider(meetingId));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Participants'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mute All'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        color: SColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.all(SSizes.pagePadding),
              child: SSearchBar(
                hint: 'Search participants...',
                onChanged: (q) {},
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Text(
                  'No participants',
                  style: TextStyle(
                    color: isDark
                        ? SColors.textDarkSecondary
                        : SColors.textLightSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
