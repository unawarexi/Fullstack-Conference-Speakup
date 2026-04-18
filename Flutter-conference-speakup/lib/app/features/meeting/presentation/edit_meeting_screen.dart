import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/utils/formatters.dart';
import 'package:flutter_conference_speakup/app/components/widgets/date_time_picker.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';

class EditMeetingScreen extends ConsumerStatefulWidget {
  final String meetingId;
  const EditMeetingScreen({super.key, required this.meetingId});

  @override
  ConsumerState<EditMeetingScreen> createState() => _EditMeetingScreenState();
}

class _EditMeetingScreenState extends ConsumerState<EditMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _passwordCtrl;
  late TextEditingController _maxParticipantsCtrl;

  DateTime? _scheduledAt;
  DateTime? _scheduledEndAt;
  bool _waitingRoom = false;
  bool _muteOnJoin = false;
  bool _cameraOffOnJoin = false;
  bool _autoRecord = false;
  bool _allowScreenShare = true;
  bool _allowChat = true;
  bool _removePassword = false;
  bool _isLoading = false;
  bool _initialized = false;

  // Recurring
  final Set<int> _recurringDays = {};
  final Map<int, TimeOfDay> _recurringStartTimes = {};
  final Map<int, TimeOfDay> _recurringEndTimes = {};
  static const _dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _maxParticipantsCtrl = TextEditingController();
  }

  void _initFromMeeting(MeetingModel meeting) {
    if (_initialized) return;
    _initialized = true;
    _titleCtrl.text = meeting.title;
    _descCtrl.text = meeting.description ?? '';
    _maxParticipantsCtrl.text = meeting.maxParticipants.toString();
    _scheduledAt = meeting.scheduledAt;
    _scheduledEndAt = meeting.scheduledEndAt;
    final s = meeting.settings ?? {};
    _waitingRoom = s['waitingRoom'] == true;
    _muteOnJoin = s['muteOnJoin'] == true;
    _cameraOffOnJoin = s['cameraOffOnJoin'] == true;
    _autoRecord = s['autoRecord'] == true;
    _allowScreenShare = s['allowScreenShare'] != false;
    _allowChat = s['allowChat'] != false;

    // Load recurrence config
    if (meeting.type == MeetingType.recurring && meeting.recurrence != null) {
      _recurringDays.addAll(meeting.recurrenceDays);
      for (final schedule in meeting.recurrenceSchedules) {
        final day = schedule['day'] as int;
        final stParts = (schedule['startTime'] as String).split(':');
        final etParts = (schedule['endTime'] as String).split(':');
        _recurringStartTimes[day] = TimeOfDay(
          hour: int.parse(stParts[0]),
          minute: int.parse(stParts[1]),
        );
        _recurringEndTimes[day] = TimeOfDay(
          hour: int.parse(etParts[0]),
          minute: int.parse(etParts[1]),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _passwordCtrl.dispose();
    _maxParticipantsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(MeetingModel meeting) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final data = <String, dynamic>{
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'maxParticipants': int.tryParse(_maxParticipantsCtrl.text) ?? meeting.maxParticipants,
        'settings': {
          'waitingRoom': _waitingRoom,
          'muteOnJoin': _muteOnJoin,
          'cameraOffOnJoin': _cameraOffOnJoin,
          'autoRecord': _autoRecord,
          'allowScreenShare': _allowScreenShare,
          'allowChat': _allowChat,
        },
      };

      if (_scheduledAt != null) {
        data['scheduledAt'] = SFormatters.toApiString(_scheduledAt!);
      }

      if (_scheduledEndAt != null) {
        data['scheduledEndAt'] = SFormatters.toApiString(_scheduledEndAt!);
      }

      // Recurrence for recurring meetings
      if (meeting.type == MeetingType.recurring && _recurringDays.isNotEmpty) {
        final schedules = (_recurringDays.toList()..sort()).map((day) {
          final st = _recurringStartTimes[day] ?? const TimeOfDay(hour: 9, minute: 0);
          final et = _recurringEndTimes[day] ?? const TimeOfDay(hour: 10, minute: 0);
          return {
            'day': day,
            'startTime': SFormatters.timeOfDayToApi(st),
            'endTime': SFormatters.timeOfDayToApi(et),
          };
        }).toList();
        data['recurrence'] = {
          'daysOfWeek': _recurringDays.toList()..sort(),
          'schedules': schedules,
        };
      }

      // Password handling
      if (_removePassword) {
        data['password'] = null;
      } else if (_passwordCtrl.text.isNotEmpty) {
        data['password'] = _passwordCtrl.text;
      }

      await ref.read(meetingRepositoryProvider).update(meeting.id, data);
      ref.invalidate(meetingByIdProvider(meeting.id));
      ref.invalidate(meetingsProvider(null));

      if (mounted) {
        HapticFeedback.mediumImpact();
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: SColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meetingAsync = ref.watch(meetingByIdProvider(widget.meetingId));

    return Scaffold(
      backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(SIcons.back, color: isDark ? SColors.textDark : SColors.textLight),
          onPressed: () => context.pop(),
        ),
        title: Text('Edit Meeting', style: TextStyle(
          fontSize: 17, fontWeight: FontWeight.w600,
          color: isDark ? SColors.textDark : SColors.textLight,
        )),
      ),
      body: meetingAsync.when(
        data: (meeting) {
          _initFromMeeting(meeting);
          return _buildForm(context, meeting, isDark);
        },
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (e, _) => Center(child: Text('Failed to load meeting')),
      ),
    );
  }

  Widget _buildForm(BuildContext context, MeetingModel meeting, bool isDark) {
    return ResponsiveBody(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SSizes.pagePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ──
              _SectionLabel('Title', isDark: isDark),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleCtrl,
                style: TextStyle(color: isDark ? SColors.textDark : SColors.textLight, fontSize: 15),
                decoration: _inputDecor('Meeting title', isDark),
                validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: SSizes.lg),

              // ── Description ──
              _SectionLabel('Description', isDark: isDark),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                style: TextStyle(color: isDark ? SColors.textDark : SColors.textLight, fontSize: 15),
                decoration: _inputDecor('Add a description...', isDark),
              ),
              const SizedBox(height: SSizes.lg),

              // ── Schedule ──
              if (meeting.type == MeetingType.scheduled) ...[
                _SectionLabel('Start Time', isDark: isDark),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _pickDateTime(context, isEnd: false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? SColors.darkCard : SColors.lightCard,
                      borderRadius: BorderRadius.circular(SSizes.radiusSm),
                      border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(SIcons.calendar, size: 18, color: SColors.primary),
                        const SizedBox(width: 10),
                        Text(
                          _scheduledAt != null
                              ? SFormatters.formatDateTimeWithDay(_scheduledAt!)
                              : 'Select start date & time',
                          style: TextStyle(
                            fontSize: 14,
                            color: _scheduledAt != null
                                ? (isDark ? SColors.textDark : SColors.textLight)
                                : (isDark ? SColors.darkMuted : SColors.lightMuted),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded, size: 18,
                            color: isDark ? SColors.darkMuted : SColors.lightMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: SSizes.md),
                _SectionLabel('End Time', isDark: isDark),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _pickDateTime(context, isEnd: true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? SColors.darkCard : SColors.lightCard,
                      borderRadius: BorderRadius.circular(SSizes.radiusSm),
                      border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(SIcons.clock, size: 18, color: SColors.primary),
                        const SizedBox(width: 10),
                        Text(
                          _scheduledEndAt != null
                              ? SFormatters.formatDateTimeWithDay(_scheduledEndAt!)
                              : 'Select end date & time',
                          style: TextStyle(
                            fontSize: 14,
                            color: _scheduledEndAt != null
                                ? (isDark ? SColors.textDark : SColors.textLight)
                                : (isDark ? SColors.darkMuted : SColors.lightMuted),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded, size: 18,
                            color: isDark ? SColors.darkMuted : SColors.lightMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: SSizes.lg),
              ],

              // ── Recurring Schedule ──
              if (meeting.type == MeetingType.recurring) ...[
                _SectionLabel('Recurring Days', isDark: isDark),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(7, (i) {
                    final selected = _recurringDays.contains(i);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (selected) {
                          _recurringDays.remove(i);
                          _recurringStartTimes.remove(i);
                          _recurringEndTimes.remove(i);
                        } else {
                          _recurringDays.add(i);
                          _recurringStartTimes[i] = const TimeOfDay(hour: 9, minute: 0);
                          _recurringEndTimes[i] = const TimeOfDay(hour: 10, minute: 0);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? SColors.primary.withValues(alpha: 0.15)
                              : (isDark ? SColors.darkCard : SColors.lightCard),
                          borderRadius: BorderRadius.circular(SSizes.radiusSm),
                          border: Border.all(
                            color: selected
                                ? SColors.primary
                                : (isDark ? SColors.darkBorder : SColors.lightBorder),
                            width: selected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Text(
                          _dayLabels[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? SColors.primary
                                : (isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: SSizes.md),
                ...(_recurringDays.toList()..sort()).map((day) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? SColors.darkCard : SColors.lightCard,
                      borderRadius: BorderRadius.circular(SSizes.radiusSm),
                      border: Border.all(
                        color: isDark ? SColors.darkBorder : SColors.lightBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 36,
                          child: Text(
                            _dayLabels[day],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? SColors.textDark : SColors.textLight,
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final t = await SDateTimePicker.pickTimeOfDay(
                                context,
                                initialTime: _recurringStartTimes[day] ??
                                    const TimeOfDay(hour: 9, minute: 0),
                              );
                              if (t != null) setState(() => _recurringStartTimes[day] = t);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? SColors.darkElevated : SColors.lightElevated,
                                borderRadius: BorderRadius.circular(SSizes.radiusSm),
                              ),
                              child: Text(
                                _recurringStartTimes[day]?.format(context) ?? '9:00 AM',
                                style: TextStyle(fontSize: 13,
                                    color: isDark ? SColors.textDark : SColors.textLight),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text('→', style: TextStyle(
                            color: isDark ? SColors.darkMuted : SColors.lightMuted,
                          )),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final t = await SDateTimePicker.pickTimeOfDay(
                                context,
                                initialTime: _recurringEndTimes[day] ??
                                    const TimeOfDay(hour: 10, minute: 0),
                              );
                              if (t != null) setState(() => _recurringEndTimes[day] = t);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? SColors.darkElevated : SColors.lightElevated,
                                borderRadius: BorderRadius.circular(SSizes.radiusSm),
                              ),
                              child: Text(
                                _recurringEndTimes[day]?.format(context) ?? '10:00 AM',
                                style: TextStyle(fontSize: 13,
                                    color: isDark ? SColors.textDark : SColors.textLight),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: SSizes.lg),
              ],

              // ── Max Participants ──
              _SectionLabel('Max Participants', isDark: isDark),
              const SizedBox(height: 6),
              TextFormField(
                controller: _maxParticipantsCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDark ? SColors.textDark : SColors.textLight, fontSize: 15),
                decoration: _inputDecor('100', isDark),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 2 || n > 1000) return 'Enter 2–1000';
                  return null;
                },
              ),
              const SizedBox(height: SSizes.lg),

              // ── Password ──
              _SectionLabel('Password', isDark: isDark),
              const SizedBox(height: 6),
              if (meeting.hasPassword && !_removePassword) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? SColors.darkCard : SColors.lightCard,
                    borderRadius: BorderRadius.circular(SSizes.radiusSm),
                    border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(SIcons.lock, size: 16, color: SColors.primary),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Password protected', style: TextStyle(
                        fontSize: 14, color: isDark ? SColors.textDark : SColors.textLight,
                      ))),
                      GestureDetector(
                        onTap: () => setState(() => _removePassword = true),
                        child: Text('Remove', style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600, color: SColors.error,
                        )),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                TextFormField(
                  controller: _passwordCtrl,
                  style: TextStyle(color: isDark ? SColors.textDark : SColors.textLight, fontSize: 15),
                  decoration: _inputDecor(
                    _removePassword ? 'Set new password (optional)' : 'Set a password (optional)',
                    isDark,
                  ),
                  validator: (v) {
                    if (v != null && v.isNotEmpty && v.length < 4) return 'Min 4 characters';
                    return null;
                  },
                ),
                if (_removePassword)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _removePassword = false),
                      child: Text('Cancel remove', style: TextStyle(
                        fontSize: 13, color: SColors.primary, fontWeight: FontWeight.w500,
                      )),
                    ),
                  ),
              ],
              const SizedBox(height: SSizes.xl),

              // ── Settings Toggles ──
              _SectionLabel('Meeting Settings', isDark: isDark),
              const SizedBox(height: 8),
              _SettingToggle(label: 'Waiting Room', value: _waitingRoom, isDark: isDark,
                  onChanged: (v) => setState(() => _waitingRoom = v)),
              _SettingToggle(label: 'Mute on Join', value: _muteOnJoin, isDark: isDark,
                  onChanged: (v) => setState(() => _muteOnJoin = v)),
              _SettingToggle(label: 'Camera Off on Join', value: _cameraOffOnJoin, isDark: isDark,
                  onChanged: (v) => setState(() => _cameraOffOnJoin = v)),
              _SettingToggle(label: 'Auto Record', value: _autoRecord, isDark: isDark,
                  onChanged: (v) => setState(() => _autoRecord = v)),
              _SettingToggle(label: 'Allow Screen Share', value: _allowScreenShare, isDark: isDark,
                  onChanged: (v) => setState(() => _allowScreenShare = v)),
              _SettingToggle(label: 'Allow Chat', value: _allowChat, isDark: isDark,
                  onChanged: (v) => setState(() => _allowChat = v)),

              const SizedBox(height: SSizes.xl),

              // ── Save Button ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _save(meeting),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SSizes.radiusMd),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Changes', style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: SSizes.xxl),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 14,
        color: isDark ? SColors.darkMuted : SColors.lightMuted,
      ),
      filled: true,
      fillColor: isDark ? SColors.darkCard : SColors.lightCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SSizes.radiusSm),
        borderSide: BorderSide(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SSizes.radiusSm),
        borderSide: BorderSide(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SSizes.radiusSm),
        borderSide: const BorderSide(color: SColors.primary, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SSizes.radiusSm),
        borderSide: const BorderSide(color: SColors.error, width: 1),
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context, {bool isEnd = false}) async {
    final initial = isEnd ? _scheduledEndAt : _scheduledAt;
    final dt = await SDateTimePicker.pickDateTime(
      context,
      initialDateTime: initial ?? DateTime.now().add(const Duration(hours: 1)),
    );
    if (dt == null || !mounted) return;

    setState(() {
      if (isEnd) {
        _scheduledEndAt = dt;
      } else {
        _scheduledAt = dt;
      }
    });
  }
}

// ── Helper Widgets ──

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionLabel(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(
      fontSize: 13, fontWeight: FontWeight.w600,
      color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
    ));
  }
}

class _SettingToggle extends StatelessWidget {
  final String label;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.label,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(
            fontSize: 14,
            color: isDark ? SColors.textDark : SColors.textLight,
          ))),
          CupertinoSwitch(
            value: value,
            activeTrackColor: SColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
