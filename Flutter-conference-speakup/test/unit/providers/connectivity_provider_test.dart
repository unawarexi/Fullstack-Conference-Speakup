import 'package:flutter_test/flutter_test.dart';
import 'package:video_confrence_app/store/connectivity_provider.dart';

void main() {
  group('NetworkState', () {
    test('default constructor has good quality and connected', () {
      const state = NetworkState();
      expect(state.quality, NetworkQuality.good);
      expect(state.isConnected, true);
    });

    test('offline constructor sets correct values', () {
      const state = NetworkState.offline();
      expect(state.quality, NetworkQuality.offline);
      expect(state.isConnected, false);
    });

    test('slow quality with connection', () {
      const state =
          NetworkState(quality: NetworkQuality.slow, isConnected: true);
      expect(state.quality, NetworkQuality.slow);
      expect(state.isConnected, true);
    });
  });

  group('NetworkQuality', () {
    test('has 3 values', () {
      expect(NetworkQuality.values.length, 3);
      expect(NetworkQuality.values, contains(NetworkQuality.offline));
      expect(NetworkQuality.values, contains(NetworkQuality.slow));
      expect(NetworkQuality.values, contains(NetworkQuality.good));
    });
  });
}
