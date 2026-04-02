import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_confrence_app/core/router/app_router.dart';
import 'package:video_confrence_app/store/connectivity_provider.dart';
import 'package:video_confrence_app/store/theme_provider.dart';
import 'package:video_confrence_app/theme/theme.dart';

class SpeakUpApp extends ConsumerWidget {
  const SpeakUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final network = ref.watch(connectivityProvider);

    return MaterialApp.router(
      title: 'SpeakUp',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      themeMode: themeMode,

      // Router
      routerConfig: appRouter,

      builder: (context, child) {
        return Column(
          children: [
            // Connectivity banner
            if (network.quality == NetworkQuality.offline)
              MaterialBanner(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: Colors.red.shade700,
                content: const Text(
                  'No internet connection',
                  style: TextStyle(color: Colors.white),
                ),
                leading: const Icon(Icons.wifi_off, color: Colors.white),
                actions: const [SizedBox.shrink()],
              )
            else if (network.quality == NetworkQuality.slow)
              MaterialBanner(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: Colors.orange.shade700,
                content: const Text(
                  'Slow network detected',
                  style: TextStyle(color: Colors.white),
                ),
                leading: const Icon(Icons.signal_wifi_statusbar_connected_no_internet_4,
                    color: Colors.white),
                actions: const [SizedBox.shrink()],
              ),
            // Main content
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        );
      },
    );
  }
}