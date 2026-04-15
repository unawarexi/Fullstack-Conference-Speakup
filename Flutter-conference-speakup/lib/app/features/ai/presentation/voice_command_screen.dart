import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/analytics_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// Voice Command History — shows all voice commands used and their outcomes.
class VoiceCommandScreen extends ConsumerWidget {
  const VoiceCommandScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analyticsAsync = ref.watch(meetingAnalyticsProvider('latest'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Commands'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: ListView(
        padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
        children: [
          // Quick commands
          Container(
            padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)]),
              borderRadius: BorderRadius.circular(SSizes.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.mic_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text('Voice Assistant', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Say "Hey SpeakUp" followed by a command', style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Available Commands', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
          _CommandTile(command: '"Summarize this meeting"', desc: 'Get an instant AI summary of the current discussion', icon: Icons.summarize_rounded, isDark: isDark),
          _CommandTile(command: '"Create action item for [person]"', desc: 'Assign a task to a participant mid-meeting', icon: Icons.task_alt_rounded, isDark: isDark),
          _CommandTile(command: '"What did [person] say about [topic]?"', desc: 'Search through meeting history for specific context', icon: Icons.search_rounded, isDark: isDark),
          _CommandTile(command: '"Start recording"', desc: 'Begin meeting recording and transcription', icon: Icons.fiber_manual_record_rounded, isDark: isDark),
          _CommandTile(command: '"Mute everyone"', desc: 'Mute all participants (host only)', icon: Icons.mic_off_rounded, isDark: isDark),
          _CommandTile(command: '"Share my screen"', desc: 'Start screen sharing', icon: Icons.screen_share_rounded, isDark: isDark),
          _CommandTile(command: '"Schedule follow-up"', desc: 'Create a follow-up meeting with participants', icon: Icons.calendar_today_rounded, isDark: isDark),
          _CommandTile(command: '"What\'s on the agenda?"', desc: 'Read out the current meeting agenda', icon: Icons.list_alt_rounded, isDark: isDark),
          const SizedBox(height: 16),
          Text('Recent Usage', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
          analyticsAsync.when(
            loading: () => const AILoadingState(message: 'Loading command history...'),
            error: (e, _) => AIErrorState(message: e.toString(), onRetry: () => ref.invalidate(meetingAnalyticsProvider('latest'))),
            data: (data) {
              final history = (data['voiceCommandHistory'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              final stats = data['voiceCommandStats'] as Map<String, dynamic>? ?? {};
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (history.isEmpty)
                    const AIEmptyState(icon: Icons.mic_off_rounded, message: 'No voice commands yet', subMessage: 'Try saying "Hey SpeakUp" followed by a command')
                  else
                    ...history.map((h) => _HistoryTile(
                      command: h['command'] as String? ?? '',
                      time: h['time'] as String? ?? '',
                      status: h['status'] as String? ?? 'completed',
                      isDark: isDark,
                    )),
                  const SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
                    decoration: BoxDecoration(
                      color: isDark ? SColors.darkCard : SColors.lightCard,
                      borderRadius: BorderRadius.circular(SSizes.radiusMd),
                      border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('This Week', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                        const SizedBox(height: 8),
                        _StatRow(label: 'Commands used', value: '${stats['commandsUsed'] ?? 0}', isDark: isDark),
                        _StatRow(label: 'Success rate', value: '${stats['successRate'] ?? 0}%', isDark: isDark),
                        _StatRow(label: 'Most used', value: '"${stats['mostUsed'] ?? 'N/A'}"', isDark: isDark),
                        _StatRow(label: 'Time saved', value: '~${stats['timeSaved'] ?? 0} min', isDark: isDark),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ].animate(interval: 40.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
      ),
    ),
    );
  }
}

class _CommandTile extends StatelessWidget {
  final String command;
  final String desc;
  final IconData icon;
  final bool isDark;
  const _CommandTile({required this.command, required this.desc, required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: SColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(command, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                  Text(desc, style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final String command;
  final String time;
  final String status;
  final bool isDark;
  const _HistoryTile({required this.command, required this.time, required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final success = status == 'completed';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
          border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(success ? Icons.check_circle_rounded : Icons.error_rounded, size: 16, color: success ? SColors.success : SColors.error),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('"$command"', style: TextStyle(fontSize: 12, color: isDark ? SColors.textDark : SColors.textLight)),
                  Text(time, style: TextStyle(fontSize: 10, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _StatRow({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
        ],
      ),
);
  }
}
