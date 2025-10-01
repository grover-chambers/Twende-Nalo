import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as order_model;
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  List<order_model.Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<order_model.Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders(String customerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _orderService.getOrdersByCustomer(customerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrderById(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final order = await _orderService.getOrderById(orderId);
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = order;
      } else {
        _orders.add(order);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _orderService.cancelOrder(orderId, reason);
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: order_model.OrderStatus.cancelled,
          cancellationReason: reason,
          updatedAt: DateTime.now(),
        );
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> rateOrder(String orderId, double rating, String? review) async {
    try {
      await _orderService.rateOrder(orderId, rating, review);
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          rating: rating,
          review: review,
          updatedAt: DateTime.now(),
        );
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> trackOrder(String orderId) async {
    try {
      final order = await _orderService.getOrderById(orderId);
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = order;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<order_model.Order> getOrdersByStatus(order_model.OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  List<order_model.Order> getActiveOrders() {
    return _orders.where((order) => order.isActive).toList();
  }

  List<order_model.Order> getCompletedOrders() {
    return _orders.where((order) => order.isCompleted).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
