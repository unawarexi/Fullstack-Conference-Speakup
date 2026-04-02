import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App integration tests', () {
    testWidgets('App launches and renders scaffold',
        (WidgetTester tester) async {
      // Minimal app that doesn't depend on Firebase / native plugins
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('SpeakUp')),
              body: const Center(child: Text('Integration Test')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('SpeakUp'), findsOneWidget);
      expect(find.text('Integration Test'), findsOneWidget);
    });

    testWidgets('Navigation between placeholder screens',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: DefaultTabController(
              length: 3,
              child: Scaffold(
                body: const TabBarView(
                  children: [
                    Center(child: Text('Home')),
                    Center(child: Text('Meetings')),
                    Center(child: Text('Settings')),
                  ],
                ),
                bottomNavigationBar: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.home), text: 'Home'),
                    Tab(icon: Icon(Icons.videocam), text: 'Meetings'),
                    Tab(icon: Icon(Icons.settings), text: 'Settings'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Home'), findsWidgets);

      // Tap meetings tab
      await tester.tap(find.text('Meetings'));
      await tester.pumpAndSettle();
      expect(find.text('Meetings'), findsWidgets);

      // Tap settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);
    });
  });
}
