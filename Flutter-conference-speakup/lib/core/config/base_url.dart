
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Resolves the backend API base URL based on environment and platform.
///
/// Priority:
///   1. Explicit env var  → `API_URL` from .env (always wins)
///   2. Release mode      → Production URL
///   3. Android emulator  → 10.0.2.2 loopback
///   4. iOS simulator     → localhost
///   5. Physical device   → LAN IP from .env (`DEV_HOST`)
class AppBaseUrl {
  AppBaseUrl._();

  static const String _productionUrl = 'https://api.speakup.app';
  static const int _devPort = 3000;
  static const String _apiPrefix = '/api/v1';

  /// Cached base URL resolved once at startup.
  static late final String value = _resolve();

  /// WebSocket URL (same host, different protocol).
  static late final String wsUrl = _resolveWs();

  static String _resolve() {
    // 1. Explicit override from .env
    final envUrl = dotenv.env['API_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl.replaceAll(RegExp(r'/+$'), '');
    }

    // 2. Release mode — production
    if (kReleaseMode) {
      return '$_productionUrl$_apiPrefix';
    }

    // 3. Debug mode — platform-specific dev URLs
    final devHost = dotenv.env['DEV_HOST'] ?? '192.168.1.100';

    if (kIsWeb) {
      return 'http://localhost:$_devPort$_apiPrefix';
    }

    if (Platform.isAndroid) {
      // Android emulator routes host loopback through 10.0.2.2
      return 'http://10.0.2.2:$_devPort$_apiPrefix';
    }

    if (Platform.isIOS) {
      // iOS simulator can reach host via localhost
      return 'http://localhost:$_devPort$_apiPrefix';
    }

    // macOS, Linux, Windows desktop
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return 'http://localhost:$_devPort$_apiPrefix';
    }

    // Physical device fallback — use LAN IP
    return 'http://$devHost:$_devPort$_apiPrefix';
  }

  static String _resolveWs() {
    final envWs = dotenv.env['WS_URL'];
    if (envWs != null && envWs.isNotEmpty) {
      return envWs.replaceAll(RegExp(r'/+$'), '');
    }

    if (kReleaseMode) {
      return 'wss://api.speakup.app';
    }

    final devHost = dotenv.env['DEV_HOST'] ?? '192.168.1.100';

    if (kIsWeb) return 'ws://localhost:$_devPort';
    if (Platform.isAndroid) return 'ws://10.0.2.2:$_devPort';
    if (Platform.isIOS || Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return 'ws://localhost:$_devPort';
    }
    return 'ws://$devHost:$_devPort';
  }
}
