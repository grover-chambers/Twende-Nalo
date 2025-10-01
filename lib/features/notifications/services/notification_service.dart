import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_item.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Initialize notification service
  Future<void> initialize() async {
    await _requestPermissions();
    await _setupFirebaseMessaging();
    await _handleInitialMessage();
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  // Setup Firebase Cloud Messaging
  Future<void> _setupFirebaseMessaging() async {
    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    
    // Save token to user profile
    if (token != null && _userId.isNotEmpty) {
      await _saveTokenToUserProfile(token);
    }

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) async {
      if (_userId.isNotEmpty) {
        await _saveTokenToUserProfile(token);
      }
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle message opened from background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = NotificationItem.fromRemoteMessage(message.data);
    
    // Save to Firestore
    _saveNotification(notification);
  }

  // Handle message opened from background
  void _handleMessageOpened(RemoteMessage message) {
    final notification = NotificationItem.fromRemoteMessage(message.data);
    _handleNotificationTap(notification.id);
  }

  // Handle initial message when app is launched from terminated state
  Future<void> _handleInitialMessage() async {
    final message = await _firebaseMessaging.getInitialMessage();
    if (message != null) {
      final notification = NotificationItem.fromRemoteMessage(message.data);
      _handleNotificationTap(notification.id);
    }
  }

  // Handle notification tap
  void _handleNotificationTap(String notificationId) {
    // Mark as read
    markAsRead(notificationId);
  }

  // Save FCM token to user profile
  Future<void> _saveTokenToUserProfile(String token) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }

  // Save notification to Firestore
  Future<void> _saveNotification(NotificationItem notification) async {
    if (_userId.isEmpty) return;
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toFirestore());
  }

  // Get notifications stream
  Stream<List<NotificationItem>> getNotifications({
    int limit = 50,
    bool unreadOnly = false,
  }) {
    if (_userId.isEmpty) return Stream.value([]);
    
    Query query = _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true);

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
    if (_userId.isEmpty) return Stream.value(0);
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    if (_userId.isEmpty) return;
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_userId.isEmpty) return;
    
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    if (_userId.isEmpty) return;

    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Delete a single notification
  Future<void> deleteNotification(String notificationId) async {
    if (_userId.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  // Subscribe to topics
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Unsubscribe from topics
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
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
    if (_userId.isEmpty) return;
    
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

    await _saveNotification(notification);
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  final notification = NotificationItem.fromRemoteMessage(message.data);
  
  // Save to Firestore
  final service = NotificationService();
  await service.createSystemNotification(
    title: notification.title,
    body: notification.body,
    type: notification.type,
    priority: notification.priority,
    data: notification.data,
    imageUrl: notification.imageUrl,
    actionUrl: notification.actionUrl,
  );
}
