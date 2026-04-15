import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/analytics_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// Export & Reports — generate and download meeting data in various formats.
class ExportReportsScreen extends ConsumerWidget {
  const ExportReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analyticsAsync = ref.watch(analyticsDashboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export & Reports'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: ListView(
        padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
        children: [
          // Quick export
          Text('Quick Export', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _ExportBtn(label: 'PDF', icon: Icons.picture_as_pdf_rounded, color: const Color(0xFFEF4444), isDark: isDark)),
              const SizedBox(width: 10),
              Expanded(child: _ExportBtn(label: 'CSV', icon: Icons.table_chart_rounded, color: const Color(0xFF10B981), isDark: isDark)),
              const SizedBox(width: 10),
              Expanded(child: _ExportBtn(label: 'JSON', icon: Icons.data_object_rounded, color: const Color(0xFFF59E0B), isDark: isDark)),
              const SizedBox(width: 10),
              Expanded(child: _ExportBtn(label: 'DOCX', icon: Icons.description_rounded, color: const Color(0xFF3B82F6), isDark: isDark)),
            ],
          ),
          const SizedBox(height: 20),
          // AI Reports
          Text('AI-Generated Reports', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
          _ReportCard(title: 'Weekly Activity Report', desc: 'Auto-generated summary of meetings, action items, and participation', schedule: 'Every Monday 8 AM', icon: Icons.calendar_view_week_rounded, isDark: isDark),
          _ReportCard(title: 'Team Engagement Report', desc: 'Speaking time distribution, participation trends, sentiment analysis', schedule: 'Bi-weekly', icon: Icons.group_work_rounded, isDark: isDark),
          _ReportCard(title: 'Productivity Insights', desc: 'Meeting-to-focus-time ratio, action item completion rate', schedule: 'Monthly', icon: Icons.trending_up_rounded, isDark: isDark),
          _ReportCard(title: 'Client Meeting Report', desc: 'External meeting recap with decisions, next steps, CRM sync', schedule: 'Per meeting', icon: Icons.business_rounded, isDark: isDark),
          const SizedBox(height: 20),
          // Data range
          Text('Custom Export', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
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
                _SelectRow(label: 'Date Range', value: 'Last 30 days', isDark: isDark),
                const SizedBox(height: 8),
                _SelectRow(label: 'Meeting Type', value: 'All types', isDark: isDark),
                const SizedBox(height: 8),
                _SelectRow(label: 'Include', value: 'Transcripts, Notes, Action Items', isDark: isDark),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SSizes.radiusMd)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Generate Custom Report', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Recent exports
          Text('Recent Exports', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
          analyticsAsync.when(
            loading: () => const AILoadingState(message: 'Loading export history...'),
            error: (e, _) => AIErrorState(message: e.toString(), onRetry: () => ref.invalidate(analyticsDashboardProvider)),
            data: (data) {
              final exports = (data['exportHistory'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              if (exports.isEmpty) {
                return const AIEmptyState(icon: Icons.download_rounded, message: 'No exports yet', subMessage: 'Generate your first report above');
              }
              return Column(
                children: exports.map((e) => _ExportHistoryTile(
                  name: e['name'] as String? ?? '',
                  size: e['size'] as String? ?? '',
                  date: e['date'] as String? ?? '',
                  isDark: isDark,
                )).toList(),
              );
            },
          ),
        ].animate(interval: 40.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
      ),
    ),
    );
  }
}

class _ExportBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  const _ExportBtn({required this.label, required this.icon, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? SColors.darkCard : SColors.lightCard,
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
        border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String desc;
  final String schedule;
  final IconData icon;
  final bool isDark;
  const _ReportCard({required this.title, required this.desc, required this.schedule, required this.icon, required this.isDark});

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
              decoration: BoxDecoration(color: SColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: SColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                  Text(desc, style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(schedule, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: SColors.primary)),
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

class _SelectRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _SelectRow({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
        Row(
          children: [
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? SColors.textDark : SColors.textLight)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 16, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
          ],
        ),
      ],
    );
  }
}

class _ExportHistoryTile extends StatelessWidget {
  final String name;
  final String size;
  final String date;
  final bool isDark;
  const _ExportHistoryTile({required this.name, required this.size, required this.date, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
          border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file_rounded, size: 18, color: SColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? SColors.textDark : SColors.textLight)),
                  Text('$size · $date', style: TextStyle(fontSize: 10, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
            Icon(Icons.download_rounded, size: 16, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
          ],
        ),
      ),
);
  }
}
