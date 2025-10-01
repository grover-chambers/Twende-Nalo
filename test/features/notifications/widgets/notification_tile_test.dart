import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twende_nalo/features/notifications/widgets/notification_tile.dart';
import 'package:twende_nalo/features/notifications/models/notification_item.dart';

void main() {
  group('NotificationTile Widget Tests', () {
    testWidgets('renders notification title and body', (WidgetTester tester) async {
      final notification = NotificationItem(
        id: '1',
        title: 'Test Title',
        body: 'Test Body',
        type: NotificationType.systemAlert,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationTile(notification: notification),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Body'), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (WidgetTester tester) async {
      bool tapped = false;
      final notification = NotificationItem(
        id: '1',
        title: 'Tap Test',
        body: 'Tap Body',
        type: NotificationType.systemAlert,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationTile(
              notification: notification,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NotificationTile));
      expect(tapped, true);
    });

    testWidgets('calls onDismiss callback when dismiss button pressed', (WidgetTester tester) async {
      bool dismissed = false;
      final notification = NotificationItem(
        id: '1',
        title: 'Dismiss Test',
        body: 'Dismiss Body',
        type: NotificationType.systemAlert,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationTile(
              notification: notification,
              onDismiss: () {
                dismissed = true;
              },
              showDismiss: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, true);
    });

    testWidgets('shows unread indicator when notification is unread', (WidgetTester tester) async {
      final notification = NotificationItem(
        id: '1',
        title: 'Unread Test',
        body: 'Unread Body',
        type: NotificationType.systemAlert,
        createdAt: DateTime.now(),
        isRead: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationTile(notification: notification),
          ),
        ),
      );

      // Look for a blue circle container (unread indicator)
      expect(find.byWidgetPredicate((widget) {
        if (widget is Container) {
          final decoration = widget.decoration;
          if (decoration is BoxDecoration) {
            return decoration.color == Colors.blue &&
                decoration.shape == BoxShape.circle;
          }
        }
        return false;
      }), findsOneWidget);
    });

    testWidgets('shows priority badge for high and critical priorities', (WidgetTester tester) async {
      final highPriorityNotification = NotificationItem(
        id: '1',
        title: 'High Priority',
        body: 'High Body',
        type: NotificationType.systemAlert,
        createdAt: DateTime.now(),
        priority: NotificationPriority.high,
      );

      final criticalPriorityNotification = NotificationItem(
        id: '2',
        title: 'Critical Priority',
        body: 'Critical Body',
        type: NotificationType.systemAlert,
        createdAt: DateTime.now(),
        priority: NotificationPriority.critical,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                NotificationTile(notification: highPriorityNotification),
                NotificationTile(notification: criticalPriorityNotification),
              ],
            ),
          ),
        ),
      );

      expect(find.text('HIGH'), findsOneWidget);
      expect(find.text('CRITICAL'), findsOneWidget);
    });
  });
}
