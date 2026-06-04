// lib/widgets/sidebar_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header
            _buildHeader(),
            
            const Divider(height: 1),
            
            // Mode Selection Title
            _buildSectionTitle('MODE'),
            
            // Mode Selection Items
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return Column(
                  children: [
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.chat_bubble_outline,
                      title: 'Chat Mode',
                      subtitle: 'Ask questions to AI',
                      isSelected: chatProvider.mode == 'chat',
                      onTap: () {
                        chatProvider.setMode('chat');
                        Navigator.pop(context);
                      },
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.summarize_outlined,
                      title: 'Summarize Mode',
                      subtitle: 'Summarize your notes',
                      isSelected: chatProvider.mode == 'summarize',
                      onTap: () {
                        chatProvider.setMode('summarize');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            ),
            
            const Divider(height: 1),
            
            // History Section
            _buildSectionTitle('HISTORY'),
            
            // Recent Chats
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  if (chatProvider.messages.isEmpty) {
                    return _buildEmptyHistory();
                  }
                  
                  // Get last 5 user messages for history
                  final recentMessages = chatProvider.messages
                      .where((m) => m.isUser)
                      .take(5)
                      .toList();
                  
                  return ListView.builder(
                    itemCount: recentMessages.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final message = recentMessages[index];
                      return _buildHistoryItem(
                        context: context,
                        message: message.content,
                        date: message.timestamp,
                      );
                    },
                  );
                },
              ),
            ),
            
            const Spacer(),
            
            // Footer
            const Divider(height: 1),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // Header with logo and title
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.school,
              color: Colors.deepPurple.shade400,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          Text(
            'AI Study Assistant',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          
          // Subtitle
          Text(
            'Your personal AI tutor',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // Section title (MODE, HISTORY)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // Drawer item (Chat Mode, Summarize Mode)
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepPurple.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.deepPurple : Colors.grey.shade800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Empty history message
  Widget _buildEmptyHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'No chat history yet',
        style: TextStyle(
          color: Colors.grey.shade400,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  // History item
  Widget _buildHistoryItem({
    required BuildContext context,
    required String message,
    required DateTime date,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(
        Icons.chat_bubble_outline,
        size: 18,
        color: Colors.grey.shade400,
      ),
      title: Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade700,
        ),
      ),
      subtitle: Text(
        _formatDate(date),
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade400,
        ),
      ),
      onTap: () {
        // Close drawer when tapping history
        Navigator.pop(context);
      },
    );
  }

  // Footer
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            size: 16,
            color: Colors.deepPurple.shade300,
          ),
          const SizedBox(width: 8),
          Text(
            'Powered by AI',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // Format date helper
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}