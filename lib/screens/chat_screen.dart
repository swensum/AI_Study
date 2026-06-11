// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_assistant/widgets/theme.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../widgets/sidebar_drawer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      key: _scaffoldKey,
      drawer: const SidebarDrawer(),
      body: Stack(
        children: [
          _buildChatArea(),

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

          // Floating delete button (top right)
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
                  color: themeProvider.getSurfaceColor(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  items: [
                    PopupMenuItem(
                      value: 'new_chat',
                      child: Row(
                        children: [
                          Icon(Icons.add, color:themeProvider.getTextColor(context)),
                          const SizedBox(width: 12),
                          Text(
                            'New Chat',
                            style:TextStyle(color: themeProvider.getTextColor(context)),
                          ),
                        ],
                      ),
                    ),
                     PopupMenuItem(
                      value: 'clear_chat',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color:themeProvider.getTextColor(context)),
                          SizedBox(width: 12),
                          Text(
                            'Clear Chat',
                            style: TextStyle(color: themeProvider.getTextColor(context)),
                          ),
                        ],
                      ),
                    ),
                     PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings_outlined, color: themeProvider.getTextColor(context)),
                          SizedBox(width: 12),
                          Text(
                            'Settings',
                            style: TextStyle(color: themeProvider.getTextColor(context)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                switch (result) {
                  case 'new_chat':
                    // Create new session
                    context.read<ChatProvider>().startNewChat();
                    break;

                  case 'clear_chat':
                    // Clear current chat messages
                    context.read<ChatProvider>().clearChat();
                    break;

                  case 'settings':
                    // Settings not implemented yet
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

          // Floating input area (bottom)
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
    return Material(
      color: Theme.of(context).primaryColor, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
        side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: themeProvider.getSurfaceColor(context)),
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    final themeProvider = Provider.of<ThemeProvider>(context);
  final isDarkMode = themeProvider.isDarkMode;
  
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.messages.isEmpty) {
          return _buildEmptyState();
        }

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

  // Empty state
  Widget _buildEmptyState() {
     final themeProvider = Provider.of<ThemeProvider>(context);
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
                  color: Colors.deepPurple.withOpacity(0.3),
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
              color: themeProvider.getTextColor(context),
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
                color: themeProvider.getSubtextColor(context),
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 32),

          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildModeChip(
                    icon: Icons.chat_bubble_outline,
                    label: 'Chat',
                    isActive: chatProvider.mode == 'chat',
                  ),
                  const SizedBox(width: 12),
                  _buildModeChip(
                    icon: Icons.summarize_outlined,
                    label: 'Summarize',
                    isActive: chatProvider.mode == 'summarize',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
  final isDarkMode = themeProvider.isDarkMode;
  
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
      color: isActive
            ? Colors.deepPurple.withOpacity(0.1)
            : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
         color: isActive
              ? Colors.deepPurple.shade200
              : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
           color: isActive ? Colors.deepPurple : themeProvider.getSubtextColor(context),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.deepPurple : themeProvider.getSubtextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingInput() {
     final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Row(
      children: [
        Expanded(
          child: Material(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              decoration: BoxDecoration(
               color: themeProvider.getSurfaceColor(context).withOpacity(0.95),
                borderRadius: BorderRadius.circular(28),
                border: Border.all( color: themeProvider.getBorderColor(context), width: 1),
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                 style: TextStyle(
                  fontSize: 15,
                  color: themeProvider.getTextColor(context),
                ),
                decoration: InputDecoration(
                  hintText: context.watch<ChatProvider>().mode == 'summarize'
                      ? 'Paste text to summarize...'
                      : 'Ask anything...',
                  hintStyle: TextStyle(color: themeProvider.getHintColor(context)),
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
          color: themeProvider.getSurfaceColor(context).withOpacity(0.95),
          elevation: 4,
          borderRadius: BorderRadius.circular(14),
          shadowColor: Colors.black.withOpacity(0.1),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.deepPurple.shade200,
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade400,
                    Colors.deepPurple.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
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
    final isDarkMode = themeProvider.isDarkMode;

    if (!isUser) {
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
                          Colors.deepPurple.shade300,
                          Colors.deepPurple.shade500,
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
                      color: themeProvider.getSubtextColor(context),
                    ),
                  ),
                ],
              ),
            ),

            // Summary badge
            if (message.isSummary)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                 color: isDarkMode ? Colors.orange.withOpacity(0.2) : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isDarkMode ? Colors.orange.withOpacity(0.5) : Colors.orange.shade200,
                 width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.summarize,
                      size: 14,
                     color: isDarkMode ? Colors.orange.shade300 : Colors.orange.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 12,
                       color: isDarkMode ? Colors.orange.shade300 : Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // Rich text with bold formatting only
            _buildRichText(context, message.content),

            // Timestamp
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 11,
                  color: themeProvider.getSubtextColor(context),
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
                  ? Colors.deepPurple.withOpacity(0.3)
                  : Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(
                20,
              ).copyWith(bottomRight: Radius.zero),
            ),
            child: SelectableText(
              message.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
               color: themeProvider.getTextColor(context),
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
               color: themeProvider.getSubtextColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  
    Widget _buildRichText(BuildContext context, String text) {
      final themeProvider = Provider.of<ThemeProvider>(context);
    
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
              color: themeProvider.getTextColor(context),
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
             color: themeProvider.getTextColor(context),
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
            color: themeProvider.getTextColor(context),
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
        color: themeProvider.getTextColor(context),
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
                        Colors.deepPurple.shade300,
                        Colors.deepPurple.shade500,
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
                     color: themeProvider.getSubtextColor(context),
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
                  color: Colors.deepPurple.shade300,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Thinking...',
                style: TextStyle(color: themeProvider.getSubtextColor(context), fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
