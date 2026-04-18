import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level handler for background FCM messages (must be top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance._showFromRemoteMessage(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// Android notification channel for meeting reminders.
  static const _meetingChannel = AndroidNotificationChannel(
    'meeting_reminders',
    'Meeting Reminders',
    description: 'Notifications for upcoming and starting meetings',
    importance: Importance.high,
  );

  /// Initialize local notifications + FCM listeners.
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

    // Create Android channel
    if (Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_meetingChannel);
    }

    // --- FCM setup ---
    final messaging = FirebaseMessaging.instance;

    // Request permission (iOS/macOS)
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_showFromRemoteMessage);

    // Background handler is registered in main.dart
  }

  /// Get the FCM token for device registration.
  Future<String?> getToken() => FirebaseMessaging.instance.getToken();

  /// Listen for token refresh.
  Stream<String> get onTokenRefresh =>
      FirebaseMessaging.instance.onTokenRefresh;

  /// Show a local notification from an FCM [RemoteMessage].
  Future<void> _showFromRemoteMessage(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    final title = notification?.title ?? data['title'] ?? 'SpeakUp';
    final body = notification?.body ?? data['body'] ?? '';

    await _local.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _meetingChannel.id,
          _meetingChannel.name,
          channelDescription: _meetingChannel.description,
          importance: Importance.high,
          priority: Priority.high,
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

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      debugPrint('Notification tapped with data: $data');
      // Navigation can be handled via a global navigator key or event bus
    } catch (_) {}
  }
}
