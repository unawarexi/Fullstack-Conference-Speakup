import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/app/features/meeting/usecases/meeting_utils.dart';

class AttachmentsSection extends StatelessWidget {
  final List<File> attachments;
  final VoidCallback onPickAttachment;
  final ValueChanged<int> onRemoveAttachment;

  const AttachmentsSection({
    super.key,
    required this.attachments,
    required this.onPickAttachment,
    required this.onRemoveAttachment,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Attachments'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? SColors.darkCard : SColors.lightCard,
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
            border: Border.all(
              color: isDark ? SColors.darkBorder : SColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onPickAttachment,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: SColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(SSizes.radiusSm),
                    color: SColors.primary.withValues(alpha: 0.04),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_file_rounded,
                          size: 18, color: SColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Add files, images or documents',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: SColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (attachments.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...attachments.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final file = entry.value;
                  final name = file.path.split('/').last;
                  final ext = name.contains('.')
                      ? name.split('.').last.toLowerCase()
                      : '';
                  final sizeKb = file.lengthSync() / 1024;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? SColors.darkElevated
                            : SColors.lightElevated,
                        borderRadius:
                            BorderRadius.circular(SSizes.radiusSm),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            fileTypeIcon(ext),
                            size: 18,
                            color: fileTypeColor(ext),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? SColors.textDark
                                        : SColors.textLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  sizeKb < 1024
                                      ? '${sizeKb.toStringAsFixed(1)} KB'
                                      : '${(sizeKb / 1024).toStringAsFixed(1)} MB',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? SColors.textDarkTertiary
                                        : SColors.textLightTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onRemoveAttachment(idx),
                            child: Icon(Icons.close_rounded,
                                size: 16,
                                color: isDark
                                    ? SColors.textDarkTertiary
                                    : SColors.textLightTertiary),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Share documents, images, or files with participants',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? SColors.textDarkTertiary
                          : SColors.textLightTertiary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
