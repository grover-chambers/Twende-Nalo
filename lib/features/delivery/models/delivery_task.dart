import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryTask {
  final String id;
  final String orderId;
  final String customerId;
  final String riderId;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final GeoPoint pickupLocation;
  final GeoPoint deliveryLocation;
  final List<DeliveryItem> items;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final String? notes;
  final String? rejectionReason;
  final double? estimatedDistance;
  final double? estimatedDuration;
  final double? riderEarnings;

  DeliveryTask({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.riderId,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.notes,
    this.rejectionReason,
    this.estimatedDistance,
    this.estimatedDuration,
    this.riderEarnings,
  });

  factory DeliveryTask.fromJson(Map<String, dynamic> json) {
    return DeliveryTask(
      id: json['id'],
      orderId: json['orderId'],
      customerId: json['customerId'],
      riderId: json['riderId'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      deliveryAddress: json['deliveryAddress'],
      pickupLocation: json['pickupLocation'],
      deliveryLocation: json['deliveryLocation'],
      items: List<DeliveryItem>.from(
        json['items'].map((item) => DeliveryItem.fromJson(item)),
      ),
      totalAmount: json['totalAmount'].toDouble(),
      status: json['status'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      acceptedAt: json['acceptedAt'] != null 
          ? (json['acceptedAt'] as Timestamp).toDate() 
          : null,
      pickedUpAt: json['pickedUpAt'] != null 
          ? (json['pickedUpAt'] as Timestamp).toDate() 
          : null,
      deliveredAt: json['deliveredAt'] != null 
          ? (json['deliveredAt'] as Timestamp).toDate() 
          : null,
      notes: json['notes'],
      rejectionReason: json['rejectionReason'],
      estimatedDistance: json['estimatedDistance']?.toDouble(),
      estimatedDuration: json['estimatedDuration']?.toDouble(),
      riderEarnings: json['riderEarnings']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'customerId': customerId,
      'riderId': riderId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'deliveryAddress': deliveryAddress,
      'pickupLocation': pickupLocation,
      'deliveryLocation': deliveryLocation,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'pickedUpAt': pickedUpAt != null ? Timestamp.fromDate(pickedUpAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'notes': notes,
      'rejectionReason': rejectionReason,
      'estimatedDistance': estimatedDistance,
      'estimatedDuration': estimatedDuration,
      'riderEarnings': riderEarnings,
    };
  }

  DeliveryTask copyWith({
    String? id,
    String? orderId,
    String? customerId,
    String? riderId,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    GeoPoint? pickupLocation,
    GeoPoint? deliveryLocation,
    List<DeliveryItem>? items,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    String? notes,
    String? rejectionReason,
    double? estimatedDistance,
    double? estimatedDuration,
    double? riderEarnings,
  }) {
    return DeliveryTask(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      riderId: riderId ?? this.riderId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      notes: notes ?? this.notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      riderEarnings: riderEarnings ?? this.riderEarnings,
    );
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isPickedUp => status == 'pickedUp';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isAvailable => status == 'pending';
  bool get canAccept => status == 'pending';
  bool get canCancel => status != 'delivered' && status != 'cancelled';
  bool get canComplete => status == 'pickedUp';

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'pickedUp':
        return 'On the way';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get estimatedDeliveryTime {
    if (estimatedDuration == null) return 'Calculating...';
    final duration = Duration(minutes: estimatedDuration!.toInt());
    return '${duration.inMinutes} min';
  }

  String get formattedDistance {
    if (estimatedDistance == null) return 'Calculating...';
    return '${estimatedDistance!.toStringAsFixed(1)} km';
  }
}

class DeliveryItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;
  final String? notes;

  DeliveryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.notes,
  });

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
      'notes': notes,
    };
  }

  double get totalPrice => price * quantity;
}
