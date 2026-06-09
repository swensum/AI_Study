import 'package:study_assistant/models/chat_message.dart';

class ChatSession {
  final String id ;
  String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;

  ChatSession({
  required this.id,
  required this.title,
  required this.createdAt,        
  required this.updatedAt,
  required this.messages,
  });

   factory ChatSession.create({String? title}){
    final now = DateTime.now();
    return ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title ?? ' New Chat',
      createdAt: now,
      updatedAt: now,
      messages: [],
    );
   }
   void updateTitle() {
    if (messages.isNotEmpty && messages.first.isUser){
      final firstMessage = messages.first.content;
      title = firstMessage.length > 30 ? '${firstMessage.substring(0, 30)}...' :  firstMessage;
    }
   }

   ChatSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
   })

   {
    return  ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
   }
}