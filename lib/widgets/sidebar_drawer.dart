import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_session.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // YOUR ORIGINAL HEADER with search and profile icons
            _buildHeader(),
            const SizedBox(height: 26),
            
            // New Chat Button
            _buildNewChatButton(context),
            
            const SizedBox(height: 16),
            _buildSectionTitle('Recents'),
            
           
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  if (chatProvider.sessions.isEmpty) {
                    return _buildEmptyHistory();
                  }
                  
                  return ListView.builder(
                    itemCount: chatProvider.sessions.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final session = chatProvider.sessions[index];
                      final isActive = chatProvider.currentSession?.id == session.id;
                      
                      return _buildSessionItem(
                        context: context,
                        session: session,
                        isActive: isActive,
                        onTap: () {
                          chatProvider.switchSession(session.id);
                          Navigator.pop(context);
                        },
                        onLongPress: () {
                          _showDeleteDialog(context, session.id, chatProvider);
                        },
                      );
                    },
                  );
                },
              ),
            ),

            const Spacer(),

            // YOUR ORIGINAL FOOTER
            const Divider(height: 1),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String sessionId, ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text('Are you sure you want to delete this conversation?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              chatProvider.deleteSession(sessionId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // YOUR ORIGINAL HEADER with search and profile
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.school, color: Colors.deepPurple.shade400, size: 32),
          const SizedBox(width: 12),

          Column(
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

          const Spacer(),

          // Search + Profile container (YOUR ORIGINAL)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F1FF),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.deepPurple.shade100, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.search,
                      size: 22,
                      color: Colors.deepPurple.shade400,
                    ),
                  ),
                ),

                const SizedBox(width: 2),

                Container(
                  width: 1,
                  height: 18,
                  color: Colors.deepPurple.shade100,
                ),

                const SizedBox(width: 2),

                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.person_outline,
                      size: 22,
                      color: Colors.deepPurple.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewChatButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        context.read<ChatProvider>().startNewChat();
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity, // Make container take full width
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade400,
              Colors.deepPurple.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'New Chat',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

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
// Session item with long press to delete
Widget _buildSessionItem({
  required BuildContext context,
  required ChatSession session,
  required bool isActive,
  required VoidCallback onTap,
  required VoidCallback onLongPress,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: isActive ? Colors.deepPurple.shade50 : Colors.transparent,
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 16,
              color: isActive ? Colors.deepPurple : Colors.grey.shade500,
            ),
            const SizedBox(width: 12),
            Flexible(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Text(
                        session.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                          color: isActive ? Colors.deepPurple : Colors.grey.shade700,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(session.updatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // YOUR ORIGINAL FOOTER
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 16, color: Colors.deepPurple.shade300),
          const SizedBox(width: 8),
          Text(
            'Powered by AI',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}