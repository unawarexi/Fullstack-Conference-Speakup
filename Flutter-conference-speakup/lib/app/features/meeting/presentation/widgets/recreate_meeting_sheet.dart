import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/utils/file_picker.dart';
import 'package:flutter_conference_speakup/app/components/ui/bottom_sheet.dart';
import 'package:flutter_conference_speakup/app/components/ui/button.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';
import 'package:flutter_conference_speakup/app/features/meeting/usecases/recreate_meeting_usecase.dart';
import 'package:flutter_conference_speakup/app/features/meeting/usecases/meeting_utils.dart';

class RecreateMeetingSheet extends ConsumerStatefulWidget {
  final MeetingModel meeting;

  const RecreateMeetingSheet({super.key, required this.meeting});

  static Future<void> show(BuildContext context, MeetingModel meeting) {
    return SBottomSheet.show(
      context: context,
      title: 'Recreate Meeting',
      child: RecreateMeetingSheet(meeting: meeting),
    );
  }

  @override
  ConsumerState<RecreateMeetingSheet> createState() =>
      _RecreateMeetingSheetState();
}

class _RecreateMeetingSheetState extends ConsumerState<RecreateMeetingSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  bool _copyMaterials = true;
  int? _durationMinutes;
  bool _isLoading = false;
  final List<File> _newAttachments = [];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.meeting.title);
    _descCtrl = TextEditingController(text: widget.meeting.description ?? '');
    _durationMinutes = widget.meeting.durationMinutes;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAttachments() async {
    final files = await pickMultipleFiles();
    if (files.isEmpty) return;
    final valid = files.where((f) => f.lengthSync() <= 20 * 1024 * 1024).toList();
    if (valid.length < files.length && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Some files exceeded 20MB limit')),
      );
    }
    if (valid.isNotEmpty) {
      setState(() => _newAttachments.addAll(valid));
    }
  }

  Future<void> _onRecreate() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(meetingRepositoryProvider);
      final params = RecreateMeetingParams(
        meetingId: widget.meeting.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isNotEmpty
            ? _descCtrl.text.trim()
            : null,
        durationMinutes: _durationMinutes,
        copyMaterials: _copyMaterials,
      );
      final newMeeting = await recreateMeeting(repo, params);

      // Upload new attachments to the recreated meeting
      if (_newAttachments.isNotEmpty) {
        for (final file in _newAttachments) {
          try {
            await repo.uploadMaterial(newMeeting.id, file);
          } catch (e) {
            debugPrint('Failed to upload material: $e');
          }
        }
      }

      if (mounted) {
        ref.invalidate(meetingsProvider(null));
        ref.invalidate(meetingsProvider('ENDED'));
        Navigator.of(context, rootNavigator: true).pop();

        if (newMeeting.type == MeetingType.instant) {
          context.push('/meeting/${newMeeting.id}');
        } else {
          context.push('/meeting-detail/${newMeeting.id}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to recreate meeting: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Update details before recreating',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
          ),
        ),
        const SizedBox(height: SSizes.lg),

        // Title field
        _buildLabel('Title', isDark),
        const SizedBox(height: 6),
        _buildTextField(_titleCtrl, 'Meeting title', isDark),
        const SizedBox(height: SSizes.md),

        // Description field
        _buildLabel('Description', isDark),
        const SizedBox(height: 6),
        _buildTextField(_descCtrl, 'Description (optional)', isDark,
            maxLines: 3),
        const SizedBox(height: SSizes.md),

        // Duration picker
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Duration', isDark),
                  const SizedBox(height: 2),
                  Text(
                    _durationMinutes != null
                        ? '$_durationMinutes min'
                        : 'No limit',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? SColors.textDarkTertiary
                          : SColors.textLightTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_durationMinutes != null)
                  GestureDetector(
                    onTap: () => setState(() => _durationMinutes = null),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.clear_rounded, size: 18,
                          color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary),
                    ),
                  ),
                SizedBox(
                  width: 140,
                  child: CupertinoSlider(
                    value: (_durationMinutes ?? 0).toDouble(),
                    min: 0,
                    max: 480,
                    divisions: 32,
                    activeColor: SColors.primary,
                    onChanged: (v) => setState(() {
                      final rounded = v.round();
                      _durationMinutes = rounded == 0 ? null : rounded;
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: SSizes.md),

        // Copy previous materials toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? SColors.darkElevated : SColors.lightElevated,
            borderRadius: BorderRadius.circular(SSizes.radiusSm),
            border: Border.all(
              color: isDark ? SColors.darkBorder : SColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.file_copy_outlined, size: 18,
                  color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keep previous attachments',
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500,
                        color: isDark ? SColors.textDark : SColors.textLight,
                      ),
                    ),
                    Text(
                      'Carry over files from the original meeting',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: _copyMaterials,
                activeTrackColor: SColors.primary,
                onChanged: (v) => setState(() => _copyMaterials = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: SSizes.md),

        // Add new attachments section
        _buildLabel('Add New Attachments', isDark),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickAttachments,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SSizes.radiusSm),
              border: Border.all(
                color: SColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
              color: SColors.primary.withValues(alpha: isDark ? 0.08 : 0.04),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attach_file_rounded, size: 18, color: SColors.primary),
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
        if (_newAttachments.isNotEmpty) ...[
          const SizedBox(height: 10),
          ..._newAttachments.asMap().entries.map((entry) {
            final idx = entry.key;
            final file = entry.value;
            final name = file.path.split('/').last;
            final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
            final sizeKb = file.lengthSync() / 1024;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? SColors.darkElevated : SColors.lightElevated,
                  borderRadius: BorderRadius.circular(SSizes.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(fileTypeIcon(ext), size: 18, color: fileTypeColor(ext)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: isDark ? SColors.textDark : SColors.textLight,
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
                      onTap: () => setState(() => _newAttachments.removeAt(idx)),
                      child: Icon(Icons.close_rounded, size: 16,
                          color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary),
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
              'These will be added alongside any kept attachments',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
              ),
            ),
          ),
        const SizedBox(height: SSizes.xl),

        // Recreate button
        SButton(
          text: _isLoading && _newAttachments.isNotEmpty
              ? 'Uploading...'
              : 'Recreate Meeting',
          prefixIcon: Icons.refresh_rounded,
          isLoading: _isLoading,
          onPressed: _onRecreate,
        ),
      ],
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(text, style: TextStyle(
      fontSize: 13, fontWeight: FontWeight.w600,
      color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
    ));
  }

  Widget _buildTextField(
    TextEditingController controller, String hint, bool isDark,
    {int maxLines = 1}
  ) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? SColors.textDark : SColors.textLight,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          color: isDark ? SColors.darkMuted : SColors.lightMuted,
        ),
        filled: true,
        fillColor: isDark ? SColors.darkBg : SColors.lightElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
          borderSide: BorderSide(
            color: isDark ? SColors.darkBorder : SColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
          borderSide: BorderSide(
            color: isDark ? SColors.darkBorder : SColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
          borderSide: const BorderSide(color: SColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 10,
        ),
      ),
    );
  }
}
