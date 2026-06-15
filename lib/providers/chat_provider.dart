import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/ai_service.dart';
import '../services/firestore_service.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatSession> _sessions = [];
  ChatSession? _currentSession;
  bool _isLoading = false;
  String _mode = 'chat';
  
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<ChatSession> get sessions => _sessions.where((s) => s.messages.isNotEmpty).toList();
  ChatSession? get currentSession => _currentSession;
  List<ChatMessage> get messages => _currentSession?.messages ?? [];
  bool get isLoading => _isLoading;
  String get mode => _mode;

  ChatProvider() {
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        // User logged in - load from Firestore
        await loadSessionsFromFirestore();
      } else {
        // User logged out - clear local data
        _sessions = [];
        createNewSession();
        notifyListeners();
      }
    });
  }

  // Load sessions from Firestore
  Future<void> loadSessionsFromFirestore() async {
    _sessions = await _firestoreService.loadSessions();
    
    if (_sessions.isEmpty) {
      createNewSession();
    } else {
      _currentSession = _sessions.first;
    }
    
    notifyListeners();
  }

  void setMode(String mode) {
    _mode = mode;
    notifyListeners();
  }

  void createNewSession() {
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

  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    
    if (_sessions.isEmpty) {
      createNewSession();
    } else if (_currentSession?.id == sessionId) {
      _currentSession = _sessions.first;
    }
    
    // Delete from Firestore
    await _firestoreService.deleteSession(sessionId);
    
    notifyListeners();
  }

  void startNewChat() {
    createNewSession();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Check if this is a new empty session
    final isNewEmptySession = _currentSession != null && 
        _currentSession!.messages.isEmpty && 
        !_sessions.any((s) => s.id == _currentSession!.id);
    
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
    
    if (_currentSession!.messages.length == 1) {
      _currentSession!.updateTitle();
      final index = _sessions.indexWhere((s) => s.id == _currentSession!.id);
      if (index != -1) {
        _sessions[index] = _currentSession!;
      }
    }
    
    _currentSession = _currentSession!.copyWith(
      updatedAt: DateTime.now(),
      messages: _currentSession!.messages,
    );
    
    final index = _sessions.indexWhere((s) => s.id == _currentSession!.id);
    if (index != -1) {
      _sessions[index] = _currentSession!;
    }
    
    _isLoading = true;
    notifyListeners();
    
    // Save to Firestore
    await _firestoreService.saveSession(_currentSession!);

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
    
    final sessionIndex = _sessions.indexWhere((s) => s.id == _currentSession!.id);
    if (sessionIndex != -1) {
      _sessions[sessionIndex] = _currentSession!;
    }
    
    _isLoading = false;
    notifyListeners();
    
    // Save to Firestore again
    await _firestoreService.saveSession(_currentSession!);
  }

  Future<void> clearChat() async {
    if (_currentSession != null && _currentSession!.messages.isNotEmpty) {
      _currentSession!.messages.clear();
      
      _currentSession = _currentSession!.copyWith(
        title: 'New Chat',
        updatedAt: DateTime.now(),
        messages: [],
      );
      
      final index = _sessions.indexWhere((s) => s.id == _currentSession!.id);
      if (index != -1) {
        _sessions[index] = _currentSession!;
      }
      
      // Save to Firestore
      await _firestoreService.saveSession(_currentSession!);
      
      notifyListeners();
    }
  }
}