import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/analytics_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// Meeting Materials — shared documents, links, and resources per meeting.
class MeetingMaterialsScreen extends ConsumerWidget {
  const MeetingMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analyticsAsync = ref.watch(meetingAnalyticsProvider('latest'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Materials'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.upload_file_rounded, color: isDark ? SColors.textDark : SColors.textLight)),
        ],
      ),
      body: ResponsiveBody(child: ListView(
        padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
        children: [
          // AI auto-collected
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SColors.primary.withValues(alpha: isDark ? 0.08 : 0.05),
              borderRadius: BorderRadius.circular(SSizes.radiusSm),
            ),
            child: Row(
              children: const [
                Icon(Icons.auto_awesome_rounded, size: 16, color: SColors.primary),
                SizedBox(width: 8),
                Expanded(child: Text('AI auto-collected 5 resources shared during meetings', style: TextStyle(fontSize: 11, color: SColors.primary))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Shared in Meeting', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
          analyticsAsync.when(
            loading: () => const AILoadingState(message: 'Loading materials...'),
            error: (e, _) => AIErrorState(message: e.toString(), onRetry: () => ref.invalidate(meetingAnalyticsProvider('latest'))),
            data: (data) {
              final materials = (data['materials'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              final links = (data['links'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              final references = (data['references'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (materials.isEmpty)
                    const AIEmptyState(icon: Icons.folder_rounded, message: 'No materials shared yet')
                  else
                    ...materials.map((m) => _MaterialTile(
                      name: m['name'] as String? ?? '',
                      type: m['type'] as String? ?? '',
                      size: m['size'] as String? ?? '',
                      sharedBy: m['sharedBy'] as String? ?? '',
                      meeting: m['meeting'] as String? ?? '',
                      isDark: isDark,
                    )),
                  const SizedBox(height: 16),
                  Text('Links Mentioned', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                  const SizedBox(height: 8),
                  ...links.map((l) => _LinkTile(
                    url: l['url'] as String? ?? '',
                    title: l['title'] as String? ?? '',
                    meeting: l['meeting'] as String? ?? '',
                    isDark: isDark,
                  )),
                  const SizedBox(height: 16),
                  Text('AI Extracted References', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                  const SizedBox(height: 8),
                  ...references.map((r) => _ReferenceTile(
                    text: r['text'] as String? ?? '',
                    source: r['source'] as String? ?? '',
                    status: r['status'] as String? ?? '',
                    isDark: isDark,
                  )),
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

class _MaterialTile extends StatelessWidget {
  final String name;
  final String type;
  final String size;
  final String sharedBy;
  final String meeting;
  final bool isDark;
  const _MaterialTile({required this.name, required this.type, required this.size, required this.sharedBy, required this.meeting, required this.isDark});

  IconData get _icon {
    switch (type) {
      case 'PDF': return Icons.picture_as_pdf_rounded;
      case 'Image': return Icons.image_rounded;
      case 'Spreadsheet': return Icons.table_chart_rounded;
      default: return Icons.insert_drive_file_rounded;
    }
  }

  Color get _iconColor {
    switch (type) {
      case 'PDF': return const Color(0xFFEF4444);
      case 'Image': return const Color(0xFF8B5CF6);
      case 'Spreadsheet': return const Color(0xFF10B981);
      default: return SColors.primary;
    }
  }

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
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: _iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(_icon, color: _iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('$size · Shared by $sharedBy · $meeting', style: TextStyle(fontSize: 10, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
            Icon(Icons.download_rounded, size: 18, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
          ],
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String url;
  final String title;
  final String meeting;
  final bool isDark;
  const _LinkTile({required this.url, required this.title, required this.meeting, required this.isDark});

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
          children: [
            const Icon(Icons.link_rounded, size: 18, color: SColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                  Text('$meeting · $url', style: TextStyle(fontSize: 10, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.open_in_new_rounded, size: 16, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
          ],
        ),
      ),
    );
  }
}

class _ReferenceTile extends StatelessWidget {
  final String text;
  final String source;
  final String status;
  final bool isDark;
  const _ReferenceTile({required this.text, required this.source, required this.status, required this.isDark});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: isDark ? SColors.textDark : SColors.textLight)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(source, style: TextStyle(fontSize: 10, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                const Spacer(),
                const Icon(Icons.auto_awesome_rounded, size: 12, color: SColors.primary),
                const SizedBox(width: 4),
                Flexible(child: Text(status, style: const TextStyle(fontSize: 10, color: SColors.primary), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
        ),
      ),
);
  }
}
