// lib/screens/login_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _isGoogleLoading = false;

  // Create an instance of AuthService
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkForEmailLink();
  }

  Future<void> _checkForEmailLink() async {
    try {
      final String? link = await _getEmailLink();

      if (link != null) {
        final email = await AuthService.getStoredEmail();
        if (email != null && email.isNotEmpty) {
          final userCredential = await AuthService.signInWithEmailLink(
            email,
            link,
          );
          if (userCredential != null) {
            _showSnackBar('Successfully signed in!', isSuccess: true);
            await _loadAndNavigate();
          }
        }
      }
    } catch (e) {
      print('Error checking email link: $e');
    }
  }

  Future<String?> _getEmailLink() async {
    return null;
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

  Future<void> _signInWithGoogle() async {
    if (_isGoogleLoading) return;

    setState(() => _isGoogleLoading = true);

    try {
      // Use the instance method
      User? user = await _authService.signInWithGoogle(context);

      if (user != null && mounted) {
        // Navigate to chat screen
        await _loadAndNavigate();
      }
    } catch (e) {
      // Error is already handled in AuthService
      // Just log it if needed
      print('Google Sign-In error: $e');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  // In LoginScreen, after successful sign in:
  Future<void> _loadAndNavigate() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.loadSessionsFromFirestore();

    if (mounted) {
      Navigator.pop(context, true);
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
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: Colors.white,
                  ),
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
                  enabled: !_linkSent,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: TextStyle(color: colors.subtext),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: colors.primary,
                    ),
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

                // Send Magic Link Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _linkSent ? _resendLink : _sendMagicLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _linkSent
                          ? Colors.green
                          : colors.primary,
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

                // Divider with OR text
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(color: colors.border, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: colors.subtext,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: colors.border, thickness: 1),
                      ),
                    ],
                  ),
                ),

                // Google Sign-In Button
                SizedBox(
  width: double.infinity,
  child: OutlinedButton(
    onPressed: _isGoogleLoading ? null : _signInWithGoogle,
    style: OutlinedButton.styleFrom(
      foregroundColor: colors.text,
      side: BorderSide(
        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
        width: 1.5,
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
    ),
    child: _isGoogleLoading
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Signing in...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google Icon in Circle Container
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.blue.shade700,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
            ],
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
                        Icon(
                          Icons.check_circle,
                          color: colors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Magic link sent! Check your email and click the link to sign in.',
                            style: TextStyle(color: colors.text, fontSize: 13),
                          ),
                        ),
                      ],
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
