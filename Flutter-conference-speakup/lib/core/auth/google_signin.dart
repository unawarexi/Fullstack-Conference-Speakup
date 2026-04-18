import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final _googleSignIn = GoogleSignIn.instance;
  static final _auth = FirebaseAuth.instance;

  /// Initialize Google Sign-In. Call once at app startup.
  static Future<void> init() async {
    await _googleSignIn.initialize();
  }

  /// Sign in with Google and return Firebase UserCredential.
  ///
  /// On Android 14+ this uses the Credential Manager API.
  /// If the user cancels, returns `null`. Other failures are rethrown
  /// with a user-readable message.
  static Future<UserCredential?> signIn() async {
    try {
      final account = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      final idToken = account.authentication.idToken;
      final credential = GoogleAuthProvider.credential(idToken: idToken);

      return _auth.signInWithCredential(credential);
    } on PlatformException catch (e) {
      // User dismissed the Credential Manager / sign-in sheet
      if (e.code == 'sign_in_cancelled' ||
          e.code == 'canceled' ||
          (e.message?.contains('cancel') ?? false) ||
          (e.message?.contains('Cancel') ?? false) ||
          (e.message?.contains('error returned from framework') ?? false)) {
        return null;
      }
      if (e.code == 'network_error') {
        throw Exception('No internet connection. Please try again.');
      }
      throw Exception('Google Sign-In failed. Please try again.');
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      // Catch-all for unexpected errors
      if (e.toString().contains('cancel') || e.toString().contains('Cancel')) {
        return null;
      }
      throw Exception('Google Sign-In failed. Please try again.');
    }
  }

  /// Sign out from both Google and Firebase.
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}
