import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/app/components/ui/toast_notifier.dart';
import 'package:flutter_conference_speakup/store/auth_provider.dart';

class LoginUseCase {
  final WidgetRef _ref;
  final BuildContext _context;

  LoginProvider? _activeProvider;
  bool get isLoading => _activeProvider != null;
  bool get isGoogleLoading => _activeProvider == LoginProvider.google;
  bool get isGithubLoading => _activeProvider == LoginProvider.github;

  /// Callback to notify the widget of state changes.
  final VoidCallback onStateChanged;

  LoginUseCase({
    required WidgetRef ref,
    required BuildContext context,
    required this.onStateChanged,
  })  : _ref = ref,
        _context = context;

  Future<void> signInWithGoogle() async {
    if (isLoading) return;
    _setActive(LoginProvider.google);
    try {
      await _ref.read(currentUserProvider.notifier).signInWithGoogle();
      if (_context.mounted) _context.go('/home');
    } catch (e) {
      if (_context.mounted) {
        SToast.show(_context, message: e.toString(), type: SToastType.error);
      }
    } finally {
      _setActive(null);
    }
  }

  Future<void> signInWithGithub() async {
    if (isLoading) return;
    _setActive(LoginProvider.github);
    try {
      await _ref.read(currentUserProvider.notifier).signInWithGithub();
      if (_context.mounted) _context.go('/home');
    } catch (e) {
      if (_context.mounted) {
        SToast.show(_context, message: e.toString(), type: SToastType.error);
      }
    } finally {
      _setActive(null);
    }
  }

  void _setActive(LoginProvider? provider) {
    _activeProvider = provider;
    onStateChanged();
  }
}

enum LoginProvider { google, github }
