// lib/widgets/sidebar_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width, // Full width like ChatGPT
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header
            _buildHeader(),
            _buildSectionTitle('Recents'),
            
            // Recent Chats
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  if (chatProvider.messages.isEmpty) {
                    return _buildEmptyHistory();
                  }
                  
                  // Get last 10 user messages for history
                  final recentMessages = chatProvider.messages
                      .where((m) => m.isUser)
                      .take(10)
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
    child: Row(
      children: [
        Icon(
          Icons.school,
          color: Colors.deepPurple.shade400,
          size: 32,
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                'Your personal AI tutor',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Search Button
        _buildHeaderIcon(
          icon: Icons.search,
          onTap: () {
            // Search action
          },
        ),

        const SizedBox(width: 8),

        // Profile Button
        _buildHeaderIcon(
          icon: Icons.person_outline,
          onTap: () {
            // Profile action
          },
        ),
      ],
    ),
  );
}
 Widget _buildHeaderIcon({
  required IconData icon,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Icon(
        icon,
        size: 20,
        color: Colors.grey.shade800,
      ),
    ),
  );
}


  // Section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
          letterSpacing: 1,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child:  InkWell(
  borderRadius: BorderRadius.circular(10),
  onTap: () {
    Navigator.pop(context);
  },
  child: Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    child: Text(
      message,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade800,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),
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
  
}