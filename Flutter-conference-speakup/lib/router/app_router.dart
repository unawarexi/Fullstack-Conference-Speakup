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
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_knowledge_gaps_screen.dart';
import 'package:flutter_conference_speakup/app/features/billing/presentation/billing_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_assistant_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_insights_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_coach_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_action_items_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_meeting_prep_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_relationships_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_predictions_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_summaries_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_documents_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_memory_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_meeting_replay_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_workflows_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_smart_scheduling_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_meeting_cost_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/transcription_viewer_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/emotion_analytics_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_sentiment_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_speaking_time_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/call_quality_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/meeting_feedback_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/meeting_materials_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_topic_tracker_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/integrations_hub_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/meeting_templates_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/quick_notes_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/export_reports_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_settings_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/people_directory_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/meeting_invite_screen.dart';
import 'package:flutter_conference_speakup/app/features/ai/presentation/ai_focus_mode_screen.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/meeting_history_screen.dart';
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

    // ──────────── AI Hub + nested sub-screens ────────────
    GoRoute(
      path: '/ai-insights',
      name: 'ai-insights',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AIInsightsScreen(),
      routes: [
        GoRoute(
          path: 'coach',
          name: 'ai-coach',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AICoachScreen(),
        ),
        GoRoute(
          path: 'action-items',
          name: 'ai-action-items',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AIActionItemsScreen(),
        ),
        GoRoute(
          path: 'meeting-prep',
          name: 'ai-meeting-prep',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AIMeetingPrepScreen(),
        ),
        GoRoute(
          path: 'relationships',
          name: 'ai-relationships',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AIRelationshipsScreen(),
        ),
        GoRoute(
          path: 'predictions',
          name: 'ai-predictions',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AIPredictionsScreen(),
        ),
        GoRoute(
          path: 'summaries',
          name: 'ai-summaries',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AISummariesScreen(),
        ),
        GoRoute(
          path: 'documents',
          name: 'ai-documents',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AIDocumentsScreen(),
        ),
        GoRoute(
          path: 'memory',
          name: 'ai-memory',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AIMemoryScreen(),
        ),
        GoRoute(
          path: 'knowledge-gaps',
          name: 'ai-knowledge-gaps',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AIKnowledgeGapsScreen(),
        ),
        GoRoute(
          path: 'workflows',
          name: 'ai-workflows',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AIWorkflowsScreen(),
        ),
        GoRoute(
          path: 'smart-scheduling',
          name: 'ai-smart-scheduling',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AISmartSchedulingScreen(),
        ),
        GoRoute(
          path: 'meeting-cost',
          name: 'ai-meeting-cost',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AIMeetingCostScreen(),
        ),
      ],
    ),

    // ──────────── Meeting Detail + nested per-meeting screens ────────────
    GoRoute(
      path: '/meeting-detail/:id',
      name: 'meeting-detail',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final meetingId = state.pathParameters['id']!;
        return MeetingDetailScreen(meetingId: meetingId);
      },
      routes: [
        GoRoute(
          path: 'replay',
          name: 'meeting-replay',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) =>
              AIMeetingReplayScreen(meetingId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: 'transcription',
          name: 'meeting-transcription',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) =>
              TranscriptionViewerScreen(meetingId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: 'emotion',
          name: 'meeting-emotion',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const EmotionAnalyticsScreen(),
        ),
        GoRoute(
          path: 'sentiment',
          name: 'meeting-sentiment',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AISentimentScreen(),
        ),
        GoRoute(
          path: 'speaking-time',
          name: 'meeting-speaking-time',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AISpeakingTimeScreen(),
        ),
        GoRoute(
          path: 'materials',
          name: 'meeting-materials',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const MeetingMaterialsScreen(),
        ),
        GoRoute(
          path: 'feedback',
          name: 'meeting-feedback',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const MeetingFeedbackScreen(),
        ),
        GoRoute(
          path: 'call-quality',
          name: 'meeting-call-quality',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const CallQualityScreen(),
        ),
        GoRoute(
          path: 'topic-tracker',
          name: 'meeting-topic-tracker',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AITopicTrackerScreen(),
        ),
      ],
    ),

    // ──────────── Standalone feature screens ────────────
    GoRoute(
      path: '/meeting-history',
      name: 'meeting-history',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const MeetingHistoryScreen(),
    ),
    GoRoute(
      path: '/people',
      name: 'people',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const PeopleDirectoryScreen(),
    ),
    GoRoute(
      path: '/integrations',
      name: 'integrations',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const IntegrationsHubScreen(),
    ),
    GoRoute(
      path: '/ai-settings',
      name: 'ai-settings',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AISettingsScreen(),
    ),
    GoRoute(
      path: '/meeting-templates',
      name: 'meeting-templates',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const MeetingTemplatesScreen(),
    ),
    GoRoute(
      path: '/quick-notes',
      name: 'quick-notes',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const QuickNotesScreen(),
    ),
    GoRoute(
      path: '/export-reports',
      name: 'export-reports',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ExportReportsScreen(),
    ),
    GoRoute(
      path: '/focus-mode',
      name: 'focus-mode',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AIFocusModeScreen(),
    ),
    GoRoute(
      path: '/meeting-invite',
      name: 'meeting-invite',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const MeetingInviteScreen(),
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
