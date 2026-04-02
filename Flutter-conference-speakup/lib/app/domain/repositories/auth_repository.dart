import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_confrence_app/core/auth/google_signin.dart';
import 'package:video_confrence_app/core/auth/github_signin.dart';
import 'package:video_confrence_app/core/network/api_client.dart';
import 'package:video_confrence_app/core/apis/endpoints.dart';
import 'package:video_confrence_app/core/services/storage_service.dart';
import 'package:video_confrence_app/core/db/hive.dart';
import 'package:video_confrence_app/app/domain/models/user_model.dart';
import 'package:video_confrence_app/core/network/api_exception.dart';

class AuthRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final _api = ApiClient.instance;

  User? get firebaseUser => _firebaseAuth.currentUser;
  bool get isLoggedIn => firebaseUser != null;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign in with Google OAuth → Firebase → Backend sync.
  Future<UserModel> signInWithGoogle() async {
    try {
      final cred = await GoogleSignInService.signIn();
      return _syncWithBackend(cred);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Sign in with GitHub OAuth → Firebase → Backend sync.
  Future<UserModel> signInWithGithub() async {
    try {
      final cred = await GithubSignInService.signIn();
      return _syncWithBackend(cred);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// After Firebase auth, sync user with backend.
  Future<UserModel> _syncWithBackend(UserCredential cred) async {
    final idToken = await cred.user!.getIdToken();
    final res = await _api.post(
      ApiEndpoints.signIn,
      data: {'idToken': idToken},
    );
    final user = UserModel.fromJson(res.data['data']['user']);

    // Cache user locally
    await SecureStorageService.saveUserId(user.id);
    HiveService.userCache.put('current_user', user.toJson());

    return user;
  }

  /// Get current user profile from backend.
  Future<UserModel> getMe() async {
    final res = await _api.get(ApiEndpoints.me);
    final user = UserModel.fromJson(res.data['data']);
    HiveService.userCache.put('current_user', user.toJson());
    return user;
  }

  /// Get cached user (offline fallback).
  UserModel? getCachedUser() {
    final cached = HiveService.userCache.get('current_user');
    if (cached != null) {
      return UserModel.fromJson(Map<String, dynamic>.from(cached));
    }
    return null;
  }

  /// Sign out from Firebase + backend.
  Future<void> signOut() async {
    try {
      await _api.post(ApiEndpoints.signOut);
    } catch (_) {
      // Backend signout failed — still clear local state
    }
    await GoogleSignInService.signOut();
    await SecureStorageService.clearAll();
    await HiveService.clearAll();
  }

  /// Delete user account.
  Future<void> deleteAccount() async {
    await _api.delete(ApiEndpoints.deleteAccount);
    await _firebaseAuth.currentUser?.delete();
    await SecureStorageService.clearAll();
    await HiveService.clearAll();
  }
}
