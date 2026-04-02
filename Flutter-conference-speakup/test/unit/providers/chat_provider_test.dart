import 'package:flutter_test/flutter_test.dart';
import 'package:video_confrence_app/store/chat_provider.dart';
import 'package:video_confrence_app/app/domain/models/chat_model.dart';

void main() {
  group('ChatMessagesState', () {
    test('initial state has defaults', () {
      const state = ChatMessagesState();
      expect(state.messages, isEmpty);
      expect(state.isLoading, false);
      expect(state.hasMore, true);
      expect(state.cursor, isNull);
    });

    test('copyWith preserves unmodified fields', () {
      const state = ChatMessagesState(hasMore: true, isLoading: false);
      final updated = state.copyWith(isLoading: true);
      expect(updated.isLoading, true);
      expect(updated.hasMore, true); // preserved
    });

    test('copyWith updates messages', () {
      const state = ChatMessagesState();
      final msg = ChatMessage(
        id: 'msg-1',
        chatRoomId: 'room-1',
        senderId: 'user-1',
        content: 'Hello',
        createdAt: DateTime(2026, 4, 2),
        updatedAt: DateTime(2026, 4, 2),
      );
      final updated = state.copyWith(messages: [msg]);
      expect(updated.messages.length, 1);
      expect(updated.messages.first.content, 'Hello');
    });
  });
}
