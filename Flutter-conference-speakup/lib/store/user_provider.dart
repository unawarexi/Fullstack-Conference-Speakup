import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_confrence_app/app/domain/models/user_model.dart';
import 'package:video_confrence_app/app/domain/repositories/user_repository.dart';
import 'package:video_confrence_app/store/auth_provider.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Update user profile and sync with auth state.
final updateProfileProvider = Provider<
    Future<UserModel> Function({String? fullName, String? bio})>((ref) {
  return ({String? fullName, String? bio}) async {
    final user = await ref.read(userRepositoryProvider).updateProfile(
          fullName: fullName,
          bio: bio,
        );
    ref.read(currentUserProvider.notifier).setUser(user);
    return user;
  };
});

/// Update avatar and sync with auth state.
final updateAvatarProvider =
    Provider<Future<UserModel> Function(String filePath)>((ref) {
  return (String filePath) async {
    final user = await ref.read(userRepositoryProvider).updateAvatar(filePath);
    ref.read(currentUserProvider.notifier).setUser(user);
    return user;
  };
});
