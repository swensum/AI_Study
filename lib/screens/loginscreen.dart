// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_assistant/providers/chat_provider.dart';

import 'package:study_assistant/services/auth_services.dart';
import '../widgets/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _linkSent = false;

  // Check for email link when app opens
  @override
  void initState() {
    super.initState();
    _checkForEmailLink();
  }

  Future<void> _checkForEmailLink() async {
    try {
      // Get the link from the current page (if the app was opened via a link)
      final String? link = await _getEmailLink();
      
      if (link != null) {
        // Try to sign in
        final email = await AuthService.getStoredEmail();
        if (email != null && email.isNotEmpty) {
          final userCredential = await AuthService.signInWithEmailLink(email, link);
          if (userCredential != null) {
            // Sign-in successful - navigate to chat
            _showSnackBar('Successfully signed in!', isSuccess: true);
            await _loadAndNavigate();
          }
        }
      }
    } catch (e) {
      print('Error checking email link: $e');
    }
  }

  // This is a placeholder - your actual implementation will depend on how you handle deep links
  Future<String?> _getEmailLink() async {
    // In a real app, this would get the link from:
    // - Android: intent data
    // - iOS: openURL
    // - Web: URL parameters
    
    // For testing, you can manually set a link here
    // return 'https://your-domain.com/finishSignIn?link=...';
    
    return null; // Return null for now
  }

  Future<void> _sendMagicLink() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      _showSnackBar('Please enter your email address');
      return;
    }
    
    if (!email.contains('@') || !email.contains('.')) {
      _showSnackBar('Please enter a valid email address');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      bool success = await AuthService.sendSignInLink(email);
      
      setState(() {
        _isLoading = false;
        _linkSent = success;
      });
      
      if (success) {
        _showSnackBar(
          '✨ Magic link sent to $email! Check your inbox.',
          isSuccess: true,
        );
        _emailController.clear();
      } else {
        _showSnackBar('Failed to send magic link. Please try again.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _loadAndNavigate() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.loadSessionsFromFirestore();
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.primary.withOpacity(0.7)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'AI Study Assistant',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _linkSent ? 'Check your email!' : 'Sign in to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: _linkSent ? colors.primary : colors.subtext,
                    fontWeight: _linkSent ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Email Input
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: colors.text),
                  enabled: !_linkSent, // Disable input when link is sent
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: TextStyle(color: colors.subtext),
                    prefixIcon: Icon(Icons.email_outlined, color: colors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Send Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _linkSent ? _resendLink : _sendMagicLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _linkSent ? Colors.green : colors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _linkSent ? 'Resend Magic Link' : 'Send Magic Link',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? colors.text : Colors.white,
                            ),
                          ),
                  ),
                ),
                
                // Resend timer or status message
                if (_linkSent) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: colors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Magic link sent! Check your email and click the link to sign in.',
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Info Text
                Text(
                  _linkSent 
                    ? "Didn't receive the email? Check spam folder or try again." 
                    : "We'll send you a magic link to sign in instantly.\nNo password needed!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.subtext,
                  ),
                ),
                
                // Test button (for development only)
                if (!_linkSent) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      // For testing: Auto-fill a test email
                      _emailController.text = 'test@example.com';
                    },
                    child: Text(
                      'Fill test email',
                      style: TextStyle(
                        color: colors.subtext,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resendLink() async {
    // If we have a previous email, resend to it
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      
      bool success = await AuthService.sendSignInLink(email);
      
      setState(() {
        _isLoading = false;
      });
      
      if (success) {
        _showSnackBar('Magic link resent to $email!', isSuccess: true);
      } else {
        _showSnackBar('Failed to resend. Please try again.');
      }
    } else {
      setState(() {
        _linkSent = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}