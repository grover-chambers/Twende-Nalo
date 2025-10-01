import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:twende_nalo/features/notifications/screens/notification_screen.dart';
import 'package:twende_nalo/features/notifications/providers/notification_provider.dart';
import 'package:twende_nalo/features/notifications/models/notification_item.dart';

// Mock NotificationProvider for testing
class MockNotificationProvider extends ChangeNotifier implements NotificationProvider {
  List<NotificationItem> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  @override
  List<NotificationItem> get notifications => _notifications;

  @override
  int get unreadCount => _unreadCount;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  @override
  Future<void> refreshNotifications() async {}

  @override
  Future<void> markAsRead(String notificationId) async {}

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<void> clearAllNotifications() async {}

  @override
  Future<void> deleteNotification(String notificationId) async {}

  @override
  List<NotificationItem> getUnreadNotifications() => [];

  @override
  List<NotificationItem> getNotificationsByType(NotificationType type) => [];

  @override
  void clearError() {}

  // Setters for testing
  set notifications(List<NotificationItem> value) {
    _notifications = value;
    notifyListeners();
  }

  set unreadCount(int value) {
    _unreadCount = value;
    notifyListeners();
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set error(String? value) {
    _error = value;
    notifyListeners();
  }
}

void main() {
  Widget createWidgetUnderTest(MockNotificationProvider provider) {
    return MaterialApp(
      home: ChangeNotifierProvider<NotificationProvider>.value(
        value: provider,
        child: const NotificationScreen(),
      ),
    );
  }

  group('NotificationScreen Widget Tests', () {
    late MockNotificationProvider provider;

    setUp(() {
      provider = MockNotificationProvider();
    });

    testWidgets('shows loading indicator when loading and no notifications', (WidgetTester tester) async {
      provider.isLoading = true;
      provider.notifications = [];
      await tester.pumpWidget(createWidgetUnderTest(provider));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message and retry button when error and no notifications', (WidgetTester tester) async {
      provider.error = 'Error occurred';
      provider.notifications = [];
      await tester.pumpWidget(createWidgetUnderTest(provider));
      expect(find.text('Error occurred'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows empty state when no notifications', (WidgetTester tester) async {
      provider.notifications = [];
      provider.error = null;
      provider.isLoading = false;
      await tester.pumpWidget(createWidgetUnderTest(provider));
      expect(find.text('No notifications yet'), findsOneWidget);
    });

    testWidgets('shows list of notifications', (WidgetTester tester) async {
      final notification = NotificationItem(
        id: '1',
        title: 'Test Notification',
        body: 'This is a test',
        type: NotificationType.systemAlert,
        createdAt: DateTime.now(),
      );
      provider.notifications = [notification];
      provider.isLoading = false;
      provider.error = null;
      await tester.pumpWidget(createWidgetUnderTest(provider));
      expect(find.text('Test Notification'), findsOneWidget);
      expect(find.text('This is a test'), findsOneWidget);
    });

    testWidgets('mark all read button appears when unreadCount > 0', (WidgetTester tester) async {
      provider.unreadCount = 1;
      await tester.pumpWidget(createWidgetUnderTest(provider));
      expect(find.text('Mark all read'), findsOneWidget);
    });

    testWidgets('mark all read button does not appear when unreadCount == 0', (WidgetTester tester) async {
      provider.unreadCount = 0;
      await tester.pumpWidget(createWidgetUnderTest(provider));
      expect(find.text('Mark all read'), findsNothing);
    });
  });
}
