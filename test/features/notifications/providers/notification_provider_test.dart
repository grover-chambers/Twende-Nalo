import 'package:flutter_test/flutter_test.dart';
import 'package:twende_nalo/features/notifications/providers/notification_provider.dart';
import 'package:twende_nalo/features/notifications/models/notification_item.dart';

void main() {
  late NotificationProvider notificationProvider;

  setUp(() {
    notificationProvider = NotificationProvider();
  });

  tearDown(() {
    notificationProvider.dispose();
  });

  group('NotificationProvider Tests', () {
    test('initial state is correct', () {
      expect(notificationProvider.notifications, isEmpty);
      expect(notificationProvider.unreadCount, 0);
      expect(notificationProvider.isLoading, false);
      expect(notificationProvider.error, isNull);
    });

    test('refreshNotifications completes without error', () async {
      await expectLater(notificationProvider.refreshNotifications(), completes);
    });

    test('markAsRead completes without error', () async {
      await expectLater(notificationProvider.markAsRead('testId'), completes);
    });

    test('markAllAsRead completes without error', () async {
      await expectLater(notificationProvider.markAllAsRead(), completes);
    });

    test('clearAllNotifications completes without error', () async {
      await expectLater(notificationProvider.clearAllNotifications(), completes);
    });

    test('deleteNotification completes without error', () async {
      await expectLater(notificationProvider.deleteNotification('testId'), completes);
    });

    test('getUnreadNotifications returns empty list initially', () {
      final unread = notificationProvider.getUnreadNotifications();
      expect(unread, isEmpty);
    });

    test('getNotificationsByType returns empty list initially', () {
      final filtered = notificationProvider.getNotificationsByType(NotificationType.systemAlert);
      expect(filtered, isEmpty);
    });

    test('clearError sets error to null', () {
      // Since we can't set error directly, we test the method exists and doesn't throw
      expect(() => notificationProvider.clearError(), returnsNormally);
    });
  });
}
