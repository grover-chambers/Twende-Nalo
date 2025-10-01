import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/router.dart' as app_router; // Ensure this import is correct
import '../models/notification_item.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_tile.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().refreshNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount > 0) {
                return TextButton(
                  onPressed: () => _markAllAsRead(context),
                  child: const Text('Mark all read'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.refreshNotifications,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll see updates here when something important happens',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refreshNotifications,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () => _handleNotificationTap(context, notification),
                  onDismiss: () => _dismissNotification(context, notification.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationItem notification) {
    context.read<NotificationProvider>().markAsRead(notification.id);
    
    // Handle navigation based on notification type
    switch (notification.type) {
      case NotificationType.orderUpdate:
      case NotificationType.deliveryStatus:
        // Navigate to order details
        if (notification.data?['orderId'] != null) {
          app_router.AppRouter.goToOrderDetail(notification.data?['orderId']);
        }
        break;
      case NotificationType.riderAssignment:
        // Navigate to delivery tracking
        if (notification.data?['deliveryId'] != null) {
          app_router.AppRouter.goToDeliveryTracking(notification.data?['deliveryId']);
        }
        break;
      case NotificationType.paymentConfirmation:
        // Navigate to payment details
        if (notification.data?['paymentId'] != null) {
          app_router.AppRouter.goToPayment();
        }
        break;
      default:
        break;
    }
  }

  void _markAllAsRead(BuildContext context) {
    context.read<NotificationProvider>().markAllAsRead();
  }

  Future<void> _dismissNotification(BuildContext context, String notificationId) async {
    await context.read<NotificationProvider>().deleteNotification(notificationId);
  }
}
