class Participant {
  final String id;
  final String meetingId;
  final String userId;
  final String name;
  final String? avatar;
  final bool isMuted;
  final bool isCameraOff;
  final bool isScreenSharing;
  final bool isHandRaised;
  final ParticipantRole role;
  final DateTime joinedAt;
  final DateTime? leftAt;

  const Participant({
    required this.id,
    required this.meetingId,
    required this.userId,
    required this.name,
    this.avatar,
    this.isMuted = false,
    this.isCameraOff = false,
    this.isScreenSharing = false,
    this.isHandRaised = false,
    this.role = ParticipantRole.attendee,
    required this.joinedAt,
    this.leftAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return Participant(
      id: json['id'] as String,
      meetingId: json['meetingId'] as String? ?? '',
      userId: json['userId'] as String,
      name: user?['fullName'] as String? ?? json['name'] as String? ?? '',
      avatar: user?['avatar'] as String? ?? json['avatar'] as String?,
      isMuted: json['isMuted'] as bool? ?? false,
      isCameraOff: json['isCameraOff'] as bool? ?? false,
      isScreenSharing: json['isScreenSharing'] as bool? ?? false,
      isHandRaised: json['isHandRaised'] as bool? ?? false,
      role: ParticipantRole.values.byName(
          (json['role'] as String? ?? 'ATTENDEE').toLowerCase()),
      joinedAt: DateTime.parse(
          json['joinedAt'] as String? ?? DateTime.now().toIso8601String()),
      leftAt: json['leftAt'] != null
          ? DateTime.parse(json['leftAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'meetingId': meetingId,
        'userId': userId,
        'name': name,
        'avatar': avatar,
        'isMuted': isMuted,
        'isCameraOff': isCameraOff,
        'isScreenSharing': isScreenSharing,
        'isHandRaised': isHandRaised,
        'role': role.name.toUpperCase(),
        'joinedAt': joinedAt.toIso8601String(),
        'leftAt': leftAt?.toIso8601String(),
      };

  Participant copyWith({
    bool? isMuted,
    bool? isCameraOff,
    bool? isScreenSharing,
    bool? isHandRaised,
    ParticipantRole? role,
  }) =>
      Participant(
        id: id,
        meetingId: meetingId,
        userId: userId,
        name: name,
        avatar: avatar,
        isMuted: isMuted ?? this.isMuted,
        isCameraOff: isCameraOff ?? this.isCameraOff,
        isScreenSharing: isScreenSharing ?? this.isScreenSharing,
        isHandRaised: isHandRaised ?? this.isHandRaised,
        role: role ?? this.role,
        joinedAt: joinedAt,
        leftAt: leftAt,
      );
}

enum ParticipantRole { host, coHost, attendee }

enum RecordingStatus { processing, ready, failed }

class RecordingModel {
  final String id;
  final String meetingId;
  final String userId;
  final String? meetingTitle;
  final String url;
  final int duration;
  final int sizeBytes;
  final RecordingStatus status;
  final DateTime createdAt;

  const RecordingModel({
    required this.id,
    required this.meetingId,
    required this.userId,
    this.meetingTitle,
    required this.url,
    this.duration = 0,
    this.sizeBytes = 0,
    this.status = RecordingStatus.processing,
    required this.createdAt,
  });

  String get formattedSize {
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get formattedDuration {
    final d = Duration(seconds: duration);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  factory RecordingModel.fromJson(Map<String, dynamic> json) {
    final meeting = json['meeting'] as Map<String, dynamic>?;
    return RecordingModel(
      id: json['id'] as String,
      meetingId: json['meetingId'] as String,
      userId: json['userId'] as String? ?? '',
      meetingTitle: meeting?['title'] as String? ?? json['meetingTitle'] as String?,
      url: json['url'] as String,
      duration: json['duration'] as int? ?? 0,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      status: RecordingStatus.values.byName(
          (json['status'] as String? ?? 'PROCESSING').toLowerCase()),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'meetingId': meetingId,
        'userId': userId,
        'url': url,
        'duration': duration,
        'sizeBytes': sizeBytes,
        'status': status.name.toUpperCase(),
        'createdAt': createdAt.toIso8601String(),
      };
}
