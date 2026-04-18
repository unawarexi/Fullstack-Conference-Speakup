import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_conference_speakup/core/auth/google_signin.dart';
import 'package:flutter_conference_speakup/core/auth/github_signin.dart';
import 'package:flutter_conference_speakup/core/network/api_client.dart';
import 'package:flutter_conference_speakup/core/apis/endpoints.dart';
import 'package:flutter_conference_speakup/core/services/storage_service.dart';
import 'package:flutter_conference_speakup/core/db/hive.dart';
import 'package:flutter_conference_speakup/app/domain/models/user_model.dart';
import 'package:flutter_conference_speakup/core/network/api_exception.dart';

class AuthRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final _api = ApiClient.instance;

  User? get firebaseUser => _firebaseAuth.currentUser;
  bool get isLoggedIn => firebaseUser != null;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign in with Google OAuth → Firebase → Backend sync.
  /// Returns `null` when the user cancels the sign-in flow.
  Future<UserModel?> signInWithGoogle() async {
    try {
      final cred = await GoogleSignInService.signIn();
      if (cred == null) return null; // user cancelled
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
    // Fire-and-forget backend signout — don't block local cleanup
    _api.post(ApiEndpoints.signOut).catchError((_) {});
    await Future.wait([
      GoogleSignInService.signOut(),
      SecureStorageService.clearAll(),
      HiveService.clearAll(),
    ]);
  }

  /// Delete user account.
  Future<void> deleteAccount() async {
    await _api.delete(ApiEndpoints.deleteAccount);
    await Future.wait([
      _firebaseAuth.currentUser?.delete() ?? Future.value(),
      SecureStorageService.clearAll(),
      HiveService.clearAll(),
    ]);
  }
}
