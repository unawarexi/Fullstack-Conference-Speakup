enum UserRole { user, admin, moderator }

class UserModel {
  final String id;
  final String firebaseUid;
  final String email;
  final String fullName;
  final String? avatar;
  final String? bio;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.fullName,
    this.avatar,
    this.bio,
    this.isOnline = false,
    this.lastSeenAt,
    this.role = UserRole.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        firebaseUid: json['firebaseUid'] as String? ?? '',
        email: json['email'] as String,
        fullName: json['fullName'] as String,
        avatar: json['avatar'] as String?,
        bio: json['bio'] as String?,
        isOnline: json['isOnline'] as bool? ?? false,
        lastSeenAt: json['lastSeenAt'] != null
            ? DateTime.parse(json['lastSeenAt'] as String).toLocal()
            : null,
        role: UserRole.values.byName(
            (json['role'] as String? ?? 'USER').toLowerCase()),
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        updatedAt: DateTime.parse(
            json['updatedAt'] as String? ?? json['createdAt'] as String).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firebaseUid': firebaseUid,
        'email': email,
        'fullName': fullName,
        'avatar': avatar,
        'bio': bio,
        'isOnline': isOnline,
        'lastSeenAt': lastSeenAt?.toIso8601String(),
        'role': role.name.toUpperCase(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// Lightweight JSON for Hive caching.
  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'firebaseUid': firebaseUid,
        'email': email,
        'fullName': fullName,
        'avatar': avatar,
        'bio': bio,
        'role': role.name.toUpperCase(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  UserModel copyWith({
    String? fullName,
    String? email,
    String? avatar,
    String? bio,
    bool? isOnline,
    DateTime? lastSeenAt,
    UserRole? role,
  }) =>
      UserModel(
        id: id,
        firebaseUid: firebaseUid,
        email: email ?? this.email,
        fullName: fullName ?? this.fullName,
        avatar: avatar ?? this.avatar,
        bio: bio ?? this.bio,
        isOnline: isOnline ?? this.isOnline,
        lastSeenAt: lastSeenAt ?? this.lastSeenAt,
        role: role ?? this.role,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

class DeviceModel {
  final String id;
  final String fcmToken;
  final String platform;
  final DateTime createdAt;

  const DeviceModel({
    required this.id,
    required this.fcmToken,
    required this.platform,
    required this.createdAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
        id: json['id'] as String,
        fcmToken: json['fcmToken'] as String,
        platform: json['platform'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      );
}
