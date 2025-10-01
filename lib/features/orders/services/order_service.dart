import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as order_model;
import '../../notifications/services/notification_service.dart';
import '../../notifications/models/notification_item.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';
  final NotificationService _notificationService = NotificationService();

  Future<List<order_model.Order>> getOrdersByCustomer(String customerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => order_model.Order.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: ${e.toString()}');
    }
  }

  Future<order_model.Order> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      if (!doc.exists) {
        throw Exception('Order not found');
      }
      return order_model.Order.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch order: ${e.toString()}');
    }
  }

  Future<void> createOrder(order_model.Order order) async {
    try {
      await _firestore.collection(_collection).doc(order.id).set(order.toMap());
      
      // Send notification to shop owner
      await _notificationService.createSystemNotification(
        title: 'New Order Received',
        body: 'You have a new order #${order.orderNumber}',
        type: NotificationType.orderUpdate,
        data: {'orderId': order.id, 'shopId': order.shopId},
      );
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  Future<void> updateOrder(order_model.Order order) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(order.id)
          .update(order.toMap());
    } catch (e) {
      throw Exception('Failed to update order: ${e.toString()}');
    }
  }

  Future<void> updateOrderStatus(String orderId, order_model.OrderStatus status, 
      {String? riderId, String? riderName, DateTime? estimatedDeliveryTime}) async {
    try {
      final updateData = {
        'status': status.toString().split('.').last,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (riderId != null) updateData['riderId'] = riderId;
      if (riderName != null) updateData['riderName'] = riderName;
      if (estimatedDeliveryTime != null) {
        updateData['estimatedDeliveryTime'] = Timestamp.fromDate(estimatedDeliveryTime);
      }

      await _firestore.collection(_collection).doc(orderId).update(updateData);

      // Get the updated order to send notifications
      final order = await getOrderById(orderId);
      await _sendStatusChangeNotification(order, status);
    } catch (e) {
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Send cancellation notification
      final order = await getOrderById(orderId);
      await _notificationService.createSystemNotification(
        title: 'Order Cancelled',
        body: 'Your order #${order.orderNumber} has been cancelled. Reason: $reason',
        type: NotificationType.orderUpdate,
        data: {'orderId': orderId, 'customerId': order.customerId},
      );
    } catch (e) {
      throw Exception('Failed to cancel order: ${e.toString()}');
    }
  }

  Future<void> rateOrder(String orderId, double rating, String? review) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'rating': rating,
        'review': review,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to rate order: ${e.toString()}');
    }
  }

  Future<List<order_model.Order>> getOrdersByShop(String shopId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('shopId', isEqualTo: shopId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => order_model.Order.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch shop orders: ${e.toString()}');
    }
  }

  Future<List<order_model.Order>> getOrdersByRider(String riderId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('riderId', isEqualTo: riderId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => order_model.Order.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch rider orders: ${e.toString()}');
    }
  }

  Stream<List<order_model.Order>> streamOrdersByCustomer(String customerId) {
    return _firestore
        .collection(_collection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => order_model.Order.fromFirestore(doc)).toList());
  }

  Stream<List<order_model.Order>> streamOrdersByShop(String shopId) {
    return _firestore
        .collection(_collection)
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => order_model.Order.fromFirestore(doc)).toList());
  }

  Stream<order_model.Order> streamOrderById(String orderId) {
    return _firestore
        .collection(_collection)
        .doc(orderId)
        .snapshots()
        .map((snapshot) => order_model.Order.fromFirestore(snapshot));
  }

  // Helper method to send notifications for status changes
  Future<void> _sendStatusChangeNotification(order_model.Order order, order_model.OrderStatus newStatus) async {
    String title;
    String body;

    switch (newStatus) {
      case order_model.OrderStatus.confirmed:
        title = 'Order Confirmed';
        body = 'Your order #${order.orderNumber} has been confirmed by the shop';
        break;
      case order_model.OrderStatus.preparing:
        title = 'Order Being Prepared';
        body = 'Your order #${order.orderNumber} is being prepared';
        break;
      case order_model.OrderStatus.readyForPickup:
        title = 'Order Ready for Pickup';
        body = 'Your order #${order.orderNumber} is ready for pickup';
        break;
      case order_model.OrderStatus.pickedUp:
        title = 'Order Picked Up';
        body = 'Your order #${order.orderNumber} has been picked up by the rider';
        break;
      case order_model.OrderStatus.inTransit:
        title = 'Order In Transit';
        body = 'Your order #${order.orderNumber} is on its way to you';
        break;
      case order_model.OrderStatus.delivered:
        title = 'Order Delivered';
        body = 'Your order #${order.orderNumber} has been delivered successfully';
        break;
      default:
        return; // No notification for other statuses
    }

    await _notificationService.createSystemNotification(
      title: title,
      body: body,
      type: NotificationType.orderUpdate,
      data: {'orderId': order.id, 'customerId': order.customerId},
    );
  }
}
