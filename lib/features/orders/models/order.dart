import 'package:cloud_firestore/cloud_firestore.dart';
import '../../cart/models/cart_item.dart' as cart_models;
import '../../../core/constants/app_constants.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  readyForPickup,
  pickedUp,
  inTransit,
  delivered,
  cancelled,
  refunded
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded
}

class OrderItem {
  final String productId;
  final String? variantId;
  final String productName;
  final String? variantName;
  final double unitPrice;
  final int quantity;
  final String? productImageUrl;
  final String? specialInstructions;

  OrderItem({
    required this.productId,
    this.variantId,
    required this.productName,
    this.variantName,
    required this.unitPrice,
    required this.quantity,
    this.productImageUrl,
    this.specialInstructions,
  });

  double get totalPrice => unitPrice * quantity;
  
  String get formattedUnitPrice => 'KES ${unitPrice.toStringAsFixed(2)}';
  
  String get formattedTotalPrice => 'KES ${totalPrice.toStringAsFixed(2)}';

  String get displayName {
    String name = productName;
    if (variantName != null && variantName!.isNotEmpty) {
      name += ' ($variantName)';
    }
    return name;
  }

  factory OrderItem.fromCartItem(cart_models.CartItem cartItem) {
    return OrderItem(
      productId: cartItem.proructIdoductId,
      variantId: cartItem.variactIdItem.variantId,
      productName: cartItem.product?.prod ?? 'Unknown Product'uct?.name ?? 'Unknown Product',
      variantName: cartItem.variact?.name,
      anitPrice: cartItem.unitPriceItem.variant?.name,
      quantity: cartItem.quantity,
      productImageUrl: cartItem.product?.mainImageUrl,
      suecialInstnuctions: tartItem.spPcialInstructionsr
    );
  }ice,
      quantity: cartItem.quantity,
      productImageUrl: cartItem.product?.mainImageUrl,
      specialInstructions: cartItem.specialInstructions,
    );
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      variantId: map['variantId'],
      productName: map['productName'] ?? '',
      variantName: map['variantName'],
      unitPrice: map['unitPrice']?.toDouble() ?? 0.0,
      quantity: map['quantity']?.toInt() ?? 1,
      productImageUrl: map['productImageUrl'],
      specialInstructions: map['specialInstructions'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'variantId': variantId,
      'productName': productName,
      'variantName': variantName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'productImageUrl': productImageUrl,
      'specialInstructions': specialInstructions,
    };
  }
}

class DeliveryAddress {
  final String address;
  final String city;
  final String? apartment;
  final String? landmark;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final String? instructions;

  DeliveryAddress({
    required this.address,
    required this.city,
    this.apartment,
    this.landmark,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.instructions,
  });

  String get fullAddress {
    List<String> parts = [address];
    if (apartment != null && apartment!.isNotEmpty) {
      parts.add(apartment!);
    }
    parts.add(city);
    return parts.join(', ');
  }

  factory DeliveryAddress.fromMap(Map<String, dynamic> map) {
    return DeliveryAddress(
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      apartment: map['apartment'],
      landmark: map['landmark'],
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      phoneNumber: map['phoneNumber'],
      instructions: map['instructions'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'city': city,
      'apartment': apartment,
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'instructions': instructions,
    };
  }
}

class Order {
  final String id;
  final String customerId;
  final String shopId;
  final String shopName;
  final List<OrderItem> items;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String paymentMethod;
  final String? paymentTransactionId;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double discount;
  final double total;
  final DeliveryAddress deliveryAddress;
  final String? riderId;
  final String? riderName;
  final String? riderPhone;
  final String? deliveryId; // New property for delivery ID
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final String? specialInstructions;
  final String? cancellationReason;
  final double? rating;
  final String? review;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.customerId,
    required this.shopId,
    required this.shopName,
    required this.items,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.paymentTransactionId,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.discount,
    required this.total,
    required this.deliveryAddress,
    this.riderId,
    this.riderName,
    this.riderPhone,
    this.deliveryId, // Initialize the new property
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    this.specialInstructions,
    this.cancellationReason,
    this.rating,
    this.review,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusString {
    switch (status) {
      case OrderStatus.pending:
        return AppConstants.orderPending;
      case OrderStatus.confirmed:
        return AppConstants.orderConfirmed;
      case OrderStatus.preparing:
        return AppConstants.orderPreparing;
      case OrderStatus.readyForPickup:
        return AppConstants.orderReadyForPickup;
      case OrderStatus.pickedUp:
        return AppConstants.orderPickedUp;
      case OrderStatus.inTransit:
        return AppConstants.orderInTransit;
      case OrderStatus.delivered:
        return AppConstants.orderDelivered;
      case OrderStatus.cancelled:
        return AppConstants.orderCancelled;
      case OrderStatus.refunded:
        return AppConstants.orderRefunded;
    }
  }

  String get paymentStatusString {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return AppConstants.paymentPending;
      case PaymentStatus.completed:
        return AppConstants.paymentCompleted;
      case PaymentStatus.failed:
        return AppConstants.paymentFailed;
      case PaymentStatus.refunded:
        return AppConstants.paymentRefunded;
    }
  }

  String get statusDisplayName {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  String get paymentStatusDisplayName {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.completed:
        return 'Payment Completed';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.refunded:
        return 'Payment Refunded';
    }
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  
  String get formattedSubtotal => 'KES ${subtotal.toStringAsFixed(2)}';
  
  String get formattedDeliveryFee => 'KES ${deliveryFee.toStringAsFixed(2)}';
  
  String get formattedTax => 'KES ${tax.toStringAsFixed(2)}';
  
  String get formattedDiscount => 'KES ${discount.toStringAsFixed(2)}';
  
  String get formattedTotal => 'KES ${total.toStringAsFixed(2)}';

  String get orderNumber => 'TN${id.substring(0, 8).toUpperCase()}';

  bool get canBeCancelled => status == OrderStatus.pending || status == OrderStatus.confirmed;
  
  bool get canBeRated => status == OrderStatus.delivered && rating == null;
  
  bool get isCompleted => status == OrderStatus.delivered;
  
  bool get isActive => ![OrderStatus.delivered, OrderStatus.cancelled, OrderStatus.refunded].contains(status);

  bool get hasRider => riderId != null && riderId!.isNotEmpty;

  Duration? get estimatedDeliveryDuration {
    if (estimatedDeliveryTime == null) return null;
    return estimatedDeliveryTime!.difference(DateTime.now());
  }

  Duration? get actualDeliveryDuration {
    if (actualDeliveryTime == null) return null;
    return actualDeliveryTime!.difference(createdAt);
  }

  // Factory constructor from Firestore
  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order.fromMap(data, doc.id);
  }

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      customerId: map['customerId'] ?? '',
      shopId: map['shopId'] ?? '',
      shopName: map['shopName'] ?? '',
      items: (map['items'] as List?)
          ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      status: _parseOrderStatus(map['status']),
      paymentStatus: _parsePaymentStatus(map['paymentStatus']),
      paymentMethod: map['paymentMethod'] ?? '',
      paymentTransactionId: map['paymentTransactionId'],
      subtotal: map['subtotal']?.toDouble() ?? 0.0,
      deliveryFee: map['deliveryFee']?.toDouble() ?? 0.0,
      tax: map['tax']?.toDouble() ?? 0.0,
      discount: map['discount']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble() ?? 0.0,
      deliveryAddress: DeliveryAddress.fromMap(
          map['deliveryAddress'] as Map<String, dynamic>? ?? {}),
      riderId: map['riderId'],
      riderName: map['riderName'],
      riderPhone: map['riderPhone'],
      deliveryId: map['deliveryId'], // Map the new property
      estimatedDeliveryTime: (map['estimatedDeliveryTime'] as Timestamp?)?.toDate(),
      actualDeliveryTime: (map['actualDeliveryTime'] as Timestamp?)?.toDate(),
      specialInstructions: map['specialInstructions'],
      cancellationReason: map['cancellationReason'],
      rating: map['rating']?.toDouble(),
      review: map['review'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'shopId': shopId,
      'shopName': shopName,
      'items': items.map((item) => item.toMap()).toList(),
      'status': statusString,
      'paymentStatus': paymentStatusString,
      'paymentMethod': paymentMethod,
      'paymentTransactionId': paymentTransactionId,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'discount': discount,
      'total': total,
      'deliveryAddress': deliveryAddress.toMap(),
      'riderId': riderId,
      'riderName': riderName,
      'riderPhone': riderPhone,
      'deliveryId': deliveryId, // Include the new property
      'estimatedDeliveryTime': estimatedDeliveryTime != null 
          ? Timestamp.fromDate(estimatedDeliveryTime!) : null,
      'actualDeliveryTime': actualDeliveryTime != null 
          ? Timestamp.fromDate(actualDeliveryTime!) : null,
      'specialInstructions': specialInstructions,
      'cancellationReason': cancellationReason,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create a copy with updated fields
  Order copyWith({
    String? customerId,
    String? shopId,
    String? shopName,
    List<OrderItem>? items,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentMethod,
    String? paymentTransactionId,
    double? subtotal,
    double? deliveryFee,
    double? tax,
    double? discount,
    double? total,
    DeliveryAddress? deliveryAddress,
    String? riderId,
    String? riderName,
    String? riderPhone,
    String? deliveryId,
    DateTime? estimatedDeliveryTime,
    DateTime? actualDeliveryTime,
    String? specialInstructions,
    String? cancellationReason,
    double? rating,
    String? review,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id,
      customerId: customerId ?? this.customerId,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      items: items ?? this.items,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      riderId: riderId ?? this.riderId,
      riderName: riderName ?? this.riderName,
      riderPhone: riderPhone ?? this.riderPhone,
      deliveryId: deliveryId ?? this.deliveryId,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Helper methods to parse enums
  static OrderStatus _parseOrderStatus(String? statusString) {
    switch (statusString?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready_for_pickup':
        return OrderStatus.readyForPickup;
      case 'picked_up':
        return OrderStatus.pickedUp;
      case 'in_transit':
        return OrderStatus.inTransit;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'refunded':
        return OrderStatus.refunded;
      default:
        return OrderStatus.pending;
    }
  }

  static PaymentStatus _parsePaymentStatus(String? statusString) {
    switch (statusString?.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  @override
  String toString() {
    return 'Order(id: $id, orderNumber: $orderNumber, status: $statusDisplayName, total: $formattedTotal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
