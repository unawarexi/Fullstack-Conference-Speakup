import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_conference_speakup/router/app_router.dart';

/// Top-level handler for background FCM messages (must be top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance._handleRemoteMessage(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  // ── Android Notification Channels ──

  static const _meetingChannel = AndroidNotificationChannel(
    'meeting_reminders',
    'Meeting Reminders',
    description: 'Notifications for upcoming and starting meetings',
    importance: Importance.high,
    enableVibration: true,
  );

  static const _callChannel = AndroidNotificationChannel(
    'incoming_calls',
    'Incoming Calls',
    description: 'Incoming call notifications with ringtone and vibration',
    importance: Importance.max,
    enableVibration: true,
    playSound: true,
  );

  static const _chatChannel = AndroidNotificationChannel(
    'chat_messages',
    'Chat Messages',
    description: 'Notifications for new chat messages',
    importance: Importance.high,
    enableVibration: true,
  );

  static const _systemChannel = AndroidNotificationChannel(
    'system_notifications',
    'System Notifications',
    description: 'General system notifications, recording ready, etc.',
    importance: Importance.defaultImportance,
  );

  /// Initialize local notifications + FCM listeners + CallKit.
  Future<void> init() async {
    // --- Local notifications setup ---
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android channels
    if (Platform.isAndroid) {
      final androidPlugin = _local.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_meetingChannel);
      await androidPlugin?.createNotificationChannel(_callChannel);
      await androidPlugin?.createNotificationChannel(_chatChannel);
      await androidPlugin?.createNotificationChannel(_systemChannel);
    }

    // --- FCM setup ---
    final messaging = FirebaseMessaging.instance;

    // Request permission (iOS/macOS)
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true, // For incoming calls on iOS
    );

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleRemoteMessage);

    // Handle notification tap when app is opened from terminated state
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _navigateFromMessage(initialMessage.data);
    }

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigateFromMessage(message.data);
    });

    // Listen for CallKit events (accept/decline incoming calls)
    FlutterCallkitIncoming.onEvent.listen((event) {
      if (event == null) return;
      switch (event.event) {
        case Event.actionCallAccept:
          final data = event.body as Map<String, dynamic>? ?? {};
          final extra = data['extra'] as Map<String, dynamic>? ?? {};
          final meetingCode = extra['meetingCode'] as String?;
          if (meetingCode != null) {
            rootNavigatorKey.currentState?.pushNamed(
              'join-by-code',
              arguments: meetingCode,
            );
          }
          break;
        case Event.actionCallDecline:
        case Event.actionCallEnded:
          FlutterCallkitIncoming.endAllCalls();
          break;
        default:
          break;
      }
    });
  }

  /// Get the FCM token for device registration.
  Future<String?> getToken() => FirebaseMessaging.instance.getToken();

  /// Listen for token refresh.
  Stream<String> get onTokenRefresh =>
      FirebaseMessaging.instance.onTokenRefresh;

  /// Route incoming FCM message to the right notification type.
  Future<void> _handleRemoteMessage(RemoteMessage message) async {
    final data = message.data;
    final type = data['type'] ?? '';
    final isInstant = data['isInstant'] == 'true';

    // Incoming call → show CallKit (native call UI with ring + vibrate)
    if (type == 'MEETING_INVITE' && isInstant) {
      await _showIncomingCall(message);
      return;
    }

    // All other notifications → local notification with appropriate channel
    await _showLocalNotification(message);
  }

  /// Show native incoming call UI (rings, vibrates, full-screen on lock screen).
  Future<void> _showIncomingCall(RemoteMessage message) async {
    final data = message.data;
    final callerName = data['hostName'] ?? data['title'] ?? 'SpeakUp Call';
    final meetingCode = data['meetingCode'] ?? data['code'] ?? '';
    final avatar = data['hostAvatar'] ?? '';

    final params = CallKitParams(
      id: data['meetingId'] ?? message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nameCaller: callerName,
      appName: 'SpeakUp',
      avatar: avatar,
      type: 1, // Video call
      duration: 45000, // Ring for 45 seconds
      textAccept: 'Join Call',
      textDecline: 'Decline',
      extra: {'meetingCode': meetingCode, 'meetingId': data['meetingId'] ?? ''},
      android: const AndroidParams(
        isCustomNotification: false,
        isShowLogo: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#1A73E8',
        actionColor: '#4CAF50',
        isShowFullLockedScreen: true,
        isShowCallID: false,
      ),
      ios: const IOSParams(
        iconName: 'AppIcon',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'videoChat',
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  /// Show a local notification with the right channel based on type.
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;
    final type = data['type'] ?? '';

    final title = notification?.title ?? data['title'] ?? 'SpeakUp';
    final body = notification?.body ?? data['body'] ?? '';

    // Pick channel based on notification type
    final channel = _channelForType(type);

    await _local.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: type == 'CHAT_MESSAGE' ? Priority.high : Priority.defaultPriority,
          enableVibration: true,
          category: type == 'CHAT_MESSAGE'
              ? AndroidNotificationCategory.message
              : AndroidNotificationCategory.event,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(data),
    );
  }

  AndroidNotificationChannel _channelForType(String type) {
    switch (type) {
      case 'MEETING_INVITE':
        return _callChannel;
      case 'CHAT_MESSAGE':
        return _chatChannel;
      case 'MEETING_REMINDER':
      case 'MEETING_CANCELLED':
        return _meetingChannel;
      case 'RECORDING_READY':
      default:
        return _systemChannel;
    }
  }

  /// Handle notification tap — navigate to the right screen.
  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateFromMessage(data);
    } catch (_) {}
  }

  /// Navigate based on notification data payload.
  void _navigateFromMessage(Map<String, dynamic> data) {
    final type = data['type'] ?? '';
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    switch (type) {
      case 'MEETING_INVITE':
        final meetingCode = data['meetingCode'] ?? data['code'];
        if (meetingCode != null) {
          appRouter.go('/join/$meetingCode');
        } else {
          appRouter.go('/meetings');
        }
        break;
      case 'CHAT_MESSAGE':
        final chatRoomId = data['chatRoomId'];
        if (chatRoomId != null) {
          appRouter.go('/chat/$chatRoomId');
        } else {
          appRouter.go('/chat');
        }
        break;
      case 'RECORDING_READY':
        appRouter.go('/recordings');
        break;
      case 'MEETING_REMINDER':
      case 'MEETING_CANCELLED':
        appRouter.go('/meetings');
        break;
      default:
        appRouter.go('/home');
    }
  }
}
