import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_item.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference get _notificationsCollection =>
      _firestore.collection('users').doc(_userId).collection('notifications');

  // Get notifications stream
  Stream<List<NotificationItem>> getNotifications({
    int limit = 50,
    bool unreadOnly = false,
  }) {
    Query query = _notificationsCollection.orderBy('createdAt', descending: true);

    if (unreadOnly) {
      query = query.where('isRead', isEqualTo: false);
    }

    if (limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => NotificationItem.fromFirestore(doc)).toList());
  }

  // Get unread count
  Stream<int> getUnreadCount() {
    return _notificationsCollection
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _notificationsCollection
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final batch = _firestore.batch();
    final snapshot = await _notificationsCollection
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  // Save notification to Firestore
  Future<void> saveNotification(NotificationItem notification) async {
    await _notificationsCollection
        .doc(notification.id)
        .set(notification.toFirestore());
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _notificationsCollection.doc(notificationId).delete();
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    final batch = _firestore.batch();
    final snapshot = await _notificationsCollection.get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Get notification by ID
  Future<NotificationItem?> getNotification(String notificationId) async {
    final doc = await _notificationsCollection.doc(notificationId).get();
    if (doc.exists) {
      return NotificationItem.fromFirestore(doc);
    }
    return null;
  }

  // Create system notification
  Future<void> createSystemNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.systemAlert,
    NotificationPriority priority = NotificationPriority.medium,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
  }) async {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      priority: priority,
      data: data,
      createdAt: DateTime.now(),
      imageUrl: imageUrl,
      actionUrl: actionUrl,
    );

    await saveNotification(notification);
  }
}
