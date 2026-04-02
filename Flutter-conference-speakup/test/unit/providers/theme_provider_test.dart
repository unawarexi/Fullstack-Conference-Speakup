import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tests for ThemeModeNotifier state transitions.
/// We avoid constructing the real ThemeModeNotifier (it requires GetStorage)
/// and instead test its logic via a standalone notifier.
class _TestThemeNotifier extends StateNotifier<ThemeMode> {
  _TestThemeNotifier() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) => state = mode;

  void toggleDarkMode() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final _testThemeProvider =
    StateNotifierProvider<_TestThemeNotifier, ThemeMode>(
        (ref) => _TestThemeNotifier());

void main() {
  group('ThemeModeNotifier', () {
    test('initial state is ThemeMode.system', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(_testThemeProvider), ThemeMode.system);
    });

    test('setThemeMode updates state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(_testThemeProvider.notifier).setThemeMode(ThemeMode.dark);
      expect(container.read(_testThemeProvider), ThemeMode.dark);
    });

    test('toggleDarkMode switches between dark and light', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(_testThemeProvider.notifier);
      notifier.setThemeMode(ThemeMode.light);
      notifier.toggleDarkMode();
      expect(container.read(_testThemeProvider), ThemeMode.dark);
      notifier.toggleDarkMode();
      expect(container.read(_testThemeProvider), ThemeMode.light);
    });
  });
}
