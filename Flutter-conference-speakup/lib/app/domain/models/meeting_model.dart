enum MeetingStatus { scheduled, live, ended, cancelled }

enum MeetingType { instant, scheduled, recurring }

class MeetingModel {
  final String id;
  final String code;
  final String title;
  final String? description;
  final String hostId;
  final String? hostName;
  final String? hostAvatar;
  final MeetingType type;
  final MeetingStatus status;
  final DateTime? scheduledAt;
  final DateTime? scheduledEndAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int participantCount;
  final int maxParticipants;
  final bool isRecording;
  final String? password;
  final int? durationMinutes;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;

  const MeetingModel({
    required this.id,
    this.code = '',
    required this.title,
    this.description,
    required this.hostId,
    this.hostName,
    this.hostAvatar,
    this.type = MeetingType.instant,
    this.status = MeetingStatus.scheduled,
    this.scheduledAt,
    this.scheduledEndAt,
    this.startedAt,
    this.endedAt,
    this.participantCount = 0,
    this.maxParticipants = 100,
    this.isRecording = false,
    this.password,
    this.durationMinutes,
    this.settings,
    required this.createdAt,
  });

  bool get isLive => status == MeetingStatus.live;
  bool get hasPassword => password != null && password!.isNotEmpty;

  /// Recurrence config stored in settings (for RECURRING meetings).
  Map<String, dynamic>? get recurrence =>
      settings?['recurrence'] as Map<String, dynamic>?;

  /// Days of week for recurrence (0=Sun..6=Sat).
  List<int> get recurrenceDays =>
      (recurrence?['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ??
      [];

  /// Per-day schedules for recurrence.
  List<Map<String, dynamic>> get recurrenceSchedules =>
      (recurrence?['schedules'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList() ??
      [];

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    final host = json['host'] as Map<String, dynamic>?;
    return MeetingModel(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      title: json['title'] as String,
      description: json['description'] as String?,
      hostId: json['hostId'] as String,
      hostName: host?['fullName'] as String? ?? json['hostName'] as String?,
      hostAvatar: host?['avatar'] as String?,
      type: MeetingType.values.byName(
          (json['type'] as String? ?? 'INSTANT').toLowerCase()),
      status: MeetingStatus.values.byName(
          (json['status'] as String? ?? 'SCHEDULED').toLowerCase()),
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String).toLocal()
          : null,
      scheduledEndAt: json['scheduledEndAt'] != null
          ? DateTime.parse(json['scheduledEndAt'] as String).toLocal()
          : null,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String).toLocal()
          : null,
      endedAt: json['endedAt'] != null
          ? DateTime.parse(json['endedAt'] as String).toLocal()
          : null,
      participantCount: json['participantCount'] as int? ??
          (json['_count']?['participants'] as int? ?? 0),
      maxParticipants: json['maxParticipants'] as int? ?? 100,
      isRecording: json['isRecording'] as bool? ?? false,
      password: json['password'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
      settings: json['settings'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(
          json['createdAt'] as String? ?? DateTime.now().toIso8601String()).toLocal(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'title': title,
        'description': description,
        'hostId': hostId,
        'type': type.name.toUpperCase(),
        'status': status.name.toUpperCase(),
        'scheduledAt': scheduledAt?.toIso8601String(),
        'scheduledEndAt': scheduledEndAt?.toIso8601String(),
        'startedAt': startedAt?.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'participantCount': participantCount,
        'maxParticipants': maxParticipants,
        'isRecording': isRecording,
        'durationMinutes': durationMinutes,
        'settings': settings,
        'createdAt': createdAt.toIso8601String(),
      };

  MeetingModel copyWith({
    String? title,
    String? description,
    MeetingType? type,
    MeetingStatus? status,
    DateTime? scheduledAt,
    DateTime? scheduledEndAt,
    DateTime? startedAt,
    DateTime? endedAt,
    int? participantCount,
    int? maxParticipants,
    bool? isRecording,
    String? password,
    int? durationMinutes,
    Map<String, dynamic>? settings,
  }) =>
      MeetingModel(
        id: id,
        code: code,
        title: title ?? this.title,
        description: description ?? this.description,
        hostId: hostId,
        hostName: hostName,
        hostAvatar: hostAvatar,
        type: type ?? this.type,
        status: status ?? this.status,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        scheduledEndAt: scheduledEndAt ?? this.scheduledEndAt,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt ?? this.endedAt,
        participantCount: participantCount ?? this.participantCount,
        maxParticipants: maxParticipants ?? this.maxParticipants,
        isRecording: isRecording ?? this.isRecording,
        password: password ?? this.password,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        settings: settings ?? this.settings,
        createdAt: createdAt,
      );
}
