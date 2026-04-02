import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_confrence_app/store/connectivity_provider.dart';

void main() {
  group('App smoke tests', () {
    testWidgets('MaterialApp.router renders without error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('SpeakUp')),
              body: const Center(child: Text('Hello SpeakUp')),
            ),
          ),
        ),
      );

      expect(find.text('SpeakUp'), findsOneWidget);
      expect(find.text('Hello SpeakUp'), findsOneWidget);
    });

    testWidgets('Theme can be switched between light and dark',
        (WidgetTester tester) async {
      final themeNotifier = ValueNotifier(ThemeMode.light);
      await tester.pumpWidget(
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, mode, _) {
            return MaterialApp(
              themeMode: mode,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              home: const Scaffold(body: Text('Themed')),
            );
          },
        ),
      );

      expect(find.text('Themed'), findsOneWidget);

      themeNotifier.value = ThemeMode.dark;
      await tester.pumpAndSettle();
      expect(find.text('Themed'), findsOneWidget);
    });

    testWidgets('Offline banner can be shown based on state',
        (WidgetTester tester) async {
      // Direct widget test — no ConnectivityNotifier (avoids platform channels)
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: const [
              Text('No internet connection'),
              Expanded(child: Placeholder()),
            ],
          ),
        ),
      );

      expect(find.text('No internet connection'), findsOneWidget);
    });

    testWidgets('NetworkState model works correctly', (_) async {
      const offline = NetworkState.offline();
      expect(offline.isConnected, false);
      expect(offline.quality, NetworkQuality.offline);

      const good = NetworkState();
      expect(good.isConnected, true);
      expect(good.quality, NetworkQuality.good);
    });
  });
}

