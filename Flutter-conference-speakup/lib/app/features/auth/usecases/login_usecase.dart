import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_confrence_app/app/components/ui/toast_notifier.dart';
import 'package:video_confrence_app/store/auth_provider.dart';

class LoginUseCase {
  final WidgetRef _ref;
  final BuildContext _context;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Callback to notify the widget of state changes.
  final VoidCallback onStateChanged;

  LoginUseCase({
    required WidgetRef ref,
    required BuildContext context,
    required this.onStateChanged,
  })  : _ref = ref,
        _context = context;

  Future<void> signInWithGoogle() async {
    if (_isLoading) return;
    _setLoading(true);
    try {
      await _ref.read(currentUserProvider.notifier).signInWithGoogle();
      if (_context.mounted) _context.go('/home');
    } catch (e) {
      if (_context.mounted) {
        SToast.show(_context, message: e.toString(), type: SToastType.error);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGithub() async {
    if (_isLoading) return;
    _setLoading(true);
    try {
      await _ref.read(currentUserProvider.notifier).signInWithGithub();
      if (_context.mounted) _context.go('/home');
    } catch (e) {
      if (_context.mounted) {
        SToast.show(_context, message: e.toString(), type: SToastType.error);
      }
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    onStateChanged();
  }
}
