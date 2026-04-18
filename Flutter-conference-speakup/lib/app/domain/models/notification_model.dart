enum NotificationType {
  meetingInvite,
  meetingReminder,
  meetingStarted,
  chatMessage,
  recordingReady,
  system,
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type = NotificationType.system,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] as String? ?? 'SYSTEM')
        .toLowerCase()
        .replaceAllMapped(
            RegExp(r'_([a-z])'), (m) => m.group(1)!.toUpperCase());
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => NotificationType.system,
      ),
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
        'type': type.name,
        'data': data,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        userId: userId,
        title: title,
        body: body,
        type: type,
        data: data,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}
