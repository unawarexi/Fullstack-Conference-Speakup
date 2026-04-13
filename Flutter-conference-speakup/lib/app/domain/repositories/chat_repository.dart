import 'package:flutter_conference_speakup/core/network/api_client.dart';
import 'package:flutter_conference_speakup/core/apis/endpoints.dart';
import 'package:flutter_conference_speakup/app/domain/models/chat_model.dart';

class ChatRepository {
  final _api = ApiClient.instance;

  Future<List<ChatRoom>> getRooms() async {
    final res = await _api.get(ApiEndpoints.chatRooms);
    final list = res.data['data'] as List;
    return list.map((e) => ChatRoom.fromJson(e)).toList();
  }

  Future<ChatRoom> getOrCreateMeetingChat(String meetingId) async {
    final res = await _api.get(ApiEndpoints.meetingChat(meetingId));
    return ChatRoom.fromJson(res.data['data']['chatRoom']);
  }

  /// Get messages with cursor-based pagination.
  Future<List<ChatMessage>> getMessages(
    String chatRoomId, {
    String? cursor,
    int limit = 50,
  }) async {
    final res = await _api.get(
      ApiEndpoints.chatMessages(chatRoomId),
      queryParameters: {
        'cursor': ?cursor,
        'limit': limit,
      },
    );
    final list = res.data['data'] as List;
    return list.map((e) => ChatMessage.fromJson(e)).toList();
  }

  Future<ChatMessage> sendMessage({
    required String chatRoomId,
    required String content,
    String type = 'TEXT',
    String? replyToId,
  }) async {
    final res = await _api.post(
      ApiEndpoints.chatMessages(chatRoomId),
      data: {
        'content': content,
        'type': type,
        'replyToId': ?replyToId,
      },
    );
    return ChatMessage.fromJson(res.data['data']['message']);
  }

  Future<void> deleteMessage(String messageId) =>
      _api.delete(ApiEndpoints.deleteMessage(messageId));
}
