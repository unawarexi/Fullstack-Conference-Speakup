import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/utils/file_picker.dart';
import 'package:flutter_conference_speakup/app/components/ui/button.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';
import 'package:flutter_conference_speakup/app/features/meeting/usecases/meeting_utils.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/create_meeting_widgets.dart';

class CreateMeetingScreen extends ConsumerStatefulWidget {
  const CreateMeetingScreen({super.key}); 

  @override
  ConsumerState<CreateMeetingScreen> createState() =>
      _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends ConsumerState<CreateMeetingScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _descFocusNode = FocusNode();
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  String _meetingType = 'INSTANT';
  bool _hasPassword = false;
  bool _autoRecord = false;
  bool _waitingRoom = false;
  bool _muteOnJoin = false;
  bool _cameraOffOnJoin = false;
  int _maxParticipants = 100;
  bool _isLoading = false;
  final List<String> _inviteEmails = [];
  final List<File> _attachments = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _passwordCtrl.dispose();
    _emailCtrl.dispose();
    _descFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(SIcons.close, size: 20,
              color: isDark ? SColors.textDark : SColors.textLight),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'New Meeting',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? SColors.textDark : SColors.textLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SSizes.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meeting Type Selector
            SectionHeader(title: 'Meeting Type'),
            Row(
              children: [
                CreateMeetingTypeChip(
                  label: 'Instant',
                  icon: Icons.bolt_rounded,
                  selected: _meetingType == 'INSTANT',
                  onTap: () => setState(() => _meetingType = 'INSTANT'),
                ),
                const SizedBox(width: 8),
                CreateMeetingTypeChip(
                  label: 'Scheduled',
                  icon: SIcons.calendar,
                  selected: _meetingType == 'SCHEDULED',
                  onTap: () => setState(() => _meetingType = 'SCHEDULED'),
                ),
                const SizedBox(width: 8),
                CreateMeetingTypeChip(
                  label: 'Recurring',
                  icon: Icons.repeat_rounded,
                  selected: _meetingType == 'RECURRING',
                  onTap: () => setState(() => _meetingType = 'RECURRING'),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: SSizes.lg),

            // Title
            CreateMeetingInputField(
              controller: _titleCtrl,
              label: 'Meeting Title',
              hint: 'e.g. Sprint Review Q4',
              icon: Icons.title_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: SSizes.md),

            // Description
            CreateMeetingInputField(
              controller: _descCtrl,
              focusNode: _descFocusNode,
              label: 'Description (optional)',
              hint: 'Add meeting agenda or notes...',
              icon: Icons.notes_rounded,
              isDark: isDark,
              maxLines: 3,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: SSizes.lg),

            // Email Invites
            SectionHeader(title: 'Invite Participants'),
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
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 42,
                          child: TextField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? SColors.textDark : SColors.textLight,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter email address',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? SColors.textDarkTertiary
                                    : SColors.textLightTertiary,
                              ),
                              prefixIcon: Icon(Icons.email_outlined,
                                  size: 17,
                                  color: isDark
                                      ? SColors.textDarkTertiary
                                      : SColors.textLightTertiary),
                              prefixIconConstraints:
                                  const BoxConstraints(minWidth: 40, minHeight: 40),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onSubmitted: (_) => _addEmail(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _addEmail,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: SColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(SSizes.radiusSm),
                          ),
                          child: const Icon(Icons.add_rounded,
                              size: 18, color: SColors.primary),
                        ),
                      ),
                    ],
                  ),
                  if (_inviteEmails.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _inviteEmails.map((email) {
                        return Chip(
                          label: Text(email,
                              style: const TextStyle(fontSize: 12)),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () =>
                              setState(() => _inviteEmails.remove(email)),
                          backgroundColor: isDark
                              ? SColors.darkElevated
                              : SColors.lightElevated,
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ],
                  if (_inviteEmails.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Invites are optional — share the code after creating',
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
            const SizedBox(height: SSizes.lg),

            // Attachments / Materials
            SectionHeader(title: 'Attachments'),
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
                    onTap: _pickAttachment,
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
                  if (_attachments.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ..._attachments.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final file = entry.value;
                      final name = file.path.split('/').last;
                      final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
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
                                onTap: () => setState(
                                    () => _attachments.removeAt(idx)),
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
            const SizedBox(height: SSizes.lg),

            // Schedule (if not instant)
            if (_meetingType != 'INSTANT') ...[
              SectionHeader(title: 'Schedule'),
              Row(
                children: [
                  Expanded(
                    child: CreateMeetingPickerTile(
                      icon: SIcons.calendar,
                      label: _scheduledDate != null
                          ? DateFormat('MMM d, y').format(_scheduledDate!)
                          : 'Select Date',
                      isDark: isDark,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CreateMeetingPickerTile(
                      icon: SIcons.clock,
                      label: _scheduledTime != null
                          ? _scheduledTime!.format(context)
                          : 'Select Time',
                      isDark: isDark,
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SSizes.lg),
            ],

            // Settings
            SectionHeader(title: 'Settings'),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? SColors.darkCard : SColors.lightCard,
                borderRadius: BorderRadius.circular(SSizes.radiusMd),
                border: Border.all(
                  color: isDark ? SColors.darkBorder : SColors.lightBorder,
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  ToggleRow(
                    icon: SIcons.lock,
                    title: 'Password Protected',
                    subtitle: 'Require password to join',
                    value: _hasPassword,
                    onChanged: (v) => setState(() => _hasPassword = v),
                  ),
                  if (_hasPassword) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: CreateMeetingInputField(
                        controller: _passwordCtrl,
                        label: '',
                        hint: 'Enter meeting password',
                        icon: SIcons.lock,
                        isDark: isDark,
                        isPassword: true,
                      ),
                    ),
                  ],
                  ToggleRow(
                    icon: SIcons.record,
                    title: 'Auto Record',
                    subtitle: 'Start recording automatically',
                    value: _autoRecord,
                    onChanged: (v) => setState(() => _autoRecord = v),
                  ),
                  ToggleRow(
                    icon: Icons.hourglass_empty_rounded,
                    title: 'Waiting Room',
                    subtitle: 'Approve participants before joining',
                    value: _waitingRoom,
                    onChanged: (v) => setState(() => _waitingRoom = v),
                  ),
                  ToggleRow(
                    icon: SIcons.micOff,
                    title: 'Mute on Join',
                    subtitle: 'Participants muted when joining',
                    value: _muteOnJoin,
                    onChanged: (v) => setState(() => _muteOnJoin = v),
                  ),
                  ToggleRow(
                    icon: SIcons.cameraOff,
                    title: 'Camera Off on Join',
                    subtitle: 'Participants camera off when joining',
                    value: _cameraOffOnJoin,
                    onChanged: (v) => setState(() => _cameraOffOnJoin = v),
                  ),
                  // Max participants
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isDark
                                ? SColors.darkElevated
                                : SColors.lightElevated,
                            borderRadius:
                                BorderRadius.circular(SSizes.radiusSm),
                          ),
                          child: Icon(SIcons.participants,
                              size: 17,
                              color: isDark
                                  ? SColors.textDarkSecondary
                                  : SColors.textLightSecondary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Max Participants',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? SColors.textDark
                                      : SColors.textLight,
                                ),
                              ),
                              Text(
                                '$_maxParticipants participants',
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
                        SizedBox(
                          width: 140,
                          child: CupertinoSlider(
                            value: _maxParticipants.toDouble(),
                            min: 2,
                            max: 500,
                            divisions: 498,
                            activeColor: SColors.primary,
                            onChanged: (v) =>
                                setState(() => _maxParticipants = v.round()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SSizes.xl),

            // Create Button
            SButton(
              text: _meetingType == 'INSTANT'
                  ? 'Start Meeting'
                  : 'Schedule Meeting',
              prefixIcon: _meetingType == 'INSTANT'
                  ? Icons.videocam_rounded
                  : SIcons.calendar,
              isLoading: _isLoading,
              onPressed: _createMeeting,
            ),
            const SizedBox(height: SSizes.xxl),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _scheduledDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _scheduledTime = time);
  }

  Future<void> _createMeeting() async {
    if (_titleCtrl.text.trim().isEmpty) {
      _titleCtrl.text = 'Quick Meeting';
    }
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(meetingRepositoryProvider);
      DateTime? scheduledAt;
      if (_scheduledDate != null) {
        final time = _scheduledTime ?? TimeOfDay.now();
        scheduledAt = DateTime(
          _scheduledDate!.year,
          _scheduledDate!.month,
          _scheduledDate!.day,
          time.hour,
          time.minute,
        );
      }
      final meeting = await repo.create({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim().isNotEmpty
            ? _descCtrl.text.trim()
            : null,
        'type': _meetingType,
        'scheduledAt': scheduledAt?.toIso8601String(),
        'maxParticipants': _maxParticipants,
        'password': _hasPassword ? _passwordCtrl.text.trim() : null,
        'settings': {
          'autoRecord': _autoRecord,
          'waitingRoom': _waitingRoom,
          'muteOnJoin': _muteOnJoin,
          'cameraOffOnJoin': _cameraOffOnJoin,
        },
        if (_inviteEmails.isNotEmpty) 'inviteEmails': _inviteEmails,
      });

      // Upload attachments in background after meeting is created
      if (_attachments.isNotEmpty) {
        for (final file in _attachments) {
          try {
            await repo.uploadMaterial(meeting.id, file);
          } catch (e) {
            debugPrint('Failed to upload material: $e');
          }
        }
      }

      if (mounted) {
        ref.invalidate(meetingsProvider(null));
        if (_meetingType == 'INSTANT') {
          context.pushReplacement('/meeting/${meeting.id}');
        } else {
          // Show meeting created dialog with code and share option
          _showMeetingCreatedDialog(meeting);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create meeting: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addEmail() {
    final email = _emailCtrl.text.trim().toLowerCase();
    if (email.isEmpty) return;
    // Basic email validation
    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }
    if (_inviteEmails.contains(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email already added')),
      );
      return;
    }
    if (_inviteEmails.length >= 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 50 invites per meeting')),
      );
      return;
    }
    setState(() {
      _inviteEmails.add(email);
      _emailCtrl.clear();
    });
  }

  Future<void> _pickAttachment() async {
    final files = await pickMultipleFiles();
    if (files.isEmpty) return;
    // 20MB per file limit
    final valid = files.where((f) => f.lengthSync() <= 20 * 1024 * 1024).toList();
    if (valid.length < files.length && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Some files exceeded 20MB limit')),
      );
    }
    if (valid.isNotEmpty) {
      setState(() => _attachments.addAll(valid));
    }
  }

  void _showMeetingCreatedDialog(dynamic meeting) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final code = meeting.code as String? ?? '';
    final meetingLink = 'https://speakup.app/join/$code';

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? SColors.darkCard : SColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? SColors.darkBorder : SColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(Icons.check_circle_rounded,
                size: 48, color: SColors.success),
            const SizedBox(height: 12),
            Text(
              'Meeting Created!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? SColors.textDark : SColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            // Meeting code display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: SColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(SSizes.radiusMd),
                border: Border.all(
                  color: SColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: SColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied!')),
                      );
                    },
                    child: const Icon(Icons.copy_rounded,
                        size: 18, color: SColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_inviteEmails.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${_inviteEmails.length} invite(s) sent via email',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? SColors.textDarkSecondary
                        : SColors.textLightSecondary,
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: SButton(
                    text: 'Share Link',
                    prefixIcon: Icons.share_rounded,
                    variant: SButtonVariant.outline,
                    onPressed: () {
                      SharePlus.instance.share(
                        ShareParams(
                          text: 'Join my SpeakUp meeting!\n\nCode: $code\nLink: $meetingLink',
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SButton(
                    text: 'Done',
                    prefixIcon: Icons.check_rounded,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.pop();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
