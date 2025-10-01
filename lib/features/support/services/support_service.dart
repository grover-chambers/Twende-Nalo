import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';

class SupportService {
  static final SupportService _instance = SupportService._internal();
  factory SupportService() => _instance;
  SupportService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  // Get support chat ID (fixed ID for support team)
  String get supportChatId => 'support_chat_$_currentUserId';

  // Send message to support
  Future<void> sendMessageToSupport({
    required String message,
    MessageType type = MessageType.text,
    String? imageUrl,
  }) async {
    if (_currentUserId.isEmpty) return;

    final messageId = _firestore.collection('support_chats').doc().id;
    final chatMessage = ChatMessage(
      id: messageId,
      senderId: _currentUserId,
      receiverId: 'support_team', // Fixed support team ID
      type: type,
      text: message,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('support_chats')
        .doc(supportChatId)
        .collection('messages')
        .doc(messageId)
        .set(chatMessage.toFirestore());
  }

  // Get support chat messages stream
  Stream<List<ChatMessage>> getSupportChatMessages() {
    if (_currentUserId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('support_chats')
        .doc(supportChatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(List<String> messageIds) async {
    if (_currentUserId.isEmpty || messageIds.isEmpty) return;

    final batch = _firestore.batch();
    for (final messageId in messageIds) {
      final ref = _firestore
          .collection('support_chats')
          .doc(supportChatId)
          .collection('messages')
          .doc(messageId);
      batch.update(ref, {'isRead': true});
    }
    await batch.commit();
  }

  // Get unread message count
  Stream<int> getUnreadMessageCount() {
    if (_currentUserId.isEmpty) return Stream.value(0);

    return _firestore
        .collection('support_chats')
        .doc(supportChatId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: _currentUserId) // Only count support team messages
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Create support ticket
  Future<void> createSupportTicket({
    required String title,
    required String description,
    String? category,
    String? priority,
  }) async {
    if (_currentUserId.isEmpty) return;

    final ticketId = _firestore.collection('support_tickets').doc().id;
    await _firestore.collection('support_tickets').doc(ticketId).set({
      'id': ticketId,
      'userId': _currentUserId,
      'title': title,
      'description': description,
      'category': category ?? 'general',
      'priority': priority ?? 'medium',
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get user support tickets
  Stream<List<Map<String, dynamic>>> getUserSupportTickets() {
    if (_currentUserId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('support_tickets')
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  // Get FAQ items
  Future<List<Map<String, dynamic>>> getFaqItems() async {
    try {
      final snapshot = await _firestore
          .collection('support_faq')
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Search FAQ
  Future<List<Map<String, dynamic>>> searchFaq(String query) async {
    try {
      final snapshot = await _firestore
          .collection('support_faq')
          .where('isActive', isEqualTo: true)
          .where('keywords', arrayContains: query.toLowerCase())
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      return [];
    }
  }
}
