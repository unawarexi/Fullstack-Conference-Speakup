class MeetingMaterialModel {
  final String id;
  final String meetingId;
  final String userId;
  final String name;
  final String url;
  final String type; // MIME type
  final int sizeBytes;
  final String? uploaderName;
  final String? uploaderAvatar;
  final DateTime createdAt;

  const MeetingMaterialModel({
    required this.id,
    required this.meetingId,
    required this.userId,
    required this.name,
    required this.url,
    required this.type,
    this.sizeBytes = 0,
    this.uploaderName,
    this.uploaderAvatar,
    required this.createdAt,
  });

  bool get isImage => type.startsWith('image/');
  bool get isVideo => type.startsWith('video/');
  bool get isAudio => type.startsWith('audio/');
  bool get isDocument => !isImage && !isVideo && !isAudio;

  String get extension => name.contains('.') ? name.split('.').last.toLowerCase() : '';

  String get readableSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory MeetingMaterialModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return MeetingMaterialModel(
      id: json['id'] as String,
      meetingId: json['meetingId'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      type: json['type'] as String? ?? 'application/octet-stream',
      sizeBytes: json['sizeBytes'] as int? ?? 0,
      uploaderName: user?['fullName'] as String?,
      uploaderAvatar: user?['avatar'] as String?,
      createdAt: DateTime.parse(
          json['createdAt'] as String? ?? DateTime.now().toIso8601String()).toLocal(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'meetingId': meetingId,
        'userId': userId,
        'name': name,
        'url': url,
        'type': type,
        'sizeBytes': sizeBytes,
        'createdAt': createdAt.toIso8601String(),
      };
}
