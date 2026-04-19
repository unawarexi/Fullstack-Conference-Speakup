import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/analytics_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// AI Document Intelligence — parse, extract, and analyze meeting documents.
class AIDocumentsScreen extends ConsumerWidget {
  const AIDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analyticsAsync = ref.watch(meetingAnalyticsProvider('latest'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Intelligence'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_rounded),
            onPressed: () => _showUploadSheet(context, isDark),
          ),
        ],
      ),
      body: ResponsiveBody(child: ListView(
        padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
        children: [
          // Upload area
          _UploadArea(isDark: isDark),
          const SizedBox(height: 20),

          // Recent documents
          Text('Recent Documents', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 10),
          analyticsAsync.when(
            loading: () => const AILoadingState(message: 'Loading documents...'),
            error: (e, _) => AIErrorState(message: e.toString(), onRetry: () => ref.invalidate(meetingAnalyticsProvider('latest'))),
            data: (data) {
              final docs = (data['documents'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              if (docs.isEmpty) {
                return const AIEmptyState(icon: Icons.description_rounded, message: 'No documents yet', subMessage: 'Upload or share documents during meetings');
              }
              return Column(
                children: docs.map((d) => _DocCard(
                  d['name'] as String? ?? 'Untitled',
                  d['detail'] as String? ?? '',
                  _docIcon(d['type'] as String?),
                  _docColor(d['type'] as String?),
                  isDark: isDark,
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 20),

          // Capabilities
          Text('AI Capabilities', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 10),
          _CapabilityTile('Text Extraction', 'OCR from images, PDFs, and scanned docs', Icons.text_fields_rounded, isDark: isDark),
          _CapabilityTile('Data Parsing', 'Tables, charts, CSVs → structured data', Icons.grid_on_rounded, isDark: isDark),
          _CapabilityTile('Summarization', 'Long docs → key points in seconds', Icons.auto_awesome_rounded, isDark: isDark),
          _CapabilityTile('Comparison', 'Diff two versions and highlight changes', Icons.compare_rounded, isDark: isDark),
          _CapabilityTile('Translation', 'Translate documents to 30+ languages', Icons.translate_rounded, isDark: isDark),
        ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
      ),
    ),
    );
  }

  static IconData _docIcon(String? type) {
    switch (type) {
      case 'pdf': return Icons.picture_as_pdf_rounded;
      case 'image': return Icons.image_rounded;
      case 'spreadsheet': return Icons.table_chart_rounded;
      case 'doc': return Icons.description_rounded;
      default: return Icons.insert_drive_file_rounded;
    }
  }

  static Color _docColor(String? type) {
    switch (type) {
      case 'pdf': return SColors.error;
      case 'image': return SColors.screenShare;
      case 'spreadsheet': return SColors.success;
      case 'doc': return SColors.primary;
      default: return SColors.warning;
    }
  }

  void _showUploadSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: isDark ? SColors.darkCard : SColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(SSizes.radiusLg)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? SColors.darkBorder : SColors.lightBorder, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: SColors.primary),
              title: Text('Scan Document', style: TextStyle(color: isDark ? SColors.textDark : SColors.textLight)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.file_upload_rounded, color: SColors.screenShare),
              title: Text('Upload File', style: TextStyle(color: isDark ? SColors.textDark : SColors.textLight)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded, color: SColors.success),
              title: Text('Import from URL', style: TextStyle(color: isDark ? SColors.textDark : SColors.textLight)),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _UploadArea extends StatelessWidget {
  final bool isDark;
  const _UploadArea({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          border: Border.all(color: SColors.primary.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_upload_rounded, size: 32, color: SColors.primary.withValues(alpha: 0.6)),
              const SizedBox(height: 8),
              Text('Drop files or tap to upload', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
              const SizedBox(height: 2),
              Text('PDF, DOCX, PNG, CSV supported', style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocCard extends StatelessWidget {
  final String name;
  final String detail;
  final IconData icon;
  final Color color;
  final bool isDark;
  const _DocCard(this.name, this.detail, this.icon, this.color, {required this.isDark});

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
            Container(width: 40, height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(detail, style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary),
          ],
        ),
      ),
    );
  }
}

class _CapabilityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDark;
  const _CapabilityTile(this.title, this.subtitle, this.icon, {required this.isDark});

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
            Icon(icon, size: 20, color: SColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                  const SizedBox(height: 1),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
);
  }
}
