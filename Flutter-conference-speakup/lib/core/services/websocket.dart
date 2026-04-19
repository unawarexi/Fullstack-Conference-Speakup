import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_conference_speakup/core/config/base_url.dart';
import 'package:logger/logger.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

typedef SocketEventHandler = void Function(dynamic data);

class WebSocketService {
  static WebSocketService? _instance;
  io.Socket? _socket;
  final _eventControllers = <String, StreamController<dynamic>>{};
  bool _reconnecting = false;
  String? _userId;

  WebSocketService._();
  factory WebSocketService() => _instance ??= WebSocketService._();

  bool get isConnected => _socket?.connected ?? false;
  bool get isReconnecting => _reconnecting;

  /// Set the authenticated user ID for WebSocket registration.
  void setUserId(String userId) {
    _userId = userId;
    _registerUser();
  }

  /// Register user with the backend so they join their personal notification room.
  void _registerUser() {
    if (_userId != null && isConnected) {
      _socket?.emit('auth:register', _userId);
      _log.i('[WS] Registered user: $_userId');
    }
  }

  /// Connect to WebSocket server with Firebase auth token.
  Future<void> connect() async {
    if (isConnected) return;

    String? token;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      token = await user.getIdToken();
    }

    _socket = io.io(
      AppBaseUrl.wsUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(10000)
          .setAuth(token != null ? {'token': token} : {})
          .build(),
    );

    _socket!
      ..onConnect((_) {
        _log.i('[WS] Connected');
        _reconnecting = false;
        _emit('connection_status', true);
        // Register user for personal notification room
        _registerUser();
      })
      ..onDisconnect((_) {
        _log.w('[WS] Disconnected');
        _emit('connection_status', false);
      })
      ..onReconnect((_) {
        _log.i('[WS] Reconnected');
        _reconnecting = false;
        _emit('connection_status', true);
        // Re-register after reconnection
        _registerUser();
      })
      ..onReconnectAttempt((_) {
        _reconnecting = true;
      })
      ..onError((err) {
        _log.e('[WS] Error: $err');
        _emit('socket_error', err);
      })
      ..connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _reconnecting = false;
    _userId = null;
  }

  void emit(String event, [dynamic data]) {
    _socket?.emit(event, data);
  }

  void on(String event, SocketEventHandler handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  /// Stream-based listener for reactive patterns.
  Stream<dynamic> stream(String event) {
    _eventControllers[event] ??= StreamController<dynamic>.broadcast();
    _socket?.on(event, (data) {
      _eventControllers[event]?.add(data);
    });
    return _eventControllers[event]!.stream;
  }

  void _emit(String event, dynamic data) {
    if (_eventControllers.containsKey(event)) {
      _eventControllers[event]?.add(data);
    }
  }

  /// Join a meeting room via WebSocket.
  void joinMeetingRoom(String meetingId) {
    emit('meeting:join', {'meetingId': meetingId});
  }

  /// Leave a meeting room via WebSocket.
  void leaveMeetingRoom(String meetingId) {
    emit('meeting:leave', {'meetingId': meetingId});
  }

  /// Join a chat room for real-time messages.
  void joinChatRoom(String chatRoomId) {
    emit('chat:join', {'chatRoomId': chatRoomId});
  }

  /// Leave a chat room.
  void leaveChatRoom(String chatRoomId) {
    emit('chat:leave', {'chatRoomId': chatRoomId});
  }

  void dispose() {
    disconnect();
    for (final ctrl in _eventControllers.values) {
      ctrl.close();
    }
    _eventControllers.clear();
    _instance = null;
  }
}
