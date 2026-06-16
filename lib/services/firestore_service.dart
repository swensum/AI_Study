import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Reference to user's chats collection
  CollectionReference<Map<String, dynamic>> get _chatsCollection {
    return _firestore.collection('users').doc(_userId).collection('chats');
  }

  // Reference to messages subcollection for a specific chat
  CollectionReference<Map<String, dynamic>> _getMessagesCollection(String sessionId) {
    return _chatsCollection.doc(sessionId).collection('messages');
  }

  // Save all sessions to Firestore
  Future<void> saveSessions(List<ChatSession> sessions) async {
    if (_userId == null) return;

    final WriteBatch batch = _firestore.batch();

    for (final ChatSession session in sessions) {
      final DocumentReference<Map<String, dynamic>> chatRef = _chatsCollection.doc(session.id);
      
      // Save chat session metadata
      batch.set(chatRef, {
        'title': session.title,
        'createdAt': Timestamp.fromDate(session.createdAt),
        'updatedAt': Timestamp.fromDate(session.updatedAt),
      });

      // Save messages
      for (final ChatMessage message in session.messages) {
        final DocumentReference<Map<String, dynamic>> messageRef = chatRef.collection('messages').doc(message.id);
        batch.set(messageRef, {
          'content': message.content,
          'isUser': message.isUser,
          'isSummary': message.isSummary,
          'timestamp': Timestamp.fromDate(message.timestamp),
        });
      }
    }

    await batch.commit();
  }

  // Load all sessions from Firestore
  Future<List<ChatSession>> loadSessions() async {
    if (_userId == null) return [];

    try {
      // Get all chat sessions
      final QuerySnapshot<Map<String, dynamic>> chatsSnapshot = await _chatsCollection
          .orderBy('updatedAt', descending: true)
          .get();

      List<ChatSession> sessions = [];

      for (final QueryDocumentSnapshot<Map<String, dynamic>> chatDoc in chatsSnapshot.docs) {
        final Map<String, dynamic> chatData = chatDoc.data();
        
        // Get messages for this chat
        final QuerySnapshot<Map<String, dynamic>> messagesSnapshot = await _getMessagesCollection(chatDoc.id)
            .orderBy('timestamp')
            .get();

        List<ChatMessage> messages = [];

        for (final QueryDocumentSnapshot<Map<String, dynamic>> msgDoc in messagesSnapshot.docs) {
          final Map<String, dynamic> msgData = msgDoc.data();
          
          messages.add(ChatMessage(
            id: msgDoc.id,
            content: msgData['content'] ?? '',
            isUser: msgData['isUser'] ?? false,
            isSummary: msgData['isSummary'] ?? false,
            timestamp: (msgData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          ));
        }

        sessions.add(ChatSession(
          id: chatDoc.id,
          title: chatData['title'] ?? 'New Chat',
          createdAt: (chatData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (chatData['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          messages: messages,
        ));
      }

      return sessions;
    } catch (e) {
      print('Error loading sessions: $e');
      return [];
    }
  }

  // Save a single session
  Future<void> saveSession(ChatSession session) async {
    if (_userId == null) return;

    final WriteBatch batch = _firestore.batch();
    final DocumentReference<Map<String, dynamic>> chatRef = _chatsCollection.doc(session.id);

    // Update chat metadata
    batch.set(chatRef, {
      'title': session.title,
      'createdAt': Timestamp.fromDate(session.createdAt),
      'updatedAt': Timestamp.fromDate(session.updatedAt),
    }, SetOptions(merge: true));

    // Delete old messages (for full sync)
    final QuerySnapshot<Map<String, dynamic>> oldMessages = await _getMessagesCollection(session.id).get();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in oldMessages.docs) {
      batch.delete(doc.reference);
    }

    // Add new messages
    for (final ChatMessage message in session.messages) {
      final DocumentReference<Map<String, dynamic>> messageRef = _getMessagesCollection(session.id).doc(message.id);
      batch.set(messageRef, {
        'content': message.content,
        'isUser': message.isUser,
        'isSummary': message.isSummary,
        'timestamp': Timestamp.fromDate(message.timestamp),
      });
    }

    await batch.commit();
  }

  // Delete a session
  Future<void> deleteSession(String sessionId) async {
    if (_userId == null) return;

    // Delete all messages subcollection
    final QuerySnapshot<Map<String, dynamic>> messages = await _getMessagesCollection(sessionId).get();
    final WriteBatch batch = _firestore.batch();
    
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in messages.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete the chat document
    batch.delete(_chatsCollection.doc(sessionId));
    
    await batch.commit();
  }

  // Clear all chats for current user
  Future<void> clearAllChats() async {
    if (_userId == null) return;

    final QuerySnapshot<Map<String, dynamic>> chats = await _chatsCollection.get();
    final WriteBatch batch = _firestore.batch();
    
    for (final QueryDocumentSnapshot<Map<String, dynamic>> chatDoc in chats.docs) {
      final QuerySnapshot<Map<String, dynamic>> messages = await _getMessagesCollection(chatDoc.id).get();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> msgDoc in messages.docs) {
        batch.delete(msgDoc.reference);
      }
      batch.delete(chatDoc.reference);
    }
    
    await batch.commit();
  }

  // Listen to real-time updates
  Stream<List<ChatSession>> watchSessions() {
    if (_userId == null) return Stream.value([]);

    return _chatsCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .asyncMap((QuerySnapshot<Map<String, dynamic>> querySnapshot) async {
          List<ChatSession> sessions = [];
          
          for (final QueryDocumentSnapshot<Map<String, dynamic>> chatDoc in querySnapshot.docs) {
            final Map<String, dynamic> chatData = chatDoc.data();
            
            final QuerySnapshot<Map<String, dynamic>> messagesSnapshot = await _getMessagesCollection(chatDoc.id)
                .orderBy('timestamp')
                .get();
            
            List<ChatMessage> messages = [];
            
            for (final QueryDocumentSnapshot<Map<String, dynamic>> msgDoc in messagesSnapshot.docs) {
              final Map<String, dynamic> msgData = msgDoc.data();
              
              messages.add(ChatMessage(
                id: msgDoc.id,
                content: msgData['content'] ?? '',
                isUser: msgData['isUser'] ?? false,
                isSummary: msgData['isSummary'] ?? false,
                timestamp: (msgData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              ));
            }
            
            sessions.add(ChatSession(
              id: chatDoc.id,
              title: chatData['title'] ?? 'New Chat',
              createdAt: (chatData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              updatedAt: (chatData['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              messages: messages,
            ));
          }
          
          return sessions;
        });
  }
}