import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_conference_speakup/app/domain/models/user_model.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/auth_repository.dart';
import 'package:flutter_conference_speakup/store/user_provider.dart';
import 'package:flutter_conference_speakup/core/network/account_guard.dart';
import 'package:flutter_conference_speakup/core/services/notification_service.dart';
import 'package:flutter_conference_speakup/core/services/storage_service.dart';

/// Auth repository singleton provider.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Stream of Firebase auth state changes.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Whether user has completed OAuth sign-in successfully.
/// This gates biometric auth — biometrics can only be enabled after this is true.
final hasOAuthSessionProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull != null;
});

/// Current app user profile (fetched after login).
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserModel?>>((ref) {
  return CurrentUserNotifier(ref);
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref _ref;
  CurrentUserNotifier(this._ref) : super(const AsyncValue.data(null)) {
    _init();
  }

  void _init() {
    // Try loading cached user immediately for fast startup
    final cached = _ref.read(authRepositoryProvider).getCachedUser();
    if (cached != null) {
      state = AsyncValue.data(cached);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _ref.read(authRepositoryProvider).signInWithGoogle();
      if (user == null) {
        // User cancelled the sign-in flow — restore idle state
        state = const AsyncValue.data(null);
        return;
      }
      state = AsyncValue.data(user);
      _registerFcmToken();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGithub() async {
    state = const AsyncValue.loading();
    try {
      final user = await _ref.read(authRepositoryProvider).signInWithGithub();
      state = AsyncValue.data(user);
      _registerFcmToken();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Fetch latest user profile from backend.
  Future<void> fetchProfile() async {
    try {
      final user = await _ref.read(authRepositoryProvider).getMe();
      state = AsyncValue.data(user);
    } catch (e, st) {
      // 404 from /auth/me means the account was deleted from the backend
      if (e is DioException && e.response?.statusCode == 404) {
        state = const AsyncValue.data(null);
        AccountGuard.trigger();
        return;
      }
      // If fetch fails but we have cached data, keep it
      if (state.valueOrNull == null) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> signOut() async {
    await _ref.read(authRepositoryProvider).signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> deleteAccount() async {
    await _ref.read(authRepositoryProvider).deleteAccount();
    state = const AsyncValue.data(null);
  }

  void setUser(UserModel user) => state = AsyncValue.data(user);

  /// Register FCM token with the backend for push notifications.
  Future<void> _registerFcmToken() async {
    try {
      final token = await NotificationService.instance.getToken();
      if (token != null) {
        await _ref.read(userRepositoryProvider).registerDevice(
              fcmToken: token,
              platform: Platform.isIOS ? 'ios' : 'android',
            );
      }
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }
  }
  void clear() => state = const AsyncValue.data(null);
}

/// Biometric lock preference — only meaningful when hasOAuthSession is true.
final biometricEnabledProvider = StateProvider<bool>((ref) {
  return LocalStorageService.biometricEnabled;
});

