import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:study_assistant/services/ai_service.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatSession> _sessions = [];
  ChatSession? _currentSession;
  bool _isLoading = false;
  String _mode = 'chat';
  
  List<ChatSession> get sessions => _sessions.where((s) => s.messages.isNotEmpty).toList();
  ChatSession? get currentSession => _currentSession;
  List<ChatMessage> get messages => _currentSession?.messages ?? [];
  bool get isLoading => _isLoading;
  String get mode => _mode;

  ChatProvider() {
    loadSessions();
  }
  
  void setMode(String mode) {
    _mode = mode;
    notifyListeners();
  }

  void createNewSession() {
    // Create new session but DON'T add to sessions list yet
    final newSession = ChatSession.create();
    _currentSession = newSession;
    notifyListeners();
  }

  void switchSession(String sessionId) {
    final session = _sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => _sessions.first,
    );
    
    if (_currentSession?.id != session.id) {
      _currentSession = session;
      notifyListeners();
    }
  }

  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.id == sessionId);
    
    if (_sessions.isEmpty) {
      createNewSession();
    } else if (_currentSession?.id == sessionId) {
      _currentSession = _sessions.first;
    }
    
    saveSessions();
    notifyListeners();
  }

  void startNewChat() {
    createNewSession();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Check if this is a new empty session that hasn't been added to sessions list yet
    final isNewEmptySession = _currentSession != null && 
        _currentSession!.messages.isEmpty && 
        !_sessions.any((s) => s.id == _currentSession!.id);
    
    // Add to sessions list if it's a new empty session
    if (isNewEmptySession) {
      _sessions.insert(0, _currentSession!);
    }

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      isSummary: false,
      timestamp: DateTime.now(),
    );
    
    _currentSession?.messages.add(userMessage);
    
    // Update session title if it's the first message
    if (_currentSession!.messages.length == 1) {
      _currentSession!.updateTitle();
      // Update the session in the list
      final index = _sessions.indexWhere((s) => s.id == _currentSession!.id);
      if (index != -1) {
        _sessions[index] = _currentSession!;
      }
    }
    
    _currentSession = _currentSession!.copyWith(
      updatedAt: DateTime.now(),
      messages: _currentSession!.messages,
    );
    
    // Update the session in the list
    final index = _sessions.indexWhere((s) => s.id == _currentSession!.id);
    if (index != -1) {
      _sessions[index] = _currentSession!;
    }
    
    _isLoading = true;
    notifyListeners();
    saveSessions();

    // Get AI response
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
      timestamp: DateTime.now(),
    );
    
    _currentSession?.messages.add(aiMessage);
    _currentSession = _currentSession!.copyWith(
      updatedAt: DateTime.now(),
      messages: _currentSession!.messages,
    );
    
    // Update the session in the list again
    final sessionIndex = _sessions.indexWhere((s) => s.id == _currentSession!.id);
    if (sessionIndex != -1) {
      _sessions[sessionIndex] = _currentSession!;
    }
    
    _isLoading = false;
    notifyListeners();
    saveSessions();
  }

  void clearChat() {
    if (_currentSession != null && _currentSession!.messages.isNotEmpty) {
      // Clear all messages
      _currentSession!.messages.clear();
      
      // Reset the session title to default
      _currentSession = _currentSession!.copyWith(
        title: 'New Chat',
        updatedAt: DateTime.now(),
        messages: [],
      );
      
      // Update the session in the list
      final index = _sessions.indexWhere((s) => s.id == _currentSession!.id);
      if (index != -1) {
        _sessions[index] = _currentSession!;
      }
      
      saveSessions();
      notifyListeners();
    }
  }

  Future<void> saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = _sessions.map((session) {
      return {
        'id': session.id,
        'title': session.title,
        'createdAt': session.createdAt.toIso8601String(),
        'updatedAt': session.updatedAt.toIso8601String(),
        'messages': session.messages.map((msg) {
          return {
            'id': msg.id,
            'content': msg.content,
            'isUser': msg.isUser,
            'isSummary': msg.isSummary,
            'timestamp': msg.timestamp.toIso8601String(),
          };
        }).toList(),
      };
    }).toList();
    
    await prefs.setString('chat_sessions', jsonEncode(sessionsJson));
  }

  Future<void> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString('chat_sessions');
    
    if (sessionsJson != null) {
      final List<dynamic> decoded = jsonDecode(sessionsJson);
      _sessions = decoded.map((sessionData) {
        final messages = (sessionData['messages'] as List).map((msgData) {
          return ChatMessage(
            id: msgData['id'],
            content: msgData['content'],
            isUser: msgData['isUser'],
            isSummary: msgData['isSummary'] ?? false,
            timestamp: DateTime.parse(msgData['timestamp']),
          );
        }).toList();
        
        return ChatSession(
          id: sessionData['id'],
          title: sessionData['title'],
          createdAt: DateTime.parse(sessionData['createdAt']),
          updatedAt: DateTime.parse(sessionData['updatedAt']),
          messages: messages.toList(),
        );
      }).toList();
      
      // Sort sessions by updatedAt (most recent first)
      _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      // Set current session to the most recent one
      if (_sessions.isNotEmpty) {
        _currentSession = _sessions.first;
      } else {
        createNewSession();
      }
      
      notifyListeners();
    } else {
      // No sessions found, create a default one
      createNewSession();
    }
  }
}