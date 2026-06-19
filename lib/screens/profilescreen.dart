import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_assistant/screens/about.dart';
import 'package:study_assistant/screens/editprofile.dart';
import 'package:study_assistant/services/auth_services.dart';
import 'package:study_assistant/widgets/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _isSigningOut = false;

  // Get current user
  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // Account Settings Section
            _buildSectionTitle('Account Settings'),

            _buildMenuItem(
              icon: Icons.lock_outline,
              title: 'Privacy & Security',
              subtitle: 'Manage your data',
              onTap: () {},
            ),

            // Preferences Section
            _buildSectionTitle('Preferences'),
            _buildSwitchMenuItem(
              icon: Icons.notifications_none,
              title: 'Notifications',
              subtitle: 'Get alerts for replies',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildDarkModeSwitch(themeProvider),

            // Support Section
            _buildSectionTitle('Support'),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help Center',
              subtitle: 'FAQs and guides',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              subtitle: 'Help us improve',
              onTap: () {
                _showFeedbackDialog(context);
              },
            ),
            _buildMenuItem(
              icon: Icons.star_outline,
              title: 'Rate Us',
              subtitle: 'Rate on App Store',
              onTap: () {},
            ),
           _buildMenuItem(
  icon: Icons.info_outline,
  title: 'About',
  subtitle: 'Version 1.0.0',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutPage()),
    );
  },
),

            const SizedBox(height: 24),
            // Sign Out Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _isSigningOut ? null : _signOut,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? colors.card
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode
                          ? colors.border
                          : Colors.red.shade200,
                    ),
                  ),
                  child: _isSigningOut
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout,
                              size: 20,
                              color: isDarkMode ? colors.text : Colors.red.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? colors.text : Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;

    // Get user info
    final user = _currentUser;
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? 'No email';

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.transparent,
              child: user?.photoURL != null
                  ? ClipOval(
                      child: Image.network(
                        user!.photoURL!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person, size: 50, color: Colors.white);
                        },
                      ),
                    )
                  : Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            displayName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.text,
            ),
          ),

          // Email
          if (email != 'No email') ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(
                fontSize: 14,
                color: colors.subtext,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Edit Profile Button
         Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? colors.card : colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkMode
                  ? colors.border
                  : colors.primary.withOpacity(0.3),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              // Show Edit Profile Bottom Sheet
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const EditProfileBottomSheet(),
              ).then((result) {
                // Refresh the profile screen if changes were saved
                if (result != null && mounted) {
                  setState(() {});
                }
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit, 
                  size: 16, 
                  color: isDarkMode ? Colors.white : colors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildSectionTitle(String title) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.subtext,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode ? colors.card : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isDarkMode ? Colors.white : colors.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.text,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: colors.subtext),
      ),
      trailing: Icon(Icons.chevron_right, color: colors.hint),
      onTap: onTap,
    );
  }

  Widget _buildSwitchMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode ? colors.card : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isDarkMode ? Colors.white : colors.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.text,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: colors.subtext),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: isDarkMode ? Colors.grey.shade400 : colors.primary,
        activeTrackColor: isDarkMode ? Colors.grey.shade700 : null,
        inactiveThumbColor: isDarkMode ? Colors.grey.shade400 : null,
        inactiveTrackColor: isDarkMode ? Colors.grey.shade800 : null,
      ),
    );
  }

  Widget _buildDarkModeSwitch(ThemeProvider themeProvider) {
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode ? colors.card : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.dark_mode_outlined, 
          size: 22, 
          color: isDarkMode ? Colors.white : colors.primary,
        ),
      ),
      title: Text(
        'Dark Mode',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.text,
        ),
      ),
      subtitle: Text(
        'Switch theme appearance',
        style: TextStyle(
          fontSize: 13,
          color: colors.subtext,
        ),
      ),
      trailing: Switch(
        value: isDarkMode,
        onChanged: (value) {
          themeProvider.toggleTheme();
        },
        activeThumbColor: isDarkMode ? Colors.grey.shade400 : colors.primary,
        activeTrackColor: isDarkMode ? Colors.grey.shade700 : null,
        inactiveThumbColor: isDarkMode ? Colors.grey.shade400 : null,
        inactiveTrackColor: isDarkMode ? Colors.grey.shade800 : null,
      ),
    );
  }

  // ==================== SIGN OUT METHOD ====================
  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final colors = themeProvider.colors;

        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text('Sign Out', style: TextStyle(color: colors.text)),
          content: Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: colors.subtext),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: colors.subtext)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true) return;

    // Start sign out process
    setState(() {
      _isSigningOut = true;
    });

    try {
      // Sign out using AuthService
      await AuthService.signOut();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
         Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });
      }
    }
  }
  // ========================================================

  void _showFeedbackDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text('Send Feedback', style: TextStyle(color: colors.text)),
        content: TextField(
          maxLines: 5,
          style: TextStyle(color: colors.text),
          decoration: InputDecoration(
            hintText: 'Share your feedback...',
            hintStyle: TextStyle(color: colors.hint),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.border),
            ),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.subtext)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your feedback!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

}