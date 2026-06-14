import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_assistant/screens/loginscreen.dart';
import 'package:study_assistant/screens/profilescreen.dart';
import 'package:study_assistant/services/auth_services.dart';
import '../providers/chat_provider.dart';
import '../models/chat_session.dart';

import '../widgets/theme.dart';

class SidebarDrawer extends StatefulWidget {
  const SidebarDrawer({super.key});

  @override
  State<SidebarDrawer> createState() => _SidebarDrawerState();
}

class _SidebarDrawerState extends State<SidebarDrawer> {
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() async {
    final auth = AuthService();
    auth.user.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;
    
    return Drawer(
      width: MediaQuery.of(context).size.width,
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER with conditional search and profile icons
            _buildHeader(),
            const SizedBox(height: 26),
            
            // New Chat Button
            _buildNewChatButton(context),
            
            const SizedBox(height: 16),
            
            // Search Bar (visible when searching and logged in)
            if (_isSearching && _currentUser != null)
              _buildSearchBar(),
            
            _buildSectionTitle('Recents'),
            
            Expanded(
              child: _currentUser != null
                  ? Consumer<ChatProvider>(
                      builder: (context, chatProvider, child) {
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
                    )
                  : _buildEmptyHistory(false),
            ),

            const Spacer(),

            Divider(
              height: 1,
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade400,
            ),
            
            // Footer - shows login button when not logged in
            _currentUser != null ? _buildFooter() : _buildLoginFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? colors.card : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDarkMode ? colors.border : colors.primary.withOpacity(0.3)),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          autofocus: true,
          style: TextStyle(color: colors.text),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: TextStyle(color: colors.hint),
            prefixIcon: Icon(Icons.search, size: 20, color: colors.primary),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close, size: 20, color: colors.hint),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.close, size: 20, color: colors.subtext),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Chat', style: TextStyle(color: colors.text)),
        content: Text('Are you sure you want to delete this conversation?', style: TextStyle(color: colors.subtext)),
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.school, color: colors.primary, size: 32),
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
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser?.email ?? 'Your personal AI tutor',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.subtext,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Only show search and profile icons when logged in
          if (_currentUser != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              decoration: BoxDecoration(
                color: isDarkMode ? colors.card : const Color(0xFFF4F1FF),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: isDarkMode ? colors.border : colors.primary.withOpacity(0.3), width: 1),
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
                        color: isDarkMode ? Colors.white : colors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(width: 2),

                  Container(
                    width: 1,
                    height: 18,
                    color: isDarkMode ? Colors.grey.shade600 : colors.primary.withOpacity(0.3),
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
                        color: isDarkMode ? Colors.white : colors.primary,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;
    
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
            gradient: isDarkMode
                ? null
                : LinearGradient(
                    colors: [
                      colors.primary,
                      colors.primary.withOpacity(0.8),
                    ],
                  ),
            color: isDarkMode ? Colors.grey.shade800 : null,
            borderRadius: BorderRadius.circular(12),
            border: isDarkMode 
                ? Border.all(color: Colors.grey.shade700, width: 1)
                : null,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.subtext,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildEmptyHistory(bool isSearching) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.chat_bubble_outline,
              size: 48,
              color: colors.hint,
            ),
            const SizedBox(height: 12),
            Text(
              isSearching ? 'No matching conversations' : 
              (_currentUser != null ? 'No chat history yet' : 'Sign in to see your chat history'),
              style: TextStyle(
                color: colors.hint,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isActive 
            ? (isDarkMode ? colors.card : colors.primary.withOpacity(0.1))
            : Colors.transparent,
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
                color: isActive 
                    ? (isDarkMode ? Colors.white : colors.primary)
                    : colors.subtext,
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
                              color: isActive 
                                  ? (isDarkMode ? Colors.white : colors.primary)
                                  : colors.text,
                            ),
                          );
                        }
                        
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
                                color: isActive 
                                    ? (isDarkMode ? Colors.white : colors.primary)
                                    : colors.text,
                              ),
                            ));
                          }
                          
                          spans.add(TextSpan(
                            text: title.substring(index, index + query.length),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                              backgroundColor: isDarkMode 
                                  ? colors.primary.withOpacity(0.3)
                                  : colors.primary.withOpacity(0.1),
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
                              color: isActive 
                                  ? (isDarkMode ? Colors.white : colors.primary)
                                  : colors.text,
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
                        color: colors.subtext,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 16, color: colors.primary),
          const SizedBox(width: 8),
          Text(
            'Powered by AI',
            style: TextStyle(fontSize: 12, color: colors.subtext),
          ),
        ],
      ),
    );
  }

  // Login button at the bottom like ChatGPT
  Widget _buildLoginFooter() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? colors.card : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? colors.border : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login_outlined,
                    size: 18,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'or Sign up',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colors.subtext,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 14, color: colors.primary.withOpacity(0.7)),
              const SizedBox(width: 6),
              Text(
                'Save your conversations',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.subtext,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}