import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

/// Lightweight connectivity check service used by interceptors.
/// For UI state management, use [ConnectivityNotifier] in connectivity_provider.dart.
class ConnectivityService {
  static ConnectivityService? _instance;
  final Connectivity _connectivity = Connectivity();

  ConnectivityService._();
  factory ConnectivityService() => _instance ??= ConnectivityService._();

  /// Stream of connectivity changes.
  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(
        (results) => results.any((r) => r != ConnectivityResult.none),
      );

  /// Check if device has any network connection.
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
