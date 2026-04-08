import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_conference_speakup/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:flutter_conference_speakup/core/db/hive.dart';
import 'package:flutter_conference_speakup/core/services/storage_service.dart';
import 'package:flutter_conference_speakup/core/auth/google_signin.dart';
import 'package:flutter_conference_speakup/firebase_options.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-cache liquid glass shaders
  await LiquidGlassWidgets.initialize();

  // Load environment
  await dotenv.load(fileName: '.env');

  // Parallel init for independent services
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    HiveService.init(),
    LocalStorageService.init(),
  ]);

  // Initialize Google Sign-In (must be after Firebase.initializeApp)
  await GoogleSignInService.init();

  // Prune expired cache entries
  await HiveService.pruneExpired();

  // Lock orientation on mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final app = ProviderScope(
    child: LiquidGlassWidgets.wrap(const SpeakUpApp()),
  );

  if (kReleaseMode) {
    await SentryFlutter.init(
      (options) {
        options.dsn = const String.fromEnvironment(
          'SENTRY_DSN',
          defaultValue: '',
        );
        options.tracesSampleRate = 0.2;
        options.environment = 'production';
      },
      appRunner: () => runApp(app),
    );
  } else {
    runApp(app);
  }
}