class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final bool isSummary;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    this.isSummary = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}