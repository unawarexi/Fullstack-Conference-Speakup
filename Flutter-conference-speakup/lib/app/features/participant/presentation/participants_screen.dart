import 'package:flutter/material.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';
import 'package:video_confrence_app/app/components/ui/input.dart';

class ParticipantsScreen extends StatelessWidget {
  final String meetingId;

  const ParticipantsScreen({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(SSizes.pagePadding),
            child: SSearchBar(
              hint: 'Search participants...',
              onChanged: (q) {},
            ),
          ),
          Expanded(
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
    );
  }
}
