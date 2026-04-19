import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

/// Premium date/time picker — uses CupertinoDatePicker in a bottom sheet
/// for a native iOS feel.
class SDateTimePicker {
  SDateTimePicker._();

  static Future<DateTime?> pickDate(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return _showCupertinoPicker(
      context,
      mode: CupertinoDatePickerMode.date,
      initialDateTime: initialDate ?? DateTime.now(),
      minimumDate: firstDate ?? DateTime.now(),
      maximumDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
    );
  }

  static Future<DateTime?> pickTime(
    BuildContext context, {
    DateTime? initialTime,
  }) {
    return _showCupertinoPicker(
      context,
      mode: CupertinoDatePickerMode.time,
      initialDateTime: initialTime ?? DateTime.now(),
    );
  }

  static Future<DateTime?> pickDateTime(
    BuildContext context, {
    DateTime? initialDateTime,
    DateTime? minimumDate,
    DateTime? maximumDate,
  }) async {
    return _showCupertinoPicker(
      context,
      mode: CupertinoDatePickerMode.dateAndTime,
      initialDateTime: initialDateTime ?? DateTime.now(),
      minimumDate: minimumDate ?? DateTime.now(),
      maximumDate: maximumDate ?? DateTime.now().add(const Duration(days: 365)),
    );
  }

  /// Convenience wrapper that returns a [TimeOfDay] instead of [DateTime].
  static Future<TimeOfDay?> pickTimeOfDay(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) async {
    final dt = await pickTime(
      context,
      initialTime: initialTime != null
          ? DateTime(2024, 1, 1, initialTime.hour, initialTime.minute)
          : null,
    );
    return dt != null ? TimeOfDay.fromDateTime(dt) : null;
  }

  static Future<DateTime?> _showCupertinoPicker(
    BuildContext context, {
    required CupertinoDatePickerMode mode,
    DateTime? initialDateTime,
    DateTime? minimumDate,
    DateTime? maximumDate,
  }) async {
    // Clamp initial so it's never before min or after max
    DateTime initial = initialDateTime ?? DateTime.now();
    if (minimumDate != null && initial.isBefore(minimumDate)) {
      initial = minimumDate;
    }
    if (maximumDate != null && initial.isAfter(maximumDate)) {
      initial = maximumDate;
    }
    DateTime? selected = initial;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (ctx) => Container(
        height: 320,
        decoration: BoxDecoration(
          color: isDark ? SColors.darkSurface : SColors.lightSurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SSizes.radiusXl),
          ),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          children: [
            // Header with cancel/done
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SSizes.pagePadding,
                vertical: SSizes.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark
                            ? SColors.textDarkSecondary
                            : SColors.textLightSecondary,
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: SColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: isDark ? Brightness.dark : Brightness.light,
                  primaryColor: SColors.primary,
                ),
                child: CupertinoDatePicker(
                  mode: mode,
                  initialDateTime: initial,
                  minimumDate: minimumDate,
                  maximumDate: maximumDate,
                  onDateTimeChanged: (dt) => selected = dt,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return (confirmed == true) ? selected : null;
  }
}
