import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send magic link to email
  Future<void> sendSignInLink(String email) async {
    final ActionCodeSettings actionCodeSettings = ActionCodeSettings(
      url: 'https://woven-spring-457211-k9.firebaseapp.com/__/auth/action',
      handleCodeInApp: true,
      iOSBundleId: 'com.example.studyAssistant',
      androidPackageName: 'com.example.study_assistant',
      androidInstallApp: true,
      androidMinimumVersion: '12',
    );

    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
    
    // Save the email for later use when signing in
    await _saveEmail(email);
  }

  // Save email to local storage
  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email_for_signin', email);
  }

  // Get saved email
  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email_for_signin');
  }

  // Sign in with magic link
  Future<User?> signInWithLink(String link) async {
    try {
      // Get the saved email
      final email = await getSavedEmail();
      
      if (email == null) {
        print('No email found. Please request a new magic link.');
        return null;
      }
      
      // Sign in with email and link
      UserCredential result = await _auth.signInWithEmailLink(
        email: email,
        emailLink: link,
      );
      
      // Clear the saved email after successful sign in
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('email_for_signin');
      
      return result.user;
    } catch (e) {
      print('Error signing in: $e');
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