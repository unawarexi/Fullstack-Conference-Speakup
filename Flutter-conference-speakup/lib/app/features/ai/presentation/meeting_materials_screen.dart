import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/core/utils/formatters.dart';
import 'package:flutter_conference_speakup/app/domain/models/material_model.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';

/// Meeting Materials — real files uploaded to a specific meeting.
class MeetingMaterialsScreen extends ConsumerStatefulWidget {
  final String meetingId;
  const MeetingMaterialsScreen({super.key, required this.meetingId});

  @override
  ConsumerState<MeetingMaterialsScreen> createState() =>
      _MeetingMaterialsScreenState();
}

class _MeetingMaterialsScreenState
    extends ConsumerState<MeetingMaterialsScreen> {
  bool _isUploading = false;
  double _uploadProgress = 0;

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      await ref.read(meetingRepositoryProvider).uploadMaterial(
        widget.meetingId,
        file,
        onProgress: (sent, total) {
          if (total > 0) {
            setState(() => _uploadProgress = sent / total);
          }
        },
      );
      ref.invalidate(meetingMaterialsProvider(widget.meetingId));
      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File uploaded successfully'),
            backgroundColor: SColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: SColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteMaterial(MeetingMaterialModel material) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete File?'),
        content: Text('Remove "${material.name}"? This cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(meetingRepositoryProvider).deleteMaterial(material.id);
      ref.invalidate(meetingMaterialsProvider(widget.meetingId));
      if (mounted) HapticFeedback.mediumImpact();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: SColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final materialsAsync =
        ref.watch(meetingMaterialsProvider(widget.meetingId));

    return Scaffold(
      backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
      appBar: AppBar(
        title: const Text('Materials'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(SIcons.back,
              color: isDark ? SColors.textDark : SColors.textLight),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _isUploading ? null : _pickAndUpload,
            icon: Icon(Icons.upload_file_rounded,
                color: isDark ? SColors.textDark : SColors.textLight),
          ),
        ],
      ),
      body: ResponsiveBody(
        child: Column(
          children: [
            // Upload progress bar
            if (_isUploading)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: SSizes.pagePadding),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: isDark
                          ? SColors.darkBorder
                          : SColors.lightBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          SColors.primary),
                      minHeight: 3,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Uploading… ${(_uploadProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? SColors.textDarkSecondary
                            : SColors.textLightSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            Expanded(
              child: materialsAsync.when(
                loading: () =>
                    const Center(child: CupertinoActivityIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 36,
                          color: isDark
                              ? SColors.darkMuted
                              : SColors.lightMuted),
                      const SizedBox(height: 8),
                      Text('Failed to load materials',
                          style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? SColors.textDarkSecondary
                                  : SColors.textLightSecondary)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(
                            meetingMaterialsProvider(widget.meetingId)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (materials) {
                  if (materials.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_open_rounded,
                              size: 44,
                              color: isDark
                                  ? SColors.darkMuted
                                  : SColors.lightMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No materials yet',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? SColors.textDark
                                  : SColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Upload files to share with participants',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? SColors.textDarkSecondary
                                  : SColors.textLightSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _pickAndUpload,
                            icon: const Icon(Icons.upload_file_rounded,
                                size: 18),
                            label: const Text('Upload File'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    SSizes.radiusSm),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(SSizes.pagePadding),
                    itemCount: materials.length,
                    itemBuilder: (context, index) {
                      final m = materials[index];
                      return _FullMaterialTile(
                        material: m,
                        isDark: isDark,
                        onDelete: () => _deleteMaterial(m),
                        onOpen: () async {
                          final uri = Uri.tryParse(m.url);
                          if (uri != null) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                      )
                          .animate()
                          .fadeIn(
                              duration: 300.ms,
                              delay: (index * 40).ms)
                          .slideY(begin: 0.03, end: 0);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Full Material Tile (for list screen)
// ─────────────────────────────────────────────
class _FullMaterialTile extends StatelessWidget {
  final MeetingMaterialModel material;
  final bool isDark;
  final VoidCallback onDelete;
  final VoidCallback onOpen;

  const _FullMaterialTile({
    required this.material,
    required this.isDark,
    required this.onDelete,
    required this.onOpen,
  });

  IconData get _icon {
    if (material.isImage) return Icons.image_rounded;
    if (material.isVideo) return Icons.videocam_rounded;
    if (material.isAudio) return Icons.audiotrack_rounded;
    if (material.type.contains('pdf')) return Icons.picture_as_pdf_rounded;
    if (material.type.contains('sheet') || material.type.contains('csv')) {
      return Icons.table_chart_rounded;
    }
    if (material.type.contains('presentation') ||
        material.type.contains('ppt')) {
      return Icons.slideshow_rounded;
    }
    if (material.type.contains('word') || material.type.contains('doc')) {
      return Icons.description_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  Color get _iconColor {
    if (material.isImage) return const Color(0xFF8B5CF6);
    if (material.isVideo) return const Color(0xFFEC4899);
    if (material.isAudio) return const Color(0xFFF59E0B);
    if (material.type.contains('pdf')) return const Color(0xFFEF4444);
    if (material.type.contains('sheet') || material.type.contains('csv')) {
      return const Color(0xFF10B981);
    }
    return SColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? SColors.darkCard : SColors.lightCard,
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
            border: Border.all(
              color: isDark ? SColors.darkBorder : SColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon, color: _iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? SColors.textDark
                            : SColors.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${material.readableSize} · ${material.extension.toUpperCase()} · ${SFormatters.formatSmartTime(material.createdAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? SColors.textDarkTertiary
                            : SColors.textLightTertiary,
                      ),
                    ),
                    if (material.uploaderName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Uploaded by ${material.uploaderName}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? SColors.textDarkTertiary
                              : SColors.textLightTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.open_in_new_rounded,
                    size: 16,
                    color: isDark
                        ? SColors.textDarkSecondary
                        : SColors.textLightSecondary),
                onPressed: onOpen,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 16, color: SColors.error),
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
