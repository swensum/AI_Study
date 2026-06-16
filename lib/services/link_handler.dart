// lib/services/link_handler.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:study_assistant/services/auth_services.dart';

class LinkHandler {
  static Future<void> handleLink(BuildContext context, String link) async {
    try {
      // Check if it's an email sign-in link
      if (FirebaseAuth.instance.isSignInWithEmailLink(link)) {
        // Get stored email
        final email = await AuthService.getStoredEmail();
        
        if (email != null && email.isNotEmpty) {
          // Complete sign-in
          final userCredential = await AuthService.signInWithEmailLink(email, link);
          
          if (userCredential != null) {
            // Navigate to home screen
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Successfully signed in!'),
                  backgroundColor: Colors.green,
                ),
              );
              
              // Navigate to chat
              Navigator.of(context).pushReplacementNamed('/chat');
            }
          }
        }
      }
    } catch (e) {
      print('Error handling link: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}