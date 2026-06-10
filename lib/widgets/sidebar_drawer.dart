import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_assistant/screens/profilescreen.dart';
import '../providers/chat_provider.dart';
import '../models/chat_session.dart';

class SidebarDrawer extends StatefulWidget {
  const SidebarDrawer({super.key});

  @override
  State<SidebarDrawer> createState() => _SidebarDrawerState();
}

class _SidebarDrawerState extends State<SidebarDrawer> {
  String _searchQuery = '';
  bool _isSearching = false; // Add this flag
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER with search and profile icons
            _buildHeader(),
            const SizedBox(height: 26),
            
            // New Chat Button
            _buildNewChatButton(context),
            
            const SizedBox(height: 16),
            
            // Search Bar (visible when searching)
            if (_isSearching)
              _buildSearchBar(),
            
            _buildSectionTitle('Recents'),
            
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  // Filter sessions based on search query
                  final filteredSessions = _searchQuery.isEmpty
                      ? chatProvider.sessions
                      : chatProvider.sessions.where((session) =>
                          session.title
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase())).toList();
                  
                  if (filteredSessions.isEmpty) {
                    return _buildEmptyHistory(_searchQuery.isNotEmpty);
                  }
                  
                  return ListView.builder(
                    itemCount: filteredSessions.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final session = filteredSessions[index];
                      final isActive = chatProvider.currentSession?.id == session.id;
                      
                      return _buildSessionItem(
                        context: context,
                        session: session,
                        isActive: isActive,
                        searchQuery: _searchQuery,
                        onTap: () {
                          // Clear search when selecting a session
                          setState(() {
                            _isSearching = false;
                            _searchQuery = '';
                            _searchController.clear();
                            _searchFocusNode.unfocus();
                          });
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

            const Divider(height: 1),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.deepPurple.shade100),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          autofocus: true,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.search, size: 20, color: Colors.deepPurple.shade400),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close, size: 20, color: Colors.grey.shade400),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.close, size: 20, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchQuery = '';
                        _searchController.clear();
                        _searchFocusNode.unfocus();
                      });
                    },
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
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
                  onTap: () {
                    setState(() {
                      _isSearching = true;
                      _searchFocusNode.requestFocus();
                    });
                  },
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
                  onTap: () {
                     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
                  },
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
          setState(() {
            _isSearching = false;
            _searchQuery = '';
            _searchController.clear();
            _searchFocusNode.unfocus();
          });
          context.read<ChatProvider>().startNewChat();
          Navigator.pop(context);
        },
        child: Container(
          width: double.infinity,
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

  Widget _buildEmptyHistory(bool isSearching) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.chat_bubble_outline,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              isSearching ? 'No matching conversations' : 'No chat history yet',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem({
    required BuildContext context,
    required ChatSession session,
    required bool isActive,
    required String searchQuery,
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
                        if (searchQuery.isEmpty) {
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
                        }
                        
                        // Highlight matching text
                        final title = session.title;
                        final query = searchQuery.toLowerCase();
                        final titleLower = title.toLowerCase();
                        
                        List<TextSpan> spans = [];
                        int lastMatch = 0;
                        
                        while (true) {
                          int index = titleLower.indexOf(query, lastMatch);
                          if (index == -1) break;
                          
                          if (index > lastMatch) {
                            spans.add(TextSpan(
                              text: title.substring(lastMatch, index),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                color: isActive ? Colors.deepPurple : Colors.grey.shade700,
                              ),
                            ));
                          }
                          
                          spans.add(TextSpan(
                            text: title.substring(index, index + query.length),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.deepPurple,
                              backgroundColor: Colors.deepPurple.shade50,
                            ),
                          ));
                          
                          lastMatch = index + query.length;
                        }
                        
                        if (lastMatch < title.length) {
                          spans.add(TextSpan(
                            text: title.substring(lastMatch),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive ? Colors.deepPurple : Colors.grey.shade700,
                            ),
                          ));
                        }
                        
                        return Text.rich(
                          TextSpan(children: spans),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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