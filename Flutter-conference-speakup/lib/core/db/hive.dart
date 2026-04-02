import 'package:hive_flutter/hive_flutter.dart';

/// Local cache using Hive — stores JSON maps, no code-gen adapters needed.
///
/// Caching strategy:
/// - `user_cache`: Current user profile (offline fallback)
/// - `meeting_cache`: Recent meetings list by status
/// - `notification_cache`: Recent notifications
/// - `settings`: App settings (non-sensitive)
class HiveService {
  static const _meetingCacheBox = 'meeting_cache';
  static const _userCacheBox = 'user_cache';
  static const _notificationCacheBox = 'notification_cache';
  static const _settingsBox = 'settings';
  static const _cacheTTLBox = 'cache_ttl';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(_meetingCacheBox),
      Hive.openBox(_userCacheBox),
      Hive.openBox(_notificationCacheBox),
      Hive.openBox(_settingsBox),
      Hive.openBox(_cacheTTLBox),
    ]);
  }

  static Box get meetingCache => Hive.box(_meetingCacheBox);
  static Box get userCache => Hive.box(_userCacheBox);
  static Box get notificationCache => Hive.box(_notificationCacheBox);
  static Box get settings => Hive.box(_settingsBox);
  static Box get _ttlBox => Hive.box(_cacheTTLBox);

  /// Store data with a TTL (time-to-live) in minutes.
  static Future<void> putWithTTL(Box box, String key, dynamic value,
      {int ttlMinutes = 30}) async {
    await box.put(key, value);
    await _ttlBox.put('${box.name}:$key',
        DateTime.now().add(Duration(minutes: ttlMinutes)).toIso8601String());
  }

  /// Get data if not expired.
  static dynamic getIfFresh(Box box, String key) {
    final expiryStr = _ttlBox.get('${box.name}:$key') as String?;
    if (expiryStr == null) return box.get(key);

    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null || DateTime.now().isAfter(expiry)) {
      // Expired — remove
      box.delete(key);
      _ttlBox.delete('${box.name}:$key');
      return null;
    }
    return box.get(key);
  }

  /// Clear all caches (user data) — called on sign out.
  static Future<void> clearAll() async {
    await meetingCache.clear();
    await userCache.clear();
    await notificationCache.clear();
    await _ttlBox.clear();
  }

  /// Clear only expired entries from all boxes.
  static Future<void> pruneExpired() async {
    final keysToRemove = <String>[];
    for (final key in _ttlBox.keys) {
      final expiryStr = _ttlBox.get(key) as String?;
      if (expiryStr != null) {
        final expiry = DateTime.tryParse(expiryStr);
        if (expiry != null && DateTime.now().isAfter(expiry)) {
          keysToRemove.add(key as String);
        }
      }
    }
    for (final key in keysToRemove) {
      await _ttlBox.delete(key);
      // Parse box name and data key from TTL key
      final parts = key.split(':');
      if (parts.length >= 2) {
        final boxName = parts[0];
        final dataKey = parts.sublist(1).join(':');
        try {
          Hive.box(boxName).delete(dataKey);
        } catch (_) {}
      }
    }
  }
}
