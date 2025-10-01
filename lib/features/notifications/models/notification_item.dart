import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum NotificationType {
  orderUpdate,
  deliveryStatus,
  paymentConfirmation,
  systemAlert,
  promotional,
  riderAssignment,
  shopUpdate,
}

enum NotificationPriority {
  low,
  medium,
  high,
  critical,
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final String? imageUrl;
  final String? actionUrl;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.medium,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.imageUrl,
    this.actionUrl,
  });

  factory NotificationItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationItem(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: _parseNotificationType(data['type']),
      priority: _parseNotificationPriority(data['priority']),
      data: data['data'] ?? {},
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      actionUrl: data['actionUrl'],
    );
  }

  factory NotificationItem.fromRemoteMessage(Map<String, dynamic> message) {
    final notification = message['notification'] ?? {};
    final data = message['data'] ?? {};

    return NotificationItem(
      id: data['notificationId'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification['title'] ?? 'New Notification',
      body: notification['body'] ?? '',
      type: _parseNotificationType(data['type']),
      priority: _parseNotificationPriority(data['priority']),
      data: data,
      isRead: false,
      createdAt: DateTime.now(),
      imageUrl: notification['imageUrl'],
      actionUrl: data['actionUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'type': type.name,
      'priority': priority.name,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    String? imageUrl,
    String? actionUrl,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(createdAt);
    }
  }

  String get typeIcon {
    switch (type) {
      case NotificationType.orderUpdate:
        return '📦';
      case NotificationType.deliveryStatus:
        return '🚚';
      case NotificationType.paymentConfirmation:
        return '💳';
      case NotificationType.systemAlert:
        return '⚠️';
      case NotificationType.promotional:
        return '🎉';
      case NotificationType.riderAssignment:
        return '🏍️';
      case NotificationType.shopUpdate:
        return '🏪';
    }
  }

  static NotificationType _parseNotificationType(String? type) {
    return NotificationType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => NotificationType.systemAlert,
    );
  }

  static NotificationPriority _parseNotificationPriority(String? priority) {
    return NotificationPriority.values.firstWhere(
      (e) => e.name == priority,
      orElse: () => NotificationPriority.medium,
    );
  }
}
