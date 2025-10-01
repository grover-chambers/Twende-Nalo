import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twende_nalo/features/notifications/models/notification_item.dart';

void main() {
  group('NotificationItem Model Tests', () {
    final firestoreTimestamp = Timestamp.fromDate(DateTime(2023, 1, 1, 12, 0, 0));
    final firestoreDoc = FakeDocumentSnapshot({
      'title': 'Test Title',
      'body': 'Test Body',
      'type': 'orderUpdate',
      'priority': 'high',
      'data': {'key': 'value'},
      'isRead': true,
      'createdAt': firestoreTimestamp,
      'imageUrl': 'http://image.url',
      'actionUrl': 'http://action.url',
    }, 'docId123');

    test('fromFirestore creates correct NotificationItem', () {
      final notification = NotificationItem.fromFirestore(firestoreDoc);
      expect(notification.id, 'docId123');
      expect(notification.title, 'Test Title');
      expect(notification.body, 'Test Body');
      expect(notification.type, NotificationType.orderUpdate);
      expect(notification.priority, NotificationPriority.high);
      expect(notification.data, {'key': 'value'});
      expect(notification.isRead, true);
      expect(notification.createdAt, firestoreTimestamp.toDate());
      expect(notification.imageUrl, 'http://image.url');
      expect(notification.actionUrl, 'http://action.url');
    });

    test('fromRemoteMessage creates NotificationItem with defaults', () {
      final message = {
        'notification': {'title': 'Remote Title', 'body': 'Remote Body', 'imageUrl': 'http://remote.image'},
        'data': {'notificationId': 'remoteId', 'type': 'paymentConfirmation', 'priority': 'medium', 'actionUrl': 'http://remote.action'}
      };
      final notification = NotificationItem.fromRemoteMessage(message);
      expect(notification.id, 'remoteId');
      expect(notification.title, 'Remote Title');
      expect(notification.body, 'Remote Body');
      expect(notification.type, NotificationType.paymentConfirmation);
      expect(notification.priority, NotificationPriority.medium);
      expect(notification.isRead, false);
      expect(notification.imageUrl, 'http://remote.image');
      expect(notification.actionUrl, 'http://remote.action');
    });

    test('toFirestore returns correct map', () {
      final notification = NotificationItem(
        id: 'id1',
        title: 'Title',
        body: 'Body',
        type: NotificationType.systemAlert,
        priority: NotificationPriority.low,
        data: {'foo': 'bar'},
        isRead: false,
        createdAt: DateTime(2023, 1, 1),
        imageUrl: 'url',
        actionUrl: 'action',
      );
      final map = notification.toFirestore();
      expect(map['title'], 'Title');
      expect(map['body'], 'Body');
      expect(map['type'], 'systemAlert');
      expect(map['priority'], 'low');
      expect(map['data'], {'foo': 'bar'});
      expect(map['isRead'], false);
      expect(map['imageUrl'], 'url');
      expect(map['actionUrl'], 'action');
      expect(map['createdAt'], isA<Timestamp>());
    });

    test('copyWith returns updated copy', () {
      final notification = NotificationItem(
        id: 'id1',
        title: 'Title',
        body: 'Body',
        type: NotificationType.systemAlert,
        priority: NotificationPriority.low,
        data: {'foo': 'bar'},
        isRead: false,
        createdAt: DateTime(2023, 1, 1),
        imageUrl: 'url',
        actionUrl: 'action',
      );
      final copy = notification.copyWith(title: 'New Title', isRead: true);
      expect(copy.title, 'New Title');
      expect(copy.isRead, true);
      expect(copy.body, 'Body');
    });

    test('formattedTime returns correct string', () {
      final now = DateTime.now();
      final justNow = NotificationItem(
        id: 'id',
        title: '',
        body: '',
        type: NotificationType.systemAlert,
        createdAt: now.subtract(const Duration(seconds: 30)),
      );
      expect(justNow.formattedTime, 'Just now');

      final minutesAgo = NotificationItem(
        id: 'id',
        title: '',
        body: '',
        type: NotificationType.systemAlert,
        createdAt: now.subtract(const Duration(minutes: 5)),
      );
      expect(minutesAgo.formattedTime, '5m ago');

      final hoursAgo = NotificationItem(
        id: 'id',
        title: '',
        body: '',
        type: NotificationType.systemAlert,
        createdAt: now.subtract(const Duration(hours: 3)),
      );
      expect(hoursAgo.formattedTime, '3h ago');

      final daysAgo = NotificationItem(
        id: 'id',
        title: '',
        body: '',
        type: NotificationType.systemAlert,
        createdAt: now.subtract(const Duration(days: 2)),
      );
      expect(daysAgo.formattedTime, '2d ago');
    });

    test('typeIcon returns correct icon', () {
      expect(NotificationItem(type: NotificationType.orderUpdate, id: '', title: '', body: '', createdAt: DateTime.now()).typeIcon, '📦');
      expect(NotificationItem(type: NotificationType.deliveryStatus, id: '', title: '', body: '', createdAt: DateTime.now()).typeIcon, '🚚');
      expect(NotificationItem(type: NotificationType.paymentConfirmation, id: '', title: '', body: '', createdAt: DateTime.now()).typeIcon, '💳');
      expect(NotificationItem(type: NotificationType.systemAlert, id: '', title: '', body: '', createdAt: DateTime.now()).typeIcon, '⚠️');
      expect(NotificationItem(type: NotificationType.promotional, id: '', title: '', body: '', createdAt: DateTime.now()).typeIcon, '🎉');
      expect(NotificationItem(type: NotificationType.riderAssignment, id: '', title: '', body: '', createdAt: DateTime.now()).typeIcon, '🏍️');
      expect(NotificationItem(type: NotificationType.shopUpdate, id: '', title: '', body: '', createdAt: DateTime.now()).typeIcon, '🏪');
    });
  });
}

// Fake DocumentSnapshot for testing
class FakeDocumentSnapshot extends DocumentSnapshot {
  final Map<String, dynamic> _data;
  final String _id;

  FakeDocumentSnapshot(this._data, this._id);

  @override
  Map<String, dynamic> data() => _data;

  @override
  String get id => _id;

  @override
  // ignore: no_such_method
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
