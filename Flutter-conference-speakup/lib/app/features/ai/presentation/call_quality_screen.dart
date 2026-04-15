import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/analytics_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// Call Quality Analytics — network, audio, and video quality metrics.
class CallQualityScreen extends ConsumerWidget {
  const CallQualityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analyticsAsync = ref.watch(meetingAnalyticsProvider('latest'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Quality'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: ListView(
        padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
        children: [
          // Overall Score
          analyticsAsync.when(
            loading: () => const AILoadingState(message: 'Loading call quality...'),
            error: (e, _) => AIErrorState(message: e.toString(), onRetry: () => ref.invalidate(meetingAnalyticsProvider('latest'))),
            data: (data) {
              final cq = data['callQuality'] as Map<String, dynamic>? ?? {};
              final overallScore = cq['overallScore'] as int? ?? 0;
              final quality = overallScore >= 90 ? 'Excellent' : overallScore >= 70 ? 'Good' : overallScore >= 50 ? 'Fair' : 'Poor';
              final gradientColors = overallScore >= 70
                  ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                  : [const Color(0xFFF59E0B), const Color(0xFFFBBF24)];
              final metrics = cq['metrics'] as Map<String, dynamic>? ?? {};
              final audio = cq['audio'] as Map<String, dynamic>? ?? {};
              final video = cq['video'] as Map<String, dynamic>? ?? {};
              final issues = (cq['issues'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(SSizes.lg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(SSizes.radiusMd),
                    ),
                    child: Column(
                      children: [
                        const Text('Overall Quality', style: TextStyle(fontSize: 13, color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text(quality, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text('$overallScore / 100', style: const TextStyle(fontSize: 14, color: Colors.white60)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _MetricTile(title: 'Latency', value: metrics['latency'] as String? ?? 'N/A', icon: Icons.speed_rounded, status: metrics['latencyStatus'] as String? ?? 'good', isDark: isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _MetricTile(title: 'Packet Loss', value: metrics['packetLoss'] as String? ?? 'N/A', icon: Icons.signal_wifi_off_rounded, status: metrics['packetLossStatus'] as String? ?? 'good', isDark: isDark)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _MetricTile(title: 'Jitter', value: metrics['jitter'] as String? ?? 'N/A', icon: Icons.graphic_eq_rounded, status: metrics['jitterStatus'] as String? ?? 'good', isDark: isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _MetricTile(title: 'Bitrate', value: metrics['bitrate'] as String? ?? 'N/A', icon: Icons.download_rounded, status: metrics['bitrateStatus'] as String? ?? 'good', isDark: isDark)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Audio Quality', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                  const SizedBox(height: 8),
                  _DetailRow(label: 'Codec', value: audio['codec'] as String? ?? 'N/A', isDark: isDark),
                  _DetailRow(label: 'Echo cancellation', value: audio['echoCancellation'] as String? ?? 'N/A', isDark: isDark),
                  _DetailRow(label: 'Noise suppression', value: audio['noiseSuppression'] as String? ?? 'N/A', isDark: isDark),
                  _DetailRow(label: 'Audio level', value: audio['audioLevel'] as String? ?? 'N/A', isDark: isDark),
                  const SizedBox(height: 16),
                  Text('Video Quality', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                  const SizedBox(height: 8),
                  _DetailRow(label: 'Resolution', value: video['resolution'] as String? ?? 'N/A', isDark: isDark),
                  _DetailRow(label: 'Codec', value: video['codec'] as String? ?? 'N/A', isDark: isDark),
                  _DetailRow(label: 'Bandwidth adapt.', value: video['bandwidthAdapt'] as String? ?? 'N/A', isDark: isDark),
                  _DetailRow(label: 'Frame drops', value: video['frameDrops'] as String? ?? 'N/A', isDark: isDark),
                  const SizedBox(height: 16),
                  Text('Recent Issues', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                  const SizedBox(height: 8),
                  if (issues.isEmpty)
                    Text('No recent issues', style: TextStyle(fontSize: 12, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary))
                  else
                    ...issues.map((i) => _IssueTile(
                      time: i['time'] as String? ?? '',
                      issue: i['issue'] as String? ?? '',
                      severity: i['severity'] as String? ?? 'low',
                      isDark: isDark,
                    )),
                ],
              );
            },
          ),
        ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
      ),
    ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String status;
  final bool isDark;
  const _MetricTile({required this.title, required this.value, required this.icon, required this.status, required this.isDark});

  Color get _statusColor {
    switch (status) {
      case 'good': return SColors.success;
      case 'warn': return SColors.warning;
      default: return SColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
      decoration: BoxDecoration(
        color: isDark ? SColors.darkCard : SColors.lightCard,
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
        border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _statusColor),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _DetailRow({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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

class _IssueTile extends StatelessWidget {
  final String time;
  final String issue;
  final String severity;
  final bool isDark;
  const _IssueTile({required this.time, required this.issue, required this.severity, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = severity == 'medium' ? SColors.warning : SColors.info;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.08 : 0.05),
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
            const SizedBox(width: 10),
            Expanded(child: Text(issue, style: TextStyle(fontSize: 12, color: isDark ? SColors.textDark : SColors.textLight))),
          ],
        ),
      ),
);
  }
}
