import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send magic link to email
  Future<void> sendSignInLink(String email) async {
    final ActionCodeSettings actionCodeSettings = ActionCodeSettings(
      url: 'https://your-app.firebaseapp.com/__/auth/action',
      handleCodeInApp: true,
      iOSBundleId: 'com.your.app',
      androidPackageName: 'com.your.app',
      androidInstallApp: true,
      androidMinimumVersion: '12',
    );

    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
  }

  // Sign in with magic link
  Future<User?> signInWithLink(String link) async {
    try {
      // Firebase automatically verifies the link
      UserCredential result = await _auth.signInWithEmailLink(emailLink: link, email: '');
      return result.user;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is signed in
  Stream<User?> get user => _auth.authStateChanges();
  
  // Get current user
  User? get currentUser => _auth.currentUser;
}