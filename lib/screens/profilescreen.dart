import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
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
            
            // Stats Cards
           
            
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
            _buildSwitchMenuItem(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Switch theme appearance',
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
            ),
            _buildDropdownMenuItem(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'Choose your preferred language',
              value: _selectedLanguage,
              items: ['English', 'Spanish', 'French', 'German', 'Hindi'],
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value;
                });
              },
            ),
            
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
                _showAboutDialog(context);
              },
            ),
            
            const SizedBox(height: 24),
            
            // Sign Out Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _showSignOutDialog(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade600,
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
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade400,
                  Colors.deepPurple.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Name
          Text(
            'Alex Johnson',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          
          
          const SizedBox(height: 12),
          
          // Edit Profile Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.deepPurple.shade200),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 16, color: Colors.deepPurple),
                  const SizedBox(width: 6),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
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
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 22, color: Colors.deepPurple.shade600),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
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
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 22, color: Colors.deepPurple.shade600),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade500,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildDropdownMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 22, color: Colors.deepPurple.shade600),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade500,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.deepPurple.shade400),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: TextField(
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Share your feedback...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
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
              backgroundColor: Colors.deepPurple,
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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 48, color: Colors.deepPurple),
            const SizedBox(height: 12),
            Text(
              'AI Study Assistant',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Text(
              'Your personal AI tutor powered by advanced language models. Get instant answers, summarize text, and enhance your learning experience.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () {
              // Add sign out logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Signed out successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}