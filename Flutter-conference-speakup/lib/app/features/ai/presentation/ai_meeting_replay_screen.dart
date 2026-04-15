import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// AI Meeting Replay — timeline with chapters, key clips, highlights.
class AIMeetingReplayScreen extends ConsumerWidget {
  final String meetingId;
  const AIMeetingReplayScreen({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final replayAsync = ref.watch(aiMemoryReplayProvider(meetingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Replay'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: replayAsync.when(
        loading: () => const AILoadingState(message: 'Loading replay…'),
        error: (err, _) => AIErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(aiMemoryReplayProvider(meetingId)),
        ),
        data: (data) {
          final title = data['title'] as String? ?? 'Meeting';
          final duration = data['duration'] as String? ?? '0:00';
          final chapters = (data['chapters'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          final moments = (data['key_moments'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          final engagement = (data['engagement_curve'] as List?)?.cast<num>() ?? [];

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
            children: [
              // Video placeholder
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: isDark ? SColors.darkCard : SColors.lightElevated,
                  borderRadius: BorderRadius.circular(SSizes.radiusMd),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_filled_rounded, size: 48, color: SColors.primary.withValues(alpha: 0.6)),
                      const SizedBox(height: 8),
                      Text('$title — $duration', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Chapters
              if (chapters.isNotEmpty) ...[
                Text('AI Chapters', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                const SizedBox(height: 8),
                ...chapters.map((c) => _ChapterTile(
                  time: c['time'] as String? ?? '',
                  title: c['title'] as String? ?? '',
                  isDark: isDark,
                  isHighlight: c['is_highlight'] as bool? ?? false,
                )),
                const SizedBox(height: 20),
              ],

              // Key moments
              if (moments.isNotEmpty) ...[
                Text('Key Moments', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                const SizedBox(height: 8),
                ...moments.map((m) {
                  final mType = m['type'] as String? ?? 'info';
                  final color = switch (mType) {
                    'decision' => SColors.success,
                    'conflict' => SColors.warning,
                    'promise' => SColors.primary,
                    _ => SColors.info,
                  };
                  return _MomentCard(
                    time: m['time'] as String? ?? '',
                    title: m['title'] as String? ?? '',
                    detail: m['detail'] as String? ?? '',
                    color: color,
                    isDark: isDark,
                  );
                }),
                const SizedBox(height: 20),
              ],

              // Engagement timeline
              if (engagement.isNotEmpty) ...[
                Text('Engagement Timeline', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                const SizedBox(height: 8),
                Container(
                  height: 60,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? SColors.darkCard : SColors.lightCard,
                    borderRadius: BorderRadius.circular(SSizes.radiusMd),
                    border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
                  ),
                  child: CustomPaint(painter: _EngagementPainter(points: engagement.map((e) => e.toDouble()).toList(), isDark: isDark)),
                ),
              ],

              if (chapters.isEmpty && moments.isEmpty)
                const AIEmptyState(icon: Icons.replay_rounded, message: 'No replay data available'),
            ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
          );
        },
      ),
    ),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final String time;
  final String title;
  final bool isDark;
  final bool isHighlight;
  const _ChapterTile({required this.time, required this.title, required this.isDark, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isHighlight
              ? SColors.primary.withValues(alpha: isDark ? 0.08 : 0.05)
              : (isDark ? SColors.darkCard : SColors.lightCard),
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
          border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 42,
              child: Text(time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SColors.primary)),
            ),
            Expanded(child: Text(title, style: TextStyle(fontSize: 13, color: isDark ? SColors.textDark : SColors.textLight))),
            if (isHighlight) const Icon(Icons.star_rounded, size: 14, color: SColors.warning),
          ],
        ),
      ),
    );
  }
}

class _MomentCard extends StatelessWidget {
  final String time;
  final String title;
  final String detail;
  final Color color;
  final bool isDark;
  const _MomentCard({required this.time, required this.title, required this.detail, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
              child: Text(time, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                  const SizedBox(height: 2),
                  Text(detail, style: TextStyle(fontSize: 12, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EngagementPainter extends CustomPainter {
  final List<double> points;
  final bool isDark;
  _EngagementPainter({required this.points, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = SColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - (points[i].clamp(0.0, 1.0) * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    final basePaint = Paint()
      ..color = (isDark ? SColors.darkBorder : SColors.lightBorder)
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), basePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
