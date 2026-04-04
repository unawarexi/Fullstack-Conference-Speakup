import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';

class SDateTimePicker {
  SDateTimePicker._();

  static Future<DateTime?> pickDate(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: SColors.primary,
                    surface: SColors.darkCard,
                    onSurface: SColors.textDark,
                  )
                : const ColorScheme.light(
                    primary: SColors.primary,
                    surface: SColors.lightSurface,
                    onSurface: SColors.textLight,
                  ),
          ),
          child: child!,
        );
      },
    );
  }

  static Future<TimeOfDay?> pickTime(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: SColors.primary,
                    surface: SColors.darkCard,
                    onSurface: SColors.textDark,
                  )
                : const ColorScheme.light(
                    primary: SColors.primary,
                    surface: SColors.lightSurface,
                    onSurface: SColors.textLight,
                  ),
          ),
          child: child!,
        );
      },
    );
  }

  static Future<DateTime?> pickDateTime(BuildContext context) async {
    final date = await pickDate(context);
    if (date == null) return null;
    final time = await pickTime(context);
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
