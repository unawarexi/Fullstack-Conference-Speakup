import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

/// Secure storage for tokens and sensitive data.
class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _userIdKey = 'user_id';

  static Future<void> saveUserId(String id) =>
      _storage.write(key: _userIdKey, value: id);

  static Future<String?> getUserId() => _storage.read(key: _userIdKey);

  static Future<void> clearAll() => _storage.deleteAll();
}

/// Local key-value storage for non-sensitive preferences.
class LocalStorageService {
  static final _box = GetStorage();

  static const _onboardingKey = 'has_seen_onboarding';
  static const _themeModeKey = 'theme_mode';
  static const _biometricKey = 'biometric_enabled';

  // Settings keys
  static const _aiCopilotKey = 'ai_copilot_enabled';
  static const _aiTranscriptionKey = 'ai_transcription_enabled';
  static const _aiCoachingKey = 'ai_coaching_enabled';
  static const _aiVoiceAssistantKey = 'ai_voice_assistant_enabled';
  static const _notificationsKey = 'notifications_enabled';
  static const _cameraOnKey = 'camera_on_by_default';
  static const _micOnKey = 'mic_on_by_default';
  static const _autoRecordKey = 'auto_record_enabled';

  static Future<void> init() => GetStorage.init();

  // Onboarding
  static bool get hasSeenOnboarding => _box.read<bool>(_onboardingKey) ?? false;
  static Future<void> setOnboardingComplete() =>
      _box.write(_onboardingKey, true);

  // Theme
  static String get themeMode => _box.read<String>(_themeModeKey) ?? 'system';
  static Future<void> setThemeMode(String mode) =>
      _box.write(_themeModeKey, mode);

  // Biometric
  static bool get biometricEnabled => _box.read<bool>(_biometricKey) ?? false;
  static Future<void> setBiometricEnabled(bool enabled) =>
      _box.write(_biometricKey, enabled);

  // AI Features
  static bool get aiCopilotEnabled => _box.read<bool>(_aiCopilotKey) ?? true;
  static Future<void> setAiCopilotEnabled(bool v) => _box.write(_aiCopilotKey, v);

  static bool get aiTranscriptionEnabled => _box.read<bool>(_aiTranscriptionKey) ?? true;
  static Future<void> setAiTranscriptionEnabled(bool v) => _box.write(_aiTranscriptionKey, v);

  static bool get aiCoachingEnabled => _box.read<bool>(_aiCoachingKey) ?? false;
  static Future<void> setAiCoachingEnabled(bool v) => _box.write(_aiCoachingKey, v);

  static bool get aiVoiceAssistantEnabled => _box.read<bool>(_aiVoiceAssistantKey) ?? true;
  static Future<void> setAiVoiceAssistantEnabled(bool v) => _box.write(_aiVoiceAssistantKey, v);

  // Notifications
  static bool get notificationsEnabled => _box.read<bool>(_notificationsKey) ?? true;
  static Future<void> setNotificationsEnabled(bool v) => _box.write(_notificationsKey, v);

  // Meeting Defaults
  static bool get cameraOnByDefault => _box.read<bool>(_cameraOnKey) ?? true;
  static Future<void> setCameraOnByDefault(bool v) => _box.write(_cameraOnKey, v);

  static bool get micOnByDefault => _box.read<bool>(_micOnKey) ?? true;
  static Future<void> setMicOnByDefault(bool v) => _box.write(_micOnKey, v);

  static bool get autoRecordEnabled => _box.read<bool>(_autoRecordKey) ?? false;
  static Future<void> setAutoRecordEnabled(bool v) => _box.write(_autoRecordKey, v);
}
