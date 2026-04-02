import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_confrence_app/app/domain/models/chat_model.dart';
import 'package:video_confrence_app/app/domain/repositories/chat_repository.dart';
import 'package:video_confrence_app/core/services/websocket.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

/// All chat rooms.
final chatRoomsProvider = FutureProvider.autoDispose<List<ChatRoom>>((ref) {
  return ref.read(chatRepositoryProvider).getRooms();
});

/// Messages for a specific chat room with cursor pagination.
final chatMessagesProvider = StateNotifierProvider.family
    .autoDispose<ChatMessagesNotifier, ChatMessagesState, String>(
        (ref, chatRoomId) {
  return ChatMessagesNotifier(ref, chatRoomId);
});

class ChatMessagesState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool hasMore;
  final String? cursor;

  const ChatMessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.cursor,
  });

  ChatMessagesState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? hasMore,
    String? cursor,
  }) =>
      ChatMessagesState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        cursor: cursor ?? this.cursor,
      );
}

class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  final Ref _ref;
  final String chatRoomId;
  StreamSubscription? _messageSub;

  ChatMessagesNotifier(this._ref, this.chatRoomId)
      : super(const ChatMessagesState()) {
    _loadInitial();
    _listenToWebSocket();
  }

  Future<void> _loadInitial() async {
    state = state.copyWith(isLoading: true);
    try {
      final messages = await _ref
          .read(chatRepositoryProvider)
          .getMessages(chatRoomId);
      state = ChatMessagesState(
        messages: messages,
        hasMore: messages.length >= 50,
        cursor: messages.isNotEmpty ? messages.last.id : null,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final more = await _ref
          .read(chatRepositoryProvider)
          .getMessages(chatRoomId, cursor: state.cursor);
      state = state.copyWith(
        messages: [...state.messages, ...more],
        hasMore: more.length >= 50,
        cursor: more.isNotEmpty ? more.last.id : state.cursor,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> sendMessage({
    required String content,
    String type = 'TEXT',
    String? replyToId,
  }) async {
    final message = await _ref.read(chatRepositoryProvider).sendMessage(
          chatRoomId: chatRoomId,
          content: content,
          type: type,
          replyToId: replyToId,
        );
    state = state.copyWith(messages: [message, ...state.messages]);
  }

  Future<void> deleteMessage(String messageId) async {
    await _ref.read(chatRepositoryProvider).deleteMessage(messageId);
    state = state.copyWith(
      messages: state.messages.where((m) => m.id != messageId).toList(),
    );
  }

  void _listenToWebSocket() {
    _messageSub = WebSocketService()
        .stream('chat:message:$chatRoomId')
        .listen((data) {
      if (data is Map<String, dynamic>) {
        final msg = ChatMessage.fromJson(data);
        // Avoid duplicates
        if (!state.messages.any((m) => m.id == msg.id)) {
          state = state.copyWith(messages: [msg, ...state.messages]);
        }
      }
    });
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    super.dispose();
  }
}
