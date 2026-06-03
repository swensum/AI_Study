import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:study_assistant/services/ai_service.dart';
import '../models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _mode = 'chat';
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String get mode => _mode;

  ChatProvider() {
    loadMessages();
  }
  void setMode(String mode) {
    _mode = mode;
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
    );
    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    String response;
    if (_mode == 'summarize') {
      response = await AIService.summarizeText(content);
    } else {
      response = await AIService.sendMessage(content);
    }

    final aiMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      isUser: false,
      isSummary: _mode == 'summarize',
    );
    _messages.add(aiMessage);
    _isLoading = false;
    notifyListeners();

    saveMessages();
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
    saveMessages();
  }

  Future<void> saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = _messages
        .map(
          (msg) => {
            'id': msg.id,
            'content': msg.content,
            'isUser': msg.isUser,
            'isSummary': msg.isSummary,
            'timestamp': msg.timestamp.toIso8601String(),
          },
        )
        .toList();
    await prefs.setString('chat_messages', jsonEncode(messagesJson));
  }

  Future<void> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString('chat_messages');
    if (messagesJson != null) {
      final List<dynamic> decoded = jsonDecode(messagesJson);
      _messages = decoded
          .map(
            (msg) => ChatMessage(
              id: msg['id'],
              content: msg['content'],
              isUser: msg['isUser'],
              timestamp: DateTime.parse(msg['timestamp']),
              isSummary: msg['isSummary'] ?? false,
            ),
          )
          .toList();
      notifyListeners();
    }
  }
}
