import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/auth/google_signin.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/db/hive.dart';
import 'package:flutter_conference_speakup/core/services/storage_service.dart';
import 'package:flutter_conference_speakup/router/app_router.dart';

/// Detects deleted / suspended accounts and forces sign-out with a user-facing
/// dialog.  Safe to call from interceptors — only the first invocation shows
/// the dialog; subsequent calls are no-ops until the flow completes.
class AccountGuard {
  AccountGuard._();

  static bool _triggered = false;

  /// Call when a persistent 401 (post-refresh) or 404 on auth endpoints is
  /// detected.  Shows a modal, clears local state, and redirects to `/login`.
  static Future<void> trigger() async {
    if (_triggered) return;
    _triggered = true;

    final context = rootNavigatorKey.currentContext;

    // Clear all auth state regardless of whether we can show a dialog.
    await _forceSignOut();

    if (context != null && context.mounted) {
      await _showAccountDialog(context);
    }

    // Navigate to login via GoRouter (works without a context).
    appRouter.go('/login');
    _triggered = false;
  }

  // ────────────── Dialog ──────────────

  static Future<void> _showAccountDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: CupertinoAlertDialog(
          title: Text(
            'Account Not Found',
            style: TextStyle(
              color: isDark ? SColors.textDark : SColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: SSizes.sm),
            child: Text(
              'Your account may have been suspended or deleted.\n\n'
              'Please contact customer support or sign up again.',
              style: TextStyle(
                color: isDark
                    ? SColors.textDarkSecondary
                    : SColors.textLightSecondary,
                fontSize: 13,
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: SColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────── Sign-out ──────────────

  static Future<void> _forceSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    try {
      await GoogleSignInService.signOut();
    } catch (_) {}
    try {
      await SecureStorageService.clearAll();
    } catch (_) {}
    try {
      await HiveService.clearAll();
    } catch (_) {}
  }
}
