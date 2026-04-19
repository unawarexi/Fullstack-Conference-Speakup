import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/utils/formatters.dart';
import 'package:flutter_conference_speakup/app/components/widgets/date_time_picker.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/core/utils/file_picker.dart';
import 'package:flutter_conference_speakup/app/components/ui/button.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';
import 'package:flutter_conference_speakup/app/features/meeting/usecases/meeting_utils.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/create_meeting_widgets.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/invite_participants_section.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/attachments_section.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/schedule_section.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/meeting_settings_section.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/meeting_created_dialog.dart';

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
  DateTime? _endDate;
  TimeOfDay? _endTime;
  String _meetingType = 'INSTANT';
  bool _hasPassword = false;
  bool _autoRecord = false;
  bool _waitingRoom = false;
  bool _muteOnJoin = false;
  bool _cameraOffOnJoin = false;
  int _maxParticipants = 100;
  int? _durationMinutes;
  bool _isLoading = false;
  final List<String> _inviteEmails = [];
  final List<File> _attachments = [];

  // Recurring: selected days (0=Sun..6=Sat) with per-day schedules
  final Set<int> _recurringDays = {};
  final Map<int, TimeOfDay> _recurringStartTimes = {};
  final Map<int, TimeOfDay> _recurringEndTimes = {};

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
      body: ResponsiveBody(child: SingleChildScrollView(
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
                  onTap: () => setState(() {
                    _meetingType = 'INSTANT';
                    _durationMinutes = null;
                  }),
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
            InviteParticipantsSection(
              meetingType: _meetingType,
              emailCtrl: _emailCtrl,
              inviteEmails: _inviteEmails,
              onAddEmail: _addEmail,
              onRemoveEmail: (email) =>
                  setState(() => _inviteEmails.remove(email)),
            ),
            const SizedBox(height: SSizes.lg),

            // Attachments
            AttachmentsSection(
              attachments: _attachments,
              onPickAttachment: _pickAttachment,
              onRemoveAttachment: (idx) =>
                  setState(() => _attachments.removeAt(idx)),
            ),
            const SizedBox(height: SSizes.lg),

            // Schedule (if not instant)
            if (_meetingType == 'SCHEDULED')
              ScheduledDateTimeSection(
                scheduledDate: _scheduledDate,
                scheduledTime: _scheduledTime,
                endDate: _endDate,
                endTime: _endTime,
                onPickDate: _pickDate,
                onPickTime: _pickTime,
                onPickEndDate: _pickEndDate,
                onPickEndTime: _pickEndTime,
              ),

            // Recurring schedule
            if (_meetingType == 'RECURRING')
              RecurringScheduleSection(
                recurringDays: _recurringDays,
                recurringStartTimes: _recurringStartTimes,
                recurringEndTimes: _recurringEndTimes,
                onToggleDay: (i) => setState(() {
                  if (_recurringDays.contains(i)) {
                    _recurringDays.remove(i);
                    _recurringStartTimes.remove(i);
                    _recurringEndTimes.remove(i);
                  } else {
                    _recurringDays.add(i);
                    _recurringStartTimes[i] =
                        const TimeOfDay(hour: 9, minute: 0);
                    _recurringEndTimes[i] =
                        const TimeOfDay(hour: 10, minute: 0);
                  }
                }),
                onStartTimeChanged: (day, t) =>
                    setState(() => _recurringStartTimes[day] = t),
                onEndTimeChanged: (day, t) =>
                    setState(() => _recurringEndTimes[day] = t),
              ),

            // Settings
            MeetingSettingsSection(
              meetingType: _meetingType,
              hasPassword: _hasPassword,
              onPasswordChanged: (v) => setState(() => _hasPassword = v),
              passwordCtrl: _passwordCtrl,
              autoRecord: _autoRecord,
              onAutoRecordChanged: (v) => setState(() => _autoRecord = v),
              waitingRoom: _waitingRoom,
              onWaitingRoomChanged: (v) => setState(() => _waitingRoom = v),
              muteOnJoin: _muteOnJoin,
              onMuteOnJoinChanged: (v) => setState(() => _muteOnJoin = v),
              cameraOffOnJoin: _cameraOffOnJoin,
              onCameraOffOnJoinChanged: (v) =>
                  setState(() => _cameraOffOnJoin = v),
              maxParticipants: _maxParticipants,
              onMaxParticipantsChanged: (v) =>
                  setState(() => _maxParticipants = v),
              durationMinutes: _durationMinutes,
              onDurationChanged: (v) =>
                  setState(() => _durationMinutes = v),
            ),
            const SizedBox(height: SSizes.xl),

            // Create Button
            SButton(
              text: _meetingType == 'INSTANT'
                  ? (_inviteEmails.isNotEmpty ? 'Start Call' : 'Start Meeting')
                  : 'Schedule Meeting',
              prefixIcon: _meetingType == 'INSTANT'
                  ? (_inviteEmails.isNotEmpty ? Icons.call_rounded : Icons.videocam_rounded)
                  : SIcons.calendar,
              isLoading: _isLoading,
              onPressed: _createMeeting,
            ),
            const SizedBox(height: SSizes.xxl),
          ],
        ),
      ),
    ),
    );
  }

  Future<void> _pickDate() async {
    final date = await SDateTimePicker.pickDate(
      context,
      initialDate: _scheduledDate ?? DateTime.now().add(const Duration(hours: 1)),
    );
    if (date != null) setState(() => _scheduledDate = date);
  }

  Future<void> _pickTime() async {
    final time = await SDateTimePicker.pickTimeOfDay(context, initialTime: _scheduledTime);
    if (time != null) setState(() => _scheduledTime = time);
  }

  Future<void> _pickEndDate() async {
    final date = await SDateTimePicker.pickDate(
      context,
      initialDate: _endDate ?? _scheduledDate ?? DateTime.now().add(const Duration(hours: 1)),
    );
    if (date != null) setState(() => _endDate = date);
  }

  Future<void> _pickEndTime() async {
    final time = await SDateTimePicker.pickTimeOfDay(
      context,
      initialTime: _endTime ?? TimeOfDay(hour: (TimeOfDay.now().hour + 1) % 24, minute: 0),
    );
    if (time != null) setState(() => _endTime = time);
  }

  Future<void> _createMeeting() async {
    if (_titleCtrl.text.trim().isEmpty) {
      _titleCtrl.text = 'Quick Meeting';
    }
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(meetingRepositoryProvider);
      DateTime? scheduledAt;
      DateTime? scheduledEndAt;
      if (_meetingType == 'SCHEDULED' && _scheduledDate != null) {
        final time = _scheduledTime ?? TimeOfDay.now();
        scheduledAt = DateTime(
          _scheduledDate!.year,
          _scheduledDate!.month,
          _scheduledDate!.day,
          time.hour,
          time.minute,
        );
        if (_endDate != null) {
          final eTime = _endTime ?? TimeOfDay(hour: (time.hour + 1) % 24, minute: 0);
          scheduledEndAt = DateTime(
            _endDate!.year,
            _endDate!.month,
            _endDate!.day,
            eTime.hour,
            eTime.minute,
          );
        }
      }

      // For recurring, use the first schedule's next occurrence as scheduledAt
      Map<String, dynamic>? recurrence;
      if (_meetingType == 'RECURRING' && _recurringDays.isNotEmpty) {
        final schedules = (_recurringDays.toList()..sort()).map((day) {
          final st = _recurringStartTimes[day] ?? const TimeOfDay(hour: 9, minute: 0);
          final et = _recurringEndTimes[day] ?? const TimeOfDay(hour: 10, minute: 0);
          return {
            'day': day,
            'startTime': SFormatters.timeOfDayToApi(st),
            'endTime': SFormatters.timeOfDayToApi(et),
          };
        }).toList();
        recurrence = {
          'daysOfWeek': _recurringDays.toList()..sort(),
          'schedules': schedules,
        };

        // Set scheduledAt to the next occurrence
        final now = DateTime.now();
        final todayWeekday = now.weekday % 7; // Convert to 0=Sun
        final sortedDays = _recurringDays.toList()..sort();
        int nextDay = sortedDays.firstWhere((d) => d >= todayWeekday, orElse: () => sortedDays.first);
        int daysUntil = (nextDay - todayWeekday + 7) % 7;
        if (daysUntil == 0) daysUntil = 7; // Schedule for next week if today
        final nextDate = now.add(Duration(days: daysUntil));
        final firstSchedule = schedules.firstWhere((s) => s['day'] == nextDay, orElse: () => schedules.first);
        final parts = (firstSchedule['startTime'] as String).split(':');
        scheduledAt = DateTime(nextDate.year, nextDate.month, nextDate.day,
            int.parse(parts[0]), int.parse(parts[1]));
        final eParts = (firstSchedule['endTime'] as String).split(':');
        scheduledEndAt = DateTime(nextDate.year, nextDate.month, nextDate.day,
            int.parse(eParts[0]), int.parse(eParts[1]));
      }

      final meeting = await repo.create({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim().isNotEmpty
            ? _descCtrl.text.trim()
            : null,
        'type': _meetingType,
        if (scheduledAt != null) 'scheduledAt': scheduledAt.toIso8601String(),
        if (scheduledEndAt != null) 'scheduledEndAt': scheduledEndAt.toIso8601String(),
        'maxParticipants': _maxParticipants,
        if (_durationMinutes != null && _meetingType != 'INSTANT') 'durationMinutes': _durationMinutes,
        if (_hasPassword && _passwordCtrl.text.trim().isNotEmpty) 'password': _passwordCtrl.text.trim(),
        'settings': {
          'autoRecord': _autoRecord,
          'waitingRoom': _waitingRoom,
          'muteOnJoin': _muteOnJoin,
          'cameraOffOnJoin': _cameraOffOnJoin,
        },
        if (_inviteEmails.isNotEmpty) 'inviteEmails': _inviteEmails,
        if (recurrence != null) 'recurrence': recurrence,
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
    final code = meeting.code as String? ?? '';
    final password = _hasPassword ? _passwordCtrl.text.trim() : null;

    MeetingCreatedDialog.show(
      context,
      code: code,
      password: password,
      inviteCount: _inviteEmails.length,
      onDone: () => context.pop(),
    );
  }
}
