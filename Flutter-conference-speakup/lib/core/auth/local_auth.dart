import 'package:local_auth/local_auth.dart';
import 'package:video_confrence_app/core/services/storage_service.dart';

class LocalAuthService {
  static final _localAuth = LocalAuthentication();

  /// Check if biometric auth is available on the device.
  static Future<bool> isAvailable() async {
    final canCheck = await _localAuth.canCheckBiometrics;
    final isDeviceSupported = await _localAuth.isDeviceSupported();
    return canCheck && isDeviceSupported;
  }

  /// Get available biometric types.
  static Future<List<BiometricType>> getAvailableBiometrics() =>
      _localAuth.getAvailableBiometrics();

  /// Check if biometric is enabled AND available.
  /// Biometric can only be activated after a successful OAuth sign-in.
  static Future<bool> canUseBiometric() async {
    final enabled = LocalStorageService.biometricEnabled;
    if (!enabled) return false;
    return isAvailable();
  }

  /// Enable biometric authentication.
  /// Should only be called after a successful Google/GitHub sign-in.
  static Future<bool> enable() async {
    final available = await isAvailable();
    if (!available) return false;

    // Verify the user can authenticate before enabling
    final authenticated = await authenticate(
      reason: 'Verify your identity to enable biometric login',
    );
    if (authenticated) {
      await LocalStorageService.setBiometricEnabled(true);
    }
    return authenticated;
  }

  /// Disable biometric authentication.
  static Future<void> disable() async {
    await LocalStorageService.setBiometricEnabled(false);
  }

  /// Authenticate with biometrics or device PIN.
  static Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
  }) async {
    return _localAuth.authenticate(
      localizedReason: reason,
      biometricOnly: false,
      sensitiveTransaction: true,
    );
  }
}
