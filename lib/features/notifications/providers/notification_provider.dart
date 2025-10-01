import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationItem> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  StreamSubscription? _notificationsSubscription;
  StreamSubscription? _unreadCountSubscription;

  NotificationProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _notificationService.initialize();
    _listenToNotifications();
    _listenToUnreadCount();
  }

  void _listenToNotifications() {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = _notificationService
        .getNotifications(limit: 50)
        .listen(
          (notifications) {
            _notifications = notifications;
            _error = null;
            notifyListeners();
          },
          onError: (error) {
            _error = error.toString();
            notifyListeners();
          },
        );
  }

  void _listenToUnreadCount() {
    _unreadCountSubscription?.cancel();
    _unreadCountSubscription = _notificationService
        .getUnreadCount()
        .listen(
          (count) {
            _unreadCount = count;
            notifyListeners();
          },
          onError: (error) {
            _error = error.toString();
            notifyListeners();
          },
        );
  }

  Future<void> refreshNotifications() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _listenToNotifications();
      _listenToUnreadCount();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      await _notificationService.clearAllNotifications();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
      
      await _notificationService.deleteNotification(notificationId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<NotificationItem> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  List<NotificationItem> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    super.dispose();
  }
}
