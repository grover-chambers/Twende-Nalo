import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/payment_method.dart';
import '../../../core/utils/logger.dart';

class CheckoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _ordersCollection => _firestore.collection('orders');
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _promoCodesCollection => _firestore.collection('promo_codes');

  /// Create a new order
  Future<String?> createOrder({
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    required PaymentType paymentType,
    required double subtotal,
    required double deliveryFee,
    required double discountAmount,
    required double totalAmount,
    String? phoneNumber,
    String? promoCode,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Validate items
      if (items.isEmpty) {
        throw Exception('Order must contain at least one item');
      }

      // Create order document
      final orderData = {
        'userId': user.uid,
        'items': items,
        'deliveryAddress': deliveryAddress,
        'paymentType': paymentType.name,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'discountAmount': discountAmount,
        'totalAmount': totalAmount,
        'phoneNumber': phoneNumber,
        'promoCode': promoCode,
        'paymentDetails': paymentDetails,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add order to Firestore
      final docRef = await _ordersCollection.add(orderData);
      
      // Update user's order history
      await _usersCollection.doc(user.uid).update({
        'orderHistory': FieldValue.arrayUnion([docRef.id]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      AppLogger.e('Error creating order: $e');
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  /// Get order details
  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }
      return null;
    } catch (e) {
      AppLogger.e('Error getting order: $e');
      throw Exception('Failed to get order: ${e.toString()}');
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.e('Error updating order status: $e');
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.e('Error cancelling order: $e');
      throw Exception('Failed to cancel order: ${e.toString()}');
    }
  }

  /// Validate promo code
  Future<Map<String, dynamic>?> validatePromoCode(String code) async {
    try {
      final query = await _promoCodesCollection
          .where('code', isEqualTo: code.toUpperCase())
          .where('isActive', isEqualTo: true)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      final promoDoc = query.docs.first;
      final promoData = promoDoc.data() as Map<String, dynamic>;

      // Check expiration
      if (promoData['expiresAt'] != null) {
        final expiresAt = (promoData['expiresAt'] as Timestamp).toDate();
        if (DateTime.now().isAfter(expiresAt)) {
          return null;
        }
      }

      // Check usage limit
      if (promoData['usageLimit'] != null) {
        final usageCount = promoData['usageCount'] ?? 0;
        if (usageCount >= promoData['usageLimit']) {
          return null;
        }
      }

      return {
        'id': promoDoc.id,
        'valid': true,
        'discountType': promoData['discountType'],
        'discountValue': promoData['discountValue'],
        'minOrderAmount': promoData['minOrderAmount'] ?? 0,
      };
    } catch (e) {
      AppLogger.e('Error validating promo code: $e');
      return null;
    }
  }

  /// Apply promo code usage
  Future<void> applyPromoCodeUsage(String promoCodeId) async {
    try {
      await _promoCodesCollection.doc(promoCodeId).update({
        'usageCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.e('Error applying promo code usage: $e');
    }
  }

  /// Get user's orders
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final query = await _ordersCollection
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      AppLogger.e('Error getting user orders: $e');
      throw Exception('Failed to get orders: ${e.toString()}');
    }
  }

  /// Calculate delivery fee based on address
  Future<double> calculateDeliveryFee(String address) async {
    try {
      // Simple delivery fee calculation based on address
      // In a real app, this would use geolocation and distance calculation
      final baseFee = 5.0;
      final addressLower = address.toLowerCase();
      
      // Add fee for distant locations (example logic)
      if (addressLower.contains('cbd') || addressLower.contains('central')) {
        return baseFee;
      } else if (addressLower.contains('outskirts') || addressLower.contains('far')) {
        return baseFee + 3.0;
      }
      
      return baseFee;
    } catch (e) {
      AppLogger.e('Error calculating delivery fee: $e');
      return 5.0; // Default fee
    }
  }

  /// Process M-Pesa payment
  Future<Map<String, dynamic>> processMpesaPayment({
    required String orderId,
    required double amount,
    required String phoneNumber,
  }) async {
    try {
      // This would integrate with your M-Pesa service
      // For now, we'll simulate a successful payment
      final transactionId = 'MP${DateTime.now().millisecondsSinceEpoch}';
      
      // Update order with payment details
      await _ordersCollection.doc(orderId).update({
        'paymentDetails': {
          'transactionId': transactionId,
          'amount': amount,
          'phoneNumber': phoneNumber,
          'paymentMethod': 'mpesa',
          'status': 'completed',
          'timestamp': FieldValue.serverTimestamp(),
        },
        'status': 'confirmed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'transactionId': transactionId,
        'message': 'Payment processed successfully',
      };
    } catch (e) {
      AppLogger.e('Error processing M-Pesa payment: $e');
      return {
        'success': false,
        'message': 'Payment failed: ${e.toString()}',
      };
    }
  }

  /// Process card payment
  Future<Map<String, dynamic>> processCardPayment({
    required String orderId,
    required double amount,
    required Map<String, dynamic> cardDetails,
  }) async {
    try {
      // This would integrate with your payment gateway
      // For now, we'll simulate a successful payment
      final transactionId = 'CD${DateTime.now().millisecondsSinceEpoch}';
      
      // Update order with payment details
      await _ordersCollection.doc(orderId).update({
        'paymentDetails': {
          'transactionId': transactionId,
          'amount': amount,
          'last4': cardDetails['last4'],
          'paymentMethod': 'card',
          'status': 'completed',
          'timestamp': FieldValue.serverTimestamp(),
        },
        'status': 'confirmed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'transactionId': transactionId,
        'message': 'Payment processed successfully',
      };
    } catch (e) {
      AppLogger.e('Error processing card payment: $e');
      return {
        'success': false,
        'message': 'Payment failed: ${e.toString()}',
      };
    }
  }

  /// Get order tracking details
  Future<Map<String, dynamic>?> getOrderTracking(String orderId) async {
    try {
      final order = await getOrder(orderId);
      if (order == null) return null;

      return {
        'orderId': orderId,
        'status': order['status'],
        'estimatedDelivery': _calculateEstimatedDelivery(order['createdAt']),
        'trackingUpdates': await _getTrackingUpdates(orderId),
      };
    } catch (e) {
      AppLogger.e('Error getting order tracking: $e');
      return null;
    }
  }

  /// Calculate estimated delivery time
  DateTime _calculateEstimatedDelivery(Timestamp createdAt) {
    final createdDate = createdAt.toDate();
    return createdDate.add(const Duration(hours: 2)); // 2-hour delivery
  }

  /// Get tracking updates for an order
  Future<List<Map<String, dynamic>>> _getTrackingUpdates(String orderId) async {
    try {
      final query = await _ordersCollection
          .doc(orderId)
          .collection('tracking')
          .orderBy('timestamp', descending: true)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      AppLogger.e('Error getting tracking updates: $e');
      return [];
    }
  }

  /// Add tracking update
  Future<void> addTrackingUpdate(String orderId, String status, String message) async {
    try {
      await _ordersCollection
          .doc(orderId)
          .collection('tracking')
          .add({
        'status': status,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.e('Error adding tracking update: $e');
    }
  }

  /// Check if user has active orders
  Future<bool> hasActiveOrders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final query = await _ordersCollection
          .where('userId', isEqualTo: user.uid)
          .where('status', whereIn: ['pending', 'confirmed', 'processing', 'out_for_delivery'])
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      AppLogger.e('Error checking active orders: $e');
      return false;
    }
  }

  /// Get order statistics
  Future<Map<String, int>> getOrderStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'total': 0,
          'pending': 0,
          'completed': 0,
          'cancelled': 0,
        };
      }

      final query = await _ordersCollection
          .where('userId', isEqualTo: user.uid)
          .get();

      final orders = query.docs;
      return {
        'total': orders.length,
        'pending': orders.where((o) => o['status'] == 'pending').length,
        'completed': orders.where((o) => o['status'] == 'completed').length,
        'cancelled': orders.where((o) => o['status'] == 'cancelled').length,
      };
    } catch (e) {
      AppLogger.e('Error getting order stats: $e');
      return {
        'total': 0,
        'pending': 0,
        'completed': 0,
        'cancelled': 0,
      };
    }
  }
}
