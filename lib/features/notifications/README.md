# Twende Nalo Notification Module

This module provides a complete notification system for the Twende Nalo app, handling both local and remote notifications with Firebase Cloud Messaging.

## Features

- **Real-time notifications** via Firebase Cloud Messaging
- **Persistent storage** in Firestore
- **Rich notification types** with icons and priority levels
- **Unread count tracking**
- **Mark as read functionality**
- **Swipe to dismiss** (ready for implementation)
- **Notification filtering** by type and read status
- **Responsive UI** with Material Design

## Architecture

### Core Components

1. **NotificationItem** (`models/notification_item.dart`)
   - Data model for notifications
   - Supports multiple notification types
   - Priority levels and metadata

2. **NotificationService** (`services/notification_service.dart`)
   - Firebase Cloud Messaging integration
   - Token management
   - Background message handling
   - Local notification display

3. **NotificationProvider** (`providers/notification_provider.dart`)
   - State management with Provider
   - Real-time Firestore updates
   - Loading states and error handling

4. **NotificationScreen** (`screens/notification_screen.dart`)
   - Main notification UI
   - Pull-to-refresh functionality
   - Empty state handling

5. **NotificationTile** (`widgets/notification_tile.dart`)
   - Individual notification display
   - Type-based icons and colors
   - Priority indicators

### Notification Types

- `orderUpdate` - Order status changes
- `deliveryStatus` - Delivery progress updates
- `paymentConfirmation` - Payment receipts
- `systemAlert` - System announcements
- `promotional` - Marketing messages
- `riderAssignment` - Rider allocation
- `shopUpdate` - Shop-related updates

### Priority Levels

- `low` - Non-urgent updates
- `medium` - Standard notifications
- `high` - Important updates
- `critical` - Urgent alerts

## Usage

### 1. Initialize in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    NotificationInitializer(
      child: MyApp(),
    ),
  );
}
```

### 2. Add notification badge to app bar

```dart
AppBar(
  actions: [
    NotificationBadge(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationScreen(),
          ),
        );
      },
    ),
  ],
)
```

### 3. Send notifications from backend

```javascript
// Firebase Cloud Function example
const message = {
  notification: {
    title: 'Order Delivered',
    body: 'Your order #12345 has been delivered successfully',
  },
  data: {
    type: 'deliveryStatus',
    priority: 'high',
    orderId: '12345',
    deliveryId: '67890',
  },
  token: userFCMToken,
};

await admin.messaging().send(message);
```

### 4. Handle notification taps

```dart
// In NotificationScreen
void _handleNotificationTap(NotificationItem notification) {
  switch (notification.type) {
    case NotificationType.orderUpdate:
      // Navigate to order details
      break;
    case NotificationType.deliveryStatus:
      // Navigate to delivery tracking
      break;
    // ... other cases
  }
}
```

## Setup Instructions

### 1. Firebase Setup
- Enable Firebase Cloud Messaging in Firebase Console
- Add your Android/iOS app with correct package name
- Download and add `google-services.json` to `android/app/`

### 2. Dependencies
The module uses these Firebase packages:
- `firebase_core`
- `firebase_messaging`
- `cloud_firestore`
- `firebase_auth`

### 3. Permissions
- Android: Notification permissions are handled automatically
- iOS: Add notification permissions to `Info.plist`

### 4. Firestore Structure
```
users/
  {userId}/
    notifications/
      {notificationId}/
        title: string
        body: string
        type: string
        priority: string
        isRead: boolean
        createdAt: timestamp
        data: map
        imageUrl: string
        actionUrl: string
```

## Customization

### Adding new notification types
1. Add new enum value in `NotificationType`
2. Update `_getIconBackgroundColor()` in `NotificationTile`
3. Add handling logic in notification tap handler

### Styling
- Modify `NotificationTile` for visual changes
- Update colors and icons in the widget
- Adjust animations and transitions

### Localization
- Use Flutter's built-in localization
- Add notification strings to `.arb` files

## Testing

### Unit Tests
- Test notification model serialization
- Test provider state management
- Test service methods

### Integration Tests
- Test Firebase Cloud Messaging
- Test Firestore operations
- Test UI interactions

## Troubleshooting

### Common Issues

1. **Notifications not appearing**
   - Check Firebase project setup
   - Verify FCM token is saved correctly
   - Check notification permissions

2. **Unread count not updating**
   - Ensure Firestore listeners are active
   - Check user authentication state

3. **Notification tap not working**
   - Verify navigation routes are defined
   - Check notification data structure

### Debug Mode
Enable debug logging:
```dart
// In NotificationService
print('FCM Token: $token');
print('Received notification: ${notification.title}');
```

## Contributing
When adding new features:
1. Update the notification model
2. Add appropriate UI components
3. Update documentation
4. Add tests for new functionality
