// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_assistant/screens/loginscreen.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Get safe area padding
          final safePadding = MediaQuery.of(context).padding;
          final screenWidth = constraints.maxWidth;
          
          // Calculate responsive sizes
          final topPadding = safePadding.top + 8;
          final bottomPadding = safePadding.bottom + 8;
          final horizontalPadding = screenWidth * 0.04; // 4% of screen width
          final buttonSize = screenWidth < 380 ? 40.0 : 44.0;
          final iconSize = screenWidth < 380 ? 18.0 : 22.0;
          final fontSize = screenWidth < 380 ? 12.0 : 14.0;
          
          return Stack(
            children: [
              _buildChatArea(constraints, safePadding),

              // Top left menu button
              Positioned(
                top: topPadding,
                left: horizontalPadding,
                child: _buildFloatingButton(
                  icon: Icons.menu,
                  iconSize: iconSize,
                  buttonSize: buttonSize,
                  onTap: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),

              // Top right button
              Positioned(
                top: topPadding,
                right: horizontalPadding,
                child: isLoggedIn
                    ? (hasMessages
                        ? _buildFloatingButton(
                            icon: Icons.more_vert,
                            iconSize: iconSize,
                            buttonSize: buttonSize,
                            onTap: () async {
                              final result = await showMenu(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                  screenWidth,
                                  topPadding + 50,
                                  horizontalPadding,
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
                                        Icon(Icons.add, color: colors.text, size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          'New Chat',
                                          style: TextStyle(
                                            color: colors.text,
                                            fontSize: fontSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'clear_chat',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline, color: colors.text, size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Clear Chat',
                                          style: TextStyle(
                                            color: colors.text,
                                            fontSize: fontSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'settings',
                                    child: Row(
                                      children: [
                                        Icon(Icons.settings_outlined, color: colors.text, size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Settings',
                                          style: TextStyle(
                                            color: colors.text,
                                            fontSize: fontSize,
                                          ),
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
                          )
                        : const SizedBox.shrink())
                    : _buildLoginButton(
                        fontSize: fontSize,
                        buttonSize: buttonSize,
                      ),
              ),

              // Floating input area - Always visible
              Positioned(
                bottom: bottomPadding,
                left: horizontalPadding,
                right: horizontalPadding,
                child: _buildFloatingInput(
                  screenWidth: screenWidth,
                  fontSize: fontSize,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onTap,
    required double iconSize,
    required double buttonSize,
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
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(buttonSize * 0.25),
          child: Icon(
            icon, 
            color: isDarkMode ? colors.text : colors.surface,
            size: iconSize,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required double fontSize,
    required double buttonSize,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;

    return Material(
      color: isDarkMode ? Colors.white : colors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
        side: BorderSide(
          color: isDarkMode ? Colors.grey.shade300 : colors.primary.withOpacity(0.5), 
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: buttonSize * 0.4,
            vertical: buttonSize * 0.25,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.login,
                color: isDarkMode ? Colors.black : Colors.white,
                size: fontSize + 4,
              ),
              SizedBox(width: fontSize * 0.4),
              Text(
                'Log In',
                style: TextStyle(
                  color: isDarkMode ? Colors.black : Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea(BoxConstraints constraints, EdgeInsets padding) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.messages.isEmpty) {
          return _buildEmptyState(constraints, padding);
        }

        final topOffset = padding.top + 70.0;
        final bottomOffset = 100.0;

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
              top: topOffset,
              bottom: bottomOffset,
              left: constraints.maxWidth * 0.04,
              right: constraints.maxWidth * 0.04,
            ),
            itemCount:
                chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == chatProvider.messages.length) {
                return const _LoadingBubble();
              }
              return _MessageBubble(
                message: chatProvider.messages[index],
                maxWidth: constraints.maxWidth * 0.85,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BoxConstraints constraints, EdgeInsets padding) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final chatProvider = context.watch<ChatProvider>();
    
    final topPadding = padding.top + 60;
    final bottomPadding = 120.0;
    final iconSize = constraints.maxWidth < 380 ? 36.0 : 48.0;
    final titleSize = constraints.maxWidth < 380 ? 20.0 : 24.0;
    final subtitleSize = constraints.maxWidth < 380 ? 13.0 : 15.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: bottomPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(constraints.maxWidth < 380 ? 18 : 24),
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
            child: Icon(
              Icons.auto_awesome,
              size: iconSize,
              color: Colors.white,
            ),
          ),
          SizedBox(height: constraints.maxWidth < 380 ? 24 : 32),

          Text(
            'How can I help you study?',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              color: colors.text,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: constraints.maxWidth < 380 ? 8 : 12),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth * 0.08,
            ),
            child: Text(
              'Ask questions about any topic or paste notes to summarize',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: subtitleSize,
                color: colors.subtext,
                height: 1.5,
              ),
            ),
          ),

          SizedBox(height: constraints.maxWidth < 380 ? 24 : 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModeChip(
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                isActive: chatProvider.mode == 'chat',
                screenWidth: constraints.maxWidth,
                onTap: () => chatProvider.setMode('chat'),
              ),
              SizedBox(width: constraints.maxWidth < 380 ? 8 : 12),
              _buildModeChip(
                icon: Icons.summarize_outlined,
                label: 'Summarize',
                isActive: chatProvider.mode == 'summarize',
                screenWidth: constraints.maxWidth,
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
    required double screenWidth,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;
    
    final chipPadding = screenWidth < 380 ? 12.0 : 16.0;
    final iconSize = screenWidth < 380 ? 14.0 : 16.0;
    final fontSize = screenWidth < 380 ? 12.0 : 13.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: chipPadding,
          vertical: chipPadding * 0.5,
        ),
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
              size: iconSize,
              color: isActive
                  ? (isDarkMode ? Colors.white : colors.primary)
                  : colors.subtext,
            ),
            SizedBox(width: iconSize * 0.4),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
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

  Widget _buildFloatingInput({
    required double screenWidth,
    required double fontSize,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;
    final chatProvider = context.watch<ChatProvider>();
    
    final inputPadding = screenWidth < 380 ? 12.0 : 14.0;
    final iconSize = screenWidth < 380 ? 18.0 : 22.0;
    
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
                  fontSize: fontSize,
                  color: colors.text,
                ),
                cursorColor: isDarkMode ? Colors.white : colors.primary,
                decoration: InputDecoration(
                  hintText: chatProvider.mode == 'summarize'
                      ? 'Paste text to summarize...'
                      : 'Ask anything...',
                  hintStyle: TextStyle(
                    color: colors.hint,
                    fontSize: fontSize,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: inputPadding * 1.5,
                    vertical: inputPadding,
                  ),
                ),
                maxLines: 4,
                minLines: 1,
              ),
            ),
          ),
        ),

        SizedBox(width: screenWidth < 380 ? 6 : 8),

        Material(
          color: isDarkMode ? colors.surface : colors.primary,
          elevation: 4,
          borderRadius: BorderRadius.circular(14),
          shadowColor: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _sendMessage,
            child: Container(
              padding: EdgeInsets.all(inputPadding),
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
                size: iconSize,
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

// Message bubble widget - Updated with LayoutBuilder for responsiveness
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final double maxWidth;

  const _MessageBubble({
    required this.message,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;

    if (!isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            _buildRichText(context, message.content, colors),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: maxWidth * 0.85,
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