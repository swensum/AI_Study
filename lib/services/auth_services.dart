// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Save email locally before sending the link
  static Future<void> saveEmailLocally(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_email', email);
  }
  
  // Get stored email
  static Future<String?> getStoredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pending_email');
  }
  
  // Clear stored email after sign-in
  static Future<void> clearStoredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_email');
  }
  
  // Send sign-in link to email
  static Future<bool> sendSignInLink(String email) async {
    try {
      // Save email before sending
      await saveEmailLocally(email);
      
      ActionCodeSettings actionCodeSettings = ActionCodeSettings(
        // Replace with your actual domain (must be whitelisted in Firebase Console)
        url:'https://woven-spring-457211-k9.web.app/finishSignIn',
        handleCodeInApp: true,
        // For Android - replace with your package name
        androidPackageName: 'com.example.study_assistant',
        androidInstallApp: true,
        androidMinimumVersion: '12',
        // For iOS - replace with your bundle ID
        iOSBundleId: 'com.example.studyAssistant',
      );
      
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
      
      return true;
    } catch (e) {
      print('Error sending sign-in link: $e');
      return false;
    }
  }
  
  // Complete sign-in with email link
  static Future<UserCredential?> signInWithEmailLink(
    String email,
    String link,
  ) async {
    try {
      // Verify it's a sign-in with email link
      if (_auth.isSignInWithEmailLink(link)) {
        UserCredential userCredential = await _auth.signInWithEmailLink(
          email: email,
          emailLink: link,
        );
        
        // Clear stored email after successful sign-in
        await clearStoredEmail();
        
        return userCredential;
      }
      return null;
    } catch (e) {
      print('Error signing in with email link: $e');
      return null;
    }
  }
  
  // Check if user is signed in
  static bool isSignedIn() {
    return _auth.currentUser != null;
  }
  
  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
  
  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }



//--------------------googlesignin--------------------------

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      // Sign out from previous Google account
      await _googleSignIn.signOut();
      
      // Start Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled by user');
      }
      
      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      
      if (user != null) {
        print("✅ Google sign-in success: ${user.email}");
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Sign In Successful!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        return user;
      } else {
        throw Exception('Firebase sign-in failed');
      }
    } catch (e) {
      print("❌ Google Sign-in Error: $e");
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-in failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      return null;
    }
  }

}