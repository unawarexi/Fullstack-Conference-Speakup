import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Network quality levels shown to user.
enum NetworkQuality { offline, slow, good }

class NetworkState {
  final NetworkQuality quality;
  final bool isConnected;

  const NetworkState({
    this.quality = NetworkQuality.good,
    this.isConnected = true,
  });

  const NetworkState.offline()
      : quality = NetworkQuality.offline,
        isConnected = false;
}

/// Global connectivity provider — monitors network quality.
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, NetworkState>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<NetworkState> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _subscription;
  Timer? _qualityTimer;

  ConnectivityNotifier() : super(const NetworkState()) {
    _init();
  }

  Future<void> _init() async {
    // Initial check
    final results = await _connectivity.checkConnectivity();
    _handleConnectivity(results);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_handleConnectivity);

    // Periodic quality check every 30 seconds
    _qualityTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkQuality(),
    );
  }

  void _handleConnectivity(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => r != ConnectivityResult.none);
    if (!hasConnection) {
      state = const NetworkState.offline();
    } else {
      _checkQuality();
    }
  }

  /// Lightweight latency check to determine network quality.
  Future<void> _checkQuality() async {
    try {
      final stopwatch = Stopwatch()..start();
      final socket = await Socket.connect(
        'dns.google', // Google public DNS — fast, reliable
        53,
        timeout: const Duration(seconds: 5),
      );
      stopwatch.stop();
      socket.destroy();

      final latency = stopwatch.elapsedMilliseconds;
      if (latency > 2000) {
        state = const NetworkState(quality: NetworkQuality.slow, isConnected: true);
      } else {
        state = const NetworkState(quality: NetworkQuality.good, isConnected: true);
      }
    } on SocketException {
      state = const NetworkState.offline();
    } catch (_) {
      // Keep current state on unexpected errors
    }
  }

  /// Force refresh connectivity state.
  Future<void> refresh() async {
    final results = await _connectivity.checkConnectivity();
    _handleConnectivity(results);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _qualityTimer?.cancel();
    super.dispose();
  }
}
