# SpeakUp Flutter — AI Skills Reference

> **App**: SpeakUp — Cross-platform video conferencing application  
> **Package**: `flutter_conference_speakup`  
> **Flutter SDK**: ^3.11.3  
> **State Management**: Riverpod 2.6  
> **Navigation**: GoRouter 14.8  
> **Design System**: Liquid Glass + Material 3 (light/dark)  
> **Backend**: Node.js (Express) at `api.speakup.app`  
> **Auth**: Firebase Auth (Google OAuth, GitHub OAuth) + Biometric  
> **Real-time**: Socket.IO (WebSocket) + LiveKit (WebRTC video)  
> **Monitoring**: Sentry Flutter  
> **Generated**: 2026-04-14

---

## Table of Contents

1. [Directory Structure](#1-directory-structure)
2. [Entry Point & App Setup](#2-entry-point--app-setup)
3. [State Management (Riverpod)](#3-state-management-riverpod)
4. [Routing / Navigation (GoRouter)](#4-routing--navigation-gorouter)
5. [Screens & Pages](#5-screens--pages)
6. [Components / Widgets](#6-components--widgets)
7. [Services / API Layer](#7-services--api-layer)
8. [Models / Data Classes](#8-models--data-classes)
9. [Theme / Design System](#9-theme--design-system)
10. [Real-time Features](#10-real-time-features)
11. [Authentication](#11-authentication)
12. [Notifications](#12-notifications)
13. [Platform Configuration](#13-platform-configuration)
14. [Assets](#14-assets)
15. [Testing](#15-testing)
16. [Build & Scripts](#16-build--scripts)
17. [API Endpoints Reference](#17-api-endpoints-reference)

---

## 1. Directory Structure

```
lib/
├── main.dart                          # App entry point — bootstrap, Firebase, Sentry
├── app.dart                           # SpeakUpApp widget — MaterialApp.router + theme
├── firebase_options.dart              # FlutterFire platform-specific Firebase config
│
├── app/
│   ├── components/
│   │   ├── shapes/
│   │   │   ├── shapes.dart            # Barrel export for all shape files
│   │   │   ├── bg_patterns.dart       # Background pattern painters
│   │   │   ├── curved_clippers.dart   # Custom ClipPath shapes
│   │   │   └── decorative_painters.dart # CustomPainter decorations
│   │   ├── ui/
│   │   │   ├── activity_indicator.dart # SActivityIndicator, SLoadingOverlay
│   │   │   ├── bottom_sheet.dart      # SBottomSheet (iOS blur backdrop)
│   │   │   ├── button.dart            # SButton (5 variants), SIconButton
│   │   │   ├── card.dart              # SCard, SMeetingCard
│   │   │   ├── connectivity_toast.dart # ConnectivityToast (auto offline/online)
│   │   │   ├── dense_widgets.dart     # SectionHeader, DenseTile, CompactMeetingTile, etc.
│   │   │   ├── input.dart             # SInput, SSearchBar
│   │   │   ├── modal.dart             # SModal (Cupertino alert dialog)
│   │   │   ├── skeleton.dart          # SSkeleton, SMeetingCardSkeleton, SAvatarSkeleton
│   │   │   └── toast_notifier.dart    # SToast (fluttertoast wrapper)
│   │   └── widgets/
│   │       ├── app_bar.dart           # Custom AppBar widget
│   │       ├── date_time_picker.dart  # Date/time picker widget
│   │       ├── fab.dart               # Floating action button
│   │       ├── input_fields.dart      # Specialized input fields
│   │       └── spinners.dart          # Loading spinner variants
│   │
│   ├── domain/
│   │   ├── models/
│   │   │   ├── ai_models.dart         # TranscriptionSegment, CopilotSuggestion, EmotionSignal,
│   │   │   │                          #   CoachingHint, ActionItem, MeetingSummary,
│   │   │   │                          #   VoiceCommandResult, WorkflowStatus, WorkflowStepStatus
│   │   │   ├── chat_model.dart        # ChatMessage, ChatRoom, ChatMember
│   │   │   ├── legal_model.dart       # LegalDocument, LegalSection, LegalSubsection
│   │   │   ├── material_model.dart    # MeetingMaterialModel
│   │   │   ├── meeting_model.dart     # MeetingModel (+ MeetingStatus, MeetingType enums)
│   │   │   ├── notification_model.dart # NotificationModel (+ NotificationType enum)
│   │   │   ├── participant_model.dart # Participant (+ ParticipantRole enum), RecordingModel
│   │   │   ├── subscription_model.dart # SubscriptionModel (+ SubscriptionPlan, SubscriptionStatus)
│   │   │   └── user_model.dart        # UserModel (+ UserRole enum), DeviceModel
│   │   └── repositories/
│   │       ├── analytics_repository.dart  # getDashboard, getUsage, getMeetingAnalytics
│   │       ├── auth_repository.dart       # signInWithGoogle/Github, _syncWithBackend, getMe,
│   │       │                              #   getCachedUser, signOut, deleteAccount
│   │       ├── billing_repository.dart    # getSubscription, createCheckout, createPortal, cancel
│   │       ├── chat_repository.dart       # getRooms, getOrCreateMeetingChat, getMessages,
│   │       │                              #   sendMessage, deleteMessage
│   │       ├── legal_repository.dart      # getTermsOfService, getPrivacyPolicy
│   │       ├── meeting_repository.dart    # CRUD meetings, join/leave/end/lock/unlock,
│   │       │                              #   getParticipants, kickParticipant, getLiveKitToken,
│   │       │                              #   uploadMaterial, getMaterials, deleteMaterial
│   │       ├── notification_repository.dart # getNotifications, getUnreadCount, markAsRead,
│   │       │                              #   markAllAsRead, delete
│   │       ├── recording_repository.dart  # getRecordings, getById, getDownloadUrl, delete,
│   │       │                              #   startRecording, stopRecording
│   │       ├── room_repository.dart       # getRoomState, updateSettings, muteAll, getActiveRooms
│   │       ├── search_repository.dart     # globalSearch, searchUsers, searchMeetings
│   │       └── user_repository.dart       # getProfile, updateProfile, updateAvatar,
│   │                                      #   getDevices, registerDevice, removeDevice, updateOnlineStatus
│   │
│   ├── features/
│   │   ├── ai/presentation/
│   │   │   ├── ai_action_items_screen.dart
│   │   │   ├── ai_assistant_screen.dart
│   │   │   ├── ai_coach_screen.dart
│   │   │   ├── ai_documents_screen.dart
│   │   │   ├── ai_focus_mode_screen.dart
│   │   │   ├── ai_insights_screen.dart
│   │   │   ├── ai_knowledge_gaps_screen.dart
│   │   │   ├── ai_meeting_cost_screen.dart
│   │   │   ├── ai_meeting_prep_screen.dart
│   │   │   ├── ai_meeting_replay_screen.dart
│   │   │   ├── ai_memory_screen.dart
│   │   │   ├── ai_predictions_screen.dart
│   │   │   ├── ai_relationships_screen.dart
│   │   │   ├── ai_sentiment_screen.dart
│   │   │   ├── ai_settings_screen.dart
│   │   │   ├── ai_smart_scheduling_screen.dart
│   │   │   ├── ai_speaking_time_screen.dart
│   │   │   ├── ai_summaries_screen.dart
│   │   │   ├── ai_topic_tracker_screen.dart
│   │   │   ├── ai_workflows_screen.dart
│   │   │   ├── call_quality_screen.dart
│   │   │   ├── emotion_analytics_screen.dart
│   │   │   ├── export_reports_screen.dart
│   │   │   ├── integrations_hub_screen.dart
│   │   │   ├── meeting_feedback_screen.dart
│   │   │   ├── meeting_invite_screen.dart
│   │   │   ├── meeting_materials_screen.dart
│   │   │   ├── meeting_templates_screen.dart
│   │   │   ├── people_directory_screen.dart
│   │   │   ├── quick_notes_screen.dart
│   │   │   ├── transcription_viewer_screen.dart
│   │   │   └── voice_command_screen.dart
│   │   │
│   │   ├── analytics/presentation/
│   │   │   └── analytics_dashboard_screen.dart
│   │   │
│   │   ├── auth/
│   │   │   ├── presentation/
│   │   │   │   └── login_screen.dart      # OAuth login (Google + GitHub)
│   │   │   └── usecases/
│   │   │       └── login_usecase.dart      # LoginUseCase orchestrator
│   │   │
│   │   ├── billing/presentation/
│   │   │   └── billing_screen.dart
│   │   │
│   │   ├── chat/presentation/
│   │   │   ├── chat_list_screen.dart
│   │   │   └── chat_room_screen.dart
│   │   │
│   │   ├── legal/presentation/
│   │   │   ├── legal_document_view.dart
│   │   │   ├── privacy_policy_screen.dart
│   │   │   └── terms_of_service_screen.dart
│   │   │
│   │   ├── meeting/
│   │   │   ├── presentation/
│   │   │   │   ├── create_meeting_screen.dart
│   │   │   │   ├── join_meeting_screen.dart
│   │   │   │   ├── meeting_detail_screen.dart
│   │   │   │   ├── meeting_history_screen.dart
│   │   │   │   ├── meeting_lobby_screen.dart
│   │   │   │   ├── meeting_room_screen.dart   # Main video call screen
│   │   │   │   ├── meetings_list_screen.dart
│   │   │   │   ├── meetings_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── create_meeting_widgets.dart
│   │   │   │       ├── join_meeting_widgets.dart
│   │   │   │       ├── meeting_chat_sheet.dart
│   │   │   │       ├── meeting_detail_widgets.dart
│   │   │   │       ├── meeting_info_sheet.dart
│   │   │   │       ├── meeting_participants_sheet.dart
│   │   │   │       ├── meetings_list_widgets.dart
│   │   │   │       ├── room_coaching_banner.dart
│   │   │   │       ├── room_controls_bar.dart
│   │   │   │       ├── room_copilot_panel.dart
│   │   │   │       ├── room_more_options_overlay.dart
│   │   │   │       ├── room_top_bar.dart
│   │   │   │       ├── room_transcription_overlay.dart
│   │   │   │       ├── room_video_grid.dart
│   │   │   │       └── room_voice_assistant_sheet.dart
│   │   │   └── usecases/
│   │   │       ├── create_meeting_usecase.dart  # CreateMeetingParams + helpers
│   │   │       ├── join_meeting_usecase.dart    # extractMeetingCode() parser
│   │   │       └── meeting_utils.dart           # formatMeetingDuration, fileTypeIcon, fileTypeColor
│   │   │
│   │   ├── notification/presentation/
│   │   │   └── notifications_screen.dart
│   │   │
│   │   ├── participant/presentation/
│   │   │   └── participants_screen.dart
│   │   │
│   │   ├── recordings/presentation/
│   │   │   └── recordings_screen.dart
│   │   │
│   │   ├── search/presentation/
│   │   │   └── search_screen.dart
│   │   │
│   │   └── settings/presentation/
│   │       ├── settings_screen.dart
│   │       └── widgets/
│   │           ├── edit_profile_content.dart
│   │           └── settings_section.dart
│   │
│   └── screens/
│       ├── bottom_navigation.dart      # Adaptive: GlassSideBar (desktop) + LiquidGlass Island (mobile)
│       ├── home_screen.dart            # Main home with collapsing header, quick actions, meetings
│       ├── home/
│       │   └── home_widgets.dart       # QuickActionGrid, AISuggestionsSection, CompactMeetingTile, etc.
│       ├── onboarding/
│       │   ├── onboarding_screen.dart  # Multi-step onboarding
│       │   └── widgets/
│       │       ├── ambient_background.dart
│       │       ├── secure_visual.dart
│       │       ├── shared_widgets.dart
│       │       ├── team_chat_visual.dart
│       │       └── video_call_visual.dart
│       └── splash/
│           └── splash_screen.dart      # Animated splash with brand reveal, pulse rings, shimmer
│
├── core/
│   ├── animations/
│   │   ├── page_transitions.dart       # SAnimations: fadeTransition, slideUpTransition (GoRouter)
│   │   ├── screen_animations.dart      # SheetRevealAnim, BrandRevealAnim, SlideUpFadeAnim,
│   │   │                               #   GlowPulseAnim, FadeInAnim, ExitAnim, RingPulseAnim,
│   │   │                               #   StaggeredCascadeAnim
│   │   └── widget_animations.dart      # SWidgetAnimations: fadeIn, scaleIn, slideUp
│   │
│   ├── apis/
│   │   └── endpoints.dart              # ApiEndpoints — all REST endpoint paths (centralized)
│   │
│   ├── auth/
│   │   ├── google_signin.dart          # GoogleSignInService: init(), signIn(), signOut()
│   │   ├── github_signin.dart          # GithubSignInService: signIn(), signOut()
│   │   └── local_auth.dart             # LocalAuthService: isAvailable(), enable(), authenticate()
│   │
│   ├── config/
│   │   ├── base_url.dart               # AppBaseUrl: resolves API + WS URLs per platform/mode
│   │   └── environment.dart            # Environment: all dotenv Firebase keys, GitHub OAuth keys
│   │
│   ├── constants/
│   │   ├── colors.dart                 # SColors: primary blue palette, dark/light surfaces,
│   │   │                               #   semantic colors, meeting-specific, chat, gradients
│   │   ├── icons.dart                  # SIcons: Iconsax icon mappings (nav, meeting controls, general)
│   │   ├── image_strings.dart          # SImages: asset paths (logos, onboarding, auth, placeholders)
│   │   ├── responsive.dart             # SResponsive: breakpoints, meetingGridColumns, ResponsiveLayout
│   │   ├── sizes.dart                  # SSizes: spacing, padding, radius, button/input/avatar heights
│   │   └── text_strings.dart           # STexts: all static UI strings (i18n-ready)
│   │
│   ├── data/                           # (empty — reserved for data layer)
│   │
│   ├── db/
│   │   └── hive.dart                   # HiveService: cache boxes (user, meeting, notification, settings),
│   │                                   #   TTL-based caching, pruneExpired(), clearAll()
│   │
│   ├── errors/
│   │   ├── exceptions.dart             # ServerException, CacheException, NetworkException
│   │   └── failures.dart               # ServerFailure, CacheFailure, NetworkFailure, AuthFailure,
│   │                                   #   ValidationFailure
│   │
│   ├── network/
│   │   ├── account_guard.dart          # AccountGuard: detects deleted/suspended accounts,
│   │   │                               #   forces sign-out + dialog + redirect to /login
│   │   ├── api_client.dart             # ApiClient (Dio singleton): get/post/put/patch/delete/upload,
│   │   │                               #   ConnectivityInterceptor, AuthInterceptor, RetryInterceptor
│   │   ├── api_exception.dart          # ApiException, ApiResult<T> (success/failure wrapper)
│   │   └── connectivity_service.dart   # ConnectivityService: isConnected, onConnectivityChanged stream
│   │
│   ├── services/
│   │   ├── storage_service.dart        # SecureStorageService (flutter_secure_storage),
│   │   │                               #   LocalStorageService (GetStorage) — all settings keys
│   │   └── websocket.dart              # WebSocketService (Socket.IO singleton): connect/disconnect,
│   │                                   #   emit/on/off, stream(), joinMeetingRoom/leaveMeetingRoom,
│   │                                   #   joinChatRoom/leaveChatRoom
│   │
│   └── utils/
│       ├── file_picker.dart            # FilePickerWithPermissions: pickImageFromGallery/Camera,
│       │                               #   pickFile, pickMultipleImages
│       ├── formatters.dart             # SFormatters: formatDate/Time/DateTime/RelativeTime/Duration/
│       │                               #   MeetingTimer/ParticipantCount, truncate
│       ├── helper_functions.dart       # SHelpers: isWeb/isMobile/isDesktop, isDarkMode,
│       │                               #   copyToClipboard, openUrl, showSnackBar
│       ├── permission_handler.dart     # PermissionManager: requestCamera/Mic/Location/Storage/
│       │                               #   Photos/Contacts/Calendar
│       └── validators.dart             # validateEmail/Password/ConfirmPassword/Name/MeetingId/Required
│
├── router/
│   └── app_router.dart                 # GoRouter config — all routes, auth guard, deep linking, 404
│
├── store/
│   ├── ai_provider.dart                # MeetingAINotifier + MeetingAIState, AISocketEvents constants
│   ├── auth_provider.dart              # CurrentUserNotifier, authStateProvider, biometricEnabledProvider
│   ├── billing_provider.dart           # subscriptionProvider
│   ├── chat_provider.dart              # ChatMessagesNotifier + ChatMessagesState, chatRoomsProvider
│   ├── connectivity_provider.dart      # ConnectivityNotifier + NetworkState + NetworkQuality enum
│   ├── legal_provider.dart             # termsOfServiceProvider, privacyPolicyProvider
│   ├── meeting_provider.dart           # ActiveMeetingNotifier + MeetingRoomState, meetingsProvider,
│   │                                   #   meetingByIdProvider, meetingParticipantsProvider
│   ├── notification_provider.dart      # NotificationsNotifier, unreadNotificationCountProvider
│   ├── recording_provider.dart         # recordingsProvider, recordingByIdProvider
│   ├── search_provider.dart            # searchQueryProvider, searchResultsProvider,
│   │                                   #   userSearchProvider, meetingSearchProvider
│   ├── settings_provider.dart          # SettingsNotifier + AppSettings, all toggle methods
│   ├── theme_provider.dart             # ThemeModeNotifier — light/dark/system toggle
│   └── user_provider.dart              # updateProfileProvider, updateAvatarProvider
│
└── theme/
    ├── theme.dart                      # TAppTheme: lightTheme + darkTheme (Material 3)
    └── custom_themes/
        ├── app_bar_theme.dart          # TAppBarTheme
        ├── bottom_sheet_theme.dart     # TBottomSheetTheme
        ├── check_box_theme.dart        # TCheckBoxTheme
        ├── chip_theme.dart             # TChipTheme
        ├── elevated_button_theme.dart  # TElevatedButtonTheme
        ├── outlined_button_theme.dart  # TOutlineButtonTheme
        ├── text_field_theme.dart       # TTextFormFieldTheme
        └── text_theme.dart             # TTextTheme
```

---

## 2. Entry Point & App Setup

### `lib/main.dart`

**Boot sequence** (all async, parallel where possible):
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `LiquidGlassWidgets.initialize()` — pre-cache glass shaders
3. `dotenv.load(fileName: '.env')` — load environment variables
4. **Parallel init**: `Firebase.initializeApp()`, `HiveService.init()`, `LocalStorageService.init()`
5. `GoogleSignInService.init()` — must be after Firebase
6. `HiveService.pruneExpired()` — clean stale cache entries
7. Lock orientation to portrait on mobile
8. Set transparent status bar
9. Wrap app in `ProviderScope` → `LiquidGlassWidgets.wrap()` → `SpeakUpApp()`
10. In release mode: wrap with `SentryFlutter.init()` (DSN from env, 0.2 sample rate)

### `lib/app.dart` — `SpeakUpApp`

- `ConsumerWidget` (reads `themeModeProvider`)
- `MaterialApp.router` with:
  - `routerConfig: appRouter` (GoRouter)
  - `theme: TAppTheme.lightTheme` / `darkTheme: TAppTheme.darkTheme`
  - `themeMode` from Riverpod provider
  - `builder` wraps child in `Overlay` with `ConnectivityToast` at top

### `lib/firebase_options.dart`

- Generated by FlutterFire CLI
- `DefaultFirebaseOptions.currentPlatform` selects per platform (web, android, ios, macos, windows)
- All keys read from `Environment` class (dotenv — never hardcoded)

---

## 3. State Management (Riverpod)

All providers are in `lib/store/`. The app uses **Riverpod 2.6** with manual `StateNotifier` pattern (no code-gen).

### Provider Registry

| Provider | Type | File | Purpose |
|----------|------|------|---------|
| `authRepositoryProvider` | `Provider<AuthRepository>` | `auth_provider.dart` | Singleton auth repo |
| `authStateProvider` | `StreamProvider<User?>` | `auth_provider.dart` | Firebase auth state stream |
| `hasOAuthSessionProvider` | `Provider<bool>` | `auth_provider.dart` | Whether OAuth session exists |
| `currentUserProvider` | `StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserModel?>>` | `auth_provider.dart` | Current user profile |
| `biometricEnabledProvider` | `StateProvider<bool>` | `auth_provider.dart` | Biometric preference |
| `meetingRepositoryProvider` | `Provider<MeetingRepository>` | `meeting_provider.dart` | Singleton meeting repo |
| `meetingsProvider` | `FutureProvider.family<List<MeetingModel>, String?>` | `meeting_provider.dart` | Meetings list by status filter |
| `meetingByIdProvider` | `FutureProvider.family<MeetingModel, String>` | `meeting_provider.dart` | Single meeting lookup |
| `meetingParticipantsProvider` | `FutureProvider.family<List<Participant>, String>` | `meeting_provider.dart` | Participants for a meeting |
| `activeMeetingProvider` | `StateNotifierProvider<ActiveMeetingNotifier, MeetingRoomState>` | `meeting_provider.dart` | Active video call state |
| `chatRepositoryProvider` | `Provider<ChatRepository>` | `chat_provider.dart` | Singleton chat repo |
| `chatRoomsProvider` | `FutureProvider<List<ChatRoom>>` | `chat_provider.dart` | All chat rooms |
| `chatMessagesProvider` | `StateNotifierProvider.family<ChatMessagesNotifier, ChatMessagesState, String>` | `chat_provider.dart` | Messages per room (cursor pagination + WebSocket) |
| `themeModeProvider` | `StateNotifierProvider<ThemeModeNotifier, ThemeMode>` | `theme_provider.dart` | Light/dark/system toggle |
| `userRepositoryProvider` | `Provider<UserRepository>` | `user_provider.dart` | Singleton user repo |
| `updateProfileProvider` | `Provider<Future<UserModel> Function(...)>` | `user_provider.dart` | Update profile + sync auth state |
| `updateAvatarProvider` | `Provider<Future<UserModel> Function(String)>` | `user_provider.dart` | Update avatar + sync auth state |
| `meetingAIProvider` | `StateNotifierProvider<MeetingAINotifier, MeetingAIState>` | `ai_provider.dart` | All AI data for active meeting |
| `notificationRepositoryProvider` | `Provider<NotificationRepository>` | `notification_provider.dart` | Singleton notification repo |
| `unreadNotificationCountProvider` | `StateProvider<int>` | `notification_provider.dart` | Badge count |
| `notificationsProvider` | `StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationModel>>>` | `notification_provider.dart` | Notifications list + WebSocket |
| `billingRepositoryProvider` | `Provider<BillingRepository>` | `billing_provider.dart` | Singleton billing repo |
| `subscriptionProvider` | `FutureProvider<SubscriptionModel?>` | `billing_provider.dart` | Current subscription |
| `connectivityProvider` | `StateNotifierProvider<ConnectivityNotifier, NetworkState>` | `connectivity_provider.dart` | Network quality monitor |
| `legalRepositoryProvider` | `Provider<LegalRepository>` | `legal_provider.dart` | Singleton legal repo |
| `termsOfServiceProvider` | `FutureProvider<LegalDocument>` | `legal_provider.dart` | ToS document |
| `privacyPolicyProvider` | `FutureProvider<LegalDocument>` | `legal_provider.dart` | Privacy policy document |
| `recordingRepositoryProvider` | `Provider<RecordingRepository>` | `recording_provider.dart` | Singleton recording repo |
| `recordingsProvider` | `FutureProvider<List<RecordingModel>>` | `recording_provider.dart` | All recordings |
| `recordingByIdProvider` | `FutureProvider.family<RecordingModel, String>` | `recording_provider.dart` | Single recording lookup |
| `searchRepositoryProvider` | `Provider<SearchRepository>` | `search_provider.dart` | Singleton search repo |
| `searchQueryProvider` | `StateProvider<String>` | `search_provider.dart` | Current search query |
| `searchResultsProvider` | `FutureProvider<Map<String, dynamic>>` | `search_provider.dart` | Global search (users + meetings) |
| `userSearchProvider` | `FutureProvider.family<List<UserModel>, String>` | `search_provider.dart` | User search |
| `meetingSearchProvider` | `FutureProvider.family<List<MeetingModel>, String>` | `search_provider.dart` | Meeting search |
| `settingsProvider` | `StateNotifierProvider<SettingsNotifier, AppSettings>` | `settings_provider.dart` | App settings (AI, meeting defaults, notifications) |

### Key StateNotifiers

#### `CurrentUserNotifier` (`auth_provider.dart`)
- **State**: `AsyncValue<UserModel?>`
- **Methods**: `signInWithGoogle()`, `signInWithGithub()`, `fetchProfile()`, `signOut()`, `deleteAccount()`, `setUser()`, `clear()`
- Loads cached user on init for fast startup

#### `ActiveMeetingNotifier` (`meeting_provider.dart`)
- **State**: `MeetingRoomState` — holds `meeting`, `liveKitToken`, `participants`, `isMicOn`, `isCameraOn`, `isScreenSharing`, `isHandRaised`, `isRecording`, `elapsed`
- **Methods**: `joinMeeting(id, password?)`, `joinByCode(code)`, `refreshParticipants()`, `toggleMic()`, `toggleCamera()`, `toggleScreenShare()`, `toggleHandRaise()`, `toggleRecording()`, `leaveMeeting()`, `endMeeting()`
- Starts 1-second elapsed timer on join

#### `MeetingAINotifier` (`ai_provider.dart`)
- **State**: `MeetingAIState` — holds transcription segments, copilot suggestions, emotion signals, coaching hints, action items, meeting summary, voice command results, workflow status, feature toggles
- **Methods**: `startListening(meetingId)`, `stopListening()`, `toggleCopilot()`, `toggleTranscription()`, `toggleCoaching()`, `toggleVoiceAssistant()`, `sendVoiceCommand()`, `confirmVoiceCommand()`, `executeTool()`, `requestSummary()`, `dismissSuggestion()`
- Subscribes to 8+ Socket.IO events on start

#### `ChatMessagesNotifier` (`chat_provider.dart`)
- **State**: `ChatMessagesState` — messages list, loading flag, cursor pagination, hasMore
- **Methods**: `loadMore()`, `sendMessage()`, `deleteMessage()`
- Listens to WebSocket `chat:message:{roomId}` for real-time messages

#### `ConnectivityNotifier` (`connectivity_provider.dart`)
- **State**: `NetworkState` — `quality` (offline/slow/good), `isConnected`
- Monitors via `connectivity_plus`, does 30-second periodic latency checks to `dns.google:53`

#### `SettingsNotifier` (`settings_provider.dart`)
- **State**: `AppSettings` — aiCopilotEnabled, aiTranscriptionEnabled, aiCoachingEnabled, aiVoiceAssistantEnabled, notificationsEnabled, cameraOnByDefault, micOnByDefault, autoRecordEnabled
- All settings persisted to `LocalStorageService` on change

---

## 4. Routing / Navigation (GoRouter)

**File**: `lib/router/app_router.dart`

### Auth Guard

Global redirect logic:
- `/splash` → always allowed
- Public routes: `/onboarding`, `/login`, `/terms`, `/privacy`
- First launch + not logged in → `/login` (if onboarding already seen)
- Not logged in + protected route → `/login`
- Logged in + public route → `/home`

### Deep Link Schemes

```
speakup://meeting/:id            → MeetingRoomScreen
speakup://meet/:code             → JoinMeetingScreen (spk-xxxx-xxxx)
speakup://chat/:id               → ChatRoomScreen
https://speakup.app/join/:code   → Universal link to join meeting
https://speakup.app/meeting/:id  → Universal link to meeting room
```

### Route Table

| Path | Name | Screen | Params | Notes |
|------|------|--------|--------|-------|
| `/splash` | `splash` | `SplashScreen` | — | Initial route |
| `/onboarding` | `onboarding` | `OnboardingScreen` | — | First-launch only |
| `/login` | `login` | `LoginScreen` | — | OAuth only |
| **Shell Routes (Bottom Nav)** | | | | |
| `/home` | `home` | `HomeScreen` | — | Tab 0 |
| `/meetings` | `meetings` | `MeetingsListScreen` | — | Tab 1 |
| `/chat` | `chat-list` | `ChatListScreen` | — | Tab 2 |
| `/settings` | `settings` | `SettingsScreen` | — | Tab 3 |
| **Standalone Routes** | | | | |
| `/meeting/:id` | `meeting-room` | `MeetingRoomScreen` | `meetingId` | Deep-linkable |
| `/join` | `join-meeting` | `JoinMeetingScreen` | — | |
| `/join/:code` | `join-by-code` | `JoinMeetingScreen` | `initialCode` | Deep-linkable |
| `/chat/:id` | `chat-room` | `ChatRoomScreen` | `chatId`, `?name` | Deep-linkable |
| `/recordings` | `recordings` | `RecordingsScreen` | — | |
| `/meeting/:id/participants` | `participants` | `ParticipantsScreen` | `meetingId` | |
| `/terms` | `terms-of-service` | `TermsOfServiceScreen` | — | Public |
| `/privacy` | `privacy-policy` | `PrivacyPolicyScreen` | — | Public |
| `/create-meeting` | `create-meeting` | `CreateMeetingScreen` | — | |
| `/search` | `search` | `SearchScreen` | — | |
| `/notifications` | `notifications` | `NotificationsScreen` | — | |
| `/analytics` | `analytics` | `AnalyticsDashboardScreen` | — | |
| `/billing` | `billing` | `BillingScreen` | — | |
| `/ai-assistant` | `ai-assistant` | `AIAssistantScreen` | — | |
| `/ai-insights` | `ai-insights` | `AIInsightsScreen` | — | Parent route |
| `/ai-insights/coach` | `ai-coach` | `AICoachScreen` | — | Nested |
| `/ai-insights/action-items` | `ai-action-items` | `AIActionItemsScreen` | — | Nested |
| `/ai-insights/meeting-prep` | `ai-meeting-prep` | `AIMeetingPrepScreen` | — | Nested |
| `/ai-insights/relationships` | `ai-relationships` | `AIRelationshipsScreen` | — | Nested |
| `/ai-insights/predictions` | `ai-predictions` | `AIPredictionsScreen` | — | Nested |
| `/ai-insights/summaries` | `ai-summaries` | `AISummariesScreen` | — | Nested |
| `/ai-insights/documents` | `ai-documents` | `AIDocumentsScreen` | — | Nested |
| `/ai-insights/memory` | `ai-memory` | `AIMemoryScreen` | — | Nested |
| `/ai-insights/knowledge-gaps` | `ai-knowledge-gaps` | `AIKnowledgeGapsScreen` | — | Nested |
| `/ai-insights/workflows` | `ai-workflows` | `AIWorkflowsScreen` | — | Nested |
| `/ai-insights/smart-scheduling` | `ai-smart-scheduling` | `AISmartSchedulingScreen` | — | Nested |
| `/ai-insights/meeting-cost` | `ai-meeting-cost` | `AIMeetingCostScreen` | — | Nested |
| `/meeting-detail/:id` | `meeting-detail` | `MeetingDetailScreen` | `meetingId` | Parent |
| `/meeting-detail/:id/replay` | `meeting-replay` | `AIMeetingReplayScreen` | `meetingId` | Nested |
| `/meeting-detail/:id/transcription` | `meeting-transcription` | `TranscriptionViewerScreen` | `meetingId` | Nested |
| `/meeting-detail/:id/emotion` | `meeting-emotion` | `EmotionAnalyticsScreen` | — | Nested |
| `/meeting-detail/:id/sentiment` | `meeting-sentiment` | `AISentimentScreen` | — | Nested |
| `/meeting-detail/:id/speaking-time` | `meeting-speaking-time` | `AISpeakingTimeScreen` | — | Nested |
| `/meeting-detail/:id/materials` | `meeting-materials` | `MeetingMaterialsScreen` | — | Nested |
| `/meeting-detail/:id/feedback` | `meeting-feedback` | `MeetingFeedbackScreen` | — | Nested |
| `/meeting-detail/:id/call-quality` | `meeting-call-quality` | `CallQualityScreen` | — | Nested |
| `/meeting-detail/:id/topic-tracker` | `meeting-topic-tracker` | `AITopicTrackerScreen` | — | Nested |
| `/meeting-history` | `meeting-history` | `MeetingHistoryScreen` | — | |
| `/people` | `people` | `PeopleDirectoryScreen` | — | |
| `/integrations` | `integrations` | `IntegrationsHubScreen` | — | |
| `/ai-settings` | `ai-settings` | `AISettingsScreen` | — | |
| `/meeting-templates` | `meeting-templates` | `MeetingTemplatesScreen` | — | |
| `/quick-notes` | `quick-notes` | `QuickNotesScreen` | — | |
| `/export-reports` | `export-reports` | `ExportReportsScreen` | — | |
| `/focus-mode` | `focus-mode` | `AIFocusModeScreen` | — | |
| `/meeting-invite` | `meeting-invite` | `MeetingInviteScreen` | — | |

**404 Page**: Custom error builder with icon, message, URI display, "Go Home" button.

---

## 5. Screens & Pages

### Core Screens

| Screen | File | Type | Key Features |
|--------|------|------|-------------|
| `SplashScreen` | `app/screens/splash/splash_screen.dart` | `StatefulWidget` + `TickerProviderStateMixin` | Multi-phase animation: logo/tagline → emblem/pulse rings → shimmer loading → navigate to onboarding/login/home |
| `OnboardingScreen` | `app/screens/onboarding/onboarding_screen.dart` | — | Multi-step with custom visual widgets (ambient bg, video call visual, team chat visual, secure visual) |
| `LoginScreen` | `app/features/auth/presentation/login_screen.dart` | `ConsumerStatefulWidget` | Responsive (mobile: hero image + bottom sheet, desktop: side-by-side). Google + GitHub OAuth buttons. Uses `LoginUseCase`. |
| `HomeScreen` | `app/screens/home_screen.dart` | `ConsumerStatefulWidget` | Collapsing SliverAppBar, pull-to-refresh, quick actions grid, AI suggestions, ongoing/upcoming meeting lists, notification badge |
| `BottomNavigation` | `app/screens/bottom_navigation.dart` | `StatelessWidget` | **Desktop**: `GlassSideBar` (72px rail, liquid glass). **Mobile**: Liquid Glass Island bottom bar with dissolving satellite animation for Settings tab |
| `MeetingsListScreen` | `app/features/meeting/presentation/meetings_list_screen.dart` | — | Filterable meeting list by status |
| `MeetingRoomScreen` | `app/features/meeting/presentation/meeting_room_screen.dart` | `ConsumerStatefulWidget` + `TickerProviderStateMixin` | Full-screen video call: `RoomVideoGrid`, `RoomTopBar`, `RoomControlsBar`, `RoomCoachingBanner`, `RoomTranscriptionOverlay`, `RoomCopilotPanel`, `RoomVoiceAssistantSheet`, `RoomMoreOptionsOverlay`. Immersive system UI mode. |
| `CreateMeetingScreen` | `app/features/meeting/presentation/create_meeting_screen.dart` | — | Form with title, description, type selector, scheduling, password, settings toggles, invite emails, file attachments |
| `JoinMeetingScreen` | `app/features/meeting/presentation/join_meeting_screen.dart` | — | Meeting code input with `extractMeetingCode()` parser (handles URLs, deep links, plain codes) |
| `MeetingDetailScreen` | `app/features/meeting/presentation/meeting_detail_screen.dart` | — | Meeting info, participants, materials, analytics links |
| `ChatListScreen` | `app/features/chat/presentation/chat_list_screen.dart` | — | List of chat rooms with last message preview, unread count |
| `ChatRoomScreen` | `app/features/chat/presentation/chat_room_screen.dart` | — | Real-time messaging with cursor pagination, message types (text/image/file/system) |
| `SettingsScreen` | `app/features/settings/presentation/settings_screen.dart` | — | Profile editing, theme toggle, AI feature toggles, meeting defaults, notifications, legal links, logout, delete account |
| `AnalyticsDashboardScreen` | `app/features/analytics/presentation/analytics_dashboard_screen.dart` | — | Analytics charts (uses `fl_chart`) |
| `BillingScreen` | `app/features/billing/presentation/billing_screen.dart` | — | Subscription management, Stripe checkout/portal links |
| `NotificationsScreen` | `app/features/notification/presentation/notifications_screen.dart` | — | Notification list, mark read, delete |
| `SearchScreen` | `app/features/search/presentation/search_screen.dart` | — | Global search across users and meetings |
| `RecordingsScreen` | `app/features/recordings/presentation/recordings_screen.dart` | — | Recording list with download, delete |
| `ParticipantsScreen` | `app/features/participant/presentation/participants_screen.dart` | — | Participant list for a meeting |

### AI Feature Screens (32 screens)

All in `app/features/ai/presentation/`:

| Screen | Purpose |
|--------|---------|
| `AIAssistantScreen` | AI assistant chat interface |
| `AIInsightsScreen` | Hub for all AI insights (parent for nested routes) |
| `AICoachScreen` | Real-time speaking coaching reports |
| `AIActionItemsScreen` | Extracted action items from meetings |
| `AIMeetingPrepScreen` | Pre-meeting preparation suggestions |
| `AIRelationshipsScreen` | Participant relationship mapping |
| `AIPredictionsScreen` | Meeting outcome predictions |
| `AISummariesScreen` | AI-generated meeting summaries |
| `AIDocumentsScreen` | Auto-generated meeting documents |
| `AIMemoryScreen` | AI memory / context query |
| `AIMeetingReplayScreen` | Meeting replay with transcription timeline |
| `AIWorkflowsScreen` | Automated post/pre-meeting workflows |
| `AISmartSchedulingScreen` | AI-optimal scheduling suggestions |
| `AIMeetingCostScreen` | Meeting cost calculator |
| `AIKnowledgeGapsScreen` | Knowledge gap detection |
| `AISettingsScreen` | AI feature configuration |
| `AIFocusModeScreen` | Distraction-free meeting mode |
| `AISentimentScreen` | Meeting sentiment analysis |
| `AISpeakingTimeScreen` | Speaking time distribution |
| `AITopicTrackerScreen` | Topic tracking timeline |
| `TranscriptionViewerScreen` | Full transcription viewer |
| `EmotionAnalyticsScreen` | Emotion analytics visualization |
| `CallQualityScreen` | Call quality metrics |
| `MeetingFeedbackScreen` | Post-meeting feedback form |
| `MeetingMaterialsScreen` | Shared meeting materials |
| `MeetingTemplatesScreen` | Reusable meeting templates |
| `QuickNotesScreen` | Quick note-taking |
| `ExportReportsScreen` | Export reports (PDF, etc.) |
| `PeopleDirectoryScreen` | People directory |
| `IntegrationsHubScreen` | Third-party integrations |
| `MeetingInviteScreen` | Meeting invitation management |
| `VoiceCommandScreen` | Voice command interface |

---

## 6. Components / Widgets

### UI Components (`app/components/ui/`)

| Component | Class | Variants/Props |
|-----------|-------|---------------|
| **Button** | `SButton` | Variants: `primary`, `secondary`, `outline`, `ghost`, `danger`. Sizes: `sm`, `md`, `lg`. Props: `isLoading`, `isFullWidth`, `prefixIcon`, `suffixIcon`. Cupertino press-scale + haptic. |
| **Icon Button** | `SIconButton` | Circular, configurable size/colors, tooltip support |
| **Card** | `SCard` | Props: `onTap`, `onLongPress`, `hasBorder`, `hasShadow`. Cupertino press-scale + haptic. |
| **Meeting Card** | `SMeetingCard` | Live badge, participant count, time display |
| **Input** | `SInput` | Full TextFormField: label, hint, error, prefix icon, suffix, obscure, validator, focus colors |
| **Search Bar** | `SSearchBar` | CupertinoSearchTextField wrapper |
| **Bottom Sheet** | `SBottomSheet.show()` | iOS blur backdrop, capsule drag handle, optional title |
| **Modal** | `SModal.show()` | CupertinoAlertDialog with backdrop blur, confirm/cancel actions, danger mode |
| **Toast** | `SToast.show()` / `SToast.showCustom()` | Types: success, error, warning, info. Uses fluttertoast + FToast overlay |
| **Skeleton** | `SSkeleton` | Shimmer-based loading placeholder. Variants: `SMeetingCardSkeleton`, `SAvatarSkeleton` |
| **Activity Indicator** | `SActivityIndicator` | CupertinoActivityIndicator (adaptive) or Material spinner |
| **Loading Overlay** | `SLoadingOverlay` | Full-screen centered spinner with optional message |
| **Connectivity Toast** | `ConnectivityToast` | Auto-fires toasts on network state changes (offline/slow/online) |
| **Dense Widgets** | `SectionHeader`, `DenseTile`, `CompactMeetingTile`, `CompactEmptyState` | Compact list/section components |

### Widgets (`app/components/widgets/`)

| Widget | Purpose |
|--------|---------|
| `app_bar.dart` | Custom AppBar |
| `date_time_picker.dart` | Date/time picker |
| `fab.dart` | Floating action button |
| `input_fields.dart` | Specialized input field variants |
| `spinners.dart` | Loading spinner variants |

### Shapes (`app/components/shapes/`)

| File | Purpose |
|------|---------|
| `shapes.dart` | Barrel export (`library; export ...`) |
| `curved_clippers.dart` | Custom `ClipPath` curve shapes |
| `bg_patterns.dart` | Background decorative patterns |
| `decorative_painters.dart` | `CustomPainter` decorations |

### Meeting Room Widgets (`app/features/meeting/presentation/widgets/`)

| Widget | Purpose |
|--------|---------|
| `room_video_grid.dart` | Participant video tile grid (responsive columns) |
| `room_top_bar.dart` | Meeting info bar (timer, participant count, recording indicator) |
| `room_controls_bar.dart` | Bottom control bar (mic, camera, screen share, hand raise, end call) |
| `room_coaching_banner.dart` | AI coaching hint banner overlay |
| `room_transcription_overlay.dart` | Real-time transcription caption overlay |
| `room_copilot_panel.dart` | AI copilot suggestions slide panel |
| `room_voice_assistant_sheet.dart` | Voice command interface sheet |
| `room_more_options_overlay.dart` | More options menu overlay |
| `meeting_chat_sheet.dart` | In-meeting chat bottom sheet |
| `meeting_participants_sheet.dart` | Participants list bottom sheet |
| `meeting_info_sheet.dart` | Meeting info bottom sheet |
| `create_meeting_widgets.dart` | Create meeting form widgets |
| `join_meeting_widgets.dart` | Join meeting form widgets |
| `meeting_detail_widgets.dart` | Meeting detail page widgets |
| `meetings_list_widgets.dart` | Meeting list item widgets |

### Onboarding Widgets (`app/screens/onboarding/widgets/`)

| Widget | Purpose |
|--------|---------|
| `ambient_background.dart` | Ambient animated background |
| `video_call_visual.dart` | Video call illustration |
| `team_chat_visual.dart` | Team chat illustration |
| `secure_visual.dart` | Security illustration |
| `shared_widgets.dart` | Shared onboarding utilities |

---

## 7. Services / API Layer

### API Client (`core/network/api_client.dart`)

**Singleton**: `ApiClient.instance` wraps Dio.

**Base Configuration**:
- Base URL: `AppBaseUrl.value` (resolved per platform/mode)
- Timeouts: connect 15s, receive 15s, send 15s
- Headers: `Content-Type: application/json`, `Accept: application/json`

**Interceptors** (in order):
1. `_ConnectivityInterceptor` — rejects if offline
2. `_AuthInterceptor` — attaches Firebase ID token as `Bearer` header; on 401 force-refreshes token and retries once; on 404+E3001 or 403+E1005/E1006 triggers `AccountGuard`
3. `_RetryInterceptor` — retry logic for transient failures
4. `LogInterceptor` — debug mode only

**HTTP Methods**: `get`, `post`, `put`, `patch`, `delete`, `upload` (multipart FormData)

### Base URL Resolution (`core/config/base_url.dart`)

**Priority**:
1. `API_URL` from `.env` (always wins)
2. Release mode → `https://api.speakup.app/api/v1`
3. Android emulator → `http://10.0.2.2:3000/api/v1`
4. iOS/macOS/desktop → `http://localhost:3000/api/v1`
5. Physical device → `http://{DEV_HOST}:3000/api/v1`

**WebSocket URL**: Same logic but `ws://` / `wss://` without `/api/v1`

### WebSocket Service (`core/services/websocket.dart`)

**Singleton**: `WebSocketService()` wraps `socket_io_client`.

- Connects with Firebase auth token
- Auto-reconnection: 10 attempts, 1-10s delay
- **Methods**: `connect()`, `disconnect()`, `emit(event, data)`, `on(event, handler)`, `off(event)`, `stream(event)` (returns `Stream<dynamic>`), `joinMeetingRoom(meetingId)`, `leaveMeetingRoom(meetingId)`, `joinChatRoom(chatRoomId)`, `leaveChatRoom(chatRoomId)`

### Storage Services (`core/services/storage_service.dart`)

**SecureStorageService** (flutter_secure_storage):
- `saveUserId(id)`, `getUserId()`, `clearAll()`

**LocalStorageService** (GetStorage):
- `hasSeenOnboarding` / `setOnboardingComplete()`
- `themeMode` / `setThemeMode(mode)`
- `biometricEnabled` / `setBiometricEnabled(bool)`
- `aiCopilotEnabled` / `setAiCopilotEnabled(bool)`
- `aiTranscriptionEnabled` / `setAiTranscriptionEnabled(bool)`
- `aiCoachingEnabled` / `setAiCoachingEnabled(bool)`
- `aiVoiceAssistantEnabled` / `setAiVoiceAssistantEnabled(bool)`
- `notificationsEnabled` / `setNotificationsEnabled(bool)`
- `cameraOnByDefault` / `setCameraOnByDefault(bool)`
- `micOnByDefault` / `setMicOnByDefault(bool)`
- `autoRecordEnabled` / `setAutoRecordEnabled(bool)`

### Hive Cache (`core/db/hive.dart`)

**Boxes**: `meeting_cache`, `user_cache`, `notification_cache`, `settings`, `cache_ttl`

- `putWithTTL(box, key, value, ttlMinutes: 30)` — store with expiration
- `getIfFresh(box, key)` — return if not expired
- `pruneExpired()` — clean all expired entries
- `clearAll()` — clear user data on sign out

---

## 8. Models / Data Classes

All in `lib/app/domain/models/`. Manual `fromJson`/`toJson` (no freezed code-gen for these).

### `UserModel` (`user_model.dart`)

| Field | Type | Notes |
|-------|------|-------|
| `id` | `String` | Backend UUID |
| `firebaseUid` | `String` | Firebase UID |
| `email` | `String` | |
| `fullName` | `String` | |
| `avatar` | `String?` | URL |
| `bio` | `String?` | |
| `isOnline` | `bool` | |
| `lastSeenAt` | `DateTime?` | |
| `role` | `UserRole` | `user`, `admin`, `moderator` |
| `createdAt` | `DateTime` | |
| `updatedAt` | `DateTime` | |

Also: `DeviceModel` with `id`, `fcmToken`, `platform`, `createdAt`.

### `MeetingModel` (`meeting_model.dart`)

| Field | Type | Notes |
|-------|------|-------|
| `id` | `String` | |
| `code` | `String` | SpeakUp code (spk-xxxx-xxxx) |
| `title` | `String` | |
| `description` | `String?` | |
| `hostId` | `String` | |
| `hostName` | `String?` | Joined from `host` relation |
| `hostAvatar` | `String?` | |
| `type` | `MeetingType` | `instant`, `scheduled`, `recurring` |
| `status` | `MeetingStatus` | `scheduled`, `live`, `ended`, `cancelled` |
| `scheduledAt` | `DateTime?` | |
| `startedAt` | `DateTime?` | |
| `endedAt` | `DateTime?` | |
| `participantCount` | `int` | |
| `maxParticipants` | `int` | Default 100 |
| `isRecording` | `bool` | |
| `password` | `String?` | |
| `settings` | `Map<String, dynamic>?` | |
| `createdAt` | `DateTime` | |

Computed: `isLive`, `hasPassword`

### `ChatMessage` / `ChatRoom` / `ChatMember` (`chat_model.dart`)

**ChatMessage**: `id`, `chatRoomId`, `senderId`, `senderName?`, `senderAvatar?`, `content`, `type` (text/image/file/system), `replyToId?`, `isEdited`, `createdAt`, `updatedAt`

**ChatRoom**: `id`, `name?`, `isGroup`, `meetingId?`, `members`, `lastMessage?`, `unreadCount`, `createdAt`

**ChatMember**: `id`, `userId`, `fullName?`, `avatar?`, `joinedAt`

### `Participant` / `RecordingModel` (`participant_model.dart`)

**Participant**: `id`, `meetingId`, `userId`, `name`, `avatar?`, `isMuted`, `isCameraOff`, `isScreenSharing`, `isHandRaised`, `role` (host/coHost/attendee), `joinedAt`, `leftAt?`

**RecordingModel**: `id`, `meetingId`, `userId`, `meetingTitle?`, `url`, `duration`, `sizeBytes`, `status` (processing/ready/failed), `createdAt`
- Computed: `formattedSize`, `formattedDuration`

### `SubscriptionModel` (`subscription_model.dart`)

Fields: `id`, `userId`, `plan` (free/pro/enterprise), `status` (active/cancelled/pastDue/trialing), `stripeCustomerId?`, `stripeSubId?`, `currentPeriodStart?`, `currentPeriodEnd?`, `canceledAt?`, `createdAt`
- Computed: `isActive`, `isPro`, `isEnterprise`, `isPaid`

### `NotificationModel` (`notification_model.dart`)

Fields: `id`, `userId`, `title`, `body`, `type` (meetingInvite/meetingReminder/meetingStarted/chatMessage/recordingReady/system), `data?`, `isRead`, `createdAt`
- `copyWith(isRead:)` for optimistic updates

### `LegalDocument` / `LegalSection` / `LegalSubsection` (`legal_model.dart`)

**LegalDocument**: `title`, `effectiveDate`, `lastUpdated`, `version`, `sections`
**LegalSection**: `id`, `heading`, `body`, `items`, `footer?`, `subsections`
**LegalSubsection**: `heading`, `items`

### `MeetingMaterialModel` (`material_model.dart`)

Fields: `id`, `meetingId`, `userId`, `name`, `url`, `type` (MIME), `sizeBytes`, `uploaderName?`, `uploaderAvatar?`, `createdAt`
- Computed: `isImage`, `isVideo`, `isAudio`, `isDocument`, `extension`, `readableSize`

### AI Models (`ai_models.dart`)

| Model | Key Fields |
|-------|-----------|
| `TranscriptionSegment` | `text`, `speakerId?`, `speakerName?`, `confidence`, `timestamp`, `language?`, `isFinal` |
| `CopilotSuggestion` | `id`, `type` (talkingPoint/question/insight/warning/followUp), `text`, `context?`, `confidence`, `isDismissed` |
| `EmotionSignal` | `participantId`, `emotion`, `confidence`, `engagementScore`, `emoji` (computed getter) |
| `CoachingHint` | `type` (pace/clarity/engagement/volume/filler/pause), `message`, `severity` |
| `ActionItem` | `id`, `text`, `assignee?`, `deadline?`, `priority`, `isCompleted` |
| `MeetingSummary` | `meetingId`, `summary`, `keyTopics`, `actionItems`, `decisions`, `durationMinutes`, `sentimentScore` |
| `VoiceCommandResult` | `command?`, `detected`, `needsConfirmation`, `parsedAction?`, `parsedParameters?`, `result?`, `status` |
| `WorkflowStatus` | `workflowId`, `status`, `progress`, `currentStep?`, `steps` |
| `WorkflowStepStatus` | `name`, `status`, `result?` |

---

## 9. Theme / Design System

### Theme Configuration (`lib/theme/theme.dart`)

**Class**: `TAppTheme` — defines `lightTheme` and `darkTheme` (`ThemeData`).

Both themes use:
- **Material 3** (`useMaterial3: true`)
- **Font**: Poppins
- **Primary**: `SColors.primary` (`#1A6BF5`)
- Custom sub-themes for: AppBar, BottomSheet, Checkbox, Chip, ElevatedButton, OutlinedButton, TextField, Text, BottomNavBar, FAB, Dialog, SnackBar, ProgressIndicator, Switch

### Color Palette (`lib/core/constants/colors.dart`)

**Class**: `SColors`

| Category | Key Colors |
|----------|-----------|
| Primary Blue | `primary` (#1A6BF5), `primaryLight`, `primaryDark`, `primarySurface`, `primaryMuted` |
| Blue Variants | `blue50` → `blue900` (10-step scale) |
| Dark Mode | `darkBg` (#0A0A0F), `darkSurface` (#12121A), `darkCard` (#1A1A25), `darkElevated`, `darkBorder`, `darkHover`, `darkMuted` |
| Light Mode | `lightBg` (#F8F9FC), `lightSurface` (#FFF), `lightCard`, `lightElevated`, `lightBorder`, `lightHover`, `lightMuted` |
| Text | `textDark`/`Secondary`/`Tertiary`, `textLight`/`Secondary`/`Tertiary` |
| Semantic | `success` (#10B981), `warning` (#F59E0B), `error` (#EF4444), `info` (#3B82F6) — each with Light/Dark variants |
| Meeting | `micOn`/`Off`, `cameraOn`/`Off`, `screenShare`, `handRaised`, `callEnd`/`Hover`, `participantTile`/`Light` |
| Chat | `chatBubbleSent`, `chatBubbleReceived`/`Light` |
| Gradients | `primaryGradient`, `darkGradient`, `accentGradient` |

### Spacing & Sizes (`lib/core/constants/sizes.dart`)

**Class**: `SSizes`

| Category | Values |
|----------|--------|
| Spacing | `xs`=4, `sm`=8, `md`=16, `lg`=24, `xl`=32, `xxl`=48, `xxxl`=64 |
| Padding | `pagePadding`=20, `cardPadding`=16, `inputPadding`=14, `chipPadding`=12, `sectionSpacing`=28 |
| Icons | `iconXs`=14, `iconSm`=18, `iconMd`=24, `iconLg`=32, `iconXl`=48 |
| Radius | `radiusXs`=4, `radiusSm`=8, `radiusMd`=12, `radiusLg`=16, `radiusXl`=24, `radiusFull`=999 |
| Buttons | `buttonHeightSm`=36, `buttonHeightMd`=48, `buttonHeightLg`=56 |
| Avatar | `avatarSm`=32, `avatarMd`=40, `avatarLg`=56, `avatarXl`=80, `avatarXxl`=120 |
| Animation | `animFast`=150ms, `animNormal`=250ms, `animSlow`=400ms |

### Dark/Light Mode Toggle

- Managed by `ThemeModeNotifier` in `theme_provider.dart`
- Persisted via `LocalStorageService.setThemeMode()` (string: 'light'/'dark'/'system')
- Read in `SpeakUpApp` via `ref.watch(themeModeProvider)`
- Toggle: `ref.read(themeModeProvider.notifier).toggleDarkMode()` or `setThemeMode(ThemeMode.xxx)`

### Responsive Design (`lib/core/constants/responsive.dart`)

**Class**: `SResponsive`

| Breakpoint | Width |
|-----------|-------|
| Mobile | < 768 |
| Tablet | 768–1024 |
| Desktop | ≥ 1024 |
| Widescreen | ≥ 1440 |

- `meetingGridColumns()` — 1-4 columns based on screen + participant count
- `value<T>()` — returns mobile/tablet/desktop value
- `pagePadding()` — 20/32/48 per breakpoint
- `maxContentWidth()` — 960/1200/∞
- `ResponsiveLayout` widget — `LayoutBuilder` with mobile/tablet/desktop children

### Liquid Glass UI

- `liquid_glass_widgets` package (^0.7.3)
- Initialized in `main.dart` with `LiquidGlassWidgets.initialize()`
- App wrapped in `LiquidGlassWidgets.wrap()`
- Used in: `BottomNavigation` desktop sidebar (`GlassSideBar`, `GlassContainer`)

---

## 10. Real-time Features

### WebSocket Events (Socket.IO)

**Connection**: `WebSocketService.connect()` — authenticates with Firebase ID token.

| Event | Direction | Purpose |
|-------|----------|---------|
| `meeting:join` | emit | Join a meeting room |
| `meeting:leave` | emit | Leave a meeting room |
| `chat:join` | emit | Join a chat room |
| `chat:leave` | emit | Leave a chat room |
| `chat:message:{roomId}` | listen | Real-time chat messages |
| `notification` | listen | Push notification delivery |
| `connection_status` | internal | Connection state (true/false) |
| `socket_error` | internal | Socket errors |

### AI WebSocket Events (via `AISocketEvents`)

| Event | Direction | Data |
|-------|----------|------|
| `ai:transcription` | listen | `TranscriptionSegment` |
| `ai:copilot_suggestions` | listen | `CopilotSuggestion` or array |
| `ai:emotion_signals` | listen | `EmotionSignal` |
| `ai:coaching_hints` | listen | `CoachingHint` |
| `ai:meeting_summary` | listen | `MeetingSummary` |
| `ai:action_items` | listen | `ActionItem[]` |
| `ai:live_insights` | listen | Live insight data |
| `ai:voice_command` | emit | `{text, meetingId}` |
| `ai:voice_command_result` | listen | `VoiceCommandResult` |
| `ai:voice_command_confirm` | emit | `{meetingId, parsedCommand}` |
| `ai:tool_execute` | emit | `{toolName, parameters}` |
| `ai:tool_result` | listen | Tool execution result |
| `ai:workflow_status` | listen | `WorkflowStatus` |
| `ai:toggle_copilot` | emit | `{enabled}` |
| `ai:toggle_transcription` | emit | `{enabled}` |
| `ai:toggle_coaching` | emit | `{enabled}` |
| `ai:request_summary` | emit | `{meetingId}` |

### LiveKit (WebRTC Video)

- **Package**: `livekit_client ^2.3.3`
- Token obtained via `MeetingRepository.getLiveKitToken(meetingId)` → `GET /meetings/:id/token`
- Token stored in `MeetingRoomState.liveKitToken`
- Used by `MeetingRoomScreen` for video grid rendering

---

## 11. Authentication

### Flow

1. **OAuth Sign-in**: User taps Google or GitHub button
2. **Firebase Auth**: `GoogleSignInService.signIn()` / `GithubSignInService.signIn()` returns `UserCredential`
3. **Backend Sync**: `POST /auth/signin` with `{idToken}` → backend creates/returns user
4. **Local Cache**: User cached in Hive (`current_user`) + secure storage (`user_id`)
5. **Subsequent requests**: `_AuthInterceptor` auto-attaches fresh Firebase ID token

### Google Sign-In (`core/auth/google_signin.dart`)
- Uses `google_sign_in ^7.2.0` (new API with `GoogleSignIn.instance`)
- `init()` → `authenticate(scopeHint: ['email', 'profile'])`
- Returns `GoogleAuthProvider.credential(idToken:)` → `signInWithCredential()`

### GitHub Sign-In (`core/auth/github_signin.dart`)
- Uses Firebase Auth's built-in `GithubAuthProvider`
- Scopes: `read:user`, `user:email`
- `signInWithProvider(provider)` — opens system OAuth flow

### Biometric Auth (`core/auth/local_auth.dart`)
- Uses `local_auth ^3.0.1`
- Only available after successful OAuth session (`hasOAuthSessionProvider`)
- `enable()` — verifies biometric first, then saves preference
- `authenticate()` — biometric + device PIN fallback

### Token Management
- Firebase automatically manages ID token refreshing
- `_AuthInterceptor` calls `user.getIdToken()` on every request
- On 401: force refresh with `getIdToken(true)` and retry once
- On persistent auth failures: `AccountGuard.trigger()` → sign out + dialog + redirect

### Account Guard (`core/network/account_guard.dart`)
- Detects: 404+E3001 (user not found), 403+E1005/E1006 (suspended/disabled), persistent 401
- Shows CupertinoAlertDialog explaining account issue
- Clears all local state (Firebase, Google, secure storage, Hive)
- Redirects to `/login`

---

## 12. Notifications

### Push Notifications (FCM)
- **Package**: `firebase_messaging ^15.2.0`
- Device registration via `UserRepository.registerDevice(fcmToken:, platform:)`
- Endpoint: `POST /users/devices`

### Local Notifications
- **Package**: `flutter_local_notifications ^17.2.1`
- Used for foreground notification display

### In-App Notifications
- Real-time via WebSocket `notification` event
- `NotificationsNotifier` listens and prepends new notifications
- `unreadNotificationCountProvider` for badge count
- Mark as read: `PUT /notifications/:id/read`
- Mark all as read: `PUT /notifications/read-all`

### Toast Notifications
- `SToast.show()` / `SToast.showCustom()` — non-persistent overlay toasts
- `ConnectivityToast` — auto-fires on network state changes

---

## 13. Platform Configuration

### Firebase

**Project ID**: `flutter-conference-speakup`

| Platform | App ID |
|----------|--------|
| Android | `1:829643820482:android:a61ec6f563c990fdb65a5b` |
| iOS | `1:829643820482:ios:fa67b1d040fc77edb65a5b` |
| macOS | `1:829643820482:ios:fa67b1d040fc77edb65a5b` |
| Web | `1:829643820482:web:9dba618eee6b90d6b65a5b` |
| Windows | `1:829643820482:web:be78b0b1d0d9aff4b65a5b` |

### Sentry

- **Auth Token**: present in `sentry.properties`
- **Organization**: `unxcorp`
- **DSN**: from `SENTRY_DSN` env var (compile-time)
- **Traces Sample Rate**: 0.2 (production only)

### App Launcher Icons

```yaml
flutter_launcher_icons:
  image_path: "assets/logo/logo.png"
  adaptive_icon_background: "#FFFFFF"
  min_sdk_android: 21
  web: theme_color: "#4A6CF7"
```

---

## 14. Assets

### Structure

```
assets/
├── images/
│   ├── camera-woman.jpg          # Auth/onboarding hero
│   ├── github.webp               # GitHub OAuth button icon
│   ├── google.webp               # Google OAuth button icon
│   ├── onboarding1.jpg → onboarding8.jpg  # Onboarding slides (7 images)
│   └── (placeholder images referenced in SImages but may not exist yet)
├── logo/
│   ├── logo.png                  # Brand logo (launcher icon source)
│   └── emblem.png               # Brand emblem (splash screen)
└── others/
    └── Screenshot *.png          # App screenshots (7 files)
```

### Asset Registration (pubspec.yaml)

```yaml
assets:
  - assets/images/
  - assets/logo/
  - .env
```

---

## 15. Testing

### Structure

```
test/
├── widget_test.dart              # Basic widget test
├── helpers/
│   └── test_helpers.dart         # Shared test utilities
└── unit/
    ├── core/
    │   ├── api_exception_test.dart
    │   ├── endpoints_test.dart
    │   └── hive_service_test.dart
    ├── models/
    │   ├── chat_model_test.dart
    │   ├── meeting_model_test.dart
    │   ├── notification_model_test.dart
    │   ├── participant_model_test.dart
    │   ├── subscription_model_test.dart
    │   └── user_model_test.dart
    └── providers/
        ├── chat_provider_test.dart
        ├── connectivity_provider_test.dart
        ├── meeting_provider_test.dart
        └── theme_provider_test.dart

integration_test/
└── app_test.dart                 # Full app integration test
```

### Testing Packages

- `flutter_test` (SDK)
- `integration_test` (SDK)
- `mockito ^5.4.0` — mock generation
- `mocktail ^1.0.4` — lightweight mocks
- `fake_async ^1.3.2` — time control
- `network_image_mock ^2.1.1` — mock NetworkImage

---

## 16. Build & Scripts

### Makefile Targets

| Target | Command | Purpose |
|--------|---------|---------|
| `get` | `flutter pub get` | Get dependencies |
| `upgrade` | `flutter pub upgrade` | Upgrade deps |
| `outdated` | `flutter pub outdated` | Check outdated |
| `env` | copy `.env.example` to `.env` | Setup env |
| `clean` | `flutter clean` | Clean build |
| `reset` | `clean` + `get` | Full reset |
| `nuke` | Nuclear reset — remove all caches, pods, pubspec.lock | Scorched earth |
| `build-runner` / `gen` | `dart run build_runner build --delete-conflicting-outputs` | Code gen |
| `watch` | `dart run build_runner watch` | Watch mode code gen |
| `icons` | `dart run flutter_launcher_icons` | Generate icons |
| `splash` | `dart run flutter_native_splash:create` | Generate splash |
| `run` | `flutter run` | Debug run |
| `run-release` | `flutter run --release` | Release run |
| `run-profile` | `flutter run --profile` | Profile run |
| `run-web` | `flutter run -d chrome` | Web run |
| `run-macos` | `flutter run -d macos` | macOS run |
| `build-apk` | `flutter build apk --release` | Release APK |
| `build-apk-split` | `flutter build apk --release --split-per-abi` | Split APKs |
| `build-appbundle` | `flutter build appbundle --release` | AAB |
| `build-ipa` | `flutter build ipa --release` | iOS IPA |
| `analyze` | `flutter analyze` | Static analysis |
| `format` | `dart format lib/ test/` | Format code |
| `test` | `flutter test` | Run tests |
| `integration-test` | `flutter test integration_test/` | Integration tests |

### Analysis Options

- Includes `package:flutter_lints/flutter.yaml`
- No custom rules enabled (commented out suggestions for `avoid_print`, `prefer_single_quotes`)

---

## 17. API Endpoints Reference

All paths relative to base URL (`/api/v1`). Defined in `lib/core/apis/endpoints.dart`.

### Auth
| Method | Path | Purpose |
|--------|------|---------|
| POST | `/auth/signin` | Sign in with Firebase ID token |
| POST | `/auth/signout` | Sign out |
| GET | `/auth/me` | Get current user profile |
| DELETE | `/auth/account` | Delete account |

### Users
| Method | Path | Purpose |
|--------|------|---------|
| GET | `/users/profile` | Get user profile |
| PUT | `/users/profile` | Update profile (fullName, bio) |
| POST | `/users/avatar` | Upload avatar (multipart) |
| GET | `/users/devices` | List devices |
| POST | `/users/devices` | Register device (FCM token) |
| DELETE | `/users/devices/:deviceId` | Remove device |
| PUT | `/users/online-status` | Update online status |

### Meetings
| Method | Path | Purpose |
|--------|------|---------|
| GET | `/meetings` | List meetings (?status, ?page, ?limit) |
| POST | `/meetings` | Create meeting |
| GET | `/meetings/:id` | Get meeting by ID |
| PUT | `/meetings/:id` | Update meeting |
| DELETE | `/meetings/:id` | Delete meeting |
| GET | `/meetings/join/:code` | Join by SpeakUp code |
| POST | `/meetings/:id/join` | Join meeting (?password) |
| POST | `/meetings/:id/leave` | Leave meeting |
| POST | `/meetings/:id/end` | End meeting |
| POST | `/meetings/:id/lock` | Lock meeting |
| POST | `/meetings/:id/unlock` | Unlock meeting |
| GET | `/meetings/:id/participants` | Get participants |
| POST | `/meetings/:id/kick/:participantId` | Kick participant |
| GET | `/meetings/:id/token` | Get LiveKit token |
| GET | `/meetings/:id/invites` | Get meeting invites |
| POST | `/meetings/invite/:token/respond` | Accept/decline invite |

### Meeting Materials
| Method | Path | Purpose |
|--------|------|---------|
| POST | `/meetings/:meetingId/materials` | Upload material (multipart) |
| GET | `/meetings/:meetingId/materials` | List materials |
| GET | `/meetings/materials/:materialId` | Get material |
| DELETE | `/meetings/materials/:materialId` | Delete material |

### Rooms
| Method | Path | Purpose |
|--------|------|---------|
| GET | `/rooms/active` | List active rooms |
| GET | `/rooms/:id` | Get room state |
| PUT | `/rooms/:id/settings` | Update room settings |
| POST | `/rooms/:id/mute-all` | Mute all participants |

### Chat
| Method | Path | Purpose |
|--------|------|---------|
| GET | `/chat/rooms` | List chat rooms |
| GET | `/chat/meeting/:meetingId` | Get/create meeting chat |
| GET | `/chat/:chatRoomId/messages` | Get messages (?cursor, ?limit) |
| POST | `/chat/:chatRoomId/messages` | Send message |
| DELETE | `/chat/messages/:messageId` | Delete message |

### Notifications
| Method | Path | Purpose |
|--------|------|---------|
| GET | `/notifications` | List notifications (?page, ?limit) |
| GET | `/notifications/unread-count` | Get unread count |
| PUT | `/notifications/read-all` | Mark all as read |
| GET | `/notifications/preferences` | Get preferences |
| PUT | `/notifications/:id/read` | Mark as read |
| DELETE | `/notifications/:id` | Delete notification |

### Recordings
| Method | Path | Purpose |
|--------|------|---------|
| GET | `/recordings` | List recordings |
| GET | `/recordings/:id` | Get recording |
| GET | `/recordings/:id/download` | Get download URL |
| DELETE | `/recordings/:id` | Delete recording |
| POST | `/recordings/meeting/:meetingId/start` | Start recording |
| POST | `/recordings/meeting/:meetingId/stop` | Stop recording |

### Analytics
| Method | Path | Purpose |
|--------|------|---------|
| GET | `/analytics/dashboard` | Dashboard data |
| GET | `/analytics/usage` | Usage stats (?startDate, ?endDate) |
| GET | `/analytics/meeting/:meetingId` | Meeting-specific analytics |

### Billing
| Method | Path | Purpose |
|--------|------|---------|
| GET | `/billing/subscription` | Get subscription |
| POST | `/billing/checkout` | Create Stripe checkout |
| POST | `/billing/portal` | Create Stripe portal |
| POST | `/billing/cancel` | Cancel subscription |

### Search
| Method | Path | Purpose |
|--------|------|---------|
| GET | `/search` | Global search (?q) |
| GET | `/search/users` | Search users (?q) |
| GET | `/search/meetings` | Search meetings (?q) |

### Legal
| Method | Path | Purpose |
|--------|------|---------|
| GET | `/legal/terms` | Terms of Service |
| GET | `/legal/privacy` | Privacy Policy |
| GET | `/legal/all` | All legal documents |

### AI / Intelligence
| Method | Path | Purpose |
|--------|------|---------|
| GET | `/ai/transcript/:meetingId` | Get transcription |
| GET | `/ai/copilot/suggestions` | Get copilot suggestions |
| GET | `/ai/copilot/coaching-report` | Coaching report |
| GET | `/ai/copilot/predict-outcome` | Predict meeting outcome |
| GET | `/ai/memory/summary` | AI meeting summary |
| GET | `/ai/memory/query` | Query AI memory/context |
| GET | `/ai/emotion/meeting/:meetingId` | Meeting emotion data |
| POST | `/ai/assistant/voice-command` | Send voice command |
| POST | `/ai/assistant/voice-command/confirm` | Confirm voice command |
| GET | `/ai/tools/schema` | Get AI tools schema |
| POST | `/ai/tools/execute` | Execute AI tool |
| POST | `/ai/workflow/post-meeting` | Run post-meeting workflow |
| POST | `/ai/workflow/pre-meeting` | Run pre-meeting workflow |
| GET | `/ai/workflow/status/:workflowId` | Get workflow status |

---

## Dependencies Summary

### Production Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | ^3.6.0 | Firebase initialization |
| `firebase_auth` | ^5.2.0 | Firebase Authentication |
| `firebase_messaging` | ^15.2.0 | FCM push notifications |
| `cloud_firestore` | ^5.4.4 | Firestore (if needed) |
| `google_sign_in` | ^7.2.0 | Google OAuth |
| `local_auth` | ^3.0.1 | Biometric authentication |
| `dio` | ^5.9.2 | HTTP client |
| `socket_io_client` | ^3.1.4 | WebSocket real-time |
| `flutter_riverpod` | ^2.6.1 | State management |
| `riverpod_annotation` | ^2.6.1 | Riverpod annotations |
| `go_router` | ^14.8.1 | Declarative routing |
| `livekit_client` | ^2.3.3 | LiveKit SFU (WebRTC video) |
| `flutter_secure_storage` | ^10.0.0 | Secure token/key storage |
| `get_storage` | ^2.1.1 | Local preferences |
| `shared_preferences` | ^2.3.4 | Platform prefs |
| `hive_flutter` | ^1.1.0 | Local cache DB |
| `intl` | ^0.20.2 | Date/number formatting |
| `permission_handler` | ^11.3.1 | Runtime permissions |
| `flutter_local_notifications` | ^17.2.1 | Local notification display |
| `url_launcher` | ^6.3.2 | Open URLs |
| `share_plus` | ^11.0.0 | Share functionality |
| `wakelock_plus` | ^1.2.8 | Keep screen on during meetings |
| `pull_to_refresh` | ^2.0.0 | Pull-to-refresh |
| `image_picker` | ^1.2.1 | Pick images from gallery/camera |
| `file_picker` | ^8.1.6 | Pick files |
| `flutter_dotenv` | ^6.0.0 | Environment variables |
| `cached_network_image` | ^3.4.1 | Cached image loading |
| `shimmer` | ^3.0.0 | Shimmer loading effects |
| `flutter_animate` | ^4.5.2 | Declarative animations |
| `connectivity_plus` | ^6.1.1 | Network connectivity |
| `logger` | ^2.5.0 | Structured logging |
| `liquid_glass_widgets` | ^0.7.3 | Liquid Glass UI |
| `sentry_flutter` | ^9.0.0 | Error monitoring |
| `speech_to_text` | ^7.0.0 | Voice recognition |
| `audio_waveforms` | ^1.2.0 | Audio visualization |
| `fl_chart` | ^0.70.2 | Charts and graphs |
| `freezed_annotation` | ^2.4.4 | Freezed annotations |
| `json_annotation` | ^4.9.0 | JSON serialization annotations |
| `fluttertoast` | ^9.0.0 | Toast notifications |
| `iconsax` | ^0.0.8 | Icon pack |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `build_runner` | ^2.4.14 | Code generation |
| `freezed` | ^2.5.7 | Immutable data classes |
| `json_serializable` | ^6.9.4 | JSON code gen |
| `riverpod_generator` | ^2.6.3 | Riverpod code gen |
| `flutter_launcher_icons` | ^0.14.4 | App icon generation |
| `mockito` | ^5.4.0 | Mocking framework |
| `mocktail` | ^1.0.4 | Lightweight mocks |
| `fake_async` | ^1.3.2 | Async test helpers |
| `network_image_mock` | ^2.1.1 | Mock network images |
| `flutter_lints` | ^6.0.0 | Lint rules |

---

## Architecture Patterns

### Layer Architecture
```
Feature Screen (ConsumerWidget)
    ↓ reads
Provider (StateNotifier / FutureProvider)
    ↓ calls
Repository (plain Dart class)
    ↓ uses
ApiClient (Dio singleton) → REST API
WebSocketService (Socket.IO singleton) → Real-time events
HiveService → Local cache
```

### Key Patterns
- **Repository Pattern**: All API calls abstracted through repository classes
- **StateNotifier**: Complex state with methods (auth, meeting, chat, AI, notifications, settings, connectivity)
- **FutureProvider**: Simple async data fetching (meetings, recordings, subscription, legal, search)
- **FutureProvider.family**: Parameterized fetching (meeting by ID, participants by meeting, etc.)
- **WebSocket Streams**: `WebSocketService.stream()` returns `Stream<dynamic>` consumed by providers
- **Offline-first Caching**: Hive boxes with TTL-based expiration, cache-first reads in auth
- **Platform-adaptive UI**: `SResponsive` breakpoints, `ResponsiveLayout` widget, adaptive navigation (glass sidebar vs island bottom bar)
- **Deep Linking**: GoRouter handles `speakup://` and `https://speakup.app/` schemes
- **Account Guard**: Centralized account deletion/suspension detection across all API calls
