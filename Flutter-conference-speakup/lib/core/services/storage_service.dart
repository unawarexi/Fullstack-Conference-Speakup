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
}
