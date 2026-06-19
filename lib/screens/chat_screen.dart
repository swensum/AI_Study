// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/theme.dart'; // Your ThemeProvider

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Get current user
  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final chatProvider = context.watch<ChatProvider>();
    final hasMessages = chatProvider.messages.isNotEmpty;
    final isLoggedIn = _currentUser != null;
    
    return Scaffold(
      backgroundColor: colors.background,
      key: _scaffoldKey,
      drawer: const SidebarDrawer(),
      body: Stack(
        children: [
          _buildChatArea(),

          // Top left menu button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: _buildFloatingButton(
              icon: Icons.menu,
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),

          // Top right menu button - ONLY show when there are messages AND user is logged in
          if (hasMessages && isLoggedIn)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: _buildFloatingButton(
                icon: Icons.more_vert,
                onTap: () async {
                  final result = await showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).padding.top + 60,
                      16,
                      0,
                    ),
                    color: colors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    items: [
                      PopupMenuItem(
                        value: 'new_chat',
                        child: Row(
                          children: [
                            Icon(Icons.add, color: colors.text),
                            const SizedBox(width: 12),
                            Text(
                              'New Chat',
                              style: TextStyle(color: colors.text),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'clear_chat',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: colors.text),
                            const SizedBox(width: 12),
                            Text(
                              'Clear Chat',
                              style: TextStyle(color: colors.text),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'settings',
                        child: Row(
                          children: [
                            Icon(Icons.settings_outlined, color: colors.text),
                            const SizedBox(width: 12),
                            Text(
                              'Settings',
                              style: TextStyle(color: colors.text),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  switch (result) {
                    case 'new_chat':
                      chatProvider.startNewChat();
                      break;

                    case 'clear_chat':
                      chatProvider.clearChat();
                      break;

                    case 'settings':
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      break;
                  }
                },
              ),
            ),

          // Floating input area (bottom) - Only show if logged in
          if (isLoggedIn)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 8,
              left: 16,
              right: 16,
              child: _buildFloatingInput(),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;
    
    return Material(
      color: isDarkMode ? colors.surface : colors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
        side: BorderSide(
          color: isDarkMode ? colors.border : colors.primary.withOpacity(0.5), 
          width: 2
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon, 
            color: isDarkMode ? colors.text : colors.surface,
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final isLoggedIn = _currentUser != null;
    
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        // If not logged in, show login prompt
        if (!isLoggedIn) {
          return _buildLoginPrompt();
        }

        // If logged in but no messages, show empty state
        if (chatProvider.messages.isEmpty) {
          return _buildEmptyState();
        }

        // Show messages
        return ShaderMask(
          shaderCallback: (Rect rect) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                ? const [Colors.transparent, Colors.black, Colors.black]
                : const [Colors.transparent, Colors.white, Colors.white],
              stops: const [0.0, 0.12, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstIn,
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 70,
              bottom: 100,
              left: 20,
              right: 20,
            ),
            itemCount:
                chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == chatProvider.messages.length) {
                return const _LoadingBubble();
              }
              return _MessageBubble(message: chatProvider.messages[index]);
            },
          ),
        );
      },
    );
  }

  // Login prompt when user is not authenticated
  Widget _buildLoginPrompt() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 60,
        bottom: 120,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade300,
                  Colors.deepPurple.shade500,
                ],
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
            child: const Icon(
              Icons.lock_outline,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'Welcome to AI Study Assistant',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: colors.text,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Please sign in to start chatting with your AI tutor',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: colors.subtext,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Login Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to login screen
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: colors.primary.withOpacity(0.3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.login, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  // Empty state for logged-in users with no messages
  Widget _buildEmptyState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final chatProvider = context.watch<ChatProvider>();
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 60,
        bottom: 120,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade300,
                  Colors.deepPurple.shade500,
                ],
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
            child: const Icon(
              Icons.auto_awesome,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'How can I help you study?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: colors.text,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Ask questions about any topic or paste notes to summarize',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: colors.subtext,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModeChip(
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                isActive: chatProvider.mode == 'chat',
                onTap: () => chatProvider.setMode('chat'),
              ),
              const SizedBox(width: 12),
              _buildModeChip(
                icon: Icons.summarize_outlined,
                label: 'Summarize',
                isActive: chatProvider.mode == 'summarize',
                onTap: () => chatProvider.setMode('summarize'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? (isDarkMode ? Colors.grey.shade700 : colors.primary.withOpacity(0.2))
              : (isDarkMode ? colors.card : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? (isDarkMode ? Colors.grey.shade500 : colors.primary)
                : (isDarkMode ? colors.border : Colors.grey.shade300),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? (isDarkMode ? Colors.white : colors.primary)
                  : colors.subtext,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? (isDarkMode ? Colors.white : colors.primary)
                    : colors.subtext,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingInput() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;
    final chatProvider = context.watch<ChatProvider>();
    
    return Row(
      children: [
        Expanded(
          child: Material(
            elevation: 4,
            shadowColor: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                style: TextStyle(
                  fontSize: 15,
                  color: colors.text,
                ),
                cursorColor: isDarkMode ? Colors.white : colors.primary,
                decoration: InputDecoration(
                  hintText: chatProvider.mode == 'summarize'
                      ? 'Paste text to summarize...'
                      : 'Ask anything...',
                  hintStyle: TextStyle(color: colors.hint),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                maxLines: 4,
                minLines: 1,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        Material(
          color: isDarkMode ? colors.surface : colors.primary,
          elevation: 4,
          borderRadius: BorderRadius.circular(14),
          shadowColor: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDarkMode ? colors.border : colors.primary.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.send_rounded,
                color: isDarkMode ? colors.text : Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      context.read<ChatProvider>().sendMessage(_controller.text.trim());
      _controller.clear();

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }
}

// Message bubble widget
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;

    if (!isUser) {
      // AI MESSAGE
      return Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI label with icon
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.primary,
                          colors.primary.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Assistant',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.subtext,
                    ),
                  ),
                ],
              ),
            ),

            // Rich text with bold formatting only
            _buildRichText(context, message.content, colors),

            // Timestamp
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.subtext,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // User messages - simple bubble, no label
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // User message bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.grey.shade800  
                  : colors.primary.withOpacity(0.1), 
              borderRadius: BorderRadius.circular(
                20,
              ).copyWith(bottomRight: Radius.zero),
            ),
            child: SelectableText(
              message.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: colors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 4),
            child: Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 11,
                color: colors.subtext,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichText(BuildContext context, String text, AppColors colors) {
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    Iterable<RegExpMatch> matches = exp.allMatches(text);

    int lastEnd = 0;

    for (RegExpMatch match in matches) {
      // Add text before this match
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: colors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }

      // Add bold text
      String matchText = match.group(1)!;
      spans.add(
        TextSpan(
          text: matchText,
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: colors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastEnd),
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: colors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // If no bold formatting found, return normal text
    if (spans.isEmpty) {
      return SelectableText(
        text,
        style: TextStyle(
          fontSize: 15,
          height: 1.6,
          color: colors.text,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return SelectableText.rich(TextSpan(children: spans));
  }
}

// Loading bubble widget
class _LoadingBubble extends StatelessWidget {
  const _LoadingBubble();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI label
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary,
                        colors.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.subtext,
                  ),
                ),
              ],
            ),
          ),

          // Loading animation
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Thinking...',
                style: TextStyle(color: colors.subtext, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}