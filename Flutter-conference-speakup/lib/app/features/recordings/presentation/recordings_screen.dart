import 'package:flutter/material.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';

class RecordingsScreen extends StatelessWidget {
  const RecordingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Recordings')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 56,
              color: isDark ? SColors.darkMuted : SColors.lightMuted,
            ),
            const SizedBox(height: SSizes.md),
            Text(
              'No recordings yet',
              style: TextStyle(
                color: isDark
                    ? SColors.textDarkSecondary
                    : SColors.textLightSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
