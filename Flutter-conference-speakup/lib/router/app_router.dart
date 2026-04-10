import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/app/screens/bottom_navigation.dart';
import 'package:flutter_conference_speakup/app/screens/home_screen.dart';
import 'package:flutter_conference_speakup/app/screens/onboarding/onboarding_screen.dart';
import 'package:flutter_conference_speakup/app/screens/splash/splash_screen.dart';
import 'package:flutter_conference_speakup/app/features/auth/presentation/login_screen.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/meetings_list_screen.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/meeting_room_screen.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/join_meeting_screen.dart';
import 'package:flutter_conference_speakup/app/features/chat/presentation/chat_list_screen.dart';
import 'package:flutter_conference_speakup/app/features/chat/presentation/chat_room_screen.dart';
import 'package:flutter_conference_speakup/app/features/settings/presentation/settings_screen.dart';
import 'package:flutter_conference_speakup/app/features/recordings/presentation/recordings_screen.dart';
import 'package:flutter_conference_speakup/app/features/participant/presentation/participants_screen.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/create_meeting_screen.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/meeting_detail_screen.dart';
import 'package:flutter_conference_speakup/app/features/search/presentation/search_screen.dart';
import 'package:flutter_conference_speakup/app/features/notification/presentation/notifications_screen.dart';
import 'package:flutter_conference_speakup/app/features/analytics/presentation/analytics_dashboard_screen.dart';
import 'package:flutter_conference_speakup/app/features/billing/presentation/billing_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_assistant_screen.dart';
import 'package:flutter_conference_speakup/app/features/legal/presentation/terms_of_service_screen.dart';
import 'package:flutter_conference_speakup/app/features/legal/presentation/privacy_policy_screen.dart';
import 'package:flutter_conference_speakup/core/services/storage_service.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// Application router with deep linking support.
///
/// Deep link schemes:
///   speakup://meeting/:id            → joins a meeting by ID
///   speakup://meet/:code             → joins by SpeakUp code (spk-xxxx-xxxx)
///   speakup://chat/:id               → opens a chat
///   https://speakup.app/join/:code   → universal link to join meeting
///   https://speakup.app/meeting/:id  → universal link to meeting room
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  debugLogDiagnostics: true,

  // Auth guard
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final location = state.matchedLocation;

    // Allow splash screen through without redirect
    if (location == '/splash') return null;

    final publicRoutes = {'/onboarding', '/login', '/terms', '/privacy'};
    final isPublicRoute = publicRoutes.contains(location);

    // First launch → onboarding
    if (location == '/onboarding' && LocalStorageService.hasSeenOnboarding && !isLoggedIn) {
      return '/login';
    }

    // Not logged in trying to access protected route
    if (!isLoggedIn && !isPublicRoute) {
      return '/login';
    }

    // Logged in trying to access auth route
    if (isLoggedIn && isPublicRoute) {
      return '/home';
    }

    return null;
  },

  routes: [
    // ──────────── Splash ────────────
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // ──────────── Onboarding ────────────
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // ──────────── Auth (OAuth only) ────────────
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // ──────────── Main Shell (Bottom Nav) ────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BottomNavigation(navigationShell: navigationShell);
      },
      branches: [
        // Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Meetings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/meetings',
              name: 'meetings',
              builder: (context, state) => const MeetingsListScreen(),
            ),
          ],
        ),

        // Chat
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              name: 'chat-list',
              builder: (context, state) => const ChatListScreen(),
            ),
          ],
        ),

        // Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),

    // ──────────── Deep-linkable standalone routes ────────────

    // Meeting room (deep link: speakup://meeting/abc-123)
    GoRoute(
      path: '/meeting/:id',
      name: 'meeting-room',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final meetingId = state.pathParameters['id']!;
        return MeetingRoomScreen(meetingId: meetingId);
      },
    ),

    // Join meeting
    GoRoute(
      path: '/join',
      name: 'join-meeting',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const JoinMeetingScreen(),
    ),

    // Join by code deep link (speakup://meet/:code or https://speakup.app/join/:code)
    GoRoute(
      path: '/join/:code',
      name: 'join-by-code',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final code = state.pathParameters['code']!;
        return JoinMeetingScreen(initialCode: code);
      },
    ),

    // Chat room (deep link: speakup://chat/user-123)
    GoRoute(
      path: '/chat/:id',
      name: 'chat-room',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final chatId = state.pathParameters['id']!;
        final title = state.uri.queryParameters['name'] ?? 'Chat';
        return ChatRoomScreen(chatId: chatId, title: title);
      },
    ),

    // Recordings
    GoRoute(
      path: '/recordings',
      name: 'recordings',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const RecordingsScreen(),
    ),

    // Participants panel
    GoRoute(
      path: '/meeting/:id/participants',
      name: 'participants',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final meetingId = state.pathParameters['id']!;
        return ParticipantsScreen(meetingId: meetingId);
      },
    ),

    // ──────────── Legal ────────────
    GoRoute(
      path: '/terms',
      name: 'terms-of-service',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const TermsOfServiceScreen(),
    ),
    GoRoute(
      path: '/privacy',
      name: 'privacy-policy',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),

    // ──────────── Create / Detail ────────────
    GoRoute(
      path: '/create-meeting',
      name: 'create-meeting',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const CreateMeetingScreen(),
    ),
    GoRoute(
      path: '/meeting-detail/:id',
      name: 'meeting-detail',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final meetingId = state.pathParameters['id']!;
        return MeetingDetailScreen(meetingId: meetingId);
      },
    ),

    // ──────────── Search / Notifications ────────────
    GoRoute(
      path: '/search',
      name: 'search',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const NotificationsScreen(),
    ),

    // ──────────── Analytics / Billing ────────────
    GoRoute(
      path: '/analytics',
      name: 'analytics',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AnalyticsDashboardScreen(),
    ),
    GoRoute(
      path: '/billing',
      name: 'billing',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const BillingScreen(),
    ),

    // ──────────── AI Assistant ────────────
    GoRoute(
      path: '/ai-assistant',
      name: 'ai-assistant',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AIAssistantScreen(),
    ),
  ],

  // Error / 404 page
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Page not found', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(state.uri.toString(), style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);
