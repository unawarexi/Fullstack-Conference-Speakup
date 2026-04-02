enum MessageType { text, image, file, system }

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String? senderName;
  final String? senderAvatar;
  final String content;
  final MessageType type;
  final String? replyToId;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.content,
    this.type = MessageType.text,
    this.replyToId,
    this.isEdited = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>?;
    return ChatMessage(
      id: json['id'] as String,
      chatRoomId: json['chatRoomId'] as String? ?? json['roomId'] as String? ?? '',
      senderId: json['senderId'] as String,
      senderName: sender?['fullName'] as String? ?? json['senderName'] as String?,
      senderAvatar: sender?['avatar'] as String? ?? json['senderAvatar'] as String?,
      content: json['content'] as String,
      type: MessageType.values.byName(
          (json['type'] as String? ?? 'TEXT').toLowerCase()),
      replyToId: json['replyToId'] as String?,
      isEdited: json['isEdited'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(
          json['updatedAt'] as String? ?? json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chatRoomId': chatRoomId,
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatar': senderAvatar,
        'content': content,
        'type': type.name.toUpperCase(),
        'replyToId': replyToId,
        'isEdited': isEdited,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class ChatRoom {
  final String id;
  final String? name;
  final bool isGroup;
  final String? meetingId;
  final List<ChatMember> members;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime createdAt;

  const ChatRoom({
    required this.id,
    this.name,
    this.isGroup = false,
    this.meetingId,
    this.members = const [],
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) => ChatRoom(
        id: json['id'] as String,
        name: json['name'] as String?,
        isGroup: json['isGroup'] as bool? ?? false,
        meetingId: json['meetingId'] as String?,
        members: (json['members'] as List?)
                ?.map((e) => ChatMember.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        lastMessage: json['lastMessage'] != null
            ? ChatMessage.fromJson(json['lastMessage'] as Map<String, dynamic>)
            : null,
        unreadCount: json['unreadCount'] as int? ?? 0,
        createdAt: DateTime.parse(
            json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isGroup': isGroup,
        'meetingId': meetingId,
        'members': members.map((m) => m.toJson()).toList(),
        'lastMessage': lastMessage?.toJson(),
        'unreadCount': unreadCount,
        'createdAt': createdAt.toIso8601String(),
      };
}

class ChatMember {
  final String id;
  final String userId;
  final String? fullName;
  final String? avatar;
  final DateTime joinedAt;

  const ChatMember({
    required this.id,
    required this.userId,
    this.fullName,
    this.avatar,
    required this.joinedAt,
  });

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return ChatMember(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fullName: user?['fullName'] as String?,
      avatar: user?['avatar'] as String?,
      joinedAt: DateTime.parse(
          json['joinedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'fullName': fullName,
        'avatar': avatar,
        'joinedAt': joinedAt.toIso8601String(),
      };
}
