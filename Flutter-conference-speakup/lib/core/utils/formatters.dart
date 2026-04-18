import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SFormatters {
  SFormatters._();

  // ── Date formats ──

  static String formatDate(DateTime date) =>
      DateFormat('MMM d, yyyy').format(date);

  static String formatDateShort(DateTime date) =>
      DateFormat('MMM d').format(date);

  static String formatDateMedium(DateTime date) =>
      DateFormat('MMM d, y').format(date);

  static String formatDateFull(DateTime date) =>
      DateFormat('EEEE, MMM d, y').format(date);

  static String formatDateWithDay(DateTime date) =>
      DateFormat('EEE, MMM d').format(date);

  static String formatMonthDay(DateTime date) =>
      DateFormat.MMMd().format(date);

  static String formatDateYMMMd(DateTime date) =>
      DateFormat.yMMMd().format(date);

  static String formatDayOfWeek(DateTime date) =>
      DateFormat.E().format(date);

  // ── Time formats ──

  static String formatTime(DateTime date) =>
      DateFormat('h:mm a').format(date);

  static String formatTimeJm(DateTime date) =>
      DateFormat.jm().format(date);

  static String formatTime24h(DateTime date) =>
      DateFormat.Hm().format(date);

  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // ── DateTime combined formats ──

  static String formatDateTime(DateTime date) =>
      DateFormat('MMM d, yyyy · h:mm a').format(date);

  static String formatDateTimeWithDay(DateTime date) =>
      DateFormat('EEE, MMM d, y · h:mm a').format(date);

  static String formatDateTimeCompact(DateTime date) =>
      DateFormat('MMM d · h:mm a').format(date);

  static String formatDateTimeShort(DateTime date) =>
      DateFormat('MMM d, h:mm a').format(date);

  // ── Time ranges ──

  static String formatTimeRange(DateTime start, DateTime end) {
    final sameDay = start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;
    if (sameDay) {
      return '${formatDateShort(start)} · ${formatTime(start)} – ${formatTime(end)}';
    }
    return '${formatDateTimeShort(start)} – ${formatDateTimeShort(end)}';
  }

  // ── Smart / relative time ──

  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(date);
  }

  static String formatSmartTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1 && now.day == date.day) return formatTimeJm(date);
    if (diff.inDays < 7) return formatDayOfWeek(date);
    return formatMonthDay(date);
  }

  // ── Duration formats ──

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  static String formatMeetingTimer(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }

  // ── Utility helpers ──

  static String formatParticipantCount(int count) {
    if (count < 1000) return '$count';
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static DateTime combineDateTime(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  static String toApiString(DateTime date) => date.toUtc().toIso8601String();

  static String timeOfDayToApi(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
