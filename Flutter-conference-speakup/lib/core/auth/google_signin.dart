import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final _googleSignIn = GoogleSignIn.instance;
  static final _auth = FirebaseAuth.instance;

  /// Initialize Google Sign-In. Call once at app startup.
  static Future<void> init() async {
    await _googleSignIn.initialize();
  }

  /// Sign in with Google and return Firebase UserCredential.
  static Future<UserCredential> signIn() async {
    final account = await _googleSignIn.authenticate(
      scopeHint: ['email', 'profile'],
    );

    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);

    return _auth.signInWithCredential(credential);
  }

  /// Sign out from both Google and Firebase.
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
