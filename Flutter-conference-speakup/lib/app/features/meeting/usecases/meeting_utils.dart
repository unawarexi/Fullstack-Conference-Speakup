import 'dart:ui';
import 'package:flutter/material.dart';

/// Format a [Duration] as `H:MM:SS` or `MM:SS`.
String formatMeetingDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

/// Basic email validation.
bool isValidEmail(String email) {
  return RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[\w\-\.]+$').hasMatch(email);
}

/// Return an [IconData] matching the given file extension.
IconData fileTypeIcon(String ext) {
  if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].contains(ext)) {
    return Icons.image_rounded;
  }
  if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) {
    return Icons.videocam_rounded;
  }
  if (['mp3', 'wav', 'aac', 'ogg', 'flac'].contains(ext)) {
    return Icons.audiotrack_rounded;
  }
  if (['pdf'].contains(ext)) return Icons.picture_as_pdf_rounded;
  if (['doc', 'docx', 'txt', 'rtf', 'odt'].contains(ext)) {
    return Icons.description_rounded;
  }
  if (['xls', 'xlsx', 'csv', 'ods'].contains(ext)) {
    return Icons.table_chart_rounded;
  }
  if (['ppt', 'pptx', 'odp'].contains(ext)) {
    return Icons.slideshow_rounded;
  }
  if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) {
    return Icons.folder_zip_rounded;
  }
  return Icons.insert_drive_file_rounded;
}

/// Return a [Color] matching the given file extension.
Color fileTypeColor(String ext) {
  if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].contains(ext)) {
    return Colors.pink;
  }
  if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) {
    return Colors.purple;
  }
  if (['mp3', 'wav', 'aac', 'ogg', 'flac'].contains(ext)) {
    return Colors.orange;
  }
  if (['pdf'].contains(ext)) return Colors.red;
  if (['doc', 'docx', 'txt', 'rtf', 'odt'].contains(ext)) {
    return Colors.blue;
  }
  if (['xls', 'xlsx', 'csv', 'ods'].contains(ext)) {
    return Colors.green;
  }
  if (['ppt', 'pptx', 'odp'].contains(ext)) return Colors.deepOrange;
  return Colors.grey;
}
