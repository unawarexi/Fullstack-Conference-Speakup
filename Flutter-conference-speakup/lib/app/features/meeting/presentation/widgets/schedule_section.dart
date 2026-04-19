import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/utils/formatters.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/app/components/widgets/date_time_picker.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/create_meeting_widgets.dart';

class ScheduledDateTimeSection extends StatelessWidget {
  final DateTime? scheduledDate;
  final TimeOfDay? scheduledTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final VoidCallback onPickEndDate;
  final VoidCallback onPickEndTime;

  const ScheduledDateTimeSection({
    super.key,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.endDate,
    required this.endTime,
    required this.onPickDate,
    required this.onPickTime,
    required this.onPickEndDate,
    required this.onPickEndTime,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Start Time'),
        Row(
          children: [
            Expanded(
              child: CreateMeetingPickerTile(
                icon: SIcons.calendar,
                label: scheduledDate != null
                    ? SFormatters.formatDateMedium(scheduledDate!)
                    : 'Select Date',
                isDark: isDark,
                onTap: onPickDate,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CreateMeetingPickerTile(
                icon: SIcons.clock,
                label: scheduledTime != null
                    ? scheduledTime!.format(context)
                    : 'Select Time',
                isDark: isDark,
                onTap: onPickTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: SSizes.md),
        const SectionHeader(title: 'End Time'),
        Row(
          children: [
            Expanded(
              child: CreateMeetingPickerTile(
                icon: SIcons.calendar,
                label: endDate != null
                    ? SFormatters.formatDateMedium(endDate!)
                    : 'Select Date',
                isDark: isDark,
                onTap: onPickEndDate,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CreateMeetingPickerTile(
                icon: SIcons.clock,
                label: endTime != null
                    ? endTime!.format(context)
                    : 'Select Time',
                isDark: isDark,
                onTap: onPickEndTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: SSizes.lg),
      ],
    );
  }
}

class RecurringScheduleSection extends StatelessWidget {
  final Set<int> recurringDays;
  final Map<int, TimeOfDay> recurringStartTimes;
  final Map<int, TimeOfDay> recurringEndTimes;
  final ValueChanged<int> onToggleDay;
  final void Function(int day, TimeOfDay time) onStartTimeChanged;
  final void Function(int day, TimeOfDay time) onEndTimeChanged;

  static const _dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  const RecurringScheduleSection({
    super.key,
    required this.recurringDays,
    required this.recurringStartTimes,
    required this.recurringEndTimes,
    required this.onToggleDay,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Recurring Days'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(7, (i) {
            final selected = recurringDays.contains(i);
            return GestureDetector(
              onTap: () => onToggleDay(i),
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
                        : (isDark
                            ? SColors.textDarkSecondary
                            : SColors.textLightSecondary),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: SSizes.md),
        ...(recurringDays.toList()..sort()).map((day) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? SColors.darkCard : SColors.lightCard,
                  borderRadius: BorderRadius.circular(SSizes.radiusSm),
                  border: Border.all(
                    color:
                        isDark ? SColors.darkBorder : SColors.lightBorder,
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
                          color: isDark
                              ? SColors.textDark
                              : SColors.textLight,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final t = await SDateTimePicker.pickTimeOfDay(
                            context,
                            initialTime: recurringStartTimes[day] ??
                                const TimeOfDay(hour: 9, minute: 0),
                          );
                          if (t != null) onStartTimeChanged(day, t);
                        },
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
                          child: Text(
                            recurringStartTimes[day]?.format(context) ??
                                '9:00 AM',
                            style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? SColors.textDark
                                    : SColors.textLight),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6),
                      child: Text('→',
                          style: TextStyle(
                            color: isDark
                                ? SColors.darkMuted
                                : SColors.lightMuted,
                          )),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final t = await SDateTimePicker.pickTimeOfDay(
                            context,
                            initialTime: recurringEndTimes[day] ??
                                const TimeOfDay(hour: 10, minute: 0),
                          );
                          if (t != null) onEndTimeChanged(day, t);
                        },
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
                          child: Text(
                            recurringEndTimes[day]?.format(context) ??
                                '10:00 AM',
                            style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? SColors.textDark
                                    : SColors.textLight),
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
    );
  }
}
