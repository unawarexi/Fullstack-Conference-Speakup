/// Extract a SpeakUp meeting code from various input formats.
///
/// Handles:
/// - Full links: `https://speakup.app/join/spk-xxxx-xxxx`
/// - Deep links: `speakup://meet/spk-xxxx-xxxx`
/// - Plain codes: `spk-xxxx-xxxx`
/// - Legacy alphanumeric IDs (8+ chars)
String? extractMeetingCode(String input) {
  final trimmed = input.trim().toLowerCase();

  // Full link
  final urlMatch =
      RegExp(r'speakup\.app/(?:join|meeting)/([a-z0-9-]+)').firstMatch(trimmed);
  if (urlMatch != null) return urlMatch.group(1);

  // Deep link
  final deepMatch =
      RegExp(r'speakup://meet/([a-z0-9-]+)').firstMatch(trimmed);
  if (deepMatch != null) return deepMatch.group(1);

  // Standard code
  if (RegExp(r'^spk-[a-z0-9]{4}-[a-z0-9]{4}$').hasMatch(trimmed)) {
    return trimmed;
  }

  // Legacy fallback
  if (RegExp(r'^[a-z0-9]{8,}$').hasMatch(trimmed)) return trimmed;

  return trimmed.isNotEmpty ? trimmed : null;
}
