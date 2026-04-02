import 'package:firebase_auth/firebase_auth.dart';

class GithubSignInService {
  static final _auth = FirebaseAuth.instance;

  /// Sign in with GitHub via Firebase Auth provider.
  static Future<UserCredential> signIn() async {
    final provider = GithubAuthProvider();
    provider.addScope('read:user');
    provider.addScope('user:email');

    return _auth.signInWithProvider(provider);
  }

  /// Sign out from Firebase.
  static Future<void> signOut() => _auth.signOut();
}
